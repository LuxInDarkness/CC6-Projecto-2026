from rest_framework import generics
from rest_framework.permissions import AllowAny

from core.models import Sites
from api.serializers.sites import SiteSerializer


class SiteListView(generics.ListAPIView):

    queryset = (
        Sites.objects
        .filter(status=Sites.Status.ACTIVE)
        .order_by("name")
    )

    serializer_class = SiteSerializer

    permission_classes = [AllowAny]


class SiteDetailView(
    generics.RetrieveAPIView
):

    queryset = Sites.objects.filter(
        status=Sites.Status.ACTIVE
    )

    serializer_class = SiteSerializer

    permission_classes = [AllowAny]

    lookup_field = "external_id"

    lookup_url_kwarg = "external_id"