from typing import Optional

from fastapi import APIRouter, Query, Response, status

from app.schemas.common import ContractStatus
from app.schemas.discography import (
    DiscographyContractRequest,
    DiscographyContractResponse,
)
from app.services import discography as service


router = APIRouter(prefix="/contrato_discografia", tags=["Discography Contracts"])


@router.get("", response_model=list[DiscographyContractResponse])
def list_contracts(
    artist_id: Optional[int] = None,
    status_filter: Optional[ContractStatus] = Query(default=None, alias="status"),
):
    return service.list_contracts(artist_id, status_filter)


@router.post(
    "",
    response_model=DiscographyContractResponse,
    status_code=status.HTTP_201_CREATED,
)
def create_contract(body: DiscographyContractRequest, response: Response):
    result = service.create_contract(body)
    response.headers["Location"] = f"/contrato_discografia/{result['contract_id']}"
    return result


@router.get("/{contract_id}", response_model=DiscographyContractResponse)
def get_contract(contract_id: int):
    return service.get_contract(contract_id)


@router.put("/{contract_id}", response_model=DiscographyContractResponse)
def update_contract(contract_id: int, body: DiscographyContractRequest):
    return service.update_contract(contract_id, body)


@router.delete("/{contract_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_contract(contract_id: int):
    service.delete_contract(contract_id)
    return Response(status_code=status.HTTP_204_NO_CONTENT)
