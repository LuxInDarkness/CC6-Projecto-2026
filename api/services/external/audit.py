from django.db import DatabaseError
from django.utils import timezone

from core.models import (
    ApiRawData,
    ApiSyncLog,
)


def start_sync(
    *,
    system,
    entity_type,
    operation,
    entity_id=None,
):

    try:

        return ApiSyncLog.objects.create(
            system=system,
            entity_type=entity_type,
            entity_id=entity_id,
            operation=operation,
            status=ApiSyncLog.Status.PENDING,
        )

    except DatabaseError:
        return None


def finish_sync_success(
    sync_log,
    *,
    records_processed=1,
):

    if sync_log is None:
        return

    try:

        sync_log.status = (
            ApiSyncLog.Status.SUCCESS
        )

        sync_log.completed_at = timezone.now()

        sync_log.records_processed = (
            records_processed
        )

        sync_log.save(
            update_fields=(
                "status",
                "completed_at",
                "records_processed",
            )
        )

    except DatabaseError:
        pass


def finish_sync_failure(
    sync_log,
    error_message,
):

    if sync_log is None:
        return

    try:

        sync_log.status = (
            ApiSyncLog.Status.FAILED
        )

        sync_log.completed_at = timezone.now()

        sync_log.error_message = str(
            error_message
        )

        sync_log.save(
            update_fields=(
                "status",
                "completed_at",
                "error_message",
            )
        )

    except DatabaseError:
        pass


def save_raw_data(
    *,
    system,
    entity_type,
    operation,
    payload,
    external_id=None,
):

    try:

        ApiRawData.objects.create(
            system=system,
            entity_type=entity_type,
            external_id=external_id,
            operation=operation,
            payload=payload,
        )

    except DatabaseError:
        pass
