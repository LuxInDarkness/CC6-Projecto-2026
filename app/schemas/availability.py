from datetime import date
from decimal import Decimal

from pydantic import BaseModel, Field


class AvailableDate(BaseModel):
    date: date
    price: Decimal = Field(ge=0)
    currency: str = Field(min_length=3, max_length=3)


class AvailableLocation(BaseModel):
    location_id: int
    location_name: str
    availability: list[AvailableDate]


class AvailabilityResponse(BaseModel):
    start_date: date
    end_date: date
    locations: list[AvailableLocation]
