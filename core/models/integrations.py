from django.db import models


class ExternalSystems(models.Model):

    class Status(models.TextChoices):
        ACTIVE = "ACTIVE", "Active"
        INACTIVE = "INACTIVE", "Inactive"

    system_id = models.BigAutoField(
        primary_key=True,
    )

    name = models.CharField(
        max_length=255,
        unique=True,
    )

    base_url = models.CharField(
        max_length=2048,
        null=True,
        blank=True,
    )

    system_type = models.CharField(
        max_length=100,
        null=True,
        blank=True,
    )

    status = models.CharField(
        max_length=8,
        choices=Status.choices,
        default=Status.ACTIVE,
    )

    created_at = models.DateTimeField(
        auto_now_add=True,
    )

    updated_at = models.DateTimeField(
        auto_now=True,
    )

    class Meta:
        managed = False
        db_table = "external_systems"

    def __str__(self):
        return self.name


class ExternalRecords(models.Model):

    class SyncStatus(models.TextChoices):
        PENDING = "PENDING", "Pending"
        SUCCESS = "SUCCESS", "Success"
        FAILED = "FAILED", "Failed"
        SKIPPED = "SKIPPED", "Skipped"

    external_record_id = models.BigAutoField(
        primary_key=True,
    )

    system = models.ForeignKey(
        ExternalSystems,
        db_column="system_id",
        on_delete=models.CASCADE,
        related_name="external_records",
    )

    entity_type = models.CharField(
        max_length=100,
    )

    internal_id = models.PositiveBigIntegerField()

    external_id = models.CharField(
        max_length=255,
    )

    external_updated_at = models.DateTimeField(
        null=True,
        blank=True,
    )

    last_synced_at = models.DateTimeField(
        null=True,
        blank=True,
    )

    sync_status = models.CharField(
        max_length=10,
        choices=SyncStatus.choices,
        default=SyncStatus.PENDING,
    )

    class Meta:
        managed = False
        db_table = "external_records"

        constraints = [
            models.UniqueConstraint(
                fields=(
                    "system",
                    "entity_type",
                    "external_id",
                ),
                name="uq_external_record_external",
            ),
            models.UniqueConstraint(
                fields=(
                    "system",
                    "entity_type",
                    "internal_id",
                ),
                name="uq_external_record_internal",
            ),
        ]

    def __str__(self):
        return (
            f"{self.system.name}:"
            f"{self.entity_type}:"
            f"{self.external_id}"
        )
