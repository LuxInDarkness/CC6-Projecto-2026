from django.shortcuts import get_object_or_404

from rest_framework import status
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from rest_framework.views import APIView

from core.models import ManufacturingContracts

from api.serializers.manufacturing import (
    ManufacturingContractWriteSerializer,
    build_manufacturing_response,
)


def get_manufacturing_contract(
    external_id,
):

    queryset = (
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

    return get_object_or_404(
        queryset,
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

        contract = get_manufacturing_contract(
            contract.contract.external_id
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

        contract = get_manufacturing_contract(
            external_id
        )

        return Response(
            build_manufacturing_response(
                contract
            ),
            status=status.HTTP_200_OK,
        )

    def put(
        self,
        request,
        external_id,
    ):

        contract = get_manufacturing_contract(
            external_id
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

        contract = get_manufacturing_contract(
            external_id
        )

        return Response(
            build_manufacturing_response(
                contract
            ),
            status=status.HTTP_200_OK,
        )
