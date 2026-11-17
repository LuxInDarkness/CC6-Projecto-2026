from django.urls import path
from rest_framework.routers import (
    DefaultRouter,
)

from api.views.internal.contracts import (
    ContractApproveView,
    ContractCancelView,
    ContractFinishView,
    ContractRejectView,
    ContractSubmitView,
)

from api.views.internal.integrations import (
    DiscographyArtistAvailabilityView,
    DiscographyArtistPricingView,
    DiscographyEventContractView,
    DiscographyEventProposalView,
    ManufacturingRequestCreateView,
    ManufacturingRequestDetailView,
)

from api.views.internal.crud import (
    InternalAlbumViewSet,
    InternalArtistViewSet,
    InternalBookingViewSet,
    InternalContractViewSet,
    InternalEventViewSet,
    InternalExternalRecordViewSet,
    InternalExternalSystemViewSet,
    InternalManufacturerViewSet,
    InternalProductViewSet,
    InternalSiteViewSet,
    InternalRawDataViewSet,
    InternalSyncLogViewSet,
)

router = DefaultRouter(
    trailing_slash=False
)


router.register(
    "sites",
    InternalSiteViewSet,
    basename="internal-sites",
)

router.register(
    "events",
    InternalEventViewSet,
    basename="internal-events",
)

router.register(
    "artists",
    InternalArtistViewSet,
    basename="internal-artists",
)

router.register(
    "albums",
    InternalAlbumViewSet,
    basename="internal-albums",
)

router.register(
    "manufacturers",
    InternalManufacturerViewSet,
    basename="internal-manufacturers",
)

router.register(
    "products",
    InternalProductViewSet,
    basename="internal-products",
)

router.register(
    "contracts",
    InternalContractViewSet,
    basename="internal-contracts",
)

router.register(
    "bookings",
    InternalBookingViewSet,
    basename="internal-bookings",
)

router.register(
    "external-systems",
    InternalExternalSystemViewSet,
    basename="internal-external-systems",
)

router.register(
    "external-records",
    InternalExternalRecordViewSet,
    basename="internal-external-records",
)

router.register(
    "sync-logs",
    InternalSyncLogViewSet,
    basename="internal-sync-logs",
)

router.register(
    "raw-data",
    InternalRawDataViewSet,
    basename="internal-raw-data",
)


urlpatterns = [

    path(
        "contracts/<str:external_id>/submit",
        ContractSubmitView.as_view(),
        name="internal-contract-submit",
    ),

    path(
        "contracts/<str:external_id>/approve",
        ContractApproveView.as_view(),
        name="internal-contract-approve",
    ),

    path(
        "contracts/<str:external_id>/reject",
        ContractRejectView.as_view(),
        name="internal-contract-reject",
    ),

    path(
        "contracts/<str:external_id>/cancel",
        ContractCancelView.as_view(),
        name="internal-contract-cancel",
    ),

    path(
        "contracts/<str:external_id>/finish",
        ContractFinishView.as_view(),
        name="internal-contract-finish",
    ),

    path(
        "integrations/discography/artists/availability",
        DiscographyArtistAvailabilityView.as_view(),
    ),

    path(
        "integrations/discography/artists/<str:artist_id>/pricing",
        DiscographyArtistPricingView.as_view(),
    ),

    path(
        "integrations/discography/event-proposals",
        DiscographyEventProposalView.as_view(),
    ),

    path(
        "integrations/discography/event-contracts/<str:contract_id>",
        DiscographyEventContractView.as_view(),
    ),

    path(
        "integrations/manufacturing/requests",
        ManufacturingRequestCreateView.as_view(),
    ),

    path(
        "integrations/manufacturing/requests/<str:request_id>",
        ManufacturingRequestDetailView.as_view(),
    ),
]

urlpatterns += router.urls
