from typing import Optional

from app.db.connection import get_connection, transaction


def list_contracts(artist_id: Optional[int], status: Optional[str]):
    where = []
    params = []

    if artist_id is not None:
        where.append("artist_id = %s")
        params.append(artist_id)

    if status is not None:
        where.append("status = %s")
        params.append(status)

    sql = "SELECT * FROM v_discography_contract_details"
    if where:
        sql += " WHERE " + " AND ".join(where)
    sql += " ORDER BY contract_id"

    with get_connection() as connection:
        cursor = connection.cursor(dictionary=True)
        try:
            cursor.execute(sql, tuple(params))
            return cursor.fetchall()
        finally:
            cursor.close()


def get_contract(contract_id: int):
    with get_connection() as connection:
        cursor = connection.cursor(dictionary=True)
        try:
            cursor.execute(
                """
                SELECT *
                FROM v_discography_contract_details
                WHERE contract_id = %s
                """,
                (contract_id,),
            )
            return cursor.fetchone()
        finally:
            cursor.close()


def create_contract(body, status: str) -> int:
    with transaction() as connection:
        cursor = connection.cursor()
        try:
            cursor.execute(
                """
                INSERT INTO contracts (
                    contract_type, status, start_date, end_date, contract_terms
                )
                VALUES ('DISCOGRAPHY', %s, %s, %s, %s)
                """,
                (
                    status,
                    body.start_date,
                    body.end_date,
                    body.contract_terms,
                ),
            )
            contract_id = cursor.lastrowid

            cursor.execute(
                """
                INSERT INTO discography_contracts (
                    contract_id, artist_id, record_label_id, album_id, release_date
                )
                VALUES (%s, %s, %s, %s, %s)
                """,
                (
                    contract_id,
                    body.artist_id,
                    body.record_label_id,
                    body.album_id,
                    body.release_date,
                ),
            )

            return contract_id
        finally:
            cursor.close()


def update_contract(contract_id: int, body, status: str) -> bool:
    with transaction() as connection:
        cursor = connection.cursor()
        try:
            cursor.execute(
                """
                UPDATE contracts
                SET status = %s,
                    start_date = %s,
                    end_date = %s,
                    contract_terms = %s
                WHERE contract_id = %s
                  AND contract_type = 'DISCOGRAPHY'
                """,
                (
                    status,
                    body.start_date,
                    body.end_date,
                    body.contract_terms,
                    contract_id,
                ),
            )

            if cursor.rowcount == 0:
                return False

            cursor.execute(
                """
                UPDATE discography_contracts
                SET artist_id = %s,
                    record_label_id = %s,
                    album_id = %s,
                    release_date = %s
                WHERE contract_id = %s
                """,
                (
                    body.artist_id,
                    body.record_label_id,
                    body.album_id,
                    body.release_date,
                    contract_id,
                ),
            )
            return True
        finally:
            cursor.close()


def delete_contract(contract_id: int) -> bool:
    with transaction() as connection:
        cursor = connection.cursor()
        try:
            cursor.execute(
                """
                DELETE FROM contracts
                WHERE contract_id = %s
                  AND contract_type = 'DISCOGRAPHY'
                """,
                (contract_id,),
            )
            return cursor.rowcount > 0
        finally:
            cursor.close()
