from rest_framework import status
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from rest_framework.views import APIView

from api.serializers.imports import (
    AlbumImportRequestSerializer,
    ArtistImportRequestSerializer,
    ManufacturerImportRequestSerializer,
    ProductImportRequestSerializer,
)

from api.services.imports import (
    import_albums,
    import_artists,
    import_manufacturers,
    import_products,
)


def build_response(
    system,
    entity_type,
    results,
):

    return {
        "system": system,
        "entity_type": entity_type,
        "processed": len(results),
        "items": results,
    }


class ArtistImportView(APIView):

    permission_classes = [AllowAny]

    def post(self, request):

        serializer = (
            ArtistImportRequestSerializer(
                data=request.data
            )
        )

        serializer.is_valid(
            raise_exception=True
        )

        system = (
            serializer.validated_data[
                "system"
            ]
        )

        results = import_artists(
            system,
            serializer.validated_data[
                "items"
            ],
        )

        return Response(
            build_response(
                system,
                "ARTIST",
                results,
            ),
            status=status.HTTP_200_OK,
        )


class AlbumImportView(APIView):

    permission_classes = [AllowAny]

    def post(self, request):

        serializer = (
            AlbumImportRequestSerializer(
                data=request.data
            )
        )

        serializer.is_valid(
            raise_exception=True
        )

        system = (
            serializer.validated_data[
                "system"
            ]
        )

        results = import_albums(
            system,
            serializer.validated_data[
                "items"
            ],
        )

        return Response(
            build_response(
                system,
                "ALBUM",
                results,
            ),
            status=status.HTTP_200_OK,
        )


class ManufacturerImportView(APIView):

    permission_classes = [AllowAny]

    def post(self, request):

        serializer = (
            ManufacturerImportRequestSerializer(
                data=request.data
            )
        )

        serializer.is_valid(
            raise_exception=True
        )

        system = (
            serializer.validated_data[
                "system"
            ]
        )

        results = import_manufacturers(
            system,
            serializer.validated_data[
                "items"
            ],
        )

        return Response(
            build_response(
                system,
                "MANUFACTURER",
                results,
            ),
            status=status.HTTP_200_OK,
        )


class ProductImportView(APIView):

    permission_classes = [AllowAny]

    def post(self, request):

        serializer = (
            ProductImportRequestSerializer(
                data=request.data
            )
        )

        serializer.is_valid(
            raise_exception=True
        )

        system = (
            serializer.validated_data[
                "system"
            ]
        )

        results = import_products(
            system,
            serializer.validated_data[
                "items"
            ],
        )

        return Response(
            build_response(
                system,
                "PRODUCT",
                results,
            ),
            status=status.HTTP_200_OK,
        )
