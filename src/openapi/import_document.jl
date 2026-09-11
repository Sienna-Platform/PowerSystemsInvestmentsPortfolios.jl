# These will get encoded into each dictionary when a struct is serialized.
const METADATA_KEY = "__metadata__"
const TYPE_KEY = "type"
const MODULE_KEY = "module"
const PORTFOLIO_KWARGS = Set((
    :internal,
    :runchecks,
    :time_series_directory,
    :time_series_in_memory,
    :time_series_read_only,
    :timeseries_metadata_file,
    :name,
    :description,
))
# The type ordering both conversion directions share. References resolve by id, and
# `OpenAPIRefs` errors on an unregistered one, so a type must appear after everything it
# points at: requirements have no references, technologies point at the base system's
# topology (seeded into `refs` up front) and at requirements. Topology lives in the base
# `PSY.System`, not the portfolio's own component store, so it is not in this plan.
const DOCUMENT_PLAN = [
    (CarbonCaps, "CarbonCaps"),
    (CarbonTax, "CarbonTax"),
    (CapacityReserveMargin, "CapacityReserveMargin"),
    (EnergyShareRequirements, "EnergyShareRequirements"),
    (HourlyMatching, "HourlyMatching"),
    (MinimumCapacityRequirements, "MinimumCapacityRequirements"),
    (MaximumCapacityRequirements, "MaximumCapacityRequirements"),
    (SupplyTechnology, "SupplyTechnology"),
    (StorageTechnology, "StorageTechnology"),
    (ColocatedSupplyStorageTechnology, "ColocatedSupplyStorageTechnology"),
    (DemandRequirement, "DemandRequirement"),
    (DemandSideTechnology, "DemandSideTechnology"),
    (AggregateTransportTechnology, "AggregateTransportTechnology"),
    (NodalACTransportTechnology, "NodalACTransportTechnology"),
    (NodalHVDCTransportTechnology, "NodalHVDCTransportTechnology"),
]

const SUPPLEMENTAL_ATTRIBUTE_PLAN = [
    (RetirementPotential, "RetirementPotential"),
    (RetrofitPotential, "RetrofitPotential"),
    (ExistingDevices, "ExistingDevices"),
    (TopologyMapping, "TopologyMapping"),
]

"""
`DOCUMENT_PLAN`'s document-facing key must be unique — two entries sharing a key would make
[`_check_no_unconverted_component_types`](@ref)'s membership test and the dependency-ordered
component pass ambiguous about which converter owns that key. Checked with `allunique` before
being wrapped in a `Set` (rather than letting the `Set` construction silently collapse a
duplicate) so a future entry that copy-pastes an existing key errors, naming the offender,
instead of quietly losing one type's converter.
"""
function _document_plan_keys(plan)
    keys_in_order = [p[2] for p in plan]
    if !allunique(keys_in_order)
        duplicate = first(k for k in keys_in_order if count(==(k), keys_in_order) > 1)
        error(
            "DOCUMENT_PLAN: duplicate key \"$duplicate\" — every entry must have a unique " *
            "document-facing key",
        )
    end
    return Set(keys_in_order)
end

const DOCUMENT_PLAN_KEYS = _document_plan_keys(DOCUMENT_PLAN)

# A `oneOf` field holds its member wrapped only after deserialization; a document built in
# memory assigns the member directly. Unwrap by dispatch, the way `convert_cost` does
# (`cost_conversion.jl`), so both shapes read the same.
_unwrap_oneof(x::OpenAPI.OneOfAPIModel) = _unwrap_oneof(x.value)
_unwrap_oneof(x) = x

"""
Whether a component type can be written to an OpenAPI document.

`false` for everything by default, and `true` only for the types [`DOCUMENT_PLAN`](@ref) names —
the methods below are generated from that list, so adding a converter there is the single edit
that makes a type exportable.

A trait rather than a membership test against a list of types, so the check dispatches and stays
extensible: a package adding its own converter adds its own method.

Used by [`warn_unexportable_components`](@ref) on the export path. Dynamic components are the
main `false` case today (dynamics is deferred, so no dynamic type has a converter) and their loss
on export is accepted for now — but it is reported rather than silent.
"""
is_document_exportable(::Union{Technology, Requirement}) = false

for (psip_type, _key) in DOCUMENT_PLAN
    @eval is_document_exportable(::$psip_type) = true
end

"""
Error, naming every offending type, when the document declares a component type with
no registered `from_openapi` converter — psy6 forbids silently skipping unconverted
types.
"""
function _check_no_unconverted_component_types(components::AbstractDict)
    unconverted = sort([k for k in keys(components) if !(k in DOCUMENT_PLAN_KEYS)])
    isempty(unconverted) || error(
        "from_openapi(Portfolio, doc): document declares component type(s) with no " *
        "registered from_openapi converter: $(join(unconverted, ", ")) — every " *
        "component type present in the document must be converted, not skipped",
    )
    return nothing
end

"""
Seed an `OpenAPIRefs` with the base system's topology components (buses, areas, load zones,
arcs), keyed by their integer id. Technology reference fields (`region`, `start_node`,
`start_region`, ...) point at these `PSY` topology structs by id, so they must be resolvable
before any technology is converted in either direction.
"""
function _register_base_system_topology!(refs::OpenAPIRefs, base_system::PSY.System)
    for component in PSY.get_components(PSY.Topology, base_system)
        refs[IS.get_id(component)] = component
    end
    return refs
end

# `PI.<Name>` transport struct for each type the document can carry, keyed by the PSIP type
# that `__metadata__` resolves to. Parametric PSIP types key on their `UnionAll`, which is
# what `IS.get_type_from_serialization_metadata` returns now that `__metadata__` no longer
# carries `parameters`.
const _OPENAPI_WIRE_TYPES = Dict{Any, DataType}(
    psip_type => getproperty(PI, Symbol(key)) for
    (psip_type, key) in Iterators.flatten((DOCUMENT_PLAN, SUPPLEMENTAL_ATTRIBUTE_PLAN))
)

function _openapi_wire_type(psip_type)
    if !haskey(_OPENAPI_WIRE_TYPES, psip_type)
        error(
            "$psip_type has no OpenAPI wire type — every serialized PSIP type must " *
            "be declared in DOCUMENT_PLAN or SUPPLEMENTAL_ATTRIBUTE_PLAN " *
            "(src/openapi/document.jl)",
        )
    end
    return _OPENAPI_WIRE_TYPES[psip_type]
end

# ── attribute attach ────────────────────────────────────────────────────────────
# An adopted sidecar already carries every association row the document names, so those pairs
# only need attaching; a hand-built document (or one augmented with an attribute the sidecar
# never saw) carries none, so those pairs need writing. Which case a row falls in is read
# from `stored_pairs` rather than from a caller-supplied mode flag.

"""
Attach `attribute` to `component`, recording `group_indices` on whichever forward map the
attribute's type carries (a no-op for the plain attribute types, whose `group_indices` is
`nothing`). A plant-family attribute can carry several indices for one `(component, attribute)`
pair — a CT/CA feeding more than one HRSG group, for instance — so every index in
`group_indices` is pushed.

`stored_pairs` holds the `(component_id, attribute_id)` pairs the store already has; a pair
written here is added to it.
"""
function _attach_attribute!(
    portfolio::Portfolio,
    stored_pairs::Set{Tuple{Int, Int}},
    component,
    attribute,
    group_indices,
)
    pair = (IS.get_id(component), IS.get_id(attribute))
    if pair in stored_pairs
        IS.attach_supplemental_attribute!(
            portfolio.data,
            component,
            attribute;
            allow_existing_time_series=true,
        )
    else
        IS.add_supplemental_attribute!(portfolio.data, component, attribute)
        push!(stored_pairs, pair)
    end
    # No group indices in PSIP: `group_indices` is always empty/`nothing` (no plant-family
    # attribute types exist), so there is nothing to record here.
    return nothing
end

# ── requirements membership reconstruction ──────────────────────────────────────
# Requirement↔member membership is serialized only in the document-level
# `requirements_associations` table (the inline `requirements` field was dropped from the
# wire; see OPENAPI_SKIP_FIELDS). Rebuild each technology's in-memory `requirements` vector
# from that table, after the component pass has registered every technology and requirement
# in `refs`. Uses the typed `_resolve` (component family), never the ambiguous `getindex`.
"""
Rebuild in-memory `requirements` vectors from the document's `requirements_associations` table.

Runs after every technology and requirement is registered in `refs`. Errors loudly on a row
naming an unregistered id rather than silently dropping membership.
"""
function load_requirements_associations!(portfolio::Portfolio, refs::OpenAPIRefs, doc)
    members = Dict{Int, Vector{Requirement}}()
    for assoc in doc.requirements_associations
        entity_id = Int(assoc.entity_id)
        requirement_id = Int(assoc.requirement_id)
        has_ref(refs, entity_id) || error(
            "load_requirements_associations!: row references unresolved entity_id=" *
            "$entity_id (requirement_id=$requirement_id)",
        )
        has_ref(refs, requirement_id) || error(
            "load_requirements_associations!: row references unresolved requirement_id=" *
            "$requirement_id (entity_id=$entity_id)",
        )
        req = _resolve(refs, requirement_id, false)::Requirement
        push!(get!(members, entity_id, Requirement[]), req)
    end
    for (entity_id, reqs) in members
        set_requirements!(_resolve(refs, entity_id, false), reqs)
    end
    return nothing
end

function _merge_doc_ext!(component, extras::AbstractDict)
    ext = get_ext(component)
    for (k, v) in extras
        ext[k] = v
    end
    return nothing
end

# ── Document-level entry point ──────────────────────────────────────────────────

"""
Apply one optional document metadata field, dispatching on presence rather than
branching: a field the document omits leaves `System`'s own value untouched.
"""
_apply_metadata_field!(::Any, ::Portfolio, ::Nothing) = nothing
_apply_metadata_field!(setter, portfolio::Portfolio, value) = setter(portfolio, value)

"""
Carry the document's system-level metadata onto `sys`.

Only `name` and `description` are applied here (`base_power` is a `from_openapi` kwarg, not a
document field). `frequency` cannot be — `System` is immutable and takes it at construction —
so [`_portfolio_with_sidecar`](@ref) applies it there, via [`_frequency_kwarg`](@ref).

`supplied` is the set of keywords the caller passed, and a field named in it is left alone: a
caller who writes `name = ...` meant it, and overwriting that with the document's value would
discard it silently. This is the same precedence `frequency` already has, where the caller's
keyword is merged after the document's — the three document-owned keywords now agree instead
of splitting on which one happens to be applied after construction.
"""
function _apply_document_metadata!(
    portfolio::Portfolio,
    doc::PD.PortfolioDocument,
    supplied,
)
    :name in supplied || _apply_metadata_field!(set_name!, portfolio, PD.get_name(doc))
    :description in supplied ||
        _apply_metadata_field!(set_description!, portfolio, PD.get_description(doc))
    return nothing
end

"""
The `frequency = ...` keyword the document asks for, as a `NamedTuple` to splat into
`System`'s constructor — empty when the document names none.

`frequency` is an optional field of the document and a construction-time keyword of an
immutable `System`, so it can only be applied here, not assigned afterwards. Empty-when-absent
is what keeps the original guarantee intact: a document that predates the field cannot
silently reset a 50 Hz system to the 60 Hz default. A caller's own `frequency` in
`portfolio_kwargs` wins, since it is merged after this one.
"""
_frequency_kwarg(::Nothing) = (;)
_frequency_kwarg(value) = (; frequency=Float64(value))

"""
$(TYPEDSIGNATURES)

Build a `System` from a `PowerCoreOpenAPIModels.PortfolioDocument`.

Takes the typed container, not JSON: reading a file belongs to
`PowerCoreOpenAPIModels.read_document`, which [`from_file`](@ref) drives.

Converts every component in dependency order ([`DOCUMENT_PLAN`](@ref), verified against
dependency order), then runs [`resolve_deferred_refs!`](@ref) once to patch in any
component→component reference a converter deferred rather than resolve on that first pass (a
forward or same-type reference — e.g. a cascading `HydroReservoir` chain — see
[`OpenAPIRefs`](@ref)). It then attaches supplemental attributes from
`supplemental_attribute_associations`
(plus `plant_associations`/`combined_cycle_associations` for the plant-family ones) and
reserve membership from `service_associations`, and — when `time_series_storage_path` is
given — adopts the HDF5 sidecar as the System's own time series store.

What happens to `doc.time_series_associations` depends on what the sidecar brought. The
bundle [`to_file`](@ref) writes is arrays only, so its catalog arrives empty and the
document's rows *are* the catalog: they are replayed into it, ids included. A sidecar that
came with its own `.sqlite` is authoritative instead, and the rows are cross-checked against
it rather than written. See [`_load_time_series_associations!`](@ref).

Errors loudly (naming the offending type, id, or field) rather than silently skipping:
a component type with no registered converter, an unresolved attribute/plant/service
association or entity reference, or time-series owner reference, an unmapped time-series
type, scaling-factor multiplier, or supplemental `attribute_type` (see
[`load_supplemental_attribute_associations!`](@ref)), a document that declares time series
but supplies no `time_series_storage_path`, and any drift this validation catches.

`base_power` is the `System`'s own computational base (MVA); every component blob is
self-interpretable via its own `power_units`/`base_power`. It defaults to the same `100.0`
`System`'s own constructor defaults to.

A caller's `name`, `description` or `frequency` outranks the document's; every other
document field is applied unconditionally.

`portfolio_kwargs` pass straight through to the fresh `Portfolio(base_power; portfolio_kwargs...)`
this builds (e.g. `time_series_in_memory`, `time_series_directory`, `time_series_read_only`,
`runchecks` — `System`'s own `PORTFOLIO_KWARGS`); an unsupported key still errors, from
`System`'s own constructor.
"""
function from_openapi(
    ::Type{Portfolio},
    doc::PD.PortfolioDocument,
    document_path::AbstractString;
    base_power::Float64=100.0,
    time_series_storage_path=nothing,
    portfolio_kwargs...,
)
    _check_no_unconverted_component_types(doc.components)

    portfolio = _portfolio_with_sidecar(doc, time_series_storage_path; portfolio_kwargs...)
    _apply_document_metadata!(portfolio, doc, keys(portfolio_kwargs))

    system_path = _resolve_base_system(doc, dirname(document_path))
    system =
        isnothing(system_path) ? DEFAULT_SYSTEM() : PSY.from_file(PSY.System, system_path)
    set_base_system!(portfolio, system)

    schedule = _resolve_investment_schedule(doc)
    isnothing(schedule) || set_investment_schedule!(portfolio, schedule)

    isnothing(doc.financial_data) ||
        set_financial_data!(portfolio, convert_nested_data(doc.financial_data))

    store = if isnothing(time_series_storage_path)
        nothing
    else
        portfolio.data.time_series_manager.data_store
    end
    _load_time_series_associations!(portfolio, doc, store)
    refs = OpenAPIRefs()
    # Seed the base system's topology (buses/areas) into refs so technologies can resolve their
    # region references — the mirror of `_build_export_refs`'s topology registration on export.
    _register_base_system_topology!(refs, get_base_system(portfolio))

    _with_import_store(store) do
        for (psip_type, key) in DOCUMENT_PLAN
            for po in PD.get_components(doc, key)
                component = from_openapi(po, refs)
                extras = get(doc.ext, Int(po.id), nothing)
                isnothing(extras) || _merge_doc_ext!(component, extras)
                IS.set_id!(component, Int(po.id))
                add_component!(portfolio, component)
                refs[Int(po.id)] = component
            end
        end
        resolve_deferred_refs!(refs)
    end
    load_supplemental_attribute_associations!(portfolio, refs, doc)
    load_requirements_associations!(portfolio, refs, doc)
    return portfolio
end

add_component!(portfolio::Portfolio, component::Technology) =
    add_technology!(portfolio, component)
add_component!(portfolio::Portfolio, component::Requirement) =
    add_requirement!(portfolio, component)

function _resolve_investment_schedule(doc::PD.PortfolioDocument)
    results = PD.get_investment_schedule(doc)
    return isnothing(results) ? nothing : _deserialize_schedule(results)
end

function _resolve_base_system(doc::PD.PortfolioDocument, dir::AbstractString)
    named = PD.get_base_system_file(doc)          # accessor confirmed
    named === nothing && return nothing
    path = joinpath(dir, named)
    ispath(path) || throw(
        IS.DataFormatError(
            "the document names base_system_file=\"$named\" but $path does not exist",
        ),
    )
    return path
end

"""
Put the document's `time_series_associations` rows into `store`, or cross-check them against
the rows it already has.

Which one depends on what the bundle carried, not on which format wrote it — `from_openapi`
is public and does not know its producer. An arrays-only sidecar arrives with a freshly
minted, empty catalog, so the document's rows are replayed, ids included; that is what keeps
a cost's `association_id` resolving to the series it named. A sidecar that brought its own
`.sqlite` is authoritative instead and the rows are only validated against it — the path a
`.sn` archive, an older bundle, and a PowerSystemCaseBuilder cache all take.

Runs before the component pass, not after it: a `MarketBidTimeSeriesCost` or time-series
`FuelCurve` resolves its `association_id` against the store while its owner is being built,
so the rows have to be there first.
"""
_load_time_series_associations!(::Portfolio, ::PD.PortfolioDocument, ::Nothing) = nothing

function _load_time_series_associations!(
    portfolio::Portfolio,
    doc::PD.PortfolioDocument,
    store,
)
    isempty(doc.time_series_associations) && return nothing
    if _catalog_is_authoritative(store)
        return _validate_time_series_associations!(portfolio, doc)
    end
    IS.import_time_series_association_rows!(store, JSON.json(doc.time_series_associations))
    return nothing
end

"""
Whether the adopted store brought its own association rows, in which case they outrank the
document's. A count, not a listing: the answer is a yes/no and the catalog can be large.
"""
_catalog_is_authoritative(store) = !iszero(IS.get_num_time_series(store))

"""
A `System` whose time series store is the document's InfraStore sidecar, adopted rather than
replayed. Without a sidecar this is just `Portfolio(base_power; portfolio_kwargs...)`.

`doc` must be a `PowerCoreOpenAPIModels.PortfolioDocument`.

`time_series_read_only` and `time_series_directory` are read from `portfolio_kwargs` (and left in
place for `System` itself) because they govern how the store is opened: a read-only open
attaches the file directly, while a writable one takes a working copy so adding series cannot
corrupt the document's sidecar. The adopted store's `supplemental_attribute_associations` rows
are left as they are — `load_supplemental_attribute_associations!` reads them.
"""
function _portfolio_with_sidecar(
    doc::PD.PortfolioDocument,
    time_series_storage_path;
    portfolio_kwargs...,
)
    isnothing(time_series_storage_path) &&
        return Portfolio(_deserialize_type_name(doc.aggregation); portfolio_kwargs...)
    isfile(time_series_storage_path) || error(
        "from_openapi(System, doc): time_series_storage_path " *
        "\"$time_series_storage_path\" does not exist",
    )
    read_only = get(portfolio_kwargs, :time_series_read_only, false)
    directory = get(portfolio_kwargs, :time_series_directory, nothing)
    store = IS.open_deserialized_infrastore_store(
        String(time_series_storage_path),
        directory,
        read_only,
    )
    attribute_manager = IS.SupplementalAttributeManager(store)
    # Positional: IS's keyword `SystemData` constructor opens its own store and cannot adopt
    # one. `1` is `next_id`; every id in the document is set explicitly, and `assign_id!`
    # advances the counter past each one as components and attributes are adopted.
    data = IS.SystemData(
        IS.read_validation_descriptor(PORTFOLIO_STRUCT_DESCRIPTOR_FILE),
        IS.TimeSeriesManager(; data_store=store, read_only=read_only),
        1,
        Dict{String, Set{Int}}(),
        attribute_manager,
        IS.InfrastructureSystemsInternal(),
    )
    return Portfolio(data, _deserialize_type_name(doc.aggregation); portfolio_kwargs...)
end

"""
Cross-check the document's own `time_series_associations` rows against the adopted sidecar's
catalog. A no-op when there is no sidecar or the document names no rows.

The sidecar is authoritative, so this never writes: every document row must match a sidecar
row, identified by `(owner_id, owner_category, time_series_type, name, resolution, interval, features)` — the same identity tuple the store's own uniqueness index keys on (`owner_type`
is a denormalized label excluded from identity); a type that carries no `resolution`/
`interval` field at all (e.g. `NonSequentialTimeSeries`) treats it as `nothing`. A matched row
must then agree with its counterpart field-for-field — compared as canonical OpenAPI JSON,
excluding `uri`/`data_hash` (informational: a document assembled from a different store may
legitimately carry different values for either, so neither participates in identity or
drift). A document row with no sidecar counterpart, or one that drifts from its match, means
the bundle is corrupt and throws `IS.DataFormatError` naming the row and, for drift, the
differing fields. Sidecar rows the document does not mention are tolerated (`@debug`-logged)
— a document only ever names the owners it carries.
"""
function _validate_time_series_associations!(
    portfolio::Portfolio,
    doc::PD.PortfolioDocument,
)
    store_rows = [
        _unwrap_oneof(row) for
        row in IS.openapi_time_series_association_rows(portfolio.data)
    ]
    store_by_identity = Dict(_ts_row_identity(row) => row for row in store_rows)
    referenced = Set{keytype(store_by_identity)}()

    for assoc in doc.time_series_associations
        row = _unwrap_oneof(assoc)
        identity = _ts_row_identity(row)
        store_row = get(store_by_identity, identity, nothing)
        if isnothing(store_row)
            throw(
                IS.DataFormatError(
                    "from_openapi(Portfolio, doc): time series association " *
                    "$(_ts_row_label(identity)) has no matching row in the adopted " *
                    "sidecar's catalog",
                ),
            )
        end
        push!(referenced, identity)
        # Checked explicitly, ahead of the generic field-drift comparison below: a mismatched
        # `association_id` means every key built from it during this import points at the
        # wrong association altogether, not just a stale metadata field, so it gets its own
        # named error carrying both values rather than surfacing as one entry in a
        # `drifted on: ...` list. A `nothing` document value is not treated as "unset and
        # therefore skip" — the schema marks `association_id` required, so a document row
        # missing it is malformed and must error loudly rather than compare vacuously equal
        # to another `nothing`.
        isnothing(row.association_id) && throw(
            IS.DataFormatError(
                "from_openapi(Portfolio, doc): time series association " *
                "$(_ts_row_label(identity)) has no association_id in the document, but " *
                "the schema marks it required",
            ),
        )
        row.association_id == store_row.association_id || throw(
            IS.DataFormatError(
                "from_openapi(Portfolio, doc): time series association " *
                "$(_ts_row_label(identity)) has association_id=$(row.association_id) in " *
                "the document but association_id=$(store_row.association_id) in the " *
                "adopted sidecar's catalog",
            ),
        )
        drift = _ts_row_drift(row, store_row)
        isempty(drift) || throw(
            IS.DataFormatError(
                "from_openapi(Portfolio, doc): time series association " *
                "$(_ts_row_label(identity)) drifted from the sidecar's catalog on: " *
                "$(join(drift, ", "))",
            ),
        )
    end

    unmatched = setdiff(keys(store_by_identity), referenced)
    isempty(unmatched) ||
        @debug "from_openapi(Portfolio, doc): sidecar catalog rows the document does not mention" unmatched

    return nothing
end

"""
The wire field value of `field` on `row`, or `nothing` when `row`'s type does not carry
that field at all (e.g. `NonSequentialTimeSeries` has no `resolution`/`interval`) — as
opposed to carrying it unset, which is also `nothing`. Either way, absent and unset compare
equal for identity purposes.
"""
function _ts_field(row, field::Symbol)
    hasproperty(row, field) && return getproperty(row, field)
    return nothing
end

"""
The `(owner_id, owner_category, time_series_type, name, resolution, interval, features)`
named tuple a time series association row is matched by — the same identity the store's own
uniqueness index keys on. See [`_validate_time_series_associations!`](@ref).

Features are compared by value: the wire type wraps each value in a mutable
`TimeSeriesFeatureValue`, which compares by object identity, so a document row and its store
counterpart would never match on the wrappers themselves.
"""
_ts_row_identity(row) = (
    owner_id=row.owner_id,
    owner_category=row.owner_category,
    time_series_type=row.time_series_type,
    name=row.name,
    resolution=_ts_field(row, :resolution),
    interval=_ts_field(row, :interval),
    features=_ts_feature_values(row.features),
)

_ts_feature_values(::Nothing) = nothing
_ts_feature_values(features::AbstractDict) =
    Dict{String, Any}(String(k) => _ts_feature_value(v) for (k, v) in features)
_ts_feature_value(v::InfrastructureTimeSeriesOpenAPIModels.TimeSeriesFeatureValue) = v.value
_ts_feature_value(v) = v

"""
Human-readable label for a time series association identity, for error messages.
"""
function _ts_row_label(identity)
    return "$(identity.time_series_type) owner $(identity.owner_id) \"$(identity.name)\""
end

"""
Wire field names on which `doc_row` and `store_row` differ, comparing canonical OpenAPI
JSON and excluding `uri`/`data_hash`.
"""
function _ts_row_drift(doc_row, store_row)
    doc_json = _ts_row_wire_dict(doc_row)
    store_json = _ts_row_wire_dict(store_row)
    fields = union(keys(doc_json), keys(store_json))
    return sort!([
        f for f in fields if get(doc_json, f, nothing) != get(store_json, f, nothing)
    ],)
end

function _ts_row_wire_dict(row)
    dict = JSON.parse(JSON.json(row))
    delete!(dict, "uri")
    delete!(dict, "data_hash")
    return dict
end

function _deserialize_schedule(raw::Dict)
    schedule = Dict()
    for (i, start_date) in enumerate(raw["start_dates"])
        end_date = raw["end_dates"][i]
        period_tuple = (Dates.Date(start_date), Dates.Date(end_date))

        schedule[period_tuple] = Dict()
        for capacity in raw["results"][i]
            technology_type = getproperty(
                PowerSystemsInvestmentsPortfolios,
                Symbol(capacity["technology"]),
            )
            parameter = getproperty(PowerSystems, Symbol(capacity["parameter"]))
            technology_tuple = (technology_type{parameter}, capacity["name"])

            if capacity["installations"] isa Dict
                capacity_tuple = NamedTuple(
                    (Symbol(key), value) for (key, value) in capacity["installations"]
                )
                schedule[period_tuple][technology_tuple] = capacity_tuple
            else
                schedule[period_tuple][technology_tuple] = capacity["installations"]
            end
        end
    end

    return InvestmentScheduleResults(schedule)
end

"""
Resolve a `"Module.Type"` string (as written by [`_serialize_type_name`](@ref)) back to the
`Type`. The leading segment names a module in scope here (`PowerSystems`, `InfrastructureSystems`,
`PowerSystemsInvestmentsPortfolios`); the remainder walks into it. Used for `doc.aggregation`.
"""
function _deserialize_type_name(qualified::AbstractString)
    parts = split(qualified, '.')
    length(parts) >= 2 ||
        error("_deserialize_type_name: expected a \"Module.Type\" name, got \"$qualified\"")
    obj = getfield(@__MODULE__, Symbol(parts[1]))
    for p in parts[2:end]
        obj = getfield(obj, Symbol(p))
    end
    return obj
end
