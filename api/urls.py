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


urlpatterns = [

    # ========================================================
    # EVENTS
    # ========================================================

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

    # ========================================================
    # SITES
    # ========================================================

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

    # ========================================================
    # DISCOGRAPHY CONTRACTS
    # ========================================================

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
]