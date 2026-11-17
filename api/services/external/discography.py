from django.conf import settings

from .base import ExternalApiClient


class DiscographyClient:

    def __init__(self):

        self.client = ExternalApiClient(
            settings.DISCOGRAPHY_BASE_URL
        )

    # --------------------------------------------------------
    # Artists
    # --------------------------------------------------------

    def get_artist_availability(
        self,
        start_date,
        end_date,
    ):

        return self.client.request(
            "GET",
            "/api/artists/availability",
            params={
                "start_date": start_date,
                "end_date": end_date,
            },
        )

    def get_artist_pricing(
        self,
        artist_id,
    ):

        return self.client.request(
            "GET",
            f"/api/artists/{artist_id}/pricing",
        )

    # --------------------------------------------------------
    # Event contracts
    # --------------------------------------------------------

    def create_event_proposal(
        self,
        *,
        artist_id,
        event_id,
        event_type_id,
        proposed_price,
        event_datetime,
        is_requested=False,
    ):

        return self.client.request(
            "POST",
            "/api/event/proposals",
            json={
                "id_artist": artist_id,
                "id_event": event_id,
                "id_event_type": event_type_id,
                "proposed_price": proposed_price,
                "event_datetime": event_datetime,
                "is_requested": is_requested,
            },
        )

    def get_event_contract(
        self,
        contract_id,
    ):

        # Despite the endpoint parameter being called
        # id_event, their API expects the contract ID.
        return self.client.request(
            "GET",
            f"/api/event/{contract_id}",
        )
