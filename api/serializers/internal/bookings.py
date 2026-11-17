from rest_framework import serializers

from core.models import (
    EventBookings,
    EventSites,
    Events,
    Sites,
)


class InternalBookingSerializer(
    serializers.ModelSerializer
):

    event_external_id = serializers.CharField(
        write_only=True,
        required=False,
    )

    site_external_id = serializers.CharField(
        write_only=True,
        required=False,
    )

    contract_external_id = (
        serializers.CharField(
            source="contract.external_id",
            read_only=True,
        )
    )

    class Meta:

        model = EventBookings

        fields = (
            "external_id",

            "event_external_id",
            "site_external_id",

            "status",

            "start_date",
            "end_date",

            "agreed_price",
            "currency",

            "contract_external_id",

            "notes",

            "created_at",
            "updated_at",
        )

        read_only_fields = (
            "external_id",
            "contract_external_id",
            "created_at",
            "updated_at",
        )

    def validate(
        self,
        attrs,
    ):

        instance = self.instance

        if (
            instance is not None
            and instance.contract_id is not None
        ):

            raise serializers.ValidationError(
                (
                    "Bookings generated from a "
                    "contract cannot be modified "
                    "directly."
                )
            )

        event = None
        site = None

        if "event_external_id" in attrs:

            try:

                event = Events.objects.get(
                    external_id=attrs[
                        "event_external_id"
                    ]
                )

            except Events.DoesNotExist:

                raise serializers.ValidationError({
                    "event_external_id": (
                        "Event not found."
                    )
                })

        elif instance is not None:

            event = Events.objects.get(
                event_id=instance.event_id
            )

        if "site_external_id" in attrs:

            try:

                site = Sites.objects.get(
                    external_id=attrs[
                        "site_external_id"
                    ]
                )

            except Sites.DoesNotExist:

                raise serializers.ValidationError({
                    "site_external_id": (
                        "Site not found."
                    )
                })

        elif instance is not None:

            site = Sites.objects.get(
                site_id=instance.site_id
            )

        if self.instance is None:

            if event is None:

                raise serializers.ValidationError({
                    "event_external_id": (
                        "This field is required."
                    )
                })

            if site is None:

                raise serializers.ValidationError({
                    "site_external_id": (
                        "This field is required."
                    )
                })

        if (
            event is not None
            and site is not None
            and not EventSites.objects.filter(
                event=event,
                site=site,
            ).exists()
        ):

            raise serializers.ValidationError({
                "site_external_id": (
                    "The site is not assigned "
                    "to the selected event."
                )
            })

        start_date = attrs.get(
            "start_date",
            (
                instance.start_date
                if instance is not None
                else None
            ),
        )

        end_date = attrs.get(
            "end_date",
            (
                instance.end_date
                if instance is not None
                else None
            ),
        )

        if (
            start_date is not None
            and end_date is not None
            and end_date < start_date
        ):

            raise serializers.ValidationError({
                "end_date": (
                    "end_date must be greater than "
                    "or equal to start_date."
                )
            })

        agreed_price = attrs.get(
            "agreed_price",
            (
                instance.agreed_price
                if instance is not None
                else None
            ),
        )

        currency = attrs.get(
            "currency",
            (
                instance.currency
                if instance is not None
                else None
            ),
        )

        if (
            agreed_price is not None
            and not currency
        ):

            raise serializers.ValidationError({
                "currency": (
                    "currency is required when "
                    "agreed_price is provided."
                )
            })

        attrs["_resolved_event"] = event
        attrs["_resolved_site"] = site

        return attrs

    def create(
        self,
        validated_data,
    ):

        event = validated_data.pop(
            "_resolved_event"
        )

        site = validated_data.pop(
            "_resolved_site"
        )

        validated_data.pop(
            "event_external_id",
            None,
        )

        validated_data.pop(
            "site_external_id",
            None,
        )

        booking = (
            EventBookings.objects.create(
                event_id=event.event_id,
                site_id=site.site_id,
                contract=None,
                **validated_data,
            )
        )

        booking.refresh_from_db()

        return booking

    def update(
        self,
        instance,
        validated_data,
    ):

        event = validated_data.pop(
            "_resolved_event",
            None,
        )

        site = validated_data.pop(
            "_resolved_site",
            None,
        )

        validated_data.pop(
            "event_external_id",
            None,
        )

        validated_data.pop(
            "site_external_id",
            None,
        )

        if event is not None:
            instance.event_id = event.event_id

        if site is not None:
            instance.site_id = site.site_id

        for field, value in (
            validated_data.items()
        ):

            setattr(
                instance,
                field,
                value,
            )

        instance.save()

        return instance

    def to_representation(
        self,
        instance,
    ):

        data = super().to_representation(
            instance
        )

        event = Events.objects.get(
            event_id=instance.event_id
        )

        site = Sites.objects.get(
            site_id=instance.site_id
        )

        data["event_external_id"] = (
            event.external_id
        )

        data["event_name"] = event.name

        data["site_external_id"] = (
            site.external_id
        )

        data["site_name"] = site.name

        return data
