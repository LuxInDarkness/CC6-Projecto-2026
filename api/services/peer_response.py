from rest_framework import status
from rest_framework.response import Response

from api.services.peer import (
    PeerUnavailableError,
    get_from_peer,
    is_peer_request,
)


def get_peer_fallback_response(
    request,
    path,
):
    """
    Attempts to retrieve a resource from the peer Events
    server after it was not found locally.

    Returns a DRF Response.
    """

    # This request already came from the peer.
    # Do not send it back.
    if is_peer_request(request):

        return Response(
            {
                "detail": "Not found."
            },
            status=status.HTTP_404_NOT_FOUND,
        )

    try:
        peer_response = get_from_peer(path)

    except PeerUnavailableError:

        return Response(
            {
                "detail": (
                    "Resource was not found locally and "
                    "the peer Events server is unavailable."
                )
            },
            status=(
                status.HTTP_503_SERVICE_UNAVAILABLE
            ),
        )

    # Peer fallback is disabled.
    if peer_response is None:

        return Response(
            {
                "detail": "Not found."
            },
            status=status.HTTP_404_NOT_FOUND,
        )

    # Peer found the resource.
    if peer_response.status_code == 200:

        try:
            data = peer_response.json()

        except ValueError:

            return Response(
                {
                    "detail": (
                        "Peer Events server returned "
                        "invalid JSON."
                    )
                },
                status=status.HTTP_502_BAD_GATEWAY,
            )

        return Response(
            data,
            status=status.HTTP_200_OK,
        )

    # Peer also doesn't have it.
    if peer_response.status_code == 404:

        return Response(
            {
                "detail": "Not found."
            },
            status=status.HTTP_404_NOT_FOUND,
        )

    # Anything else from peer is an upstream error.
    return Response(
        {
            "detail": (
                "Peer Events server returned an "
                "unexpected response."
            ),
            "peer_status": (
                peer_response.status_code
            ),
        },
        status=status.HTTP_502_BAD_GATEWAY,
    )
