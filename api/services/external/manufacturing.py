from django.conf import settings

from .base import ExternalApiClient


class ManufacturingClient:

    def __init__(self):

        self.client = ExternalApiClient(
            settings.MANUFACTURING_BASE_URL
        )

    def create_request(
        self,
        *,
        event_id,
        artist_id,
        contract_id,
        requested_delivery_date,
        products,
    ):

        return self.client.request(
            "POST",
            "/api/manufacture/requests/",
            json={
                "id_event": event_id,
                "id_artist": artist_id,
                "id_contract": contract_id,
                "requested_delivery_date": (
                    requested_delivery_date
                ),
                "products": products,
            },
        )

    def get_request(
        self,
        request_id,
        refresh=False,
    ):

        params = {
            "id_request": request_id,
        }

        if refresh:
            params["refresh"] = 1

        return self.client.request(
            "GET",
            "/api/manufacture/requests/",
            params=params,
        )
