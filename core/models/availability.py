from django.db import models


class SiteAvailableDates(models.Model):

    availability_id = models.BigIntegerField(
        primary_key=True,
    )

    site_id = models.BigIntegerField()

    site_external_id = models.CharField(
        max_length=15,
    )

    location_name = models.CharField(
        max_length=255,
    )

    date = models.DateField()

    price = models.DecimalField(
        max_digits=12,
        decimal_places=2,
        null=True,
    )

    currency = models.CharField(
        max_length=3,
        null=True,
    )

    class Meta:
        managed = False
        db_table = "v_site_available_dates"
