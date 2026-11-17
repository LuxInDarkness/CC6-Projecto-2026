from core.models import (
    ExternalRecords,
    ExternalSystems,
)


class ExternalMappingError(Exception):
    pass


def get_external_mapping(
    *,
    system_name,
    entity_type,
    internal_id,
):

    try:
        system = ExternalSystems.objects.get(
            name=system_name,
            status=ExternalSystems.Status.ACTIVE,
        )

    except ExternalSystems.DoesNotExist:
        raise ExternalMappingError(
            f"External system '{system_name}' is not configured or active."
        )

    mapping = (
        ExternalRecords.objects
        .filter(
            system=system,
            entity_type=entity_type,
            internal_id=internal_id,
        )
        .first()
    )

    if mapping is None:
        raise ExternalMappingError(
            (
                f"No {entity_type} mapping exists in "
                f"'{system_name}' for internal ID {internal_id}."
            )
        )

    return mapping


def get_external_id(
    *,
    system_name,
    entity_type,
    internal_id,
):

    return get_external_mapping(
        system_name=system_name,
        entity_type=entity_type,
        internal_id=internal_id,
    ).external_id
