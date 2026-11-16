from rest_framework import generics
from rest_framework.permissions import AllowAny

from core.models import Events
from api.serializers.events import (
    EventCreateSerializer,
    EventDetailSerializer,
)


class EventCreateView(generics.CreateAPIView):

    queryset = Events.objects.all()

    serializer_class = EventCreateSerializer

    permission_classes = [AllowAny]

    def create(self, request, *args, **kwargs):

        serializer = self.get_serializer(
            data=request.data
        )

        serializer.is_valid(
            raise_exception=True
        )

        event = serializer.save()

        output = EventDetailSerializer(event)

        from rest_framework.response import Response
        from rest_framework import status

        return Response(
            output.data,
            status=status.HTTP_201_CREATED,
        )


class EventDetailView(generics.RetrieveAPIView):

    queryset = Events.objects.all()

    serializer_class = EventDetailSerializer

    permission_classes = [AllowAny]

    lookup_field = "external_id"

    lookup_url_kwarg = "external_id"
