from django.shortcuts import get_object_or_404

from rest_framework import status
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from rest_framework.views import APIView

from core.models import (
    DiscographyContracts,
)

from api.serializers.discography import (
    DiscographyContractWriteSerializer,
    build_discography_response,
)

from api.services.peer_response import (
    get_peer_fallback_response,
)


def get_discography_queryset():

    return (
        DiscographyContracts.objects
        .select_related(
            "contract",
            "contract__event",
            "contract__site",
            "artist",
            "album",
            "record_label",
            "record_label__party",
        )
    )


def find_discography_contract(
    external_id,
):

    return (
        get_discography_queryset()
        .filter(
            contract__external_id=external_id
        )
        .first()
    )


def get_discography_contract_or_404(
    external_id,
):

    return get_object_or_404(
        get_discography_queryset(),
        contract__external_id=external_id,
    )


class DiscographyContractCreateView(
    APIView
):

    permission_classes = [AllowAny]

    def post(self, request):

        serializer = (
            DiscographyContractWriteSerializer(
                data=request.data
            )
        )

        serializer.is_valid(
            raise_exception=True
        )

        contract = serializer.save()

        contract = (
            get_discography_contract_or_404(
                contract.contract.external_id
            )
        )

        return Response(
            build_discography_response(
                contract
            ),
            status=status.HTTP_201_CREATED,
        )


class DiscographyContractDetailView(
    APIView
):

    permission_classes = [AllowAny]

    def get(
        self,
        request,
        external_id,
    ):

        # For GET we do NOT use get_object_or_404.
        contract = find_discography_contract(
            external_id
        )

        if contract is not None:

            return Response(
                build_discography_response(
                    contract
                ),
                status=status.HTTP_200_OK,
            )

        return get_peer_fallback_response(
            request,
            (
                f"/api/contracts/"
                f"discography/"
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
            get_discography_contract_or_404(
                external_id
            )
        )

        serializer = (
            DiscographyContractWriteSerializer(
                contract,
                data=request.data,
            )
        )

        serializer.is_valid(
            raise_exception=True
        )

        serializer.save()

        contract = (
            get_discography_contract_or_404(
                external_id
            )
        )

        return Response(
            build_discography_response(
                contract
            ),
            status=status.HTTP_200_OK,
        )
