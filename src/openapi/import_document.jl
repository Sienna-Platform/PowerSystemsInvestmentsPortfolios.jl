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

const SUPPLEMENTAL_ATTRIBUTE_PLAN = [
    (RetirementPotential, "RetirementPotential"),
    (RetrofitPotential, "RetrofitPotential"),
    (ExistingDevices, "ExistingDevices"),
    (TopologyMapping, "TopologyMapping"),
]
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
    # The cross-reference registry for the whole document. Technologies point at the base
    # system's topology (buses, areas, ...) and at requirements by id, so the registry is
    # seeded with the base system's topology components before any technology is converted;
    # attributes resolve nothing and share an independent id stream, so they stay out of it.
    refs = OpenAPIRefs()
    _register_base_system_topology!(refs, base_system)
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

    return IS.SystemData(
        validation_descriptors,
        time_series_manager,
        Int(get(raw, "next_component_id", 1)),
        Int(get(raw, "next_supplemental_attribute_id", 1)),
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
            po = OpenAPI.from_json(_openapi_wire_type(attribute_type), raw_attribute)
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
    for (psip_type, _key) in DOCUMENT_PLAN
        haskey(by_type, psip_type) || continue
        for raw_component in pop!(by_type, psip_type)
            # `psip_type` is the `UnionAll` for a parametric component, so a future
            # special-case method written for a concrete `Name{Param}` would never
            # dispatch here; declare it on the `UnionAll`.
            handle_deserialization_special_cases!(raw_component, psip_type)
            po = OpenAPI.from_json(_openapi_wire_type(psip_type), raw_component)
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
Clear any value stored in ext.
"""
clear_ext!(port::Portfolio) = IS.clear_ext!(port.internal)
