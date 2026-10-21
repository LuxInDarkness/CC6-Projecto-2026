from datetime import date
from typing import Optional

from app.db.connection import get_connection


def find_available_dates(
    start_date: date,
    end_date: date,
    site_id: Optional[int],
):
    sql = """
        SELECT
            sa.site_id AS location_id,
            s.name AS location_name,
            sa.date,
            sa.price,
            sa.currency
        FROM site_availability sa
        JOIN sites s
          ON s.site_id = sa.site_id
        WHERE sa.available = TRUE
          AND s.status = 'ACTIVE'
          AND sa.date BETWEEN %s AND %s
          AND NOT EXISTS (
              SELECT 1
              FROM event_bookings eb
              WHERE eb.site_id = sa.site_id
                AND eb.status IN ('HOLD', 'CONFIRMED')
                AND sa.date BETWEEN eb.start_date AND eb.end_date
          )
    """

    params = [start_date, end_date]

    if site_id is not None:
        sql += " AND sa.site_id = %s"
        params.append(site_id)

    sql += " ORDER BY sa.site_id, sa.date"

    with get_connection() as connection:
        cursor = connection.cursor(dictionary=True)
        try:
            cursor.execute(sql, tuple(params))
            return cursor.fetchall()
        finally:
            cursor.close()
