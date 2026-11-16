from rest_framework import serializers


class AvailabilityQuerySerializer(
    serializers.Serializer
):

    start_date = serializers.DateField()
    end_date = serializers.DateField()

    def validate(self, attrs):

        if (
            attrs["end_date"]
            < attrs["start_date"]
        ):
            raise serializers.ValidationError({
                "end_date": (
                    "end_date must be greater than or "
                    "equal to start_date."
                )
            })

        return attrs


class AvailabilityResultSerializer(
    serializers.Serializer
):

    site_external_id = serializers.CharField()

    location_name = serializers.CharField()

    date = serializers.DateField()

    price = serializers.DecimalField(
        max_digits=12,
        decimal_places=2,
    )

    currency = serializers.CharField(
        max_length=3,
    )
