from django.db import models


class Parties(models.Model):

    class PartyType(models.TextChoices):
        ARTIST = "ARTIST", "Artist"
        RECORD_LABEL = "RECORD_LABEL", "Record Label"
        MANUFACTURER = "MANUFACTURER", "Manufacturer"
        ORGANIZER = "ORGANIZER", "Organizer"
        SPONSOR = "SPONSOR", "Sponsor"
        SUPPLIER = "SUPPLIER", "Supplier"
        OTHER = "OTHER", "Other"

    party_id = models.BigAutoField(
        primary_key=True,
    )

    external_id = models.CharField(
        max_length=15,
        unique=True,
        null=True,
        blank=True,
        editable=False,
    )

    party_type = models.CharField(
        max_length=20,
        choices=PartyType.choices,
    )

    name = models.CharField(
        max_length=255,
    )

    email = models.CharField(
        max_length=320,
        null=True,
        blank=True,
    )

    phone = models.CharField(
        max_length=50,
        null=True,
        blank=True,
    )

    website = models.CharField(
        max_length=2048,
        null=True,
        blank=True,
    )

    address = models.CharField(
        max_length=500,
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
        db_table = "parties"

    def __str__(self):
        return self.name


class Artists(models.Model):

    artist_id = models.BigAutoField(
        primary_key=True,
    )

    external_id = models.CharField(
        max_length=15,
        unique=True,
        null=True,
        blank=True,
        editable=False,
    )

    party = models.OneToOneField(
        Parties,
        db_column="party_id",
        on_delete=models.CASCADE,
        related_name="artist",
    )

    stage_name = models.CharField(
        max_length=255,
    )

    legal_name = models.CharField(
        max_length=255,
        null=True,
        blank=True,
    )

    country_code = models.CharField(
        max_length=2,
        null=True,
        blank=True,
    )

    biography = models.TextField(
        null=True,
        blank=True,
    )

    website = models.CharField(
        max_length=2048,
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
        db_table = "artists"

    def __str__(self):
        return self.stage_name


class RecordLabels(models.Model):

    record_label_id = models.BigAutoField(
        primary_key=True,
    )

    external_id = models.CharField(
        max_length=15,
        unique=True,
        null=True,
        blank=True,
        editable=False,
    )

    party = models.OneToOneField(
        Parties,
        db_column="party_id",
        on_delete=models.CASCADE,
        related_name="record_label",
    )

    catalog_prefix = models.CharField(
        max_length=50,
        null=True,
        blank=True,
    )

    website = models.CharField(
        max_length=2048,
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
        db_table = "record_labels"

    def __str__(self):
        return self.party.name
