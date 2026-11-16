from django.db import models

from .contracts import Contracts


class EventBookings(models.Model):

    class Status(models.TextChoices):
        HOLD = "HOLD", "Hold"
        CONFIRMED = "CONFIRMED", "Confirmed"
        CANCELLED = "CANCELLED", "Cancelled"
        COMPLETED = "COMPLETED", "Completed"

    booking_id = models.BigAutoField(
        primary_key=True,
    )

    external_id = models.CharField(
        max_length=15,
        unique=True,
        null=True,
        blank=True,
        editable=False,
    )

    # These are intentionally numeric fields rather than Django
    # ForeignKeys because the database enforces them through the
    # composite (event_id, site_id) FK to event_sites.
    event_id = models.PositiveBigIntegerField()

    site_id = models.PositiveBigIntegerField()

    start_date = models.DateField()

    end_date = models.DateField()

    status = models.CharField(
        max_length=10,
        choices=Status.choices,
        default=Status.HOLD,
    )

    agreed_price = models.DecimalField(
        max_digits=12,
        decimal_places=2,
        null=True,
        blank=True,
    )

    currency = models.CharField(
        max_length=3,
        null=True,
        blank=True,
    )

    contract = models.ForeignKey(
        Contracts,
        db_column="contract_id",
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name="bookings",
    )

    notes = models.TextField(
        null=True,
        blank=True,
    )

    created_at = models.DateTimeField(
        auto_now_add=True,
    )

    updated_at = models.DateTimeField(
        auto_now=True,
    )

    class Meta:
        managed = False
        db_table = "event_bookings"

    def __str__(self):
        return (
            self.external_id
            or str(self.booking_id)
        )
