from django.shortcuts import get_object_or_404

from rest_framework import status
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from rest_framework.views import APIView

from core.models import (
    ManufacturingContracts,
)

from api.serializers.manufacturing import (
    ManufacturingContractWriteSerializer,
    build_manufacturing_response,
)

from api.services.peer_response import (
    get_peer_fallback_response,
)


def get_manufacturing_queryset():

    return (
        ManufacturingContracts.objects
        .select_related(
            "contract",
            "contract__event",
            "contract__site",
            "manufacturer",
            "manufacturer__party",
            "product",
        )
    )


def find_manufacturing_contract(
    external_id,
):

    return (
        get_manufacturing_queryset()
        .filter(
            contract__external_id=external_id
        )
        .first()
    )


def get_manufacturing_contract_or_404(
    external_id,
):

    return get_object_or_404(
        get_manufacturing_queryset(),
        contract__external_id=external_id,
    )


class ManufacturingContractCreateView(
    APIView
):

    permission_classes = [AllowAny]

    def post(self, request):

        serializer = (
            ManufacturingContractWriteSerializer(
                data=request.data
            )
        )

        serializer.is_valid(
            raise_exception=True
        )

        contract = serializer.save()

        contract = (
            get_manufacturing_contract_or_404(
                contract.contract.external_id
            )
        )

        return Response(
            build_manufacturing_response(
                contract
            ),
            status=status.HTTP_201_CREATED,
        )


class ManufacturingContractDetailView(
    APIView
):

    permission_classes = [AllowAny]

    def get(
        self,
        request,
        external_id,
    ):

        contract = (
            find_manufacturing_contract(
                external_id
            )
        )

        if contract is not None:

            return Response(
                build_manufacturing_response(
                    contract
                ),
                status=status.HTTP_200_OK,
            )

        return get_peer_fallback_response(
            request,
            (
                f"/api/contracts/"
                f"manufacturing/"
                f"{external_id}"
            ),
        )

    def put(
        self,
        request,
        external_id,
    ):

        # PUT remains strictly local.
        contract = (
            get_manufacturing_contract_or_404(
                external_id
            )
        )

        serializer = (
            ManufacturingContractWriteSerializer(
                contract,
                data=request.data,
            )
        )

        serializer.is_valid(
            raise_exception=True
        )

        serializer.save()

        contract = (
            get_manufacturing_contract_or_404(
                external_id
            )
        )

        return Response(
            build_manufacturing_response(
                contract
            ),
            status=status.HTTP_200_OK,
        )
