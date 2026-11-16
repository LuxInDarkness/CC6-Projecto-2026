from django.db import transaction
from django.utils import timezone

from rest_framework import serializers

from core.models import (
    Albums,
    Artists,
    ExternalRecords,
    ExternalSystems,
    Manufacturers,
    Parties,
    Products,
)


# ============================================================
# SHARED HELPERS
# ============================================================


def get_external_system(name):

    system, _ = ExternalSystems.objects.get_or_create(
        name=name,
        defaults={
            "system_type": "PARTNER_API",
            "status": ExternalSystems.Status.ACTIVE,
        },
    )

    return system


def get_external_mapping(
    system,
    entity_type,
    source_id,
):

    return (
        ExternalRecords.objects
        .filter(
            system=system,
            entity_type=entity_type,
            external_id=source_id,
        )
        .first()
    )


def mark_mapping_synced(mapping):

    mapping.last_synced_at = timezone.now()

    mapping.sync_status = (
        ExternalRecords.SyncStatus.SUCCESS
    )

    mapping.save(
        update_fields=(
            "last_synced_at",
            "sync_status",
        )
    )


# ============================================================
# ARTISTS
# ============================================================


@transaction.atomic
def import_artists(system_name, items):

    system = get_external_system(system_name)

    results = []

    for item in items:

        source_id = item["source_id"]

        mapping = get_external_mapping(
            system,
            "ARTIST",
            source_id,
        )

        if mapping:

            artist = Artists.objects.get(
                artist_id=mapping.internal_id
            )

            artist.stage_name = item["name"]
            artist.legal_name = item.get(
                "legal_name"
            )
            artist.country_code = item.get(
                "country_code"
            )
            artist.biography = item.get(
                "biography"
            )
            artist.website = item.get(
                "website"
            )

            artist.save()

            artist.party.name = item["name"]
            artist.party.save(
                update_fields=("name",)
            )

            mark_mapping_synced(mapping)

            status = "UPDATED"

        else:

            party = Parties.objects.create(
                party_type=(
                    Parties.PartyType.ARTIST
                ),
                name=item["name"],
            )

            party.refresh_from_db()

            artist = Artists.objects.create(
                party=party,
                stage_name=item["name"],
                legal_name=item.get(
                    "legal_name"
                ),
                country_code=item.get(
                    "country_code"
                ),
                biography=item.get(
                    "biography"
                ),
                website=item.get(
                    "website"
                ),
            )

            artist.refresh_from_db()

            ExternalRecords.objects.create(
                system=system,
                entity_type="ARTIST",
                internal_id=artist.artist_id,
                external_id=source_id,
                last_synced_at=timezone.now(),
                sync_status=(
                    ExternalRecords
                    .SyncStatus
                    .SUCCESS
                ),
            )

            status = "CREATED"

        results.append({
            "source_id": source_id,
            "external_id": artist.external_id,
            "status": status,
        })

    return results


# ============================================================
# ALBUMS
# ============================================================


@transaction.atomic
def import_albums(system_name, items):

    system = get_external_system(system_name)

    results = []

    for item in items:

        artist_mapping = get_external_mapping(
            system,
            "ARTIST",
            item["artist_source_id"],
        )

        if artist_mapping is None:

            raise serializers.ValidationError({
                "artist_source_id": (
                    "Artist has not been imported "
                    f"for source ID "
                    f"{item['artist_source_id']}."
                )
            })

        artist = Artists.objects.get(
            artist_id=artist_mapping.internal_id
        )

        source_id = item["source_id"]

        mapping = get_external_mapping(
            system,
            "ALBUM",
            source_id,
        )

        if mapping:

            album = Albums.objects.get(
                album_id=mapping.internal_id
            )

            album.artist = artist
            album.title = item["title"]

            album.release_date = item.get(
                "release_date"
            )

            album.catalog_number = item.get(
                "catalog_number"
            )

            album.save()

            mark_mapping_synced(mapping)

            status = "UPDATED"

        else:

            album = Albums.objects.create(
                artist=artist,
                title=item["title"],
                release_date=item.get(
                    "release_date"
                ),
                catalog_number=item.get(
                    "catalog_number"
                ),
            )

            album.refresh_from_db()

            ExternalRecords.objects.create(
                system=system,
                entity_type="ALBUM",
                internal_id=album.album_id,
                external_id=source_id,
                last_synced_at=timezone.now(),
                sync_status=(
                    ExternalRecords
                    .SyncStatus
                    .SUCCESS
                ),
            )

            status = "CREATED"

        results.append({
            "source_id": source_id,
            "external_id": album.external_id,
            "status": status,
        })

    return results


# ============================================================
# MANUFACTURERS
# ============================================================


@transaction.atomic
def import_manufacturers(
    system_name,
    items,
):

    system = get_external_system(system_name)

    results = []

    for item in items:

        source_id = item["source_id"]

        mapping = get_external_mapping(
            system,
            "MANUFACTURER",
            source_id,
        )

        if mapping:

            manufacturer = (
                Manufacturers.objects.get(
                    manufacturer_id=(
                        mapping.internal_id
                    )
                )
            )

            manufacturer.manufacturer_type = (
                item.get(
                    "manufacturer_type"
                )
            )

            manufacturer.website = item.get(
                "website"
            )

            manufacturer.save()

            manufacturer.party.name = (
                item["name"]
            )

            manufacturer.party.save(
                update_fields=("name",)
            )

            mark_mapping_synced(mapping)

            status = "UPDATED"

        else:

            party = Parties.objects.create(
                party_type=(
                    Parties
                    .PartyType
                    .MANUFACTURER
                ),
                name=item["name"],
            )

            party.refresh_from_db()

            manufacturer = (
                Manufacturers.objects.create(
                    party=party,
                    manufacturer_type=item.get(
                        "manufacturer_type"
                    ),
                    website=item.get(
                        "website"
                    ),
                )
            )

            manufacturer.refresh_from_db()

            ExternalRecords.objects.create(
                system=system,
                entity_type="MANUFACTURER",
                internal_id=(
                    manufacturer.manufacturer_id
                ),
                external_id=source_id,
                last_synced_at=timezone.now(),
                sync_status=(
                    ExternalRecords
                    .SyncStatus
                    .SUCCESS
                ),
            )

            status = "CREATED"

        results.append({
            "source_id": source_id,
            "external_id": (
                manufacturer.external_id
            ),
            "status": status,
        })

    return results


# ============================================================
# PRODUCTS
# ============================================================


@transaction.atomic
def import_products(system_name, items):

    system = get_external_system(system_name)

    results = []

    for item in items:

        manufacturer_mapping = (
            get_external_mapping(
                system,
                "MANUFACTURER",
                item[
                    "manufacturer_source_id"
                ],
            )
        )

        if manufacturer_mapping is None:

            raise serializers.ValidationError({
                "manufacturer_source_id": (
                    "Manufacturer has not been "
                    "imported for source ID "
                    f"{item['manufacturer_source_id']}."
                )
            })

        manufacturer = (
            Manufacturers.objects.get(
                manufacturer_id=(
                    manufacturer_mapping.internal_id
                )
            )
        )

        source_id = item["source_id"]

        mapping = get_external_mapping(
            system,
            "PRODUCT",
            source_id,
        )

        if mapping:

            product = Products.objects.get(
                product_id=mapping.internal_id
            )

            product.manufacturer = manufacturer

            product.product_name = (
                item["product_name"]
            )

            product.description = item.get(
                "description"
            )

            product.sku = item.get("sku")

            product.product_type = item.get(
                "product_type"
            )

            product.save()

            mark_mapping_synced(mapping)

            status = "UPDATED"

        else:

            product = Products.objects.create(
                manufacturer=manufacturer,
                product_name=(
                    item["product_name"]
                ),
                description=item.get(
                    "description"
                ),
                sku=item.get("sku"),
                product_type=item.get(
                    "product_type"
                ),
            )

            product.refresh_from_db()

            ExternalRecords.objects.create(
                system=system,
                entity_type="PRODUCT",
                internal_id=product.product_id,
                external_id=source_id,
                last_synced_at=timezone.now(),
                sync_status=(
                    ExternalRecords
                    .SyncStatus
                    .SUCCESS
                ),
            )

            status = "CREATED"

        results.append({
            "source_id": source_id,
            "external_id": product.external_id,
            "status": status,
        })

    return results
