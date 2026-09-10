# These will get encoded into each dictionary when a struct is serialized.
const METADATA_KEY = "__metadata__"
const TYPE_KEY = "type"
const MODULE_KEY = "module"
const SYSTEM_KWARGS = Set((
    :internal,
    :runchecks,
    :time_series_directory,
    :time_series_in_memory,
    :time_series_read_only,
    :timeseries_metadata_file,
    :name,
    :description,
))

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

"""
Constructs a Portfolio from a file path ending with .json
"""
function Portfolio(file_path::AbstractString; try_reimport=true, kwargs...)
    ext = lowercase(splitext(file_path)[2])
    if ext == ".json"
        unsupported = setdiff(keys(kwargs), SYSTEM_KWARGS)
        !isempty(unsupported) && error("Unsupported kwargs = $unsupported")
        time_series_read_only = get(kwargs, :time_series_read_only, false)
        time_series_directory = get(kwargs, :time_series_directory, nothing)
        # TODO: `runchecks` governs the base system read only; portfolio-level validation on
        # load is not wired up yet.
        return deserialize(
            Portfolio,
            file_path;
            time_series_read_only=time_series_read_only,
            time_series_directory=time_series_directory,
            runchecks=get(kwargs, :runchecks, false),
        )
    else
        throw(IS.DataFormatError("$file_path is not a supported file type"))
    end
end

function IS.serialize(portfolio::T) where {T <: Portfolio}
    refs = _build_export_refs(portfolio)
    return task_local_storage(_EXPORT_REFS_KEY, refs) do
        data = Dict{String, Any}()
        data["data_format_version"] = DATA_FORMAT_VERSION
        for field in fieldnames(T)
            # Exclude time_series_directory because the portfolio may get deserialized on a
            # different portfolio. `aggregation` is written below instead, in a form that
            # does not depend on the writing session's module scope.
            if !(field in [:time_series_directory, :base_system, :aggregation])
                data[string(field)] = serialize(getfield(portfolio, field))
            end
        end
        data["aggregation"] = _serialize_type_name(get_aggregation(portfolio))
        return data
    end
end

function deserialize(::Type{Portfolio}, filename::AbstractString; kwargs...)
    raw = open(filename) do io
        JSON3.read(io, Dict)
    end

    if raw["data_format_version"] != DATA_FORMAT_VERSION
        pre_read_conversion!(raw)
    end

    # These file paths are relative to the portfolio file.
    directory = dirname(filename)
    for file_key in ("time_series_storage_file",)
        if haskey(raw["data"], file_key) && !isabspath(raw["data"][file_key])
            raw["data"][file_key] = joinpath(directory, raw["data"][file_key])
        end
    end

    return from_dict(Portfolio, raw, filename; kwargs...)
end

function IS.serialize(schedule::InvestmentScheduleResults)
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
Rendering goes through the generated packages' `encode` rather than `JSON3.write` because
only the former unwraps the `oneOf` wrappers and stamps their discriminators. `encode` is the
public entry point that replaced OpenAPI.jl 0.2's `OpenAPI.to_json`, which 1.x deleted.
"""
function _serialize_openapi(component)
    # Rejected on write as well as on read: a type absent from the plans would otherwise
    # be emitted happily and then refused by `deserialize_components!`, producing a
    # document that cannot be read back. `Base.typename(...).wrapper` is the plan key for
    # a parametric type, matching what `_group_by_serialized_type` resolves to.
    _openapi_wire_type(Base.typename(typeof(component)).wrapper)
    po = to_openapi(component, _active_export_refs())
    data = Dict{String, Any}(PC.encode(po))
    add_serialization_metadata!(data, typeof(component))
    return data
end

IS.serialize(value::Technology) = _serialize_openapi(value)
IS.serialize(value::Requirement) = _serialize_openapi(value)

# `Zone`/`Node` (the only `RegionTopology`s) carry `openapi: false` (SiennaSchemas
# 51f872e dropped the Regions folder): neither has a `PI.` counterpart, so they fall
# through to `IS.serialize`'s generic `InfrastructureSystemsType` default rather than
# the OpenAPI path the other component families use.

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
Clear any value stored in ext.
"""
clear_ext!(port::Portfolio) = IS.clear_ext!(port.internal)

function from_dict(
    ::Type{Portfolio},
    raw::Dict{String, Any},
    filename::AbstractString;
    time_series_read_only=false,
    time_series_directory=nothing,
    kwargs...,
)
    # Read any field that is defined in Portfolio but optional for the constructors and not
    # already handled here.
    handled = (
        "aggregation",
        "discount_rate",
        "data",
        "base_system",
        "financial_data",
        "investment_schedule",
        "time_series_directory",
        "time_series_container",
        "metadata",
        "internal",
    )
    parsed_kwargs = Dict{Symbol, Any}()
    for field in setdiff(keys(raw), handled)
        parsed_kwargs[Symbol(field)] = raw[field]
    end

    # The user can override the serialized runchecks value by passing a kwarg here.
    if haskey(kwargs, :runchecks)
        parsed_kwargs[:runchecks] = kwargs[:runchecks]
    end

    # Metadata
    metadata = get(raw, "metadata", Dict())
    name = get(metadata, "name", nothing)
    description = get(metadata, "description", nothing)

    #Financial Data
    financial_data = get(raw, "financial_data", Dict())
    base_year = get(financial_data, "base_year", nothing)
    inflation_rate = get(financial_data, "inflation_rate", nothing)
    discount_rate = get(financial_data, "discount_rate", nothing)
    interest_rate = get(financial_data, "interest_rate", nothing)

    #Base system
    base_system_file =
        joinpath(dirname(filename), splitext(basename(filename))[1] * "_base_system.json")
    # `runchecks` reaches PSY here: a portfolio's base system is often a placeholder with no
    # buses, and PSY's checks report that as an error. The caller says whether to run them.
    base_system = PSY.System(base_system_file; runchecks=get(kwargs, :runchecks, false))

    internal = IS.deserialize(InfrastructureSystemsInternal, raw["internal"])
    aggregation = _deserialize_type_name(raw["aggregation"])
    investment_schedule = get(raw, "investment_schedule", nothing)
    if !isnothing(investment_schedule)
        investment_schedule = deserialize(InvestmentScheduleResults, investment_schedule)
    end
    data = deserialize(
        IS.SystemData,
        raw["data"];
        time_series_read_only=time_series_read_only,
        time_series_directory=time_series_directory,
    )
    portfolio = Portfolio(
        aggregation,
        data,
        base_system,
        investment_schedule,
        internal;
        financial_data=PortfolioFinancialData(
            base_year,
            discount_rate,
            inflation_rate,
            interest_rate,
        ),
        name=name,
        description=description,
        parsed_kwargs...,
    )
    # The cross-reference registry for the whole document. Only components are referenced
    # (technologies point at regions and requirements), so only components are registered;
    # attributes resolve nothing and share an independent id stream, so they stay out of it.
    refs = OpenAPIRefs()
    deserialize_attributes!(
        portfolio,
        get(raw["data"], "supplemental_attribute_manager", Dict("attributes" => [])),
        refs,
    )
    if raw["data_format_version"] != DATA_FORMAT_VERSION
        pre_deserialize_conversion!(raw, portfolio)
    end

    ext = get_ext(portfolio)
    ext["deserialization_in_progress"] = true
    try
        deserialize_components!(portfolio, raw["data"], refs)
    finally
        pop!(ext, "deserialization_in_progress")
        isempty(ext) && clear_ext!(portfolio)
    end

    if raw["data_format_version"] != DATA_FORMAT_VERSION
        post_deserialize_conversion!(portfolio, raw)
    end

    return portfolio
end

"""
Write a `Type`-valued field, such as `Portfolio.aggregation`, in the `"Module.Type"` form
[`_deserialize_type_name`](@ref) requires.

Emitted explicitly rather than left to the generic `serialize` path: `IS` has no
`serialize(::Type)` method, so the raw `DataType` would reach JSON3, which stringifies it
through `show` — and `show` resolves a type name against `Base.active_module()`. A writer
with `using PowerSystems` in scope would then emit the bare `"ACBus"` and a writer with
`import PowerSystems as PSY` the qualified `"PowerSystems.ACBus"`, making the document
depend on the writing session's scope and unreadable in the first case.
"""
_serialize_type_name(T::Type) = string(parentmodule(T), '.', nameof(T))

"""
Resolve a `"Module.Type"` string — the form [`_serialize_type_name`](@ref) writes a
`Type`-valued field in, such as `Portfolio.aggregation` — back to the type itself.
"""
function _deserialize_type_name(name::AbstractString)
    parts = split(name, '.')
    if length(parts) != 2
        error(
            "cannot resolve serialized type name \"$name\": expected the \"Module.Type\" " *
            "form _serialize_type_name writes",
        )
    end
    return getproperty(IS.get_module(String(parts[1])), Symbol(parts[2]))
end

# Mirrors `IS.deserialize(::Type{IS.SystemData}, ::Dict)`, with one deliberate difference:
# the supplemental attribute manager is left empty here and filled by
# [`deserialize_attributes!`](@ref) once the `Portfolio` exists, because PSIP attributes are
# rebuilt through the OpenAPI converters and those need the document's id registry.
function deserialize(
    ::Type{IS.SystemData},
    raw::Dict;
    time_series_read_only=false,
    time_series_directory=nothing,
    validation_descriptor_file=nothing,
    kwargs...,
)
    time_series_manager =
        _deserialize_time_series_manager(raw, time_series_directory, time_series_read_only)
    subsystems = Dict(k => Set(Int.(v)) for (k, v) in raw["subsystems"])
    internal = IS.deserialize(IS.InfrastructureSystemsInternal, raw["internal"])
    validation_descriptors = if isnothing(validation_descriptor_file)
        []
    else
        IS.read_validation_descriptor(validation_descriptor_file)
    end
    if !haskey(raw, "next_id")
        error(
            "The serialized system predates the single id stream (it carries " *
            "next_component_id/next_supplemental_attribute_id); regenerate it with " *
            "this version of InfrastructureSystems.",
        )
    end

    return IS.SystemData(
        validation_descriptors,
        time_series_manager,
        Int(raw["next_id"]),
        subsystems,
        IS.SupplementalAttributeManager(time_series_manager.data_store),
        internal,
    )
end

"""
Open the time series store the document names, or create a fresh one when it named none.

Both the arrays and the supplemental attribute association rows live in that store, so a
document with attributes but no time series still carries one.
"""
function _deserialize_time_series_manager(
    raw::Dict,
    time_series_directory,
    time_series_read_only::Bool,
)
    if !haskey(raw, "time_series_storage_file")
        return IS.TimeSeriesManager(;
            in_memory=get(raw, "time_series_in_memory", true),
            directory=time_series_directory,
            read_only=time_series_read_only,
            compression=CompressionSettings(;
                enabled=get(raw, "time_series_compression_enabled", false),
            ),
        )
    end
    storage_type = IS.strip_module_name(get(raw, "time_series_storage_type", ""))
    if !in(storage_type, ("InfraStore", "RustTimeSeriesStore"))
        error(
            "portfolio was serialized with the $storage_type time series storage, which " *
            "is no longer supported; regenerate it with the InfraStore backend",
        )
    end
    if !isfile(raw["time_series_storage_file"])
        error("time series file $(raw["time_series_storage_file"]) does not exist")
    end
    return IS.TimeSeriesManager(;
        data_store=IS.open_deserialized_infrastore_store(
            raw["time_series_storage_file"],
            time_series_directory,
            time_series_read_only,
        ),
        read_only=time_series_read_only,
    )
end

function deserialize(::Type{InvestmentScheduleResults}, raw::Dict)
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

# Mirrors `IS.deserialize(::Type{IS.SupplementalAttributeManager}, ...)` but builds each
# attribute through the OpenAPI converters, so supplemental attributes take the same route as
# components in both directions. Fills the manager the `IS.SystemData` was constructed with
# rather than replacing it: that manager already holds the store handle the association rows
# were read from, and the components added next take their shared references from it.
function deserialize_attributes!(portfolio::Portfolio, data::Dict, refs::OpenAPIRefs)
    mgr = portfolio.data.supplemental_attribute_manager
    shared_references = IS.SharedSystemReferences(;
        supplemental_attribute_manager=mgr,
        time_series_manager=portfolio.data.time_series_manager,
    )
    by_type = _group_by_serialized_type(data["attributes"])
    for (attribute_type, _key) in SUPPLEMENTAL_ATTRIBUTE_PLAN
        haskey(by_type, attribute_type) || continue
        for raw_attribute in pop!(by_type, attribute_type)
            po = PC.decode(_openapi_wire_type(attribute_type), raw_attribute)
            attribute = from_openapi(po, refs)
            # The wire carries the document id in `po.id`. Stamp it onto the attribute's
            # internal identity so it becomes the stored id the store's association rows
            # name; without it the attribute would be silently lost on reload. Attributes
            # are never the target of a cross-reference, so they are not registered in
            # `refs` — and must not be, since an attribute may legitimately share a numeric
            # id with a component (the two families have independent id streams).
            IS.set_id!(attribute, Int(po.id))
            id = get_id(attribute)
            if !haskey(mgr.data, attribute_type)
                mgr.data[attribute_type] = Dict{Int, IS.SupplementalAttribute}()
            end
            if haskey(mgr.data[attribute_type], id)
                error(
                    "Bug: duplicate id in attributes container: " *
                    "type=$attribute_type id=$id",
                )
            end
            mgr.data[attribute_type][id] = attribute
            IS.set_shared_system_references!(attribute, shared_references)
        end
    end
    _reject_unplanned_types(
        by_type,
        "supplemental attribute",
        "SUPPLEMENTAL_ATTRIBUTE_PLAN",
    )
    return mgr
end

function deserialize_components!(portfolio::Portfolio, raw, refs::OpenAPIRefs)
    # DOCUMENT_PLAN order is dependency order: regions and requirements land in `refs`
    # before the technologies whose references resolve against them.
    by_type = _group_by_serialized_type(raw["components"])
    # Zone/Node (`openapi: false`) were written through `IS.serialize`'s generic
    # `InfrastructureSystemsType` path (`serialization.jl`'s `RegionTopology` note),
    # not `PC.decode`/`from_openapi`, so they need the matching generic `IS.deserialize`
    # here, ahead of DOCUMENT_PLAN, and are never in that plan themselves.
    for psip_type in filter(t -> t <: RegionTopology, collect(keys(by_type)))
        for raw_component in pop!(by_type, psip_type)
            component = IS.deserialize(psip_type, raw_component)
            IS.add_component!(portfolio.data, component; skip_validation=true)
            refs[get_id(component)] = component
        end
    end
    for (psip_type, _key) in DOCUMENT_PLAN
        haskey(by_type, psip_type) || continue
        for raw_component in pop!(by_type, psip_type)
            # `psip_type` is the `UnionAll` for a parametric component, so a future
            # special-case method written for a concrete `Name{Param}` would never
            # dispatch here; declare it on the `UnionAll`.
            handle_deserialization_special_cases!(raw_component, psip_type)
            po = PC.decode(_openapi_wire_type(psip_type), raw_component)
            component = from_openapi(po, refs)
            # The wire carries the document id in `po.id`; `from_openapi` does not read it
            # because id is no longer a struct field. Stamp it onto the component's internal
            # identity before adding so `IS.add_component!` keeps it (rather than assigning a
            # fresh sequential id) and the document's references resolve against it.
            IS.set_id!(component, Int(po.id))
            #TODO: skip_validation currently set to true, review the IS validation
            IS.add_component!(portfolio.data, component; skip_validation=true)
            # Registered after conversion, never before: a component cannot reference
            # itself, and registering first would mask a DOCUMENT_PLAN ordering bug.
            refs[get_id(component)] = component
        end
    end
    _reject_unplanned_types(by_type, "component", "DOCUMENT_PLAN")
    return
end

"""
Buckets by `__metadata__`'s type, which for a parametric component is its `UnionAll` —
`__metadata__` no longer carries `parameters` — and that is the key both plans use.
"""
function _group_by_serialized_type(raw_values)
    grouped = Dict{Any, Vector{Dict}}()
    for raw_value in raw_values
        type = IS.get_type_from_serialization_data(raw_value)
        if !haskey(grouped, type)
            grouped[type] = Vector{Dict}()
        end
        push!(grouped[type], raw_value)
    end
    return grouped
end

function _reject_unplanned_types(grouped, family::AbstractString, plan_name::AbstractString)
    if !isempty(grouped)
        names = join(sort!([string(type) for type in keys(grouped)]), ", ")
        error(
            "the portfolio document carries $family types absent from $plan_name " *
            "(src/openapi/document.jl): $names",
        )
    end
    return
end

"""
Allow types to implement handling of special cases during deserialization.

# Arguments

  - `component::Dict`: The component serialized as a dictionary.
  - `::Type`: The type of the technology.
"""
handle_deserialization_special_cases!(
    component::Dict,
    ::Type{<:InfrastructureSystemsComponent},
) = nothing

function _is_deserialization_in_progress(portfolio::Portfolio)
    ext = get_ext(portfolio)
    return get(ext, "deserialization_in_progress", false)
end

"""
Serializes a portfolio to a JSON file and saves time series to an HDF5 file.

# Arguments

  - `portfolio::Portfolio`: portfolio
  - `filename::AbstractString`: filename to write

# Keyword arguments

  - `user_data::Union{Nothing, Dict} = nothing`: optional metadata to record
  - `pretty::Bool = false`: whether to pretty-print the JSON
  - `force::Bool = false`: whether to overwrite existing files
  - `runchecks::Bool = false`: whether to run portfolio validation checks

Refer to [`check_component`](@ref) for exceptions thrown if `check = true`.
"""
function to_json(
    portfolio::Portfolio,
    filename::AbstractString;
    user_data=nothing,
    pretty=false,
    force=false,
    runchecks=false,
)
    IS.prepare_for_serialization_to_file!(portfolio.data, filename; force=force)
    data = to_json(portfolio; pretty=pretty)

    open(filename, "w") do io
        write(io, data)
    end

    mfile = joinpath(dirname(filename), splitext(basename(filename))[1] * "_metadata.json")
    _serialize_portfolio_metadata_to_file(portfolio, mfile, user_data)
    @info "Serialized Portfolio to $filename"

    # Serialize base system to a separate file
    base_system_file =
        joinpath(dirname(filename), splitext(basename(filename))[1] * "_base_system.json")
    PSY.to_json(portfolio.base_system, base_system_file; pretty=pretty, force=force)

    return
end

"""
Serializes a InfrastructureSystemsType to a JSON string.

Component-level serialization is portfolio-scoped: a technology, region, requirement or
supplemental attribute records its references as document ids, which only the owning
`Portfolio` can assign, so passing one here on its own raises. Pass the `Portfolio` — or
use [`to_json(portfolio, filename)`](@ref) to write the whole document to disk.
"""
function to_json(obj::T; pretty=false, indent=2) where {T <: InfrastructureSystemsType}
    try
        if pretty
            io = IOBuffer()
            JSON3.pretty(io, serialize(obj), JSON3.AlignmentContext(; indent=indent))
            return take!(io)
        else
            return JSON3.write(serialize(obj))
        end
    catch e
        @error "Failed to serialize $(summary(obj))"
        rethrow(e)
    end
end

function _serialize_portfolio_metadata_to_file(portfolio::Portfolio, filename, user_data)
    name = get_name(portfolio)
    description = get_description(portfolio)
    metadata = OrderedDict(
        "name" => isnothing(name) ? "" : name,
        "description" => isnothing(description) ? "" : description,
        "component_counts" => IS.get_component_counts_by_type(portfolio.data),
        "time_series_counts" => IS.get_time_series_counts_by_type(portfolio.data),
    )
    if !isnothing(user_data)
        metadata["user_data"] = user_data
    end

    open(filename, "w") do io
        JSON3.pretty(io, metadata)
    end

    @info "Serialized Portfolio metadata to $filename"
end

"""
Construct a Portfolio from a serialized JSON string or stream.

Warning: time series data is not restored by this method. If that is needed, use the normal
process to construct the portfolio from a serialized JSON file instead, such as with
`Portfolio("portfolio.json")`.
"""
function IS.from_json(io::Union{IO, String}, ::Type{Portfolio}; kwargs...)
    data = JSON3.read(io, Dict)
    # These objects could be removed in to_json(portfolio). Doing it here will allow us to
    # keep that JSON string fully consistent with time series and potentially use it in the
    # future.
    for component in data["data"]["components"]
        if haskey(component, "time_series_container")
            empty!(component["time_series_container"])
        end
    end

    return from_dict(Portfolio, data; kwargs...)
end
