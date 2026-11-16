from django.db import transaction

from rest_framework import serializers

from core.models import (
    Contracts,
    Events,
    EventSites,
    Manufacturers,
    ManufacturingContracts,
    Products,
    Sites,
)


class EntityReferenceSerializer(
    serializers.Serializer
):
    external_id = serializers.CharField()
    name = serializers.CharField()


class ManufacturingContractResponseSerializer(
    serializers.Serializer
):

    external_id = serializers.CharField()

    contract_type = serializers.CharField()
    status = serializers.CharField()

    event = EntityReferenceSerializer()
    site = EntityReferenceSerializer()

    manufacturer = EntityReferenceSerializer()
    product = EntityReferenceSerializer()

    release_date = serializers.DateField()

    start_date = serializers.DateField(
        allow_null=True,
    )

    end_date = serializers.DateField(
        allow_null=True,
    )

    contract_terms = serializers.CharField()

    created_at = serializers.DateTimeField()
    updated_at = serializers.DateTimeField()


class ManufacturingContractWriteSerializer(
    serializers.Serializer
):

    event_external_id = serializers.CharField(
        min_length=15,
        max_length=15,
    )

    site_external_id = serializers.CharField(
        min_length=15,
        max_length=15,
    )

    manufacturer_external_id = (
        serializers.CharField(
            min_length=15,
            max_length=15,
        )
    )

    product_external_id = serializers.CharField(
        min_length=15,
        max_length=15,
    )

    release_date = serializers.DateField()

    start_date = serializers.DateField(
        required=False,
        allow_null=True,
    )

    end_date = serializers.DateField(
        required=False,
        allow_null=True,
    )

    contract_terms = serializers.CharField(
        allow_blank=False,
    )

    status = serializers.ChoiceField(
        choices=(
            Contracts.Status.DRAFT,
            Contracts.Status.PENDING,
        ),
        default=Contracts.Status.DRAFT,
    )

    def validate(self, attrs):

        start_date = attrs.get("start_date")
        end_date = attrs.get("end_date")

        if (
            start_date is not None
            and end_date is not None
            and end_date < start_date
        ):
            raise serializers.ValidationError({
                "end_date": (
                    "end_date must be greater than or "
                    "equal to start_date."
                )
            })

        event = self._get_event(
            attrs["event_external_id"]
        )

        site = self._get_site(
            attrs["site_external_id"]
        )

        manufacturer = self._get_manufacturer(
            attrs["manufacturer_external_id"]
        )

        product = self._get_product(
            attrs["product_external_id"]
        )

        if not EventSites.objects.filter(
            event=event,
            site=site,
        ).exists():

            raise serializers.ValidationError({
                "site_external_id": (
                    "The selected site does not belong "
                    "to the selected event."
                )
            })

        if (
            product.manufacturer.manufacturer_id
            != manufacturer.manufacturer_id
        ):
            raise serializers.ValidationError({
                "product_external_id": (
                    "The selected product does not belong "
                    "to the selected manufacturer."
                )
            })

        attrs["_event"] = event
        attrs["_site"] = site
        attrs["_manufacturer"] = manufacturer
        attrs["_product"] = product

        return attrs

    def _get_event(self, external_id):

        try:
            return Events.objects.get(
                external_id=external_id
            )
        except Events.DoesNotExist:
            raise serializers.ValidationError({
                "event_external_id": (
                    "Event does not exist."
                )
            })

    def _get_site(self, external_id):

        try:
            return Sites.objects.get(
                external_id=external_id,
                status=Sites.Status.ACTIVE,
            )
        except Sites.DoesNotExist:
            raise serializers.ValidationError({
                "site_external_id": (
                    "Active site does not exist."
                )
            })

    def _get_manufacturer(
        self,
        external_id,
    ):

        try:
            return Manufacturers.objects.get(
                external_id=external_id
            )
        except Manufacturers.DoesNotExist:
            raise serializers.ValidationError({
                "manufacturer_external_id": (
                    "Manufacturer does not exist."
                )
            })

    def _get_product(
        self,
        external_id,
    ):

        try:
            return Products.objects.get(
                external_id=external_id
            )
        except Products.DoesNotExist:
            raise serializers.ValidationError({
                "product_external_id": (
                    "Product does not exist."
                )
            })

    @transaction.atomic
    def create(self, validated_data):

        event = validated_data.pop("_event")
        site = validated_data.pop("_site")

        manufacturer = validated_data.pop(
            "_manufacturer"
        )

        product = validated_data.pop(
            "_product"
        )

        validated_data.pop(
            "event_external_id"
        )

        validated_data.pop(
            "site_external_id"
        )

        validated_data.pop(
            "manufacturer_external_id"
        )

        validated_data.pop(
            "product_external_id"
        )

        release_date = validated_data.pop(
            "release_date"
        )

        status = validated_data.pop(
            "status",
            Contracts.Status.DRAFT,
        )

        contract = Contracts.objects.create(
            contract_type=(
                Contracts.ContractType.MANUFACTURING
            ),
            status=status,
            event=event,
            site=site,
            start_date=validated_data.get(
                "start_date"
            ),
            end_date=validated_data.get(
                "end_date"
            ),
            contract_terms=validated_data[
                "contract_terms"
            ],
        )

        contract.refresh_from_db()

        manufacturing = (
            ManufacturingContracts.objects.create(
                contract=contract,
                manufacturer=manufacturer,
                product=product,
                release_date=release_date,
            )
        )

        return manufacturing

    @transaction.atomic
    def update(
        self,
        instance,
        validated_data,
    ):

        contract = instance.contract

        if contract.status not in (
            Contracts.Status.DRAFT,
            Contracts.Status.PENDING,
        ):
            raise serializers.ValidationError({
                "status": (
                    "Only DRAFT or PENDING contracts "
                    "can be modified through the "
                    "public API."
                )
            })

        event = validated_data.pop("_event")
        site = validated_data.pop("_site")

        manufacturer = validated_data.pop(
            "_manufacturer"
        )

        product = validated_data.pop(
            "_product"
        )

        validated_data.pop(
            "event_external_id"
        )

        validated_data.pop(
            "site_external_id"
        )

        validated_data.pop(
            "manufacturer_external_id"
        )

        validated_data.pop(
            "product_external_id"
        )

        contract.event = event
        contract.site = site

        contract.start_date = (
            validated_data.get("start_date")
        )

        contract.end_date = (
            validated_data.get("end_date")
        )

        contract.contract_terms = (
            validated_data["contract_terms"]
        )

        contract.status = validated_data.get(
            "status",
            contract.status,
        )

        contract.save(
            update_fields=(
                "event",
                "site",
                "start_date",
                "end_date",
                "contract_terms",
                "status",
            )
        )

        instance.manufacturer = manufacturer
        instance.product = product

        instance.release_date = (
            validated_data["release_date"]
        )

        instance.save(
            update_fields=(
                "manufacturer",
                "product",
                "release_date",
            )
        )

        contract.refresh_from_db()

        return instance


def build_manufacturing_response(instance):

    contract = instance.contract

    data = {
        "external_id": contract.external_id,

        "contract_type": (
            contract.contract_type
        ),

        "status": contract.status,

        "event": {
            "external_id": (
                contract.event.external_id
            ),
            "name": contract.event.name,
        },

        "site": {
            "external_id": (
                contract.site.external_id
            ),
            "name": contract.site.name,
        },

        "manufacturer": {
            "external_id": (
                instance.manufacturer.external_id
            ),
            "name": (
                instance.manufacturer.party.name
            ),
        },

        "product": {
            "external_id": (
                instance.product.external_id
            ),
            "name": (
                instance.product.product_name
            ),
        },

        "release_date": instance.release_date,

        "start_date": contract.start_date,
        "end_date": contract.end_date,

        "contract_terms": (
            contract.contract_terms
        ),

        "created_at": contract.created_at,
        "updated_at": contract.updated_at,
    }

    serializer = (
        ManufacturingContractResponseSerializer(
            data
        )
    )

    return serializer.data
