from datetime import date, datetime
from typing import Optional

from pydantic import BaseModel, Field, model_validator

from app.schemas.common import ContractStatus


class DiscographyContractRequest(BaseModel):
    artist_id: int = Field(gt=0)
    album_id: int = Field(gt=0)
    record_label_id: Optional[int] = Field(default=None, gt=0)
    release_date: date
    contract_terms: str = Field(min_length=1)
    status: Optional[ContractStatus] = None
    start_date: Optional[date] = None
    end_date: Optional[date] = None

    @model_validator(mode="after")
    def validate_dates(self):
        if (
            self.start_date is not None
            and self.end_date is not None
            and self.end_date < self.start_date
        ):
            raise ValueError("end_date must be greater than or equal to start_date")
        return self


class DiscographyContractResponse(BaseModel):
    contract_id: int
    artist_id: int
    artist_name: str
    album_id: int
    album_title: str
    record_label_id: Optional[int] = None
    record_label_name: Optional[str] = None
    release_date: date
    contract_terms: str
    status: ContractStatus
    start_date: Optional[date] = None
    end_date: Optional[date] = None
    created_at: datetime
    updated_at: datetime
