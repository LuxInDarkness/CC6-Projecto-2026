from rest_framework import generics
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from rest_framework.views import APIView

from core.models import Sites

from api.serializers.sites import (
    SiteSerializer,
)

from api.services.peer_response import (
    get_peer_fallback_response,
)


class SiteListView(
    generics.ListAPIView
):

    queryset = (
        Sites.objects
        .filter(
            status=Sites.Status.ACTIVE
        )
        .order_by("name")
    )

    serializer_class = SiteSerializer

    permission_classes = [AllowAny]


class SiteDetailView(APIView):

    permission_classes = [AllowAny]

    def get(
        self,
        request,
        external_id,
    ):

        site = (
            Sites.objects
            .filter(
                external_id=external_id,
                status=Sites.Status.ACTIVE,
            )
            .first()
        )

        # Local database wins.
        if site is not None:

            serializer = SiteSerializer(
                site
            )

            return Response(
                serializer.data
            )

        # Local miss -> peer.
        return get_peer_fallback_response(
            request,
            (
                f"/api/sites/"
                f"{external_id}"
            ),
        )