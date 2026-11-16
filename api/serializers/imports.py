from rest_framework import serializers


class ImportRequestSerializer(serializers.Serializer):

    system = serializers.CharField(
        max_length=255,
    )


# ============================================================
# ARTISTS
# ============================================================


class ArtistImportItemSerializer(serializers.Serializer):

    source_id = serializers.CharField(
        max_length=255,
    )

    name = serializers.CharField(
        max_length=255,
    )

    legal_name = serializers.CharField(
        max_length=255,
        required=False,
        allow_null=True,
        allow_blank=True,
    )

    country_code = serializers.CharField(
        max_length=2,
        required=False,
        allow_null=True,
        allow_blank=True,
    )

    biography = serializers.CharField(
        required=False,
        allow_null=True,
        allow_blank=True,
    )

    website = serializers.CharField(
        max_length=2048,
        required=False,
        allow_null=True,
        allow_blank=True,
    )


class ArtistImportRequestSerializer(
    ImportRequestSerializer
):

    items = ArtistImportItemSerializer(
        many=True,
        allow_empty=False,
    )


# ============================================================
# ALBUMS
# ============================================================


class AlbumImportItemSerializer(serializers.Serializer):

    source_id = serializers.CharField(
        max_length=255,
    )

    artist_source_id = serializers.CharField(
        max_length=255,
    )

    title = serializers.CharField(
        max_length=255,
    )

    release_date = serializers.DateField(
        required=False,
        allow_null=True,
    )

    catalog_number = serializers.CharField(
        max_length=100,
        required=False,
        allow_null=True,
        allow_blank=True,
    )


class AlbumImportRequestSerializer(
    ImportRequestSerializer
):

    items = AlbumImportItemSerializer(
        many=True,
        allow_empty=False,
    )


# ============================================================
# MANUFACTURERS
# ============================================================


class ManufacturerImportItemSerializer(
    serializers.Serializer
):

    source_id = serializers.CharField(
        max_length=255,
    )

    name = serializers.CharField(
        max_length=255,
    )

    manufacturer_type = serializers.CharField(
        max_length=100,
        required=False,
        allow_null=True,
        allow_blank=True,
    )

    website = serializers.CharField(
        max_length=2048,
        required=False,
        allow_null=True,
        allow_blank=True,
    )


class ManufacturerImportRequestSerializer(
    ImportRequestSerializer
):

    items = ManufacturerImportItemSerializer(
        many=True,
        allow_empty=False,
    )


# ============================================================
# PRODUCTS
# ============================================================


class ProductImportItemSerializer(
    serializers.Serializer
):

    source_id = serializers.CharField(
        max_length=255,
    )

    manufacturer_source_id = serializers.CharField(
        max_length=255,
    )

    product_name = serializers.CharField(
        max_length=255,
    )

    description = serializers.CharField(
        required=False,
        allow_null=True,
        allow_blank=True,
    )

    sku = serializers.CharField(
        max_length=100,
        required=False,
        allow_null=True,
        allow_blank=True,
    )

    product_type = serializers.CharField(
        max_length=100,
        required=False,
        allow_null=True,
        allow_blank=True,
    )


class ProductImportRequestSerializer(
    ImportRequestSerializer
):

    items = ProductImportItemSerializer(
        many=True,
        allow_empty=False,
    )
