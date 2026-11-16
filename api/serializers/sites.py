from rest_framework import serializers

from core.models import Sites


class SiteSerializer(serializers.ModelSerializer):

    class Meta:
        model = Sites

        fields = (
            "external_id",
            "name",
            "description",
            "address",
            "city",
            "state",
            "country",
            "postal_code",
            "latitude",
            "longitude",
            "capacity",
            "site_type",
            "status",
        )

        read_only_fields = fields