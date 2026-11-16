from django.urls import path

from api.views.events import (
    EventCreateView,
    EventDetailView,
)

from api.views.sites import (
    SiteListView,
    SiteDetailView,
)

from api.views.discography import (
    DiscographyContractCreateView,
    DiscographyContractDetailView,
)

from api.views.manufacturing import (
    ManufacturingContractCreateView,
    ManufacturingContractDetailView,
)

from api.views.availability import (
    AvailabilityView,
)

from api.views.imports import (
    AlbumImportView,
    ArtistImportView,
    ManufacturerImportView,
    ProductImportView,
)


urlpatterns = [

    # Events
    path(
        "events",
        EventCreateView.as_view(),
        name="event-create",
    ),

    path(
        "events/<str:external_id>",
        EventDetailView.as_view(),
        name="event-detail",
    ),

    # Sites
    path(
        "sites",
        SiteListView.as_view(),
        name="site-list",
    ),

    path(
        "sites/<str:external_id>",
        SiteDetailView.as_view(),
        name="site-detail",
    ),

    # Discography contracts
    path(
        "contracts/discography",
        DiscographyContractCreateView.as_view(),
        name="discography-contract-create",
    ),

    path(
        "contracts/discography/<str:external_id>",
        DiscographyContractDetailView.as_view(),
        name="discography-contract-detail",
    ),

    # Manufacturing contracts
    path(
        "contracts/manufacturing",
        ManufacturingContractCreateView.as_view(),
        name="manufacturing-contract-create",
    ),

    path(
        "contracts/manufacturing/<str:external_id>",
        ManufacturingContractDetailView.as_view(),
        name="manufacturing-contract-detail",
    ),

    # Availability
    path(
        "availability",
        AvailabilityView.as_view(),
        name="availability",
    ),

    # Imports
    path(
        "import/artists",
        ArtistImportView.as_view(),
        name="import-artists",
    ),

    path(
        "import/albums",
        AlbumImportView.as_view(),
        name="import-albums",
    ),

    path(
        "import/manufacturers",
        ManufacturerImportView.as_view(),
        name="import-manufacturers",
    ),

    path(
        "import/products",
        ProductImportView.as_view(),
        name="import-products",
    ),
]