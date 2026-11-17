from rest_framework import serializers


class ArtistAvailabilityQuerySerializer(
    serializers.Serializer
):

    start_date = serializers.DateField(
        input_formats=["%d-%m-%Y"],
    )

    end_date = serializers.DateField(
        input_formats=["%d-%m-%Y"],
    )

    def validate(self, attrs):

        start = attrs["start_date"]
        end = attrs["end_date"]

        if end < start:
            raise serializers.ValidationError(
                "end_date cannot be before start_date."
            )

        if (end - start).days > 13:
            raise serializers.ValidationError(
                "The requested range cannot exceed 14 days."
            )

        return attrs


class EventProposalSerializer(
    serializers.Serializer
):

    artist_id = serializers.CharField()

    event_id = serializers.CharField()

    event_type_id = serializers.IntegerField(
        min_value=1,
        max_value=3,
    )

    proposed_price = serializers.DecimalField(
        max_digits=14,
        decimal_places=2,
    )

    event_datetime = serializers.DateTimeField(
        input_formats=[
            "%d-%m-%Y %H:%M",
        ],
    )

    is_requested = serializers.BooleanField(
        required=False,
        default=False,
    )


class ManufacturingProductSerializer(
    serializers.Serializer
):

    product_type = serializers.ChoiceField(
        choices=(
            "VINYL",
            "CD",
            "CASSETTE",
            "SHIRT",
            "HOODIE",
            "CAP",
            "PIN",
            "POSTER",
            "STICKER",
        )
    )

    quantity = serializers.IntegerField(
        min_value=1,
    )


class ManufacturingRequestSerializer(
    serializers.Serializer
):

    event_id = serializers.CharField()

    artist_id = serializers.CharField()

    contract_id = serializers.CharField()

    requested_delivery_date = (
        serializers.DateField(
            input_formats=[
                "%d-%m-%Y",
            ]
        )
    )

    products = ManufacturingProductSerializer(
        many=True,
        allow_empty=False,
    )
