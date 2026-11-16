from rest_framework import generics
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from rest_framework.views import APIView

from api.services.peer_response import (
    get_peer_fallback_response,
)

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


class EventDetailView(APIView):

    permission_classes = [AllowAny]

    def get(
        self,
        request,
        external_id,
    ):

        event = (
            Events.objects
            .filter(
                external_id=external_id
            )
            .first()
        )

        if event is not None:

            serializer = EventDetailSerializer(
                event
            )

            return Response(
                serializer.data
            )

        return get_peer_fallback_response(
            request,
            (
                f"/api/events/"
                f"{external_id}"
            ),
        )
