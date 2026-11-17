import requests

from django.conf import settings


class ExternalApiError(Exception):

    def __init__(
        self,
        message,
        status_code=None,
        data=None,
    ):
        super().__init__(message)

        self.status_code = status_code
        self.data = data


class ExternalApiClient:

    def __init__(self, base_url):

        self.base_url = base_url.rstrip("/")

        self.timeout = (
            settings.EXTERNAL_API_TIMEOUT_SECONDS
        )

    def request(
        self,
        method,
        path,
        *,
        params=None,
        json=None,
        headers=None,
    ):

        url = f"{self.base_url}{path}"

        try:

            response = requests.request(
                method=method,
                url=url,
                params=params,
                json=json,
                headers=headers,
                timeout=self.timeout,
            )

        except requests.RequestException as exc:

            raise ExternalApiError(
                "External service could not be reached."
            ) from exc

        try:
            data = response.json()

        except ValueError:
            data = None

        if not response.ok:

            raise ExternalApiError(
                "External service returned an error.",
                status_code=response.status_code,
                data=data,
            )

        return data
