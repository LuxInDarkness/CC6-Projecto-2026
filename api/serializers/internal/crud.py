from django.db import transaction

from rest_framework import serializers

from core.models import (
    Albums,
    Artists,
    EventSites,
    Events,
    Manufacturers,
    Parties,
    Products,
    Sites,
)


# ============================================================
# SHARED PARTY
# ============================================================


class PartyDataSerializer(serializers.Serializer):

    name = serializers.CharField(
        max_length=255,
    )

    email = serializers.EmailField(
        required=False,
        allow_null=True,
        allow_blank=True,
    )

    phone = serializers.CharField(
        max_length=50,
        required=False,
        allow_null=True,
        allow_blank=True,
    )

    website = serializers.CharField(
        max_length=2048,
        required=False,
        allow_null=True,
        allow_blank=True,
    )

    address = serializers.CharField(
        max_length=500,
        required=False,
        allow_null=True,
        allow_blank=True,
    )


def update_party(
    party,
    data,
):

    for field, value in data.items():
        setattr(
            party,
            field,
            value,
        )

    party.save()

    return party


# ============================================================
# SITES
# ============================================================


class InternalSiteSerializer(
    serializers.ModelSerializer
):

    class Meta:

        model = Sites

        fields = (
            "external_id",
            "name",
            "description",
            "address",
            "city",
            "state",
            "country",
            "postal_code",
            "latitude",
            "longitude",
            "capacity",
            "site_type",
            "status",
            "created_at",
            "updated_at",
        )

        read_only_fields = (
            "external_id",
            "created_at",
            "updated_at",
        )

    def validate_latitude(
        self,
        value,
    ):

        if value is not None:

            if value < -90 or value > 90:

                raise serializers.ValidationError(
                    "Latitude must be between "
                    "-90 and 90."
                )

        return value

    def validate_longitude(
        self,
        value,
    ):

        if value is not None:

            if value < -180 or value > 180:

                raise serializers.ValidationError(
                    "Longitude must be between "
                    "-180 and 180."
                )

        return value


# ============================================================
# ARTISTS
# ============================================================


class InternalArtistSerializer(
    serializers.ModelSerializer
):

    party = PartyDataSerializer()

    class Meta:

        model = Artists

        fields = (
            "external_id",
            "party",
            "stage_name",
            "legal_name",
            "country_code",
            "biography",
            "website",
            "created_at",
            "updated_at",
        )

        read_only_fields = (
            "external_id",
            "created_at",
            "updated_at",
        )

    def validate_country_code(
        self,
        value,
    ):

        if value:

            value = value.upper()

        return value

    @transaction.atomic
    def create(
        self,
        validated_data,
    ):

        party_data = validated_data.pop(
            "party"
        )

        party = Parties.objects.create(
            party_type=(
                Parties.PartyType.ARTIST
            ),
            **party_data,
        )

        party.refresh_from_db()

        artist = Artists.objects.create(
            party=party,
            **validated_data,
        )

        artist.refresh_from_db()

        return artist

    @transaction.atomic
    def update(
        self,
        instance,
        validated_data,
    ):

        party_data = validated_data.pop(
            "party",
            None,
        )

        if party_data is not None:

            update_party(
                instance.party,
                party_data,
            )

        for field, value in (
            validated_data.items()
        ):

            setattr(
                instance,
                field,
                value,
            )

        instance.save()

        return instance


# ============================================================
# MANUFACTURERS
# ============================================================


class InternalManufacturerSerializer(
    serializers.ModelSerializer
):

    party = PartyDataSerializer()

    class Meta:

        model = Manufacturers

        fields = (
            "external_id",
            "party",
            "manufacturer_type",
            "website",
            "created_at",
            "updated_at",
        )

        read_only_fields = (
            "external_id",
            "created_at",
            "updated_at",
        )

    @transaction.atomic
    def create(
        self,
        validated_data,
    ):

        party_data = validated_data.pop(
            "party"
        )

        party = Parties.objects.create(
            party_type=(
                Parties
                .PartyType
                .MANUFACTURER
            ),
            **party_data,
        )

        party.refresh_from_db()

        manufacturer = (
            Manufacturers.objects.create(
                party=party,
                **validated_data,
            )
        )

        manufacturer.refresh_from_db()

        return manufacturer

    @transaction.atomic
    def update(
        self,
        instance,
        validated_data,
    ):

        party_data = validated_data.pop(
            "party",
            None,
        )

        if party_data is not None:

            update_party(
                instance.party,
                party_data,
            )

        for field, value in (
            validated_data.items()
        ):

            setattr(
                instance,
                field,
                value,
            )

        instance.save()

        return instance


# ============================================================
# ALBUMS
# ============================================================


class InternalAlbumSerializer(
    serializers.ModelSerializer
):

    artist_external_id = (
        serializers.SlugRelatedField(
            source="artist",
            slug_field="external_id",
            queryset=Artists.objects.all(),
        )
    )

    artist_name = serializers.CharField(
        source="artist.stage_name",
        read_only=True,
    )

    class Meta:

        model = Albums

        fields = (
            "external_id",
            "artist_external_id",
            "artist_name",
            "title",
            "release_date",
            "catalog_number",
            "created_at",
            "updated_at",
        )

        read_only_fields = (
            "external_id",
            "artist_name",
            "created_at",
            "updated_at",
        )


# ============================================================
# PRODUCTS
# ============================================================


class InternalProductSerializer(
    serializers.ModelSerializer
):

    manufacturer_external_id = (
        serializers.SlugRelatedField(
            source="manufacturer",
            slug_field="external_id",
            queryset=Manufacturers.objects.all(),
        )
    )

    manufacturer_name = serializers.CharField(
        source="manufacturer.party.name",
        read_only=True,
    )

    class Meta:

        model = Products

        fields = (
            "external_id",
            "manufacturer_external_id",
            "manufacturer_name",
            "product_name",
            "description",
            "sku",
            "product_type",
            "created_at",
            "updated_at",
        )

        read_only_fields = (
            "external_id",
            "manufacturer_name",
            "created_at",
            "updated_at",
        )


# ============================================================
# EVENTS
# ============================================================


class InternalEventSiteSerializer(
    serializers.Serializer
):

    external_id = serializers.CharField(
        max_length=15,
    )

    role = serializers.CharField(
        max_length=100,
        required=False,
        default="MAIN",
    )


class InternalEventSerializer(
    serializers.ModelSerializer
):

    # Input representation.
    sites = InternalEventSiteSerializer(
        many=True,
        required=True,
        write_only=True,
        allow_empty=False,
    )

    class Meta:

        model = Events

        fields = (
            "external_id",
            "name",
            "description",
            "event_type",
            "status",
            "start_date",
            "end_date",
            "sites",
            "created_at",
            "updated_at",
        )

        read_only_fields = (
            "external_id",
            "created_at",
            "updated_at",
        )

    def validate(
        self,
        attrs,
    ):

        start_date = attrs.get(
            "start_date",
            getattr(
                self.instance,
                "start_date",
                None,
            ),
        )

        end_date = attrs.get(
            "end_date",
            getattr(
                self.instance,
                "end_date",
                None,
            ),
        )

        if (
            start_date is not None
            and end_date is not None
            and end_date < start_date
        ):

            raise serializers.ValidationError({
                "end_date": (
                    "end_date must be greater "
                    "than or equal to start_date."
                )
            })

        site_data = attrs.get("sites")

        if site_data is not None:

            external_ids = [
                item["external_id"]
                for item in site_data
            ]

            if (
                len(external_ids)
                != len(set(external_ids))
            ):

                raise serializers.ValidationError({
                    "sites": (
                        "The same site cannot be "
                        "assigned more than once."
                    )
                })

            existing_ids = set(
                Sites.objects.filter(
                    external_id__in=external_ids
                ).values_list(
                    "external_id",
                    flat=True,
                )
            )

            missing = (
                set(external_ids)
                - existing_ids
            )

            if missing:

                raise serializers.ValidationError({
                    "sites": (
                        "Unknown site external ID(s): "
                        + ", ".join(
                            sorted(missing)
                        )
                    )
                })

        return attrs

    def _set_sites(
        self,
        event,
        site_data,
    ):

        desired = {}

        for item in site_data:

            site = Sites.objects.get(
                external_id=(
                    item["external_id"]
                )
            )

            desired[site.site_id] = {
                "site": site,
                "role": item.get(
                    "role",
                    "MAIN",
                ),
            }

        existing = {
            event_site.site_id: event_site
            for event_site
            in EventSites.objects.filter(
                event=event
            )
        }

        # Add new assignments and update roles.
        for site_id, data in desired.items():

            current = existing.get(site_id)

            if current is None:

                EventSites.objects.create(
                    event=event,
                    site=data["site"],
                    role=data["role"],
                )

            elif current.role != data["role"]:

                current.role = data["role"]

                current.save(
                    update_fields=("role",)
                )

        # Remove associations that are no longer
        # part of the requested event.
        removed_ids = (
            set(existing)
            - set(desired)
        )

        if removed_ids:

            EventSites.objects.filter(
                event=event,
                site_id__in=removed_ids,
            ).delete()

    @transaction.atomic
    def create(
        self,
        validated_data,
    ):

        site_data = validated_data.pop(
            "sites"
        )

        event = Events.objects.create(
            **validated_data
        )

        event.refresh_from_db()

        self._set_sites(
            event,
            site_data,
        )

        return event

    @transaction.atomic
    def update(
        self,
        instance,
        validated_data,
    ):

        site_data = validated_data.pop(
            "sites",
            None,
        )

        for field, value in (
            validated_data.items()
        ):

            setattr(
                instance,
                field,
                value,
            )

        instance.save()

        if site_data is not None:

            self._set_sites(
                instance,
                site_data,
            )

        return instance

    def to_representation(
        self,
        instance,
    ):

        data = super().to_representation(
            instance
        )

        assignments = (
            EventSites.objects
            .filter(
                event=instance
            )
            .select_related("site")
            .order_by("site__name")
        )

        data["sites"] = [
            {
                "external_id": (
                    assignment
                    .site
                    .external_id
                ),
                "name": (
                    assignment
                    .site
                    .name
                ),
                "role": assignment.role,
            }
            for assignment in assignments
        ]

        return data
