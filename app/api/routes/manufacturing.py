from typing import Optional

from fastapi import APIRouter, Query, Response, status

from app.schemas.common import ContractStatus
from app.schemas.manufacturing import (
    ManufacturingContractRequest,
    ManufacturingContractResponse,
)
from app.services import manufacturing as service


router = APIRouter(prefix="/contrato_manufactura", tags=["Manufacturing Contracts"])


@router.get("", response_model=list[ManufacturingContractResponse])
def list_contracts(
    manufacturer_id: Optional[int] = None,
    status_filter: Optional[ContractStatus] = Query(default=None, alias="status"),
):
    return service.list_contracts(manufacturer_id, status_filter)


@router.post(
    "",
    response_model=ManufacturingContractResponse,
    status_code=status.HTTP_201_CREATED,
)
def create_contract(body: ManufacturingContractRequest, response: Response):
    result = service.create_contract(body)
    response.headers["Location"] = f"/contrato_manufactura/{result['contract_id']}"
    return result


@router.get("/{contract_id}", response_model=ManufacturingContractResponse)
def get_contract(contract_id: int):
    return service.get_contract(contract_id)


@router.put("/{contract_id}", response_model=ManufacturingContractResponse)
def update_contract(contract_id: int, body: ManufacturingContractRequest):
    return service.update_contract(contract_id, body)


@router.delete("/{contract_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_contract(contract_id: int):
    service.delete_contract(contract_id)
    return Response(status_code=status.HTTP_204_NO_CONTENT)
