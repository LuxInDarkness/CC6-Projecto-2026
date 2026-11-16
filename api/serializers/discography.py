from django.db import transaction
from rest_framework import serializers

from core.models import (
    Albums,
    Artists,
    Contracts,
    DiscographyContracts,
    Events,
    EventSites,
    RecordLabels,
    Sites,
)


# ============================================================
# RESPONSE SERIALIZERS
# ============================================================


class EntityReferenceSerializer(serializers.Serializer):
    external_id = serializers.CharField()
    name = serializers.CharField()


class DiscographyContractResponseSerializer(serializers.Serializer):
    external_id = serializers.CharField()

    contract_type = serializers.CharField()
    status = serializers.CharField()

    event = EntityReferenceSerializer()
    site = EntityReferenceSerializer()
    artist = EntityReferenceSerializer()
    album = EntityReferenceSerializer()

    record_label = EntityReferenceSerializer(
        allow_null=True
    )

    release_date = serializers.DateField()

    start_date = serializers.DateField(
        allow_null=True
    )

    end_date = serializers.DateField(
        allow_null=True
    )

    contract_terms = serializers.CharField()

    created_at = serializers.DateTimeField()
    updated_at = serializers.DateTimeField()


# ============================================================
# WRITE SERIALIZER
# ============================================================


class DiscographyContractWriteSerializer(
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

    artist_external_id = serializers.CharField(
        min_length=15,
        max_length=15,
    )

    album_external_id = serializers.CharField(
        min_length=15,
        max_length=15,
    )

    record_label_external_id = serializers.CharField(
        min_length=15,
        max_length=15,
        required=False,
        allow_null=True,
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

    # Public clients must NOT be able to approve contracts.
    status = serializers.ChoiceField(
        choices=(
            "DRAFT",
            "PENDING",
        ),
        default="DRAFT",
    )

    # ========================================================
    # GENERAL VALIDATION
    # ========================================================

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

        artist = self._get_artist(
            attrs["artist_external_id"]
        )

        album = self._get_album(
            attrs["album_external_id"]
        )

        record_label = self._get_record_label(
            attrs.get(
                "record_label_external_id"
            )
        )

        # ----------------------------------------------------
        # Event / site validation
        # ----------------------------------------------------

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

        # ----------------------------------------------------
        # Album / artist validation
        # ----------------------------------------------------

        if album.artist.artist_id != artist.artist_id:

            raise serializers.ValidationError({
                "album_external_id": (
                    "The selected album does not belong "
                    "to the selected artist."
                )
            })

        # Store resolved ORM objects so create/update does not
        # need to query them again.
        attrs["_event"] = event
        attrs["_site"] = site
        attrs["_artist"] = artist
        attrs["_album"] = album
        attrs["_record_label"] = record_label

        return attrs

    # ========================================================
    # LOOKUP HELPERS
    # ========================================================

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
                status="ACTIVE",
            )
        except Sites.DoesNotExist:
            raise serializers.ValidationError({
                "site_external_id": (
                    "Active site does not exist."
                )
            })

    def _get_artist(self, external_id):

        try:
            return Artists.objects.get(
                external_id=external_id
            )
        except Artists.DoesNotExist:
            raise serializers.ValidationError({
                "artist_external_id": (
                    "Artist does not exist."
                )
            })

    def _get_album(self, external_id):

        try:
            return Albums.objects.get(
                external_id=external_id
            )
        except Albums.DoesNotExist:
            raise serializers.ValidationError({
                "album_external_id": (
                    "Album does not exist."
                )
            })

    def _get_record_label(self, external_id):

        if external_id is None:
            return None

        try:
            return RecordLabels.objects.get(
                external_id=external_id
            )
        except RecordLabels.DoesNotExist:
            raise serializers.ValidationError({
                "record_label_external_id": (
                    "Record label does not exist."
                )
            })

    # ========================================================
    # CREATE
    # ========================================================

    @transaction.atomic
    def create(self, validated_data):

        event = validated_data.pop("_event")
        site = validated_data.pop("_site")
        artist = validated_data.pop("_artist")
        album = validated_data.pop("_album")
        record_label = validated_data.pop(
            "_record_label"
        )

        # Remove the public external-ID input values.
        validated_data.pop("event_external_id")
        validated_data.pop("site_external_id")
        validated_data.pop("artist_external_id")
        validated_data.pop("album_external_id")

        validated_data.pop(
            "record_label_external_id",
            None,
        )

        release_date = validated_data.pop(
            "release_date"
        )

        status = validated_data.pop(
            "status",
            "DRAFT",
        )

        contract = Contracts.objects.create(
            contract_type=(Contracts.ContractType.DISCOGRAPHY),
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

        # external_id is generated by MySQL trigger.
        contract.refresh_from_db()

        discography = (
            DiscographyContracts.objects.create(
                contract=contract,
                artist=artist,
                album=album,
                record_label=record_label,
                release_date=release_date,
            )
        )

        return discography

    # ========================================================
    # UPDATE
    # ========================================================

    @transaction.atomic
    def update(
        self,
        instance,
        validated_data,
    ):

        contract = instance.contract

        # Public users may only modify contracts that have not
        # yet entered the administrative approval workflow.
        if contract.status not in (
            "DRAFT",
            "PENDING",
        ):
            raise serializers.ValidationError({
                "status": (
                    "Only DRAFT or PENDING contracts "
                    "can be modified through the public API."
                )
            })

        event = validated_data.pop("_event")
        site = validated_data.pop("_site")
        artist = validated_data.pop("_artist")
        album = validated_data.pop("_album")
        record_label = validated_data.pop(
            "_record_label"
        )

        validated_data.pop("event_external_id")
        validated_data.pop("site_external_id")
        validated_data.pop("artist_external_id")
        validated_data.pop("album_external_id")

        validated_data.pop(
            "record_label_external_id",
            None,
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

        instance.artist = artist
        instance.album = album
        instance.record_label = record_label

        instance.release_date = (
            validated_data["release_date"]
        )

        instance.save(
            update_fields=(
                "artist",
                "album",
                "record_label",
                "release_date",
            )
        )

        contract.refresh_from_db()

        return instance


# ============================================================
# RESPONSE BUILDER
# ============================================================


def build_discography_response(instance):

    contract = instance.contract

    record_label = None

    if instance.record_label is not None:

        record_label = {
            "external_id": (
                instance.record_label.external_id
            ),
            "name": instance.record_label.party.name,
        }

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

        "artist": {
            "external_id": (
                instance.artist.external_id
            ),
            "name": instance.artist.stage_name,
        },

        "album": {
            "external_id": (
                instance.album.external_id
            ),
            "name": instance.album.title,
        },

        "record_label": record_label,

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
        DiscographyContractResponseSerializer(
            data
        )
    )

    return serializer.data