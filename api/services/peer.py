import requests

from django.conf import settings


PEER_REQUEST_HEADER = "X-Events-Peer-Request"


class PeerUnavailableError(Exception):
    pass


def is_peer_request(request):
    """
    Returns True when this request already came from the
    other Events server.

    This prevents:

        Server A -> Server B -> Server A -> ...
    """

    return (
        request.headers.get(
            PEER_REQUEST_HEADER
        )
        == "1"
    )


def get_from_peer(path):
    """
    Performs a GET against the other Events server.

    Returns:
        requests.Response | None

    None means no peer has been configured.
    """

    base_url = getattr(
        settings,
        "EVENTS_PEER_BASE_URL",
        "",
    ).rstrip("/")

    if not base_url:
        return None

    timeout = getattr(
        settings,
        "EVENTS_PEER_TIMEOUT_SECONDS",
        3,
    )

    url = f"{base_url}{path}"

    try:
        return requests.get(
            url,
            headers={
                PEER_REQUEST_HEADER: "1",
            },
            timeout=timeout,
        )

    except requests.RequestException as exc:
        raise PeerUnavailableError(
            "The peer Events server could not be reached."
        ) from exc
