from app.core.errors import ApiException
from app.db.connection import get_connection


def validate_discography_references(
    artist_id: int,
    album_id: int,
    record_label_id: int | None,
):
    with get_connection() as connection:
        cursor = connection.cursor(dictionary=True)
        try:
            cursor.execute(
                "SELECT artist_id FROM artists WHERE artist_id = %s",
                (artist_id,),
            )
            if cursor.fetchone() is None:
                raise ApiException(422, "INVALID_REFERENCE", "artist_id does not exist.")

            cursor.execute(
                "SELECT artist_id FROM albums WHERE album_id = %s",
                (album_id,),
            )
            album = cursor.fetchone()

            if album is None:
                raise ApiException(422, "INVALID_REFERENCE", "album_id does not exist.")

            if album["artist_id"] != artist_id:
                raise ApiException(
                    422,
                    "INVALID_REFERENCE",
                    "album_id does not belong to artist_id.",
                )

            if record_label_id is not None:
                cursor.execute(
                    """
                    SELECT record_label_id
                    FROM record_labels
                    WHERE record_label_id = %s
                    """,
                    (record_label_id,),
                )
                if cursor.fetchone() is None:
                    raise ApiException(
                        422,
                        "INVALID_REFERENCE",
                        "record_label_id does not exist.",
                    )
        finally:
            cursor.close()


def validate_manufacturing_references(
    manufacturer_id: int,
    product_id: int,
):
    with get_connection() as connection:
        cursor = connection.cursor(dictionary=True)
        try:
            cursor.execute(
                """
                SELECT manufacturer_id
                FROM manufacturers
                WHERE manufacturer_id = %s
                """,
                (manufacturer_id,),
            )
            if cursor.fetchone() is None:
                raise ApiException(
                    422,
                    "INVALID_REFERENCE",
                    "manufacturer_id does not exist.",
                )

            cursor.execute(
                """
                SELECT manufacturer_id
                FROM products
                WHERE product_id = %s
                """,
                (product_id,),
            )
            product = cursor.fetchone()

            if product is None:
                raise ApiException(
                    422,
                    "INVALID_REFERENCE",
                    "product_id does not exist.",
                )

            if product["manufacturer_id"] != manufacturer_id:
                raise ApiException(
                    422,
                    "INVALID_REFERENCE",
                    "product_id does not belong to manufacturer_id.",
                )
        finally:
            cursor.close()
