from rest_framework import status
from rest_framework.permissions import IsAdminUser
from rest_framework.response import Response
from rest_framework.views import APIView

from api.serializers.internal.integrations import (
    ArtistAvailabilityQuerySerializer,
    EventProposalSerializer,
    ManufacturingRequestSerializer,
)

from api.services.external.base import (
    ExternalApiError,
)

from api.services.external.discography import (
    DiscographyClient,
)

from api.services.external.manufacturing import (
    ManufacturingClient,
)


def external_error_response(exc):

    if exc.status_code is None:

        return Response(
            {
                "detail": str(exc),
            },
            status=status.HTTP_503_SERVICE_UNAVAILABLE,
        )

    return Response(
        {
            "detail": str(exc),
            "external_status": exc.status_code,
            "external_response": exc.data,
        },
        status=status.HTTP_502_BAD_GATEWAY,
    )


class DiscographyArtistAvailabilityView(
    APIView
):

    permission_classes = [IsAdminUser]

    def get(self, request):

        serializer = (
            ArtistAvailabilityQuerySerializer(
                data=request.query_params
            )
        )

        serializer.is_valid(
            raise_exception=True
        )

        start = serializer.validated_data[
            "start_date"
        ]

        end = serializer.validated_data[
            "end_date"
        ]

        try:

            result = (
                DiscographyClient()
                .get_artist_availability(
                    start.strftime("%d-%m-%Y"),
                    end.strftime("%d-%m-%Y"),
                )
            )

        except ExternalApiError as exc:
            return external_error_response(exc)

        return Response(result)


class DiscographyArtistPricingView(
    APIView
):

    permission_classes = [IsAdminUser]

    def get(
        self,
        request,
        artist_id,
    ):

        try:

            result = (
                DiscographyClient()
                .get_artist_pricing(
                    artist_id
                )
            )

        except ExternalApiError as exc:
            return external_error_response(exc)

        return Response(result)


class DiscographyEventProposalView(
    APIView
):

    permission_classes = [IsAdminUser]

    def post(self, request):

        serializer = EventProposalSerializer(
            data=request.data
        )

        serializer.is_valid(
            raise_exception=True
        )

        data = serializer.validated_data

        try:

            result = (
                DiscographyClient()
                .create_event_proposal(
                    artist_id=data[
                        "artist_id"
                    ],
                    event_id=data[
                        "event_id"
                    ],
                    event_type_id=data[
                        "event_type_id"
                    ],
                    proposed_price=float(
                        data["proposed_price"]
                    ),
                    event_datetime=(
                        data["event_datetime"]
                        .strftime(
                            "%d-%m-%Y %H:%M"
                        )
                    ),
                    is_requested=data[
                        "is_requested"
                    ],
                )
            )

        except ExternalApiError as exc:
            return external_error_response(exc)

        return Response(
            result,
            status=status.HTTP_201_CREATED,
        )


class DiscographyEventContractView(
    APIView
):

    permission_classes = [IsAdminUser]

    def get(
        self,
        request,
        contract_id,
    ):

        try:

            result = (
                DiscographyClient()
                .get_event_contract(
                    contract_id
                )
            )

        except ExternalApiError as exc:
            return external_error_response(exc)

        return Response(result)


class ManufacturingRequestCreateView(
    APIView
):

    permission_classes = [IsAdminUser]

    def post(self, request):

        serializer = (
            ManufacturingRequestSerializer(
                data=request.data
            )
        )

        serializer.is_valid(
            raise_exception=True
        )

        data = serializer.validated_data

        try:

            result = (
                ManufacturingClient()
                .create_request(
                    event_id=data["event_id"],
                    artist_id=data[
                        "artist_id"
                    ],
                    contract_id=data[
                        "contract_id"
                    ],
                    requested_delivery_date=(
                        data[
                            "requested_delivery_date"
                        ].strftime(
                            "%d-%m-%Y"
                        )
                    ),
                    products=data["products"],
                )
            )

        except ExternalApiError as exc:
            return external_error_response(exc)

        return Response(
            result,
            status=status.HTTP_201_CREATED,
        )


class ManufacturingRequestDetailView(
    APIView
):

    permission_classes = [IsAdminUser]

    def get(
        self,
        request,
        request_id,
    ):

        refresh = (
            request.query_params.get(
                "refresh"
            )
            == "1"
        )

        try:

            result = (
                ManufacturingClient()
                .get_request(
                    request_id,
                    refresh=refresh,
                )
            )

        except ExternalApiError as exc:
            return external_error_response(exc)

        return Response(result)
