from django.conf import settings

from .base import ExternalApiClient


class DiscographyClient:

    SYSTEM_NAME = "Discography Gateway"

    def __init__(self):

        self.client = ExternalApiClient(
            system_name=self.SYSTEM_NAME,
            fallback_base_url=(
                settings.DISCOGRAPHY_BASE_URL
            ),
        )

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
            entity_type="ARTIST_AVAILABILITY",
        )

    def get_artist_pricing(
        self,
        artist_id,
    ):

        return self.client.request(
            "GET",
            (
                f"/api/artists/"
                f"{artist_id}/pricing"
            ),
            entity_type="ARTIST_PRICING",
            external_id=artist_id,
        )

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
                "id_event_type": (
                    event_type_id
                ),
                "proposed_price": (
                    proposed_price
                ),
                "event_datetime": (
                    event_datetime
                ),
                "is_requested": (
                    is_requested
                ),
            },
            entity_type="EVENT_PROPOSAL",
            external_id=event_id,
        )

    def get_event_contract(
        self,
        contract_id,
    ):

        return self.client.request(
            "GET",
            f"/api/event/{contract_id}",
            entity_type=(
                "DISCOGRAPHY_EVENT_CONTRACT"
            ),
            external_id=contract_id,
        )
