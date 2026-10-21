from datetime import date
from typing import Optional

from fastapi import APIRouter

from app.schemas.availability import AvailabilityResponse
from app.services.availability import get_availability


router = APIRouter(tags=["Availability"])


@router.get("/disponible", response_model=AvailabilityResponse)
def available_locations(
    start_date: date,
    end_date: date,
    site_id: Optional[int] = None,
):
    return get_availability(start_date, end_date, site_id)
