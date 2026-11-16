from django.shortcuts import get_object_or_404

from rest_framework import status
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from rest_framework.views import APIView

from core.models import DiscographyContracts

from api.serializers.discography import (
    DiscographyContractWriteSerializer,
    build_discography_response,
)


def get_discography_contract(external_id):
    """
    Fetch a complete discography contract using the
    public contract external ID.
    """

    queryset = (
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

    return get_object_or_404(
        queryset,
        contract__external_id=external_id,
    )


class DiscographyContractCreateView(APIView):

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

        # Reload all relations so the response does not
        # generate unnecessary additional queries.
        contract = get_discography_contract(
            contract.contract.external_id
        )

        return Response(
            build_discography_response(
                contract
            ),
            status=status.HTTP_201_CREATED,
        )


class DiscographyContractDetailView(APIView):

    permission_classes = [AllowAny]

    def get(
        self,
        request,
        external_id,
    ):

        contract = get_discography_contract(
            external_id
        )

        return Response(
            build_discography_response(
                contract
            ),
            status=status.HTTP_200_OK,
        )

    def put(
        self,
        request,
        external_id,
    ):

        contract = get_discography_contract(
            external_id
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

        contract = serializer.save()

        contract = get_discography_contract(
            external_id
        )

        return Response(
            build_discography_response(
                contract
            ),
            status=status.HTTP_200_OK,
        )
