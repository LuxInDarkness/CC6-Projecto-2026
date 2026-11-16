from django.db import models

from .catalog import (
    Albums,
    Products,
)

from .events import Events

from .parties import (
    Artists,
    Manufacturers,
    RecordLabels,
)

from .sites import Sites


class Contracts(models.Model):

    class ContractType(models.TextChoices):
        DISCOGRAPHY = (
            "DISCOGRAPHY",
            "Discography",
        )
        MANUFACTURING = (
            "MANUFACTURING",
            "Manufacturing",
        )
        MERCHANDISE = (
            "MERCHANDISE",
            "Merchandise",
        )
        OTHER = (
            "OTHER",
            "Other",
        )

    class Status(models.TextChoices):
        DRAFT = "DRAFT", "Draft"
        PENDING = "PENDING", "Pending"
        APPROVED = "APPROVED", "Approved"
        REJECTED = "REJECTED", "Rejected"
        CANCELLED = "CANCELLED", "Cancelled"
        FINISHED = "FINISHED", "Finished"

    contract_id = models.BigAutoField(
        primary_key=True,
    )

    external_id = models.CharField(
        max_length=15,
        unique=True,
        null=True,
        blank=True,
        editable=False,
    )

    contract_type = models.CharField(
        max_length=20,
        choices=ContractType.choices,
    )

    status = models.CharField(
        max_length=20,
        choices=Status.choices,
        default=Status.DRAFT,
    )

    site = models.ForeignKey(
        Sites,
        db_column="site_id",
        on_delete=models.PROTECT,
        related_name="contracts",
    )

    event = models.ForeignKey(
        Events,
        db_column="event_id",
        on_delete=models.PROTECT,
        related_name="contracts",
    )

    start_date = models.DateField(
        null=True,
        blank=True,
    )

    end_date = models.DateField(
        null=True,
        blank=True,
    )

    contract_terms = models.TextField()

    created_at = models.DateTimeField(
        auto_now_add=True,
    )

    updated_at = models.DateTimeField(
        auto_now=True,
    )

    class Meta:
        managed = False
        db_table = "contracts"

    def __str__(self):
        return (
            self.external_id
            or str(self.contract_id)
        )


class DiscographyContracts(models.Model):

    contract = models.OneToOneField(
        Contracts,
        db_column="contract_id",
        primary_key=True,
        on_delete=models.CASCADE,
        related_name="discography_details",
    )

    artist = models.ForeignKey(
        Artists,
        db_column="artist_id",
        on_delete=models.PROTECT,
        related_name="discography_contracts",
    )

    record_label = models.ForeignKey(
        RecordLabels,
        db_column="record_label_id",
        on_delete=models.PROTECT,
        null=True,
        blank=True,
        related_name="discography_contracts",
    )

    album = models.ForeignKey(
        Albums,
        db_column="album_id",
        on_delete=models.PROTECT,
        related_name="discography_contracts",
    )

    release_date = models.DateField()

    class Meta:
        managed = False
        db_table = "discography_contracts"

    def __str__(self):
        return (
            self.contract.external_id
            or str(self.contract.contract_id)
        )


class ManufacturingContracts(models.Model):

    contract = models.OneToOneField(
        Contracts,
        db_column="contract_id",
        primary_key=True,
        on_delete=models.CASCADE,
        related_name="manufacturing_details",
    )

    manufacturer = models.ForeignKey(
        Manufacturers,
        db_column="manufacturer_id",
        on_delete=models.PROTECT,
        related_name="manufacturing_contracts",
    )

    product = models.ForeignKey(
        Products,
        db_column="product_id",
        on_delete=models.PROTECT,
        related_name="manufacturing_contracts",
    )

    release_date = models.DateField()

    class Meta:
        managed = False
        db_table = "manufacturing_contracts"

    def __str__(self):
        return (
            self.contract.external_id
            or str(self.contract.contract_id)
        )