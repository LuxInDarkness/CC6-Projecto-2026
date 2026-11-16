from django.db import models


class Sites(models.Model):

    class Status(models.TextChoices):
        ACTIVE = "ACTIVE", "Active"
        INACTIVE = "INACTIVE", "Inactive"
        MAINTENANCE = "MAINTENANCE", "Maintenance"

    site_id = models.BigAutoField(
        primary_key=True,
    )

    external_id = models.CharField(
        max_length=15,
        unique=True,
        null=True,
        blank=True,
        editable=False,
    )

    name = models.CharField(
        max_length=255,
    )

    description = models.TextField(
        null=True,
        blank=True,
    )

    address = models.CharField(
        max_length=500,
        null=True,
        blank=True,
    )

    city = models.CharField(
        max_length=150,
        null=True,
        blank=True,
    )

    state = models.CharField(
        max_length=150,
        null=True,
        blank=True,
    )

    country = models.CharField(
        max_length=150,
        null=True,
        blank=True,
    )

    postal_code = models.CharField(
        max_length=30,
        null=True,
        blank=True,
    )

    latitude = models.DecimalField(
        max_digits=9,
        decimal_places=6,
        null=True,
        blank=True,
    )

    longitude = models.DecimalField(
        max_digits=9,
        decimal_places=6,
        null=True,
        blank=True,
    )

    capacity = models.PositiveIntegerField(
        null=True,
        blank=True,
    )

    site_type = models.CharField(
        max_length=100,
        null=True,
        blank=True,
    )

    status = models.CharField(
        max_length=11,
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
        db_table = "sites"

    def __str__(self):
        return self.name