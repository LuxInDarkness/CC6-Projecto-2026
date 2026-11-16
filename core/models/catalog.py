from django.db import models

from .parties import (
    Artists,
    Manufacturers,
)


class Albums(models.Model):

    album_id = models.BigAutoField(
        primary_key=True,
    )

    external_id = models.CharField(
        max_length=15,
        unique=True,
        null=True,
        blank=True,
        editable=False,
    )

    artist = models.ForeignKey(
        Artists,
        db_column="artist_id",
        on_delete=models.PROTECT,
        related_name="albums",
    )

    title = models.CharField(
        max_length=255,
    )

    release_date = models.DateField(
        null=True,
        blank=True,
    )

    catalog_number = models.CharField(
        max_length=100,
        unique=True,
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
        db_table = "albums"

    def __str__(self):
        return self.title


class Products(models.Model):

    product_id = models.BigAutoField(
        primary_key=True,
    )

    external_id = models.CharField(
        max_length=15,
        unique=True,
        null=True,
        blank=True,
        editable=False,
    )

    manufacturer = models.ForeignKey(
        Manufacturers,
        db_column="manufacturer_id",
        on_delete=models.PROTECT,
        related_name="products",
    )

    product_name = models.CharField(
        max_length=255,
    )

    description = models.TextField(
        null=True,
        blank=True,
    )

    sku = models.CharField(
        max_length=100,
        unique=True,
        null=True,
        blank=True,
    )

    product_type = models.CharField(
        max_length=100,
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
        db_table = "products"

    def __str__(self):
        return self.product_name
