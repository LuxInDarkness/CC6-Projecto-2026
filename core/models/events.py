from django.db import models

from .sites import Sites


class Events(models.Model):

    class Status(models.TextChoices):
        PLANNED = "PLANNED", "Planned"
        CONFIRMED = "CONFIRMED", "Confirmed"
        CANCELLED = "CANCELLED", "Cancelled"
        COMPLETED = "COMPLETED", "Completed"

    event_id = models.BigAutoField(
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

    event_type = models.CharField(
        max_length=100,
        null=True,
        blank=True,
    )

    status = models.CharField(
        max_length=10,
        choices=Status.choices,
        default=Status.PLANNED,
    )

    start_date = models.DateField()

    end_date = models.DateField()

    created_at = models.DateTimeField(
        auto_now_add=True,
    )

    updated_at = models.DateTimeField(
        auto_now=True,
    )

    class Meta:
        managed = False
        db_table = "events"

    def __str__(self):
        return self.name


class EventSites(models.Model):

    pk = models.CompositePrimaryKey(
        "event",
        "site",
    )

    event = models.ForeignKey(
        Events,
        db_column="event_id",
        on_delete=models.CASCADE,
        related_name="event_sites",
    )

    site = models.ForeignKey(
        Sites,
        db_column="site_id",
        on_delete=models.PROTECT,
        related_name="event_sites",
    )

    role = models.CharField(
        max_length=100,
        default="MAIN",
    )

    class Meta:
        managed = False
        db_table = "event_sites"

    def __str__(self):
        return (
            f"{self.event.name} - "
            f"{self.site.name}"
        )