from django.db import (
    DatabaseError,
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
    Contracts,
    EventBookings,
    Events,
    ExternalRecords,
    ExternalSystems,
    Manufacturers,
    Products,
    Sites,
    ApiRawData,
    ApiSyncLog,
)

from api.serializers.internal.bookings import (
    InternalBookingSerializer,
)

from api.serializers.internal.contracts_crud import (
    InternalContractCrudSerializer,
)

from api.serializers.internal.external_systems import (
    InternalExternalRecordSerializer,
    InternalExternalSystemSerializer,
)

from api.serializers.internal.crud import (
    InternalAlbumSerializer,
    InternalArtistSerializer,
    InternalEventSerializer,
    InternalManufacturerSerializer,
    InternalProductSerializer,
    InternalSiteSerializer,
)

from api.serializers.internal.audit import (
    InternalRawDataSerializer,
    InternalSyncLogSerializer,
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

        except DatabaseError as exc:

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

        except DatabaseError as exc:

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

        except DatabaseError as exc:

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

        except DatabaseError as exc:

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


# ============================================================
# CONTRACTS
# ============================================================


class InternalContractViewSet(
    InternalCrudViewSet
):

    queryset = (
        Contracts.objects
        .select_related(
            "event",
            "site",
        )
        .all()
        .order_by(
            "-created_at",
        )
    )

    serializer_class = (
        InternalContractCrudSerializer
    )

    def destroy(
        self,
        request,
        *args,
        **kwargs,
    ):

        instance = self.get_object()

        if EventBookings.objects.filter(
            contract=instance
        ).exists():

            return Response(
                {
                    "detail": (
                        "A contract with an associated "
                        "booking cannot be deleted."
                    )
                },
                status=status.HTTP_409_CONFLICT,
            )

        return super().destroy(
            request,
            *args,
            **kwargs,
        )


# ============================================================
# BOOKINGS
# ============================================================


class InternalBookingViewSet(
    InternalCrudViewSet
):

    queryset = (
        EventBookings.objects
        .select_related(
            "contract",
        )
        .all()
        .order_by(
            "-start_date",
        )
    )

    serializer_class = (
        InternalBookingSerializer
    )

    def destroy(
        self,
        request,
        *args,
        **kwargs,
    ):

        instance = self.get_object()

        if instance.contract_id is not None:

            return Response(
                {
                    "detail": (
                        "Bookings generated from a "
                        "contract cannot be deleted "
                        "directly."
                    )
                },
                status=status.HTTP_409_CONFLICT,
            )

        return super().destroy(
            request,
            *args,
            **kwargs,
        )


# ============================================================
# EXTERNAL SYSTEMS
# ============================================================


class InternalExternalSystemViewSet(
    InternalCrudViewSet
):

    queryset = (
        ExternalSystems.objects
        .all()
        .order_by("name")
    )

    serializer_class = (
        InternalExternalSystemSerializer
    )

    # external_systems does not have one of our
    # generated public IDs.
    lookup_field = "system_id"

    lookup_url_kwarg = "system_id"


# ============================================================
# EXTERNAL RECORDS
# ============================================================


class InternalExternalRecordViewSet(
    InternalCrudViewSet
):

    queryset = (
        ExternalRecords.objects
        .select_related("system")
        .all()
        .order_by(
            "system__name",
            "entity_type",
            "external_id",
        )
    )

    serializer_class = (
        InternalExternalRecordSerializer
    )

    lookup_field = "external_record_id"

    lookup_url_kwarg = (
        "external_record_id"
    )


class InternalSyncLogViewSet(
    viewsets.ReadOnlyModelViewSet
):

    permission_classes = [
        IsAdminUser,
    ]

    queryset = (
        ApiSyncLog.objects
        .select_related("system")
        .all()
        .order_by("-started_at")
    )

    serializer_class = (
        InternalSyncLogSerializer
    )

    lookup_field = "sync_id"

    lookup_url_kwarg = "sync_id"


class InternalRawDataViewSet(
    viewsets.ReadOnlyModelViewSet
):

    permission_classes = [
        IsAdminUser,
    ]

    queryset = (
        ApiRawData.objects
        .select_related("system")
        .all()
        .order_by("-received_at")
    )

    serializer_class = (
        InternalRawDataSerializer
    )

    lookup_field = "raw_data_id"

    lookup_url_kwarg = "raw_data_id"
