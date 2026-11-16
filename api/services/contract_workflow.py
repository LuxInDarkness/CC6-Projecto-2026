from django.db import transaction

from core.models import (
    Contracts,
)


class ContractWorkflowError(Exception):
    pass


class InvalidContractTransition(
    ContractWorkflowError
):
    pass


class ContractApprovalError(
    ContractWorkflowError
):
    pass


ACTION_TARGET_STATUS = {
    "submit": Contracts.Status.PENDING,
    "approve": Contracts.Status.APPROVED,
    "reject": Contracts.Status.REJECTED,
    "cancel": Contracts.Status.CANCELLED,
    "finish": Contracts.Status.FINISHED,
}


ALLOWED_SOURCE_STATUSES = {

    "submit": {
        Contracts.Status.DRAFT,
    },

    "approve": {
        Contracts.Status.PENDING,
    },

    "reject": {
        Contracts.Status.PENDING,
    },

    "cancel": {
        Contracts.Status.DRAFT,
        Contracts.Status.PENDING,
        Contracts.Status.APPROVED,
    },

    "finish": {
        Contracts.Status.APPROVED,
    },
}


@transaction.atomic
def transition_contract(
    external_id,
    action,
):

    if action not in ACTION_TARGET_STATUS:
        raise InvalidContractTransition(
            f"Unknown contract action: {action}."
        )

    try:
        contract = (
            Contracts.objects
            .select_for_update()
            .select_related(
                "event",
                "site",
            )
            .get(
                external_id=external_id
            )
        )

    except Contracts.DoesNotExist:

        return None

    current_status = contract.status

    allowed_statuses = (
        ALLOWED_SOURCE_STATUSES[action]
    )

    if current_status not in allowed_statuses:

        allowed_text = ", ".join(
            sorted(allowed_statuses)
        )

        raise InvalidContractTransition(
            (
                f"Action '{action}' cannot be "
                f"performed while the contract "
                f"is in status '{current_status}'. "
                f"Allowed source status(es): "
                f"{allowed_text}."
            )
        )

    # --------------------------------------------------------
    # Approval-specific validation
    # --------------------------------------------------------

    if action == "approve":

        if (
            contract.start_date is None
            or contract.end_date is None
        ):
            raise ContractApprovalError(
                (
                    "The contract cannot be approved "
                    "without start_date and end_date."
                )
            )

        if contract.end_date < contract.start_date:
            raise ContractApprovalError(
                (
                    "The contract cannot be approved "
                    "because end_date is before "
                    "start_date."
                )
            )

    target_status = (
        ACTION_TARGET_STATUS[action]
    )

    contract.status = target_status

    # Saving this field is enough.
    #
    # The MySQL trigger then handles:
    #
    # APPROVED:
    #   create/update CONFIRMED booking
    #
    # REJECTED/CANCELLED:
    #   cancel booking
    #
    # FINISHED:
    #   complete booking

    contract.save(
        update_fields=(
            "status",
        )
    )

    contract.refresh_from_db()

    return contract
