from django.urls import path

from api.views.internal.contracts import (
    ContractApproveView,
    ContractCancelView,
    ContractFinishView,
    ContractRejectView,
    ContractSubmitView,
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
]
