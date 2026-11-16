from rest_framework import serializers

from core.models import Events, EventSites, Sites
from django.db import transaction

class EventSitesResponseSerializer(serializers.Serializer):

    external_id = serializers.CharField()
    name = serializers.CharField()


class EventCreateSerializer(serializers.ModelSerializer):

    site_external_ids = serializers.ListField(
        child=serializers.CharField(
            min_length=15,
            max_length=15,
        ),
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
            "site_external_ids",
        )

        read_only_fields = (
            "external_id",
            "status",
        )

    def validate(self, attrs):
        if attrs["end_date"] < attrs["start_date"]:
            raise serializers.ValidationError({
                "end_date": (
                    "end_date must be greater than or "
                    "equal to start_date."
                )
            })

        return attrs

    def validate_site_external_ids(self, values):
        if len(values) != len(set(values)):
            raise serializers.ValidationError(
                "Duplicate site IDs are not allowed."
            )

        sites = Sites.objects.filter(
            external_id__in=values,
            status="ACTIVE",
        )

        found_ids = set(
            sites.values_list(
                "external_id",
                flat=True,
            )
        )

        missing = set(values) - found_ids

        if missing:
            raise serializers.ValidationError(
                f"Unknown site IDs: {sorted(missing)}"
            )

        return values

    @transaction.atomic
    def create(self, validated_data):

        site_external_ids = validated_data.pop(
            "site_external_ids"
        )

        event = Events.objects.create(
            **validated_data
        )

        event.refresh_from_db()

        sites = Sites.objects.filter(
            external_id__in=site_external_ids,
            status="ACTIVE",
        )

        for site in sites:
            EventSites.objects.create(
                event=event,
                site=site,
                role="MAIN",
            )

        return event


class EventDetailSerializer(serializers.ModelSerializer):

    sites = serializers.SerializerMethodField()

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

    def get_sites(self, obj):
        event_sites = EventSites.objects.filter(
            event=obj
        ).select_related("site")

        return [
            {
                "external_id": item.site.external_id,
                "name": item.site.name,
                "role": item.role,
            }
            for item in event_sites
        ]
