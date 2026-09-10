# `IS.serialize` reaches each component through `IS.serialize(::IS.SystemData)`, which hands
# it no portfolio, but `to_openapi` needs the document's id registry. The registry for one
# `IS.serialize(::Portfolio)` call therefore lives in task-local storage for its duration:
# task-scoped so two portfolios serialized on different threads cannot see each other's
# registry, re-entrant, and unwound on throw without an explicit `finally`.
const _EXPORT_REFS_KEY = :psip_openapi_export_refs

function _active_export_refs()
    storage = task_local_storage()
    if !haskey(storage, _EXPORT_REFS_KEY)
        error(
            "no active OpenAPI export registry: a PSIP component resolves its references " *
            "by document id, which only a Portfolio can supply, so a component cannot be " *
            "serialized on its own. Serialize the owning portfolio instead — " *
            "`to_json(portfolio, filename)` or `to_json(portfolio)`.",
        )
    end
    return storage[_EXPORT_REFS_KEY]
end

function _serialize_schedule(schedule::InvestmentScheduleResults)
    start_dates = Vector{String}()
    end_dates = Vector{String}()
    capacity_data = Vector{Vector{Dict{String, Any}}}()
    for (period, investments) in schedule.results
        push!(start_dates, string(period[1]))
        push!(end_dates, string(period[2]))

        installation_list = Vector{Dict{String, Any}}()
        for (technology, capacity) in investments
            installation = Dict{String, Any}(
                "technology" => string(nameof(technology[1])),
                "parameter" => string(nameof((only(technology[1].parameters)))),
                "name" => technology[2],
                "installations" => capacity,
            )
            push!(installation_list, installation)
        end
        push!(capacity_data, installation_list)
    end
    return Dict{String, Any}(
        "start_dates" => start_dates,
        "end_dates" => end_dates,
        "results" => capacity_data,
    )
end
"""
Rendering goes through `OpenAPI.to_json` rather than `JSON3.write` because only the former
unwraps the `oneOf` wrappers and stamps their discriminators.
"""
function _serialize_openapi(component)
    # Rejected on write as well as on read: a type absent from the plans would otherwise
    # be emitted happily and then refused by `deserialize_components!`, producing a
    # document that cannot be read back. `Base.typename(...).wrapper` is the plan key for
    # a parametric type, matching what `_group_by_serialized_type` resolves to.
    _openapi_wire_type(Base.typename(typeof(component)).wrapper)
    po = to_openapi(component, _active_export_refs())
    data = JSON3.read(OpenAPI.to_json(po), Dict{String, Any})
    add_serialization_metadata!(data, typeof(component))
    return data
end
IS.serialize(value::Technology) = _serialize_openapi(value)
IS.serialize(value::Requirement) = _serialize_openapi(value)

# PSIP's supplemental attributes subtype `IS.SupplementalAttribute` directly, with no PSIP
# supertype of their own, so dispatching on the abstract type would pirate every other
# package's attributes. One method per declared type instead, driven by the same plan the
# deserialize side reads.
for (attribute_type, _key) in SUPPLEMENTAL_ATTRIBUTE_PLAN
    @eval IS.serialize(value::$attribute_type) = _serialize_openapi(value)
end
"""
Add type information to the dictionary that can be used to deserialize the value.

A parametric component's type parameter is not recorded here: it travels in the payload's
own `power_systems_type` field, which `from_openapi` reads.
"""
function add_serialization_metadata!(data::Dict, ::Type{T}) where {T}
    data[METADATA_KEY] = Dict{String, Any}(
        TYPE_KEY => string(nameof(T)),
        MODULE_KEY => string(parentmodule(T)),
    )
    return
end
"""
Write a `Type`-valued field, such as `Portfolio.aggregation`, in the `"Module.Type"` form
[`_deserialize_type_name`](@ref) requires.

Emitted explicitly because `IS` has no `serialize(::Type)`: the raw `DataType` would reach
JSON3, which stringifies it through `show`, and `show` resolves the name against
`Base.active_module()` — making the document depend on the writing session's imports. The
qualified form does not.
"""
_serialize_type_name(T::Type) = string(parentmodule(T), '.', nameof(T))
function _build_export_refs(portfolio::Portfolio)
    refs = OpenAPIRefs()
    _register_base_system_topology!(refs, portfolio.base_system)
    for (psip_type, _key) in DOCUMENT_PLAN
        for component in IS.get_components(psip_type, portfolio.data)
            refs[get_id(component)] = component
        end
    end
    # Supplemental attributes are registered (and their rows emitted) by
    # `_export_supplemental_attributes`, which keys off `has_ref` to emit each attribute exactly
    # once — so they must NOT be pre-registered here, or their rows would be silently skipped.
    return refs
end

# ── unexportable components ─────────────────────────────────────────────────────

"""
Warn, naming each type and how many of it, when `portfolio` holds components no converter covers.

Those components are omitted from the document. Dynamics is deferred, so no dynamic type has a
converter and a dynamics-bearing portfolio cannot round-trip through a document — but it is
reported on every export rather than left silent, so a consumer of the document knows what is
not in it.

Warns rather than errors so the document stays usable as a cache format. A type drops out of
this warning automatically once its converter joins [`DOCUMENT_PLAN`](@ref).
"""
function warn_unexportable_components(portfolio::Portfolio)
    counts = Dict{Symbol, Int}()
    for technology in get_technologies(Technology, portfolio)
        if !is_document_exportable(technology)
            name = nameof(typeof(technology))
            counts[name] = get(counts, name, 0) + 1
        end
    end
    for requirement in get_requirements(Requirement, portfolio)
        if !is_document_exportable(requirement)
            name = nameof(typeof(requirement))
            counts[name] = get(counts, name, 0) + 1
        end
    end
    isempty(counts) && return nothing
    listed = join(("$k ($(counts[k]))" for k in sort(collect(keys(counts)))), ", ")
    @warn "to_openapi: omitting component type(s) with no OpenAPI converter — they will not " *
          "be in the document and will not survive a round trip: $listed"
    return nothing
end

"""
Emit the attribute rows and their associations from the store's own OpenAPI export
([`IS.openapi_supplemental_attribute_association_rows`](@ref)) rather than converting each
association row by hand: the rows already carry `component_id`/`attribute_id` in the
document's id space and their `attribute_type`/`component_type` labels.

Only rows whose component has a document id are kept, mirroring
[`warn_unexportable_components`](@ref): a dynamics component's attribute is dropped along
with the component itself. Each distinct attribute is registered into `refs` under its own id
before `to_openapi(attr, refs)` reads that id back. The store's rows already arrive sorted by
`(component_id, attribute_id)`, so document order tracks component order with no local sort.
"""
function _export_supplemental_attributes(refs::OpenAPIRefs, portfolio::Portfolio)
    attribute_rows = OpenAPI.APIModel[]
    association_rows = IC.SupplementalAttributeAssociation[]
    attributes_by_id = Dict{Int, SupplementalAttribute}(
        IS.get_id(attr) => attr for attr in IS.iterate_supplemental_attributes(portfolio.data)
    )
    for row in IS.openapi_supplemental_attribute_association_rows(portfolio.data)
        entity_id = Int(row.component_id)
        has_ref(refs, entity_id) || continue
        attr_id = Int(row.attribute_id)
        haskey(attributes_by_id, attr_id) || error(
            "to_openapi: supplemental attribute association (attribute id $attr_id, " *
            "entity id $entity_id) references an attribute absent from the attribute " *
            "manager — the store and the attribute manager disagree about what exists",
        )
        attr = attributes_by_id[attr_id]
        if !has_ref(refs, attr_id)
            refs[attr_id] = attr
            push!(attribute_rows, to_openapi(attr, refs))
        end
        push!(association_rows, row)
    end
    return attribute_rows, association_rows
end

# ── time series ────────────────────────────────────────────────────────────────
#
# The mirror of import's store adoption: the portfolio's InfraStore *is* the sidecar, so export
# serializes it and describes it via the store's own OpenAPI export
# (`IS.openapi_time_series_association_rows`) rather than walking series and converting each
# metadata row by hand. The catalog's owner ids are already document ids for both owner
# kinds, so a row's `owner_category` is read only to pick the right failure mode.

"""Whether a time series owner absent from the document is a tolerated loss or a hard error.

A component owner may be absent because it has no converter — the same reported loss
[`warn_unexportable_components`](@ref) already flags. An absent supplemental-attribute owner
means the sidecar and the attribute manager disagree about what exists: every attribute the
document can describe was registered into `refs` by `_export_supplemental_attributes` before
this runs."""
function _absent_owner_is_tolerated(row)
    row.owner_category == "Component" && return true
    row.owner_category == "SupplementalAttribute" && return false
    error(
        "to_openapi: time series \"$(row.name)\" (owner id $(row.owner_id)) has " *
        "unrecognized owner_category $(row.owner_category)",
    )
end

"""
Refuse to emit a document whose costs reference series it does not describe.

A cost may reference a series owned by another component, and `_export_all_time_series`
skips the association rows of owners the document cannot describe (see
[`_absent_owner_is_tolerated`](@ref)). The two together produce a document carrying a bare
`association_id` with no declared identity beside it, and an import has then nothing to
check that id against: resolved against a different sidecar it binds the cost to whichever
series happens to hold that id there, silently.

A dataset in that state has a broken relationship -- a cost pointing at something the
document does not contain -- so this errors rather than dropping the reference. Dropping it
would change the model on the way out, and quietly.
"""
function _check_costs_reference_declared_series!(doc::PD.PortfolioDocument, emitted::Set{Int})
    isempty(emitted) && return nothing
    declared = Set{Int}(
        _unwrap_oneof(row).association_id for row in doc.time_series_associations
    )
    dangling = sort!(collect(setdiff(emitted, declared)))
    isempty(dangling) && return nothing
    throw(
        IS.DataFormatError(
            "to_openapi: $(length(dangling)) time-series-backed cost(s) reference " *
            "association id(s) $(join(dangling, ", ")) that the document does not " *
            "describe. A cost may reference a series owned by another component, and a " *
            "series whose owner has no OpenAPI converter is omitted from the document " *
            "(see the omission warnings above) -- so the reference cannot survive a " *
            "round trip and would resolve against an unrelated series in another " *
            "sidecar. Give the owning component a converter, or remove the reference.",
        ),
    )
end

function _export_all_time_series(
    portfolio::Portfolio,
    refs::OpenAPIRefs,
    time_series_storage_path,
    write_catalog::Bool,
)
    rows = PTS.TimeSeriesAssociation[]
    # Counted, not `isempty(store)`: one store holds the supplemental attribute associations
    # as well, so a portfolio with attributes and no series has a non-empty store and would
    # otherwise demand a sidecar it has nothing to put in.
    num_time_series = IS.get_num_time_series(portfolio.data)
    iszero(num_time_series) && return rows
    isnothing(time_series_storage_path) && error(
        "to_openapi: $num_time_series time series are attached but no " *
        "time_series_storage_path was given — cannot write the sidecar",
    )
    skipped_counts = Dict{String, Int}()
    for assoc in IS.openapi_time_series_association_rows(portfolio.data)
        row = assoc.value
        owner_id = Int(row.owner_id)
        if !has_ref(refs, owner_id)
            _absent_owner_is_tolerated(row) || error(
                "to_openapi: supplemental attribute (owner id $owner_id, type " *
                "$(row.owner_type)) owns time series \"$(row.name)\", but is not " *
                "registered in the exported document — the sidecar and the attribute " *
                "manager disagree about what exists",
            )
            skipped_counts[row.owner_type] = get(skipped_counts, row.owner_type, 0) + 1
            continue
        end
        push!(rows, assoc)
    end
    if !isempty(skipped_counts)
        total = sum(values(skipped_counts))
        types = join(sort(collect(keys(skipped_counts))), ", ")
        @warn "to_openapi: omitting $total time series row(s) whose owning component has " *
              "no OpenAPI converter ($types) — they remain in the sidecar but are not " *
              "described in the document and will not survive a round trip"
    end
    # The rows above go into the document either way; `write_catalog` decides only whether
    # InfraStore's own `.sqlite` is written beside the arrays as well. See `to_file`.
    store = IS.get_data_store(portfolio.data)
    path = String(time_series_storage_path)
    if write_catalog
        IS.serialize(store, path)
    else
        IS.serialize_arrays(store, path)
    end
    return rows
end

"""Enumerate the live instances of a `DOCUMENT_PLAN` type. Technology types walk the masked
container alongside the live one so components masked out of the portfolio's own enumeration are
still exported by id; requirement types (which have no masked container) enumerate directly."""
_plan_components(portfolio::Portfolio, ::Type{T}) where {T <: Technology} = Iterators.flatten((
    get_technologies(T, portfolio),
    IS.get_masked_components(T, portfolio.data),
))
_plan_components(portfolio::Portfolio, ::Type{T}) where {T <: Requirement} =
    get_requirements(T, portfolio)

"""
Store a component's `ext` dict into `doc.ext` under its id, the inverse of the import's
[`_merge_doc_ext!`](@ref). Skips components with an empty `ext` so the document carries a row
only when there is something to carry.
"""
function _export_ext!(doc::PD.PortfolioDocument, id::Integer, component)
    ext = get_ext(component)
    isempty(ext) || (doc.ext[Int(id)] = Dict{String, Any}(ext))
    return nothing
end

# ── component pass ───────────────────────────────────────────────────────────────

"""
Convert every component in [`DOCUMENT_PLAN`](@ref) order and add it to `doc`.

`add_component!` buckets by the PO type's own name and keeps each bucket concretely typed, so
the document's `components` map needs no key bookkeeping here.
"""
function _export_components!(
    doc::PD.PortfolioDocument,
    refs::OpenAPIRefs,
    portfolio::Portfolio,
)
    for (psip_type, key) in DOCUMENT_PLAN
        for c in _plan_components(portfolio, psip_type)
            PD.add_component!(doc, to_openapi(c, refs))
            _export_ext!(doc, component_id(refs, c), c)
        end
    end
    return nothing
end

# ── requirement membership (reverse of the requirement-membership branch on import) ──
# A row in the `RequirementAssociation` table: `requirement_id` and `entity_id` both name
# components, so no `attribute_type` discriminator is needed.

function _export_requirements_associations!(
    doc::PD.PortfolioDocument,
    refs::OpenAPIRefs,
    portfolio::Portfolio,
)
    for technology in get_technologies(Technology, portfolio)
        supports_requirements(technology) || continue
        for requirement in get_requirements(technology)
            PD.add_requirement_association!(
                doc,
                PO.RequirementAssociation(;
                    requirement_id = component_id(refs, requirement),
                    entity_id = component_id(refs, technology),
                ),
            )
        end
    end
    return nothing
end

# ── document-level entry point ──────────────────────────────────────────────────

"""
$(TYPEDSIGNATURES)

Build a `PortfolioDocument` from `portfolio`, the reverse of `from_openapi`.

Returns the typed container, not JSON: writing it to disk belongs to `PD.write_document`,
which [`to_file`](@ref) drives. Every id — components and supplemental attributes alike — comes
from the document's single counter, since consumers key a row by id without its type.
Components are walked in [`DOCUMENT_PLAN`](@ref) order.

`write_catalog` decides whether InfraStore's `<sidecar>.sqlite` is written beside the arrays:
`false` (default) writes the arrays alone, `true` keeps the catalog too. Either way the rows
appear in `doc.time_series_associations` — the keyword adds a file, it does not move them. See
the notes in `src/openapi/file_io.jl` for which written form uses which.

Errors rather than silently dropping data when time series are attached but no
`time_series_storage_path` is given.
"""
function to_openapi(
    portfolio::Portfolio;
    base_system_path::AbstractString,
    time_series_storage_path = nothing,
    write_catalog::Bool = false,
)
    warn_unexportable_components(portfolio)
    refs = _build_export_refs(portfolio)

    doc = PD.PortfolioDocument(
        _serialize_type_name(get_aggregation(portfolio));
        name = get_name(portfolio),
        description = get_description(portfolio),
        base_system_file = _base_system_relpath(base_system_path),
        time_series_storage_file = _sidecar_basename(time_series_storage_path),
        financial_data = convert_nested_data_to_openapi(get_financial_data(portfolio)),
        investment_schedule = isnothing(get_investment_schedule(portfolio)) ? nothing : _serialize_schedule(get_investment_schedule(portfolio)),
    )
    emitted = Set{Int}()
    task_local_storage(_EMITTED_ASSOCIATION_IDS_KEY, emitted) do
        _export_components!(doc, refs, portfolio)
        supplemental_attributes,
        supplemental_attribute_associations =
            _export_supplemental_attributes(refs, portfolio)
        append!(doc.supplemental_attributes, supplemental_attributes)
        append!(
            doc.supplemental_attribute_associations,
            supplemental_attribute_associations,
        )
        _export_requirements_associations!(doc, refs, portfolio)
        append!(
            doc.time_series_associations,
            _export_all_time_series(portfolio, refs, time_series_storage_path, write_catalog),
        )
        _reserve_ids!(doc, refs)
    end

    _check_costs_reference_declared_series!(doc, emitted)
    PD.validate_document(doc)
    return doc
end

_sidecar_basename(::Nothing) = nothing
_sidecar_basename(path) = basename(String(path))

# The base system is written as PSY's directory form under `base_system/`, so the portable
# `base_system_file` is that relative directory name, resolved against the document's dir on read.
_base_system_relpath(::Nothing) = nothing
_base_system_relpath(path) = basename(String(path))

"""Reserve `doc`'s own id counter above every id already assigned, so it cannot reissue one
that collides. Components and supplemental attributes share one id stream, and `refs`
registers both kinds by the time this runs."""
function _reserve_ids!(doc::PD.PortfolioDocument, refs::OpenAPIRefs)
    if isempty(refs.by_component_id)
        return nothing
    end
    PD.reserve_ids!(doc, maximum(keys(refs.by_component_id)))
    return nothing
end