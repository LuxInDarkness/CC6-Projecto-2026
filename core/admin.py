import json
from django.contrib import admin, messages
from django.db import DatabaseError

from core.models import (
    Albums,
    ApiRawData,
    ApiSyncLog,
    Artists,
    Contracts,
    DiscographyContracts,
    EventBookings,
    EventSites,
    Events,
    ExternalRecords,
    ExternalSystems,
    Manufacturers,
    ManufacturingContracts,
    Parties,
    Products,
    RecordLabels,
    Sites,
)

from core.models import (
    DiscographyContractAdminProxy,
    ManufacturingContractAdminProxy,
    ManufacturingIntegrationConsole,
    DiscographyIntegrationConsole,
)

from api.services.contract_workflow import (
    ContractApprovalError,
    InvalidContractTransition,
    transition_contract,
)

from django.template.response import (
    TemplateResponse,
)

from core.admin_forms import (
    ArtistAvailabilityAdminForm,
    ArtistPricingAdminForm,
    EventContractLookupAdminForm,
    EventProposalAdminForm,
    DiscographyContractAdminForm,
    ManufacturingContractAdminForm,
    ManufacturingLookupAdminForm,
    ManufacturingRequestAdminForm,
)

from api.services.external.base import (
    ExternalApiError,
)

from api.services.external.discography import (
    DiscographyClient,
)

from api.services.external.manufacturing import (
    ManufacturingClient,
)


# ============================================================
# ADMIN SITE
# ============================================================

admin.site.site_header = "Event Management Administration"
admin.site.site_title = "Event Management"
admin.site.index_title = "Event Management"


# ============================================================
# PARTIES
# ============================================================


@admin.register(Parties)
class PartiesAdmin(admin.ModelAdmin):

    list_display = (
        "external_id",
        "name",
        "party_type",
        "email",
        "phone",
    )

    list_filter = (
        "party_type",
    )

    search_fields = (
        "external_id",
        "name",
        "email",
    )

    readonly_fields = (
        "external_id",
        "created_at",
        "updated_at",
    )

    ordering = (
        "name",
    )


# ============================================================
# ARTISTS
# ============================================================


@admin.register(Artists)
class ArtistsAdmin(admin.ModelAdmin):

    list_display = (
        "external_id",
        "stage_name",
        "legal_name",
        "party_name",
        "country_code",
    )

    search_fields = (
        "external_id",
        "stage_name",
        "legal_name",
        "party__name",
    )

    list_filter = (
        "country_code",
    )

    autocomplete_fields = (
        "party",
    )

    readonly_fields = (
        "external_id",
        "created_at",
        "updated_at",
    )

    ordering = (
        "stage_name",
    )

    @admin.display(
        description="Party"
    )
    def party_name(self, obj):

        return obj.party.name


# ============================================================
# RECORD LABELS
# ============================================================


@admin.register(RecordLabels)
class RecordLabelsAdmin(admin.ModelAdmin):

    list_display = (
        "external_id",
        "party_name",
        "catalog_prefix",
        "website",
    )

    search_fields = (
        "external_id",
        "party__name",
        "catalog_prefix",
    )

    autocomplete_fields = (
        "party",
    )

    readonly_fields = (
        "external_id",
        "created_at",
        "updated_at",
    )

    @admin.display(
        description="Name"
    )
    def party_name(self, obj):

        return obj.party.name


# ============================================================
# MANUFACTURERS
# ============================================================


@admin.register(Manufacturers)
class ManufacturersAdmin(admin.ModelAdmin):

    list_display = (
        "external_id",
        "party_name",
        "manufacturer_type",
        "website",
    )

    search_fields = (
        "external_id",
        "party__name",
        "manufacturer_type",
    )

    list_filter = (
        "manufacturer_type",
    )

    autocomplete_fields = (
        "party",
    )

    readonly_fields = (
        "external_id",
        "created_at",
        "updated_at",
    )

    @admin.display(
        description="Name"
    )
    def party_name(self, obj):

        return obj.party.name


# ============================================================
# ALBUMS
# ============================================================


@admin.register(Albums)
class AlbumsAdmin(admin.ModelAdmin):

    list_display = (
        "external_id",
        "title",
        "artist",
        "release_date",
        "catalog_number",
    )

    search_fields = (
        "external_id",
        "title",
        "catalog_number",
        "artist__stage_name",
    )

    autocomplete_fields = (
        "artist",
    )

    readonly_fields = (
        "external_id",
        "created_at",
        "updated_at",
    )

    ordering = (
        "artist__stage_name",
        "title",
    )


# ============================================================
# PRODUCTS
# ============================================================


@admin.register(Products)
class ProductsAdmin(admin.ModelAdmin):

    list_display = (
        "external_id",
        "product_name",
        "manufacturer_name",
        "product_type",
        "sku",
    )

    search_fields = (
        "external_id",
        "product_name",
        "sku",
        "manufacturer__party__name",
    )

    list_filter = (
        "product_type",
    )

    autocomplete_fields = (
        "manufacturer",
    )

    readonly_fields = (
        "external_id",
        "created_at",
        "updated_at",
    )

    @admin.display(
        description="Manufacturer"
    )
    def manufacturer_name(self, obj):

        return obj.manufacturer.party.name


# ============================================================
# SITES
# ============================================================


@admin.register(Sites)
class SitesAdmin(admin.ModelAdmin):

    list_display = (
        "external_id",
        "name",
        "city",
        "country",
        "capacity",
        "site_type",
        "status",
    )

    list_filter = (
        "status",
        "country",
        "site_type",
    )

    search_fields = (
        "external_id",
        "name",
        "address",
        "city",
        "state",
        "country",
    )

    readonly_fields = (
        "external_id",
        "created_at",
        "updated_at",
    )

    ordering = (
        "name",
    )


# ============================================================
# EVENT / SITE INLINE
# ============================================================


class EventSitesInline(admin.TabularInline):

    model = EventSites

    extra = 0

    autocomplete_fields = (
        "site",
    )

    fields = (
        "site",
        "role",
    )


# ============================================================
# EVENTS
# ============================================================


@admin.register(Events)
class EventsAdmin(admin.ModelAdmin):

    list_display = (
        "external_id",
        "name",
        "event_type",
        "status",
        "start_date",
        "end_date",
    )

    list_filter = (
        "status",
        "event_type",
        "start_date",
    )

    search_fields = (
        "external_id",
        "name",
        "description",
        "event_type",
    )

    readonly_fields = (
        "external_id",
        "created_at",
        "updated_at",
    )

    inlines = (
        EventSitesInline,
    )

    ordering = (
        "-start_date",
    )


# ============================================================
# CONTRACT SUBTYPE INLINES
# ============================================================


class DiscographyContractInline(
    admin.StackedInline
):

    model = DiscographyContracts

    extra = 0

    max_num = 1

    autocomplete_fields = (
        "artist",
        "record_label",
        "album",
    )

    def has_add_permission(
        self,
        request,
        obj=None,
    ):

        if obj is None:
            return False

        return (
            obj.contract_type
            == Contracts.ContractType.DISCOGRAPHY
        )


class ManufacturingContractInline(
    admin.StackedInline
):

    model = ManufacturingContracts

    extra = 0

    max_num = 1

    autocomplete_fields = (
        "manufacturer",
        "product",
    )

    def has_add_permission(
        self,
        request,
        obj=None,
    ):

        if obj is None:
            return False

        return (
            obj.contract_type
            == Contracts.ContractType.MANUFACTURING
        )


# ============================================================
# CONTRACTS
# ============================================================


@admin.register(Contracts)
class ContractsAdmin(admin.ModelAdmin):

    list_display = (
        "external_id",
        "contract_type",
        "status",
        "event",
        "site",
        "start_date",
        "end_date",
    )

    list_filter = (
        "contract_type",
        "status",
        "start_date",
    )

    search_fields = (
        "external_id",
        "event__name",
        "event__external_id",
        "site__name",
        "site__external_id",
    )

    autocomplete_fields = (
        "event",
        "site",
    )

    readonly_fields = (
        "external_id",
        "status",
        "created_at",
        "updated_at",
    )

    inlines = (
        DiscographyContractInline,
        ManufacturingContractInline,
    )

    actions = (
        "submit_contracts",
        "approve_contracts",
        "reject_contracts",
        "cancel_contracts",
        "finish_contracts",
    )

    ordering = (
        "-created_at",
    )

    def get_inline_instances(
        self,
        request,
        obj=None,
    ):

        if obj is None:
            return []

        instances = []

        if (
            obj.contract_type
            == Contracts.ContractType.DISCOGRAPHY
        ):

            instances.append(
                DiscographyContractInline(
                    self.model,
                    self.admin_site,
                )
            )

        elif (
            obj.contract_type
            == Contracts.ContractType.MANUFACTURING
        ):

            instances.append(
                ManufacturingContractInline(
                    self.model,
                    self.admin_site,
                )
            )

        return instances

    def _run_transition(
        self,
        request,
        queryset,
        action,
    ):

        success_count = 0

        errors = []

        for contract in queryset:

            try:

                result = transition_contract(
                    external_id=(
                        contract.external_id
                    ),
                    action=action,
                )

                if result is not None:
                    success_count += 1

            except (
                InvalidContractTransition,
                ContractApprovalError,
                DatabaseError,
            ) as exc:

                errors.append(
                    (
                        f"{contract.external_id}: "
                        f"{exc}"
                    )
                )

        if success_count:

            self.message_user(
                request,
                (
                    f"{success_count} contract(s) "
                    f"successfully processed."
                ),
                level=messages.SUCCESS,
            )

        for error in errors:

            self.message_user(
                request,
                error,
                level=messages.ERROR,
            )

    @admin.action(
        description="Submit selected contracts"
    )
    def submit_contracts(
        self,
        request,
        queryset,
    ):

        self._run_transition(
            request,
            queryset,
            "submit",
        )

    @admin.action(
        description="Approve selected contracts"
    )
    def approve_contracts(
        self,
        request,
        queryset,
    ):

        self._run_transition(
            request,
            queryset,
            "approve",
        )

    @admin.action(
        description="Reject selected contracts"
    )
    def reject_contracts(
        self,
        request,
        queryset,
    ):

        self._run_transition(
            request,
            queryset,
            "reject",
        )

    @admin.action(
        description="Cancel selected contracts"
    )
    def cancel_contracts(
        self,
        request,
        queryset,
    ):

        self._run_transition(
            request,
            queryset,
            "cancel",
        )

    @admin.action(
        description="Finish selected contracts"
    )
    def finish_contracts(
        self,
        request,
        queryset,
    ):

        self._run_transition(
            request,
            queryset,
            "finish",
        )

    def has_add_permission(
        self,
        request,
    ):
        return False


# ============================================================
# BOOKINGS
# ============================================================


@admin.register(EventBookings)
class EventBookingsAdmin(admin.ModelAdmin):

    list_display = (
        "external_id",
        "event_name",
        "site_name",
        "status",
        "start_date",
        "end_date",
        "contract_external_id",
    )

    list_filter = (
        "status",
        "start_date",
    )

    search_fields = (
        "external_id",
        "contract__external_id",
    )

    readonly_fields = (
        "external_id",
        "contract",
        "created_at",
        "updated_at",
    )

    ordering = (
        "-start_date",
    )

    @admin.display(
        description="Event"
    )
    def event_name(self, obj):

        try:

            event = Events.objects.get(
                event_id=obj.event_id
            )

            return event.name

        except Events.DoesNotExist:

            return obj.event_id

    @admin.display(
        description="Site"
    )
    def site_name(self, obj):

        try:

            site = Sites.objects.get(
                site_id=obj.site_id
            )

            return site.name

        except Sites.DoesNotExist:

            return obj.site_id

    @admin.display(
        description="Contract"
    )
    def contract_external_id(
        self,
        obj,
    ):

        if obj.contract is None:
            return "-"

        return obj.contract.external_id

    def get_readonly_fields(
        self,
        request,
        obj=None,
    ):

        fields = list(
            self.readonly_fields
        )

        if (
            obj is not None
            and obj.contract_id is not None
        ):

            fields.extend([
                "event_id",
                "site_id",
                "status",
                "start_date",
                "end_date",
                "agreed_price",
                "currency",
                "notes",
            ])

        return fields

    def has_delete_permission(
        self,
        request,
        obj=None,
    ):

        if (
            obj is not None
            and obj.contract_id is not None
        ):
            return False

        return super().has_delete_permission(
            request,
            obj,
        )


# ============================================================
# EXTERNAL SYSTEMS
# ============================================================


@admin.register(ExternalSystems)
class ExternalSystemsAdmin(admin.ModelAdmin):

    list_display = (
        "system_id",
        "name",
        "system_type",
        "status",
        "base_url",
    )

    list_filter = (
        "status",
        "system_type",
    )

    search_fields = (
        "name",
        "system_type",
        "base_url",
    )

    readonly_fields = (
        "system_id",
        "created_at",
        "updated_at",
    )


# ============================================================
# EXTERNAL RECORDS
# ============================================================


@admin.register(ExternalRecords)
class ExternalRecordsAdmin(admin.ModelAdmin):

    list_display = (
        "external_record_id",
        "system",
        "entity_type",
        "external_id",
        "internal_id",
        "sync_status",
        "last_synced_at",
    )

    list_filter = (
        "system",
        "entity_type",
        "sync_status",
    )

    search_fields = (
        "external_id",
        "entity_type",
        "system__name",
    )

    autocomplete_fields = (
        "system",
    )

    readonly_fields = (
        "external_record_id",
    )

    ordering = (
        "system",
        "entity_type",
        "external_id",
    )


# ============================================================
# SYNC LOGS
# ============================================================


@admin.register(ApiSyncLog)
class ApiSyncLogAdmin(admin.ModelAdmin):

    list_display = (
        "sync_id",
        "system",
        "entity_type",
        "operation",
        "status",
        "started_at",
        "completed_at",
        "records_processed",
    )

    list_filter = (
        "system",
        "operation",
        "status",
        "entity_type",
    )

    search_fields = (
        "entity_type",
        "error_message",
        "system__name",
    )

    readonly_fields = (
        "sync_id",
        "system",
        "entity_type",
        "entity_id",
        "operation",
        "started_at",
        "completed_at",
        "status",
        "error_message",
        "records_processed",
    )

    ordering = (
        "-started_at",
    )

    def has_add_permission(
        self,
        request,
    ):

        return False

    def has_change_permission(
        self,
        request,
        obj=None,
    ):

        return True

    def has_delete_permission(
        self,
        request,
        obj=None,
    ):

        return False


# ============================================================
# RAW API DATA
# ============================================================


@admin.register(ApiRawData)
class ApiRawDataAdmin(admin.ModelAdmin):

    list_display = (
        "raw_data_id",
        "system",
        "entity_type",
        "external_id",
        "operation",
        "received_at",
    )

    list_filter = (
        "system",
        "entity_type",
        "operation",
    )

    search_fields = (
        "external_id",
        "entity_type",
        "system__name",
    )

    readonly_fields = (
        "raw_data_id",
        "system",
        "entity_type",
        "external_id",
        "operation",
        "pretty_payload",
        "received_at",
    )

    fields = (
        "raw_data_id",
        "system",
        "entity_type",
        "external_id",
        "operation",
        "pretty_payload",
        "received_at",
    )

    ordering = (
        "-received_at",
    )

    @admin.display(
        description="Payload"
    )
    def pretty_payload(self, obj):

        import json

        return json.dumps(
            obj.payload,
            indent=4,
            ensure_ascii=False,
        )

    def has_add_permission(
        self,
        request,
    ):

        return False

    def has_delete_permission(
        self,
        request,
        obj=None,
    ):

        return False


@admin.register(
    DiscographyContractAdminProxy
)
class DiscographyContractAdmin(
    admin.ModelAdmin
):

    form = DiscographyContractAdminForm

    list_display = (
        "external_id",
        "status",
        "event",
        "site",
        "start_date",
        "end_date",
    )

    list_filter = (
        "status",
        "start_date",
    )

    search_fields = (
        "external_id",
        "event__name",
        "site__name",
    )

    autocomplete_fields = (
        "event",
        "site",
    )

    readonly_fields = (
        "external_id",
        "contract_type",
        "status",
        "created_at",
        "updated_at",
    )

    fieldsets = (
        (
            "Contract",
            {
                "fields": (
                    "external_id",
                    "contract_type",
                    "status",
                )
            },
        ),
        (
            "Event",
            {
                "fields": (
                    "event",
                    "site",
                    "start_date",
                    "end_date",
                )
            },
        ),
        (
            "Discography",
            {
                "fields": (
                    "artist",
                    "album",
                    "record_label",
                    "release_date",
                )
            },
        ),
        (
            "Terms",
            {
                "fields": (
                    "contract_terms",
                )
            },
        ),
        (
            "Audit",
            {
                "fields": (
                    "created_at",
                    "updated_at",
                )
            },
        ),
    )

    def get_queryset(self, request):

        return (
            super()
            .get_queryset(request)
            .filter(
                contract_type=(
                    Contracts
                    .ContractType
                    .DISCOGRAPHY
                )
            )
        )

    def save_model(
        self,
        request,
        obj,
        form,
        change,
    ):

        if not change:

            obj.contract_type = (
                Contracts
                .ContractType
                .DISCOGRAPHY
            )

            obj.status = (
                Contracts.Status.DRAFT
            )

        super().save_model(
            request,
            obj,
            form,
            change,
        )

        obj.refresh_from_db()

    def save_related(
        self,
        request,
        form,
        formsets,
        change,
    ):

        super().save_related(
            request,
            form,
            formsets,
            change,
        )

        DiscographyContracts.objects.update_or_create(
            contract=form.instance,
            defaults={
                "artist": (
                    form.cleaned_data["artist"]
                ),
                "album": (
                    form.cleaned_data["album"]
                ),
                "record_label": (
                    form.cleaned_data[
                        "record_label"
                    ]
                ),
                "release_date": (
                    form.cleaned_data[
                        "release_date"
                    ]
                ),
            },
        )


@admin.register(
    ManufacturingContractAdminProxy
)
class ManufacturingContractAdmin(
    admin.ModelAdmin
):

    form = ManufacturingContractAdminForm

    list_display = (
        "external_id",
        "status",
        "event",
        "site",
        "start_date",
        "end_date",
    )

    list_filter = (
        "status",
        "start_date",
    )

    search_fields = (
        "external_id",
        "event__name",
        "site__name",
    )

    autocomplete_fields = (
        "event",
        "site",
    )

    readonly_fields = (
        "external_id",
        "contract_type",
        "status",
        "created_at",
        "updated_at",
    )

    fieldsets = (
        (
            "Contract",
            {
                "fields": (
                    "external_id",
                    "contract_type",
                    "status",
                )
            },
        ),
        (
            "Event",
            {
                "fields": (
                    "event",
                    "site",
                    "start_date",
                    "end_date",
                )
            },
        ),
        (
            "Manufacturing",
            {
                "fields": (
                    "manufacturer",
                    "product",
                    "release_date",
                )
            },
        ),
        (
            "Terms",
            {
                "fields": (
                    "contract_terms",
                )
            },
        ),
        (
            "Audit",
            {
                "fields": (
                    "created_at",
                    "updated_at",
                )
            },
        ),
    )

    def get_queryset(self, request):

        return (
            super()
            .get_queryset(request)
            .filter(
                contract_type=(
                    Contracts
                    .ContractType
                    .MANUFACTURING
                )
            )
        )

    def save_model(
        self,
        request,
        obj,
        form,
        change,
    ):

        if not change:

            obj.contract_type = (
                Contracts
                .ContractType
                .MANUFACTURING
            )

            obj.status = (
                Contracts.Status.DRAFT
            )

        super().save_model(
            request,
            obj,
            form,
            change,
        )

        obj.refresh_from_db()

    def save_related(
        self,
        request,
        form,
        formsets,
        change,
    ):

        super().save_related(
            request,
            form,
            formsets,
            change,
        )

        ManufacturingContracts.objects.update_or_create(
            contract=form.instance,
            defaults={
                "manufacturer": (
                    form.cleaned_data[
                        "manufacturer"
                    ]
                ),
                "product": (
                    form.cleaned_data["product"]
                ),
                "release_date": (
                    form.cleaned_data[
                        "release_date"
                    ]
                ),
            },
        )


@admin.register(
    DiscographyIntegrationConsole
)
class DiscographyIntegrationConsoleAdmin(
    admin.ModelAdmin
):

    change_list_template = (
        "admin/core/"
        "discography_console.html"
    )

    def has_add_permission(
        self,
        request,
    ):
        return False

    def has_change_permission(
        self,
        request,
        obj=None,
    ):
        return True

    def has_delete_permission(
        self,
        request,
        obj=None,
    ):
        return False

    def get_queryset(
        self,
        request,
    ):

        return (
            super()
            .get_queryset(request)
            .none()
        )

    def changelist_view(
        self,
        request,
        extra_context=None,
    ):

        availability_form = (
            ArtistAvailabilityAdminForm(
                prefix="availability"
            )
        )

        pricing_form = (
            ArtistPricingAdminForm(
                prefix="pricing"
            )
        )

        proposal_form = (
            EventProposalAdminForm(
                prefix="proposal"
            )
        )

        contract_form = (
            EventContractLookupAdminForm(
                prefix="contract"
            )
        )

        result = None
        error = None
        result_title = None

        if request.method == "POST":

            operation = request.POST.get(
                "operation"
            )

            try:

                if operation == "availability":

                    availability_form = (
                        ArtistAvailabilityAdminForm(
                            request.POST,
                            prefix="availability",
                        )
                    )

                    if availability_form.is_valid():

                        data = (
                            availability_form
                            .cleaned_data
                        )

                        result = (
                            DiscographyClient()
                            .get_artist_availability(
                                data[
                                    "start_date"
                                ].strftime(
                                    "%d-%m-%Y"
                                ),
                                data[
                                    "end_date"
                                ].strftime(
                                    "%d-%m-%Y"
                                ),
                            )
                        )

                        result_title = (
                            "Artist Availability"
                        )

                elif operation == "pricing":

                    pricing_form = (
                        ArtistPricingAdminForm(
                            request.POST,
                            prefix="pricing",
                        )
                    )

                    if pricing_form.is_valid():

                        result = (
                            DiscographyClient()
                            .get_artist_pricing(
                                pricing_form
                                .cleaned_data[
                                    "artist_id"
                                ]
                            )
                        )

                        result_title = (
                            "Artist Pricing"
                        )

                elif operation == "proposal":

                    proposal_form = (
                        EventProposalAdminForm(
                            request.POST,
                            prefix="proposal",
                        )
                    )

                    if proposal_form.is_valid():

                        data = (
                            proposal_form
                            .cleaned_data
                        )

                        result = (
                            DiscographyClient()
                            .create_event_proposal(
                                artist_id=(
                                    data[
                                        "artist_id"
                                    ]
                                ),
                                event_id=(
                                    data["event_id"]
                                ),
                                event_type_id=int(
                                    data[
                                        "event_type_id"
                                    ]
                                ),
                                proposed_price=float(
                                    data[
                                        "proposed_price"
                                    ]
                                ),
                                event_datetime=(
                                    data[
                                        "event_datetime"
                                    ].strftime(
                                        "%d-%m-%Y %H:%M"
                                    )
                                ),
                                is_requested=(
                                    data[
                                        "is_requested"
                                    ]
                                ),
                            )
                        )

                        result_title = (
                            "Event Proposal"
                        )

                elif operation == "contract":

                    contract_form = (
                        EventContractLookupAdminForm(
                            request.POST,
                            prefix="contract",
                        )
                    )

                    if contract_form.is_valid():

                        result = (
                            DiscographyClient()
                            .get_event_contract(
                                contract_form
                                .cleaned_data[
                                    "contract_id"
                                ]
                            )
                        )

                        result_title = (
                            "Event Contract"
                        )

            except ExternalApiError as exc:

                error = str(exc)

                if exc.data:
                    error += (
                        "\n\n"
                        + json.dumps(
                            exc.data,
                            indent=2,
                            ensure_ascii=False,
                        )
                    )

        context = {
            **self.admin_site.each_context(
                request
            ),
            "title": "Discography Console",
            "availability_form": (
                availability_form
            ),
            "pricing_form": pricing_form,
            "proposal_form": proposal_form,
            "contract_form": contract_form,
            "result": (
                json.dumps(
                    result,
                    indent=2,
                    ensure_ascii=False,
                )
                if result is not None
                else None
            ),
            "result_title": result_title,
            "error": error,
        }

        return TemplateResponse(
            request,
            self.change_list_template,
            context,
        )


@admin.register(
    ManufacturingIntegrationConsole
)
class ManufacturingIntegrationConsoleAdmin(
    admin.ModelAdmin
):

    change_list_template = (
        "admin/core/"
        "manufacturing_console.html"
    )

    def has_add_permission(
        self,
        request,
    ):
        return False

    def has_change_permission(
        self,
        request,
        obj=None,
    ):
        return True

    def has_delete_permission(
        self,
        request,
        obj=None,
    ):
        return False

    def get_queryset(
        self,
        request,
    ):

        return (
            super()
            .get_queryset(request)
            .none()
        )

    def changelist_view(
        self,
        request,
        extra_context=None,
    ):

        request_form = (
            ManufacturingRequestAdminForm(
                prefix="request"
            )
        )

        lookup_form = (
            ManufacturingLookupAdminForm(
                prefix="lookup"
            )
        )

        result = None
        error = None
        result_title = None

        if request.method == "POST":

            operation = request.POST.get(
                "operation"
            )

            try:

                if operation == "create":

                    request_form = (
                        ManufacturingRequestAdminForm(
                            request.POST,
                            prefix="request",
                        )
                    )

                    if request_form.is_valid():

                        data = (
                            request_form
                            .cleaned_data
                        )

                        result = (
                            ManufacturingClient()
                            .create_request(
                                event_id=(
                                    data["event_id"]
                                ),
                                artist_id=(
                                    data["artist_id"]
                                ),
                                contract_id=(
                                    data[
                                        "contract_id"
                                    ]
                                ),
                                requested_delivery_date=(
                                    data[
                                        "requested_delivery_date"
                                    ].strftime(
                                        "%d-%m-%Y"
                                    )
                                ),
                                products=(
                                    data["products"]
                                ),
                            )
                        )

                        result_title = (
                            "Manufacturing Request"
                        )

                elif operation == "lookup":

                    lookup_form = (
                        ManufacturingLookupAdminForm(
                            request.POST,
                            prefix="lookup",
                        )
                    )

                    if lookup_form.is_valid():

                        data = (
                            lookup_form
                            .cleaned_data
                        )

                        result = (
                            ManufacturingClient()
                            .get_request(
                                data[
                                    "request_id"
                                ],
                                refresh=data[
                                    "refresh"
                                ],
                            )
                        )

                        result_title = (
                            "Manufacturing Status"
                        )

            except ExternalApiError as exc:

                error = str(exc)

                if exc.data:

                    error += (
                        "\n\n"
                        + json.dumps(
                            exc.data,
                            indent=2,
                            ensure_ascii=False,
                        )
                    )

        context = {
            **self.admin_site.each_context(
                request
            ),
            "title": (
                "Manufacturing Console"
            ),
            "request_form": request_form,
            "lookup_form": lookup_form,
            "result": (
                json.dumps(
                    result,
                    indent=2,
                    ensure_ascii=False,
                )
                if result is not None
                else None
            ),
            "result_title": result_title,
            "error": error,
        }

        return TemplateResponse(
            request,
            self.change_list_template,
            context,
        )
