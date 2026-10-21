from app.core.errors import ApiException
from app.repositories import manufacturing as repository
from app.services.contract_validation import validate_manufacturing_references


def list_contracts(manufacturer_id=None, status=None):
    return repository.list_contracts(
        manufacturer_id,
        status.value if status else None,
    )


def get_contract(contract_id: int):
    result = repository.get_contract(contract_id)

    if result is None:
        raise ApiException(404, "NOT_FOUND", "Manufacturing contract not found.")

    return result


def create_contract(body):
    validate_manufacturing_references(
        body.manufacturer_id,
        body.product_id,
    )

    status = body.status.value if body.status else "DRAFT"
    contract_id = repository.create_contract(body, status)

    return get_contract(contract_id)


def update_contract(contract_id: int, body):
    validate_manufacturing_references(
        body.manufacturer_id,
        body.product_id,
    )

    current = get_contract(contract_id)
    status = body.status.value if body.status else current["status"]

    updated = repository.update_contract(contract_id, body, status)
    if not updated:
        raise ApiException(404, "NOT_FOUND", "Manufacturing contract not found.")

    return get_contract(contract_id)


def delete_contract(contract_id: int):
    if not repository.delete_contract(contract_id):
        raise ApiException(404, "NOT_FOUND", "Manufacturing contract not found.")
