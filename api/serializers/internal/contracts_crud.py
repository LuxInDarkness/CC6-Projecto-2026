from django.db import transaction

from rest_framework import serializers

from core.models import (
    Albums,
    Artists,
    Contracts,
    DiscographyContracts,
    EventSites,
    Events,
    Manufacturers,
    ManufacturingContracts,
    Products,
    RecordLabels,
    Sites,
)


class InternalContractCrudSerializer(
    serializers.Serializer
):

    external_id = serializers.CharField(
        read_only=True,
    )

    contract_type = serializers.ChoiceField(
        choices=Contracts.ContractType.choices,
    )

    status = serializers.CharField(
        read_only=True,
    )

    event_external_id = (
        serializers.SlugRelatedField(
            queryset=Events.objects.all(),
            slug_field="external_id",
        )
    )

    site_external_id = (
        serializers.SlugRelatedField(
            queryset=Sites.objects.all(),
            slug_field="external_id",
        )
    )

    start_date = serializers.DateField(
        required=False,
        allow_null=True,
    )

    end_date = serializers.DateField(
        required=False,
        allow_null=True,
    )

    contract_terms = serializers.CharField()

    # ========================================================
    # DISCOGRAPHY
    # ========================================================

    artist_external_id = (
        serializers.SlugRelatedField(
            queryset=Artists.objects.all(),
            slug_field="external_id",
            required=False,
            allow_null=True,
        )
    )

    album_external_id = (
        serializers.SlugRelatedField(
            queryset=Albums.objects.all(),
            slug_field="external_id",
            required=False,
            allow_null=True,
        )
    )

    record_label_external_id = (
        serializers.SlugRelatedField(
            queryset=RecordLabels.objects.all(),
            slug_field="external_id",
            required=False,
            allow_null=True,
        )
    )

    # ========================================================
    # MANUFACTURING
    # ========================================================

    manufacturer_external_id = (
        serializers.SlugRelatedField(
            queryset=Manufacturers.objects.all(),
            slug_field="external_id",
            required=False,
            allow_null=True,
        )
    )

    product_external_id = (
        serializers.SlugRelatedField(
            queryset=Products.objects.all(),
            slug_field="external_id",
            required=False,
            allow_null=True,
        )
    )

    # Used by either contract subtype.
    release_date = serializers.DateField(
        required=False,
        allow_null=True,
    )

    created_at = serializers.DateTimeField(
        read_only=True,
    )

    updated_at = serializers.DateTimeField(
        read_only=True,
    )

    # ========================================================
    # VALIDATION
    # ========================================================

    def validate(
        self,
        attrs,
    ):

        instance = self.instance

        contract_type = attrs.get(
            "contract_type",
            (
                instance.contract_type
                if instance is not None
                else None
            ),
        )

        if contract_type not in (
            Contracts.ContractType.DISCOGRAPHY,
            Contracts.ContractType.MANUFACTURING,
        ):

            raise serializers.ValidationError({
                "contract_type": (
                    "Internal CRUD currently supports "
                    "DISCOGRAPHY and MANUFACTURING "
                    "contracts."
                )
            })

        if (
            instance is not None
            and "contract_type" in attrs
            and attrs["contract_type"]
            != instance.contract_type
        ):

            raise serializers.ValidationError({
                "contract_type": (
                    "contract_type cannot be changed "
                    "after creation."
                )
            })

        event = attrs.get(
            "event_external_id",
            (
                instance.event
                if instance is not None
                else None
            ),
        )

        site = attrs.get(
            "site_external_id",
            (
                instance.site
                if instance is not None
                else None
            ),
        )

        if (
            event is not None
            and site is not None
            and not EventSites.objects.filter(
                event=event,
                site=site,
            ).exists()
        ):

            raise serializers.ValidationError({
                "site_external_id": (
                    "The selected site is not "
                    "assigned to the selected event."
                )
            })

        start_date = attrs.get(
            "start_date",
            (
                instance.start_date
                if instance is not None
                else None
            ),
        )

        end_date = attrs.get(
            "end_date",
            (
                instance.end_date
                if instance is not None
                else None
            ),
        )

        if (
            start_date is not None
            and end_date is not None
            and end_date < start_date
        ):

            raise serializers.ValidationError({
                "end_date": (
                    "end_date must be greater than "
                    "or equal to start_date."
                )
            })

        if (
            contract_type
            == Contracts.ContractType.DISCOGRAPHY
        ):

            self._validate_discography(
                attrs
            )

        elif (
            contract_type
            == Contracts.ContractType.MANUFACTURING
        ):

            self._validate_manufacturing(
                attrs
            )

        return attrs

    def _validate_discography(
        self,
        attrs,
    ):

        current = None

        if self.instance is not None:

            current = (
                DiscographyContracts.objects
                .filter(
                    contract=self.instance
                )
                .first()
            )

        artist = attrs.get(
            "artist_external_id",
            (
                current.artist
                if current is not None
                else None
            ),
        )

        album = attrs.get(
            "album_external_id",
            (
                current.album
                if current is not None
                else None
            ),
        )

        release_date = attrs.get(
            "release_date",
            (
                current.release_date
                if current is not None
                else None
            ),
        )

        if artist is None:

            raise serializers.ValidationError({
                "artist_external_id": (
                    "This field is required for "
                    "discography contracts."
                )
            })

        if album is None:

            raise serializers.ValidationError({
                "album_external_id": (
                    "This field is required for "
                    "discography contracts."
                )
            })

        if album.artist_id != artist.artist_id:

            raise serializers.ValidationError({
                "album_external_id": (
                    "The selected album does not "
                    "belong to the selected artist."
                )
            })

        if release_date is None:

            raise serializers.ValidationError({
                "release_date": (
                    "This field is required."
                )
            })

    def _validate_manufacturing(
        self,
        attrs,
    ):

        current = None

        if self.instance is not None:

            current = (
                ManufacturingContracts.objects
                .filter(
                    contract=self.instance
                )
                .first()
            )

        manufacturer = attrs.get(
            "manufacturer_external_id",
            (
                current.manufacturer
                if current is not None
                else None
            ),
        )

        product = attrs.get(
            "product_external_id",
            (
                current.product
                if current is not None
                else None
            ),
        )

        release_date = attrs.get(
            "release_date",
            (
                current.release_date
                if current is not None
                else None
            ),
        )

        if manufacturer is None:

            raise serializers.ValidationError({
                "manufacturer_external_id": (
                    "This field is required for "
                    "manufacturing contracts."
                )
            })

        if product is None:

            raise serializers.ValidationError({
                "product_external_id": (
                    "This field is required for "
                    "manufacturing contracts."
                )
            })

        if (
            product.manufacturer_id
            != manufacturer.manufacturer_id
        ):

            raise serializers.ValidationError({
                "product_external_id": (
                    "The selected product does not "
                    "belong to the selected "
                    "manufacturer."
                )
            })

        if release_date is None:

            raise serializers.ValidationError({
                "release_date": (
                    "This field is required."
                )
            })

    # ========================================================
    # CREATE
    # ========================================================

    @transaction.atomic
    def create(
        self,
        validated_data,
    ):

        contract_type = validated_data.pop(
            "contract_type"
        )

        event = validated_data.pop(
            "event_external_id"
        )

        site = validated_data.pop(
            "site_external_id"
        )

        release_date = validated_data.pop(
            "release_date"
        )

        artist = validated_data.pop(
            "artist_external_id",
            None,
        )

        album = validated_data.pop(
            "album_external_id",
            None,
        )

        record_label = validated_data.pop(
            "record_label_external_id",
            None,
        )

        manufacturer = validated_data.pop(
            "manufacturer_external_id",
            None,
        )

        product = validated_data.pop(
            "product_external_id",
            None,
        )

        contract = Contracts.objects.create(
            contract_type=contract_type,
            status=Contracts.Status.DRAFT,
            event=event,
            site=site,
            **validated_data,
        )

        contract.refresh_from_db()

        if (
            contract_type
            == Contracts.ContractType.DISCOGRAPHY
        ):

            DiscographyContracts.objects.create(
                contract=contract,
                artist=artist,
                album=album,
                record_label=record_label,
                release_date=release_date,
            )

        else:

            ManufacturingContracts.objects.create(
                contract=contract,
                manufacturer=manufacturer,
                product=product,
                release_date=release_date,
            )

        return contract

    # ========================================================
    # UPDATE
    # ========================================================

    @transaction.atomic
    def update(
        self,
        instance,
        validated_data,
    ):

        validated_data.pop(
            "contract_type",
            None,
        )

        event = validated_data.pop(
            "event_external_id",
            None,
        )

        site = validated_data.pop(
            "site_external_id",
            None,
        )

        release_date_present = (
            "release_date" in validated_data
        )

        release_date = validated_data.pop(
            "release_date",
            None,
        )

        if event is not None:
            instance.event = event

        if site is not None:
            instance.site = site

        for field in (
            "start_date",
            "end_date",
            "contract_terms",
        ):

            if field in validated_data:

                setattr(
                    instance,
                    field,
                    validated_data[field],
                )

        instance.save()

        if (
            instance.contract_type
            == Contracts.ContractType.DISCOGRAPHY
        ):

            subtype = (
                DiscographyContracts.objects
                .select_for_update()
                .get(
                    contract=instance
                )
            )

            if (
                "artist_external_id"
                in validated_data
            ):

                subtype.artist = validated_data[
                    "artist_external_id"
                ]

            if (
                "album_external_id"
                in validated_data
            ):

                subtype.album = validated_data[
                    "album_external_id"
                ]

            if (
                "record_label_external_id"
                in validated_data
            ):

                subtype.record_label = (
                    validated_data[
                        "record_label_external_id"
                    ]
                )

            if release_date_present:

                subtype.release_date = (
                    release_date
                )

            subtype.save()

        else:

            subtype = (
                ManufacturingContracts.objects
                .select_for_update()
                .get(
                    contract=instance
                )
            )

            if (
                "manufacturer_external_id"
                in validated_data
            ):

                subtype.manufacturer = (
                    validated_data[
                        "manufacturer_external_id"
                    ]
                )

            if (
                "product_external_id"
                in validated_data
            ):

                subtype.product = (
                    validated_data[
                        "product_external_id"
                    ]
                )

            if release_date_present:

                subtype.release_date = (
                    release_date
                )

            subtype.save()

        instance.refresh_from_db()

        return instance

    # ========================================================
    # OUTPUT
    # ========================================================

    def to_representation(
        self,
        instance,
    ):

        result = {
            "external_id": instance.external_id,
            "contract_type": (
                instance.contract_type
            ),
            "status": instance.status,
            "event_external_id": (
                instance.event.external_id
            ),
            "event_name": instance.event.name,
            "site_external_id": (
                instance.site.external_id
            ),
            "site_name": instance.site.name,
            "start_date": instance.start_date,
            "end_date": instance.end_date,
            "contract_terms": (
                instance.contract_terms
            ),
            "created_at": instance.created_at,
            "updated_at": instance.updated_at,
        }

        if (
            instance.contract_type
            == Contracts.ContractType.DISCOGRAPHY
        ):

            subtype = (
                DiscographyContracts.objects
                .select_related(
                    "artist",
                    "album",
                    "record_label",
                    "record_label__party",
                )
                .get(
                    contract=instance
                )
            )

            result.update({
                "artist_external_id": (
                    subtype.artist.external_id
                ),
                "artist_name": (
                    subtype.artist.stage_name
                ),
                "album_external_id": (
                    subtype.album.external_id
                ),
                "album_title": (
                    subtype.album.title
                ),
                "record_label_external_id": (
                    subtype.record_label.external_id
                    if subtype.record_label
                    else None
                ),
                "record_label_name": (
                    subtype.record_label.party.name
                    if subtype.record_label
                    else None
                ),
                "release_date": (
                    subtype.release_date
                ),
            })

        elif (
            instance.contract_type
            == Contracts.ContractType.MANUFACTURING
        ):

            subtype = (
                ManufacturingContracts.objects
                .select_related(
                    "manufacturer",
                    "manufacturer__party",
                    "product",
                )
                .get(
                    contract=instance
                )
            )

            result.update({
                "manufacturer_external_id": (
                    subtype
                    .manufacturer
                    .external_id
                ),
                "manufacturer_name": (
                    subtype
                    .manufacturer
                    .party
                    .name
                ),
                "product_external_id": (
                    subtype.product.external_id
                ),
                "product_name": (
                    subtype.product.product_name
                ),
                "release_date": (
                    subtype.release_date
                ),
            })

        return result
