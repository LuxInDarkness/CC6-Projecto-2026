import requests

from django.conf import settings

from core.models import (
    ApiSyncLog,
    ExternalSystems,
)

from api.services.external.audit import (
    finish_sync_failure,
    finish_sync_success,
    save_raw_data,
    start_sync,
)


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

    def __init__(
        self,
        *,
        system_name,
        fallback_base_url,
    ):

        self.system_name = system_name

        self.fallback_base_url = (
            fallback_base_url.rstrip("/")
            if fallback_base_url
            else ""
        )

        self.timeout = (
            settings
            .EXTERNAL_API_TIMEOUT_SECONDS
        )

    def _get_system(self):

        system = (
            ExternalSystems.objects
            .filter(
                name=self.system_name,
                status=(
                    ExternalSystems
                    .Status
                    .ACTIVE
                ),
            )
            .first()
        )

        return system

    def _get_base_url(
        self,
        system,
    ):

        if (
            system is not None
            and system.base_url
        ):

            return system.base_url.rstrip("/")

        return self.fallback_base_url

    def request(
        self,
        method,
        path,
        *,
        params=None,
        json=None,
        headers=None,
        entity_type="API_REQUEST",
        external_id=None,
    ):

        system = self._get_system()

        if system is None:

            raise ExternalApiError(
                (
                    f"External system "
                    f"'{self.system_name}' "
                    f"is not configured or active."
                )
            )

        base_url = self._get_base_url(
            system
        )

        if not base_url:

            raise ExternalApiError(
                (
                    f"No base URL configured for "
                    f"'{self.system_name}'."
                )
            )

        url = f"{base_url}{path}"

        method = method.upper()

        if method == "GET":
            sync_operation = (
                ApiSyncLog.Operation.IMPORT
            )

        elif method == "POST":
            sync_operation = (
                ApiSyncLog.Operation.CREATE
            )

        elif method in (
            "PUT",
            "PATCH",
        ):
            sync_operation = (
                ApiSyncLog.Operation.UPDATE
            )

        elif method == "DELETE":
            sync_operation = (
                ApiSyncLog.Operation.DELETE
            )

        else:
            sync_operation = (
                ApiSyncLog.Operation.IMPORT
            )

        sync_log = start_sync(
            system=system,
            entity_type=entity_type,
            operation=sync_operation,
        )

        # Preserve outgoing payload.
        if json is not None:

            save_raw_data(
                system=system,
                entity_type=entity_type,
                external_id=external_id,
                operation="EXPORT",
                payload=json,
            )

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

            finish_sync_failure(
                sync_log,
                exc,
            )

            raise ExternalApiError(
                "External service could not be reached."
            ) from exc

        try:
            data = response.json()

        except ValueError:
            data = None

        if data is not None:

            save_raw_data(
                system=system,
                entity_type=entity_type,
                external_id=external_id,
                operation="IMPORT",
                payload=data,
            )

        if not response.ok:

            finish_sync_failure(
                sync_log,
                (
                    f"HTTP "
                    f"{response.status_code}"
                ),
            )

            raise ExternalApiError(
                "External service returned an error.",
                status_code=(
                    response.status_code
                ),
                data=data,
            )

        records_processed = 1

        if (
            isinstance(data, dict)
            and isinstance(
                data.get("data"),
                dict,
            )
        ):

            nested = data["data"]

            if isinstance(
                nested.get("artists"),
                list,
            ):

                records_processed = len(
                    nested["artists"]
                )

        finish_sync_success(
            sync_log,
            records_processed=(
                records_processed
            ),
        )

        return data
