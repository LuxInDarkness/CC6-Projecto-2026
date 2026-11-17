from rest_framework import serializers

from core.models import (
    ExternalRecords,
    ExternalSystems,
)


class InternalExternalSystemSerializer(
    serializers.ModelSerializer
):

    class Meta:

        model = ExternalSystems

        fields = (
            "system_id",
            "name",
            "base_url",
            "system_type",
            "status",
            "created_at",
            "updated_at",
        )

        read_only_fields = (
            "system_id",
            "created_at",
            "updated_at",
        )


class InternalExternalRecordSerializer(
    serializers.ModelSerializer
):

    system_id = (
        serializers.PrimaryKeyRelatedField(
            source="system",
            queryset=ExternalSystems.objects.all(),
        )
    )

    system_name = serializers.CharField(
        source="system.name",
        read_only=True,
    )

    class Meta:

        model = ExternalRecords

        fields = (
            "external_record_id",

            "system_id",
            "system_name",

            "entity_type",
            "internal_id",
            "external_id",

            "external_updated_at",
            "last_synced_at",

            "sync_status",
        )

        read_only_fields = (
            "external_record_id",
            "system_name",
        )

    def validate_internal_id(
        self,
        value,
    ):

        if value < 1:

            raise serializers.ValidationError(
                "internal_id must be positive."
            )

        return value
