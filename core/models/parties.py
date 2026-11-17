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

    name = models.CharField(max_length=255)

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
        verbose_name = "Party"
        verbose_name_plural = "Parties"

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
        verbose_name = "Artist"
        verbose_name_plural = "Artists"

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
        verbose_name = "Record Label"
        verbose_name_plural = "Record Labels"

    def __str__(self):
        return self.party.name


class Manufacturers(models.Model):

    manufacturer_id = models.BigAutoField(
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
        related_name="manufacturer",
    )

    manufacturer_type = models.CharField(
        max_length=100,
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
        db_table = "manufacturers"
        verbose_name = "Manufacturer"
        verbose_name_plural = "Manufacturers"

    def __str__(self):
        return self.party.name
