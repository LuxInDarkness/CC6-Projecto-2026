from django.db import (
    IntegrityError,
    transaction,
)

from rest_framework import (
    status,
    viewsets,
)

from rest_framework.permissions import (
    IsAdminUser,
)

from rest_framework.response import Response

from core.models import (
    Albums,
    Artists,
    Events,
    Manufacturers,
    Products,
    Sites,
)

from api.serializers.internal.crud import (
    InternalAlbumSerializer,
    InternalArtistSerializer,
    InternalEventSerializer,
    InternalManufacturerSerializer,
    InternalProductSerializer,
    InternalSiteSerializer,
)


class InternalCrudViewSet(
    viewsets.ModelViewSet
):

    permission_classes = [
        IsAdminUser,
    ]

    lookup_field = "external_id"

    lookup_url_kwarg = "external_id"

    def _conflict_response(
        self,
        exc,
    ):

        return Response(
            {
                "detail": (
                    "The operation conflicts with "
                    "existing database relationships "
                    "or constraints."
                ),
                "database_error": str(exc),
            },
            status=status.HTTP_409_CONFLICT,
        )

    def create(
        self,
        request,
        *args,
        **kwargs,
    ):

        try:
            with transaction.atomic():

                return super().create(
                    request,
                    *args,
                    **kwargs,
                )

        except IntegrityError as exc:

            return self._conflict_response(
                exc
            )

    def update(
        self,
        request,
        *args,
        **kwargs,
    ):

        try:
            with transaction.atomic():

                return super().update(
                    request,
                    *args,
                    **kwargs,
                )

        except IntegrityError as exc:

            return self._conflict_response(
                exc
            )

    def partial_update(
        self,
        request,
        *args,
        **kwargs,
    ):

        try:
            with transaction.atomic():

                return super().partial_update(
                    request,
                    *args,
                    **kwargs,
                )

        except IntegrityError as exc:

            return self._conflict_response(
                exc
            )

    def destroy(
        self,
        request,
        *args,
        **kwargs,
    ):

        instance = self.get_object()

        try:

            with transaction.atomic():

                self.perform_destroy(
                    instance
                )

        except IntegrityError as exc:

            return self._conflict_response(
                exc
            )

        return Response(
            status=status.HTTP_204_NO_CONTENT
        )


# ============================================================
# SITES
# ============================================================


class InternalSiteViewSet(
    InternalCrudViewSet
):

    queryset = (
        Sites.objects
        .all()
        .order_by("name")
    )

    serializer_class = (
        InternalSiteSerializer
    )


# ============================================================
# EVENTS
# ============================================================


class InternalEventViewSet(
    InternalCrudViewSet
):

    queryset = (
        Events.objects
        .all()
        .order_by(
            "-start_date",
            "name",
        )
    )

    serializer_class = (
        InternalEventSerializer
    )


# ============================================================
# ARTISTS
# ============================================================


class InternalArtistViewSet(
    InternalCrudViewSet
):

    queryset = (
        Artists.objects
        .select_related("party")
        .all()
        .order_by("stage_name")
    )

    serializer_class = (
        InternalArtistSerializer
    )

    def perform_destroy(
        self,
        instance,
    ):

        party = instance.party

        # Albums/contracts may cause this deletion
        # to fail with RESTRICT. The base ViewSet
        # will convert that to HTTP 409.
        instance.delete()

        # Artist deletion does not remove the parent
        # Party, so remove it after the artist.
        party.delete()


# ============================================================
# ALBUMS
# ============================================================


class InternalAlbumViewSet(
    InternalCrudViewSet
):

    queryset = (
        Albums.objects
        .select_related("artist")
        .all()
        .order_by(
            "artist__stage_name",
            "title",
        )
    )

    serializer_class = (
        InternalAlbumSerializer
    )


# ============================================================
# MANUFACTURERS
# ============================================================


class InternalManufacturerViewSet(
    InternalCrudViewSet
):

    queryset = (
        Manufacturers.objects
        .select_related("party")
        .all()
        .order_by("party__name")
    )

    serializer_class = (
        InternalManufacturerSerializer
    )

    def perform_destroy(
        self,
        instance,
    ):

        party = instance.party

        instance.delete()

        party.delete()


# ============================================================
# PRODUCTS
# ============================================================


class InternalProductViewSet(
    InternalCrudViewSet
):

    queryset = (
        Products.objects
        .select_related(
            "manufacturer",
            "manufacturer__party",
        )
        .all()
        .order_by(
            "manufacturer__party__name",
            "product_name",
        )
    )

    serializer_class = (
        InternalProductSerializer
    )
