from rest_framework import serializers

from core.models import (
    Contracts,
    EventBookings,
)


class InternalContractEventSerializer(
    serializers.Serializer
):

    external_id = serializers.CharField()

    name = serializers.CharField()


class InternalContractSiteSerializer(
    serializers.Serializer
):

    external_id = serializers.CharField()

    name = serializers.CharField()


class InternalBookingSerializer(
    serializers.ModelSerializer
):

    class Meta:

        model = EventBookings

        fields = (
            "external_id",
            "status",
            "start_date",
            "end_date",
            "agreed_price",
            "currency",
            "notes",
            "created_at",
            "updated_at",
        )


class InternalContractSerializer(
    serializers.ModelSerializer
):

    event = InternalContractEventSerializer(
        read_only=True,
    )

    site = InternalContractSiteSerializer(
        read_only=True,
    )

    booking = serializers.SerializerMethodField()

    class Meta:

        model = Contracts

        fields = (
            "external_id",
            "contract_type",
            "status",

            "event",
            "site",

            "start_date",
            "end_date",

            "contract_terms",

            "booking",

            "created_at",
            "updated_at",
        )

        read_only_fields = fields

    def get_booking(
        self,
        obj,
    ):

        booking = (
            EventBookings.objects
            .filter(
                contract=obj
            )
            .first()
        )

        if booking is None:
            return None

        return InternalBookingSerializer(
            booking
        ).data
