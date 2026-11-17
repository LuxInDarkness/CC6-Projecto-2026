import json

from django import forms

from core.models import (
    Albums,
    Artists,
    Contracts,
    DiscographyContractAdminProxy,
    DiscographyContracts,
    Events,
    EventSites,
    Manufacturers,
    ManufacturingContractAdminProxy,
    ManufacturingContracts,
    Products,
    RecordLabels,
)


# ============================================================
# CONTRACT FORMS
# ============================================================


class DiscographyContractAdminForm(
    forms.ModelForm
):

    artist = forms.ModelChoiceField(
        queryset=Artists.objects.all().order_by(
            "stage_name"
        ),
        required=True,
    )

    album = forms.ModelChoiceField(
        queryset=Albums.objects.all().order_by(
            "title"
        ),
        required=True,
    )

    record_label = forms.ModelChoiceField(
        queryset=(
            RecordLabels.objects
            .select_related("party")
            .all()
        ),
        required=False,
    )

    release_date = forms.DateField(
        required=True,
        widget=forms.DateInput(
            attrs={
                "type": "date",
            }
        ),
    )

    class Meta:
        model = DiscographyContractAdminProxy

        fields = (
            "event",
            "site",
            "start_date",
            "end_date",
            "contract_terms",
        )

        widgets = {
            "start_date": forms.DateInput(
                attrs={"type": "date"}
            ),
            "end_date": forms.DateInput(
                attrs={"type": "date"}
            ),
            "contract_terms": forms.Textarea(
                attrs={
                    "rows": 8,
                }
            ),
        }

    def __init__(
        self,
        *args,
        **kwargs,
    ):

        super().__init__(
            *args,
            **kwargs,
        )

        if (
            self.instance
            and self.instance.pk
        ):

            subtype = (
                DiscographyContracts.objects
                .filter(
                    contract=self.instance
                )
                .first()
            )

            if subtype:

                self.fields[
                    "artist"
                ].initial = subtype.artist

                self.fields[
                    "album"
                ].initial = subtype.album

                self.fields[
                    "record_label"
                ].initial = subtype.record_label

                self.fields[
                    "release_date"
                ].initial = subtype.release_date

    def clean(self):

        cleaned = super().clean()

        event = cleaned.get("event")
        site = cleaned.get("site")

        artist = cleaned.get("artist")
        album = cleaned.get("album")

        start = cleaned.get("start_date")
        end = cleaned.get("end_date")

        if (
            start
            and end
            and end < start
        ):

            self.add_error(
                "end_date",
                (
                    "End date must be greater "
                    "than or equal to start date."
                ),
            )

        if (
            event
            and site
            and not EventSites.objects.filter(
                event=event,
                site=site,
            ).exists()
        ):

            self.add_error(
                "site",
                (
                    "This site is not assigned "
                    "to the selected event."
                ),
            )

        if (
            artist
            and album
            and album.artist_id
            != artist.artist_id
        ):

            self.add_error(
                "album",
                (
                    "The selected album does not "
                    "belong to the selected artist."
                ),
            )

        return cleaned


class ManufacturingContractAdminForm(
    forms.ModelForm
):

    manufacturer = forms.ModelChoiceField(
        queryset=(
            Manufacturers.objects
            .select_related("party")
            .all()
        ),
        required=True,
    )

    product = forms.ModelChoiceField(
        queryset=Products.objects.all().order_by(
            "product_name"
        ),
        required=True,
    )

    release_date = forms.DateField(
        required=True,
        widget=forms.DateInput(
            attrs={
                "type": "date",
            }
        ),
    )

    class Meta:
        model = ManufacturingContractAdminProxy

        fields = (
            "event",
            "site",
            "start_date",
            "end_date",
            "contract_terms",
        )

        widgets = {
            "start_date": forms.DateInput(
                attrs={"type": "date"}
            ),
            "end_date": forms.DateInput(
                attrs={"type": "date"}
            ),
            "contract_terms": forms.Textarea(
                attrs={
                    "rows": 8,
                }
            ),
        }

    def __init__(
        self,
        *args,
        **kwargs,
    ):

        super().__init__(
            *args,
            **kwargs,
        )

        if (
            self.instance
            and self.instance.pk
        ):

            subtype = (
                ManufacturingContracts.objects
                .filter(
                    contract=self.instance
                )
                .first()
            )

            if subtype:

                self.fields[
                    "manufacturer"
                ].initial = (
                    subtype.manufacturer
                )

                self.fields[
                    "product"
                ].initial = subtype.product

                self.fields[
                    "release_date"
                ].initial = (
                    subtype.release_date
                )

    def clean(self):

        cleaned = super().clean()

        event = cleaned.get("event")
        site = cleaned.get("site")

        manufacturer = cleaned.get(
            "manufacturer"
        )

        product = cleaned.get(
            "product"
        )

        start = cleaned.get("start_date")
        end = cleaned.get("end_date")

        if (
            start
            and end
            and end < start
        ):

            self.add_error(
                "end_date",
                (
                    "End date must be greater "
                    "than or equal to start date."
                ),
            )

        if (
            event
            and site
            and not EventSites.objects.filter(
                event=event,
                site=site,
            ).exists()
        ):

            self.add_error(
                "site",
                (
                    "This site is not assigned "
                    "to the selected event."
                ),
            )

        if (
            manufacturer
            and product
            and product.manufacturer_id
            != manufacturer.manufacturer_id
        ):

            self.add_error(
                "product",
                (
                    "The selected product does not "
                    "belong to the selected "
                    "manufacturer."
                ),
            )

        return cleaned


# ============================================================
# DISCOGRAPHY INTEGRATION FORMS
# ============================================================


class ArtistAvailabilityAdminForm(
    forms.Form
):

    start_date = forms.DateField(
        widget=forms.DateInput(
            attrs={"type": "date"}
        )
    )

    end_date = forms.DateField(
        widget=forms.DateInput(
            attrs={"type": "date"}
        )
    )

    def clean(self):

        cleaned = super().clean()

        start = cleaned.get("start_date")
        end = cleaned.get("end_date")

        if start and end:

            if end < start:

                raise forms.ValidationError(
                    (
                        "End date cannot be "
                        "before start date."
                    )
                )

            if (end - start).days > 13:

                raise forms.ValidationError(
                    (
                        "The range cannot exceed "
                        "14 days."
                    )
                )

        return cleaned


class ArtistPricingAdminForm(
    forms.Form
):

    artist = forms.ModelChoiceField(
        queryset=(
            Artists.objects
            .all()
            .order_by("stage_name")
        ),
        label="Artist",
    )


class EventProposalAdminForm(
    forms.Form
):

    EVENT_TYPES = (
        (1, "Concert"),
        (2, "Private Event"),
        (3, "Festival"),
    )

    artist = forms.ModelChoiceField(
        queryset=(
            Artists.objects
            .all()
            .order_by("stage_name")
        ),
    )

    event = forms.ModelChoiceField(
        queryset=(
            Events.objects
            .all()
            .order_by("-start_date")
        ),
    )

    event_type_id = forms.ChoiceField(
        choices=EVENT_TYPES,
    )

    proposed_price = forms.DecimalField(
        min_value=0,
        max_digits=14,
        decimal_places=2,
    )

    event_datetime = forms.DateTimeField(
        widget=forms.DateTimeInput(
            attrs={
                "type": "datetime-local",
            }
        ),
        input_formats=[
            "%Y-%m-%dT%H:%M",
        ],
    )

    is_requested = forms.BooleanField(
        required=False,
    )


class EventContractLookupAdminForm(
    forms.Form
):

    contract_id = forms.CharField(
        label="Discography Contract ID",
        help_text="Example: KNGC-4",
        max_length=100,
    )


# ============================================================
# MANUFACTURING INTEGRATION FORMS
# ============================================================


class ManufacturingRequestAdminForm(
    forms.Form
):

    event = forms.ModelChoiceField(
        queryset=(
            Events.objects
            .all()
            .order_by("-start_date")
        ),
    )

    artist = forms.ModelChoiceField(
        queryset=(
            Artists.objects
            .all()
            .order_by("stage_name")
        ),
    )

    contract_id = forms.CharField(
        label="Discography Contract ID",
        help_text=(
            "Contract returned by Discography, "
            "for example KNGC-4."
        ),
        max_length=100,
    )

    requested_delivery_date = (
        forms.DateField(
            widget=forms.DateInput(
                attrs={
                    "type": "date",
                }
            )
        )
    )

    products = forms.JSONField(
        widget=forms.Textarea(
            attrs={
                "rows": 8,
                "cols": 70,
            }
        ),
        help_text=(
            'Example: '
            '[{"product_type":"VINYL",'
            '"quantity":200}]'
        ),
    )

    def clean_products(self):

        products = self.cleaned_data[
            "products"
        ]

        if not isinstance(products, list):

            raise forms.ValidationError(
                "Products must be a JSON array."
            )

        allowed = {
            "VINYL",
            "CD",
            "CASSETTE",
            "SHIRT",
            "HOODIE",
            "CAP",
            "PIN",
            "POSTER",
            "STICKER",
        }

        if not products:

            raise forms.ValidationError(
                "At least one product is required."
            )

        for item in products:

            if not isinstance(item, dict):

                raise forms.ValidationError(
                    "Every product must be a JSON object."
                )

            product_type = item.get(
                "product_type"
            )

            quantity = item.get(
                "quantity"
            )

            if product_type not in allowed:

                raise forms.ValidationError(
                    (
                        "Unsupported product type: "
                        f"{product_type}"
                    )
                )

            if (
                not isinstance(quantity, int)
                or quantity < 1
            ):

                raise forms.ValidationError(
                    (
                        "Every quantity must be "
                        "a positive integer."
                    )
                )

        return products


class ManufacturingLookupAdminForm(
    forms.Form
):

    request_id = forms.CharField(
        label="Manufacturing Request ID",
        help_text="Example: MREQ-0001",
        max_length=100,
    )

    refresh = forms.BooleanField(
        required=False,
        help_text=(
            "Ask Manufacturing to refresh "
            "known MAN-B1 order status."
        ),
    )
