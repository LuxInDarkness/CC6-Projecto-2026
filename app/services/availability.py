from datetime import date

from app.core.errors import ApiException
from app.repositories.availability import find_available_dates


def get_availability(start_date: date, end_date: date, site_id=None):
    if end_date < start_date:
        raise ApiException(
            400,
            "INVALID_DATE_RANGE",
            "end_date must be greater than or equal to start_date.",
        )

    if site_id is not None and site_id <= 0:
        raise ApiException(
            400,
            "INVALID_SITE_ID",
            "site_id must be greater than 0.",
        )

    rows = find_available_dates(start_date, end_date, site_id)

    locations = {}

    for row in rows:
        location_id = row["location_id"]

        if location_id not in locations:
            locations[location_id] = {
                "location_id": location_id,
                "location_name": row["location_name"],
                "availability": [],
            }

        locations[location_id]["availability"].append(
            {
                "date": row["date"],
                "price": row["price"],
                "currency": row["currency"],
            }
        )

    return {
        "start_date": start_date,
        "end_date": end_date,
        "locations": list(locations.values()),
    }
