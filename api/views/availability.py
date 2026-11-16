from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from rest_framework.views import APIView

from core.models import SiteAvailableDates

from api.serializers.availability import (
    AvailabilityQuerySerializer,
    AvailabilityResultSerializer,
)


class AvailabilityView(APIView):

    permission_classes = [AllowAny]

    def get(self, request):

        query_serializer = (
            AvailabilityQuerySerializer(
                data=request.query_params
            )
        )

        query_serializer.is_valid(
            raise_exception=True
        )

        start_date = (
            query_serializer.validated_data[
                "start_date"
            ]
        )

        end_date = (
            query_serializer.validated_data[
                "end_date"
            ]
        )

        queryset = (
            SiteAvailableDates.objects
            .filter(
                date__range=(
                    start_date,
                    end_date,
                )
            )
            .order_by(
                "date",
                "location_name",
            )
        )

        serializer = (
            AvailabilityResultSerializer(
                queryset,
                many=True,
            )
        )

        return Response(serializer.data)
