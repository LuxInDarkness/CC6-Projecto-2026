from datetime import date, datetime
from typing import Optional

from pydantic import BaseModel, Field, model_validator

from app.schemas.common import ContractStatus


class ManufacturingContractRequest(BaseModel):
    manufacturer_id: int = Field(gt=0)
    product_id: int = Field(gt=0)
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


class ManufacturingContractResponse(BaseModel):
    contract_id: int
    manufacturer_id: int
    manufacturer_name: str
    product_id: int
    product_title: str
    release_date: date
    contract_terms: str
    status: ContractStatus
    start_date: Optional[date] = None
    end_date: Optional[date] = None
    created_at: datetime
    updated_at: datetime
