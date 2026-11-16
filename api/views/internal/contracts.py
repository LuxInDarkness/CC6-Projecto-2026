from django.db import DatabaseError

from rest_framework import status
from rest_framework.permissions import IsAdminUser
from rest_framework.response import Response
from rest_framework.views import APIView

from api.serializers.internal.contracts import (
    InternalContractSerializer,
)

from api.services.contract_workflow import (
    ContractApprovalError,
    InvalidContractTransition,
    transition_contract,
)


class ContractActionView(APIView):

    permission_classes = [
        IsAdminUser,
    ]

    action = None

    def post(
        self,
        request,
        external_id,
    ):

        try:

            contract = transition_contract(
                external_id=external_id,
                action=self.action,
            )

        except InvalidContractTransition as exc:

            return Response(
                {
                    "detail": str(exc),
                },
                status=status.HTTP_409_CONFLICT,
            )

        except ContractApprovalError as exc:

            return Response(
                {
                    "detail": str(exc),
                },
                status=status.HTTP_400_BAD_REQUEST,
            )

        except DatabaseError as exc:

            # This can happen when the database rejects
            # approval because, for example, the booking
            # overlaps an existing HOLD/CONFIRMED booking.

            return Response(
                {
                    "detail": (
                        "The database rejected the "
                        "contract transition."
                    ),
                    "database_error": str(exc),
                },
                status=status.HTTP_409_CONFLICT,
            )

        if contract is None:

            return Response(
                {
                    "detail": "Contract not found."
                },
                status=status.HTTP_404_NOT_FOUND,
            )

        serializer = InternalContractSerializer(
            contract
        )

        return Response(
            serializer.data,
            status=status.HTTP_200_OK,
        )


class ContractSubmitView(
    ContractActionView
):
    action = "submit"


class ContractApproveView(
    ContractActionView
):
    action = "approve"


class ContractRejectView(
    ContractActionView
):
    action = "reject"


class ContractCancelView(
    ContractActionView
):
    action = "cancel"


class ContractFinishView(
    ContractActionView
):
    action = "finish"
