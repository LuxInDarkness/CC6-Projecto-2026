from rest_framework import serializers

from core.models import (
    ApiRawData,
    ApiSyncLog,
)


class InternalSyncLogSerializer(
    serializers.ModelSerializer
):

    system_name = serializers.CharField(
        source="system.name",
        read_only=True,
    )

    class Meta:

        model = ApiSyncLog

        fields = (
            "sync_id",
            "system_name",
            "entity_type",
            "entity_id",
            "operation",
            "started_at",
            "completed_at",
            "status",
            "error_message",
            "records_processed",
        )


class InternalRawDataSerializer(
    serializers.ModelSerializer
):

    system_name = serializers.CharField(
        source="system.name",
        read_only=True,
    )

    class Meta:

        model = ApiRawData

        fields = (
            "raw_data_id",
            "system_name",
            "entity_type",
            "external_id",
            "operation",
            "payload",
            "received_at",
        )
