# These will get encoded into each dictionary when a struct is serialized.
const METADATA_KEY = "__metadata__"
const TYPE_KEY = "type"
const MODULE_KEY = "module"
const PARAMETERS_KEY = "parameters"
const CONSTRUCT_WITH_PARAMETERS_KEY = "construct_with_parameters"
const FUNCTION_KEY = "function"
const _CONTAINS_SHOULD_ENCODE =
    Union{ResourceTechnology, DemandTechnology, TransmissionTechnology, RegionTopology}
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
const ENCODED_FIELDS = Set((
    :duration_limits,
    :capacity_limits,
    :capacity_limits_energy,
    :capacity_limits_discharge,
    :capacity_limits_charge,
    :angle_limits,
    :co2,
    :fuel,
    :prime_mover_type,
    :heat_rate_mmbtu_per_mwh,
    :storage_tech,
    :cofire_level_limits,
    :cofire_start_limits,
    :bus_type,
    :node,
    :region,
    :start_region,
    :end_region,
    :start_node,
    :end_node,
    :efficiency,
    :ramp_limits,
    :time_limits,
    :eligible_regions,
    :eligible_resources,
    :eligible_demand,
    :eligible_technologies,
    :uuid,
    :conformity,
    :requirements,
))

"""
Constructs a Portfolio from a file path ending with .json

If the file is JSON, then `assign_new_uuids = true` will generate new UUIDs for the system
and all components.
"""
function Portfolio(
    file_path::AbstractString;
    from_python=false,
    assign_new_uuids=false,
    try_reimport=true,
    kwargs...,
)
    ext = lowercase(splitext(file_path)[2])
    if ext == ".json"
        unsupported = setdiff(keys(kwargs), SYSTEM_KWARGS)
        !isempty(unsupported) && error("Unsupported kwargs = $unsupported")
        runchecks = get(kwargs, :runchecks, false)
        time_series_read_only = get(kwargs, :time_series_read_only, false)
        time_series_directory = get(kwargs, :time_series_directory, nothing)
        portfolio = deserialize(
            Portfolio,
            file_path;
            from_python=from_python,
            time_series_read_only=time_series_read_only,
            # runchecks = runchecks,
            time_series_directory=time_series_directory,
        )
        _post_deserialize_handling(
            portfolio;
            runchecks=runchecks,
            assign_new_uuids=assign_new_uuids,
        )
        return portfolio
    else
        throw(DataFormatError("$file_path is not a supported file type"))
    end
end

function IS.serialize(portfolio::T) where {T <: Portfolio}
    data = Dict{String, Any}()
    data["data_format_version"] = DATA_FORMAT_VERSION
    for field in fieldnames(T)
        # Exclude time_series_directory because the portfolio may get deserialized on a
        # different portfolio.
        if !(field in [:time_series_directory, :base_system])
            data[string(field)] = serialize(getfield(portfolio, field))
        end
    end
    return data
end

function deserialize(
    ::Type{Portfolio},
    filename::AbstractString;
    from_python=false,
    kwargs...,
)
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

    return from_dict(Portfolio, raw, filename; from_python, kwargs...)
end

function serialize(schedule::InvestmentScheduleResults)
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
    openapi_schedule = APIServer.InvestmentScheduleResults(
        start_dates=start_dates,
        end_dates=end_dates,
        results=capacity_data,
    )
    data = Dict{String, Any}(
        string(name) => serialize(getproperty(openapi_schedule, name)) for
        name in fieldnames(typeof(openapi_schedule))
    )

    return data
end

function serialize(technology::T) where {T <: _CONTAINS_SHOULD_ENCODE}
    api_struct = serialize_openapi_struct(technology)

    struct_type = typeof(technology)
    api_type = typeof(api_struct)

    # Build OpenAPI struct from modeling struct
    for field in fieldnames(api_type)
        if technology isa SupplyTechnology && field == :outage_factor
            continue
        end
        if technology isa StorageTechnology &&
           field in (:capital_costs_energy, :capital_costs_charge, :capital_costs_discharge)
            continue
        end
        if field in ENCODED_FIELDS
            value = serialize_custom_types(field, technology)
        else
            value = getfield(technology, field)
        end
        setfield!(api_struct, field, value)
    end

    data = Dict{String, Any}(
        string(name) => serialize(getproperty(api_struct, name)) for
        name in fieldnames(typeof(api_struct))
    )
    if technology isa StorageTechnology
        for field in ("capital_costs_energy", "capital_costs_charge", "capital_costs_discharge")
            delete!(data, field)
        end
        data["capital_costs_storage"] = serialize(get_capital_costs_storage(technology))
    elseif technology isa SupplyTechnology
        delete!(data, "outage_factor")
        data["outage_factors"] = serialize(get_outage_factors(technology))
    end
    # Associations and time-series metadata refer to the original component UUID.
    data["internal"] = serialize(IS.get_internal(technology))
    data["ext"] = serialize(get_ext(technology))

    add_serialization_metadata!(data, struct_type)
    if !isempty(struct_type.parameters)
        data[IS.METADATA_KEY][IS.CONSTRUCT_WITH_PARAMETERS_KEY] = true
    end

    return data
end

"""
Add type information to the dictionary that can be used to deserialize the value.
"""
function add_serialization_metadata!(data::Dict, ::Type{T}) where {T}
    data[METADATA_KEY] = Dict{String, Any}(
        TYPE_KEY => string(nameof(T)),
        MODULE_KEY => string(parentmodule(T)),
    )
    if !isempty(T.parameters)
        data[METADATA_KEY][PARAMETERS_KEY] = [string(nameof(x)) for x in T.parameters]
    end

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
    from_python=false,
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
    base_system = PSY.System(base_system_file)

    internal = IS.deserialize(InfrastructureSystemsInternal, raw["internal"])
    aggregation = PSY.ACBus
    investment_schedule = get(raw, "investment_schedule", nothing)
    if !isnothing(investment_schedule)
        investment_schedule = deserialize(InvestmentScheduleResults, investment_schedule)
    end
    data = deserialize(
        IS.SystemData,
        raw["data"];
        from_python=from_python,
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
    portfolio.data.supplemental_attribute_manager = deserialize_attributes(
        portfolio,
        IS.SupplementalAttributeManager,
        get(
            raw["data"],
            "supplemental_attribute_manager",
            Dict("attributes" => [], "associations" => []),
        ),
        portfolio.data.time_series_manager,
    )
    if raw["data_format_version"] != DATA_FORMAT_VERSION
        pre_deserialize_conversion!(raw, portfolio)
    end

    ext = get_ext(portfolio)
    ext["deserialization_in_progress"] = true
    try
        deserialize_components!(portfolio, raw["data"])
    finally
        pop!(ext, "deserialization_in_progress")
        isempty(ext) && clear_ext!(portfolio)
    end

    if raw["data_format_version"] != DATA_FORMAT_VERSION
        post_deserialize_conversion!(portfolio, raw)
    end

    return portfolio
end

# Function copied over from IS. This version of the function is modified to not use the internal field  and UUIDs for components,
# since the internal field is not stored in the JSON when serializing with OpenAPI structs
function deserialize(
    ::Type{IS.SystemData},
    raw::Dict;
    from_python=false,
    time_series_read_only=false,
    time_series_directory=nothing,
    validation_descriptor_file=nothing,
    kwargs...,
)
    if haskey(raw, "time_series_storage_file")
        if !isfile(raw["time_series_storage_file"])
            error("time series file $(raw["time_series_storage_file"]) does not exist")
        end

        # Additional functionality to read tiemseries metadata from a portfolio written and serialized in pyPSIP, 
        # Long-term, we should probably either make it so infrasys supports deserializing without a DB
        # Or add an option to write this DB file in the serialization functions in IS
        if from_python
            if !isnothing(time_series_directory)
                metadata_path = joinpath(time_series_directory, IS.DB_FILENAME)
                ts_path = joinpath(time_series_directory, "time_series_storage.h5")
            else
                metadata_path = joinpath(raw["time_series"]["directory"], IS.DB_FILENAME)
                ts_path =
                    joinpath(raw["time_series"]["directory"], "time_series_storage.h5")
            end

            # Update h5 file to store this updated DB
            metadata = open(metadata_path, "r") do io
                read(io)
            end
            HDF5.h5open(ts_path, "r+") do file
                if IS.METADATA_TABLE_NAME in keys(file)
                    HDF5.delete_object(file, IS.HDF5_TS_METADATA_ROOT_PATH)
                end
                file[IS.HDF5_TS_METADATA_ROOT_PATH] = metadata
            end
        end

        # TODO: need to address this limitation
        if IS.strip_module_name(raw["time_series_storage_type"]) ==
           "InMemoryTimeSeriesStorage"
            @info "Deserializing with InMemoryTimeSeriesStorage is currently not supported. Using HDF"
            #hdf5_storage = Hdf5TimeSeriesStorage(raw["time_series_storage_file"], true)
            #time_series_storage = InMemoryTimeSeriesStorage(hdf5_storage)
        end
        time_series_storage = IS.from_file(
            IS.Hdf5TimeSeriesStorage,
            raw["time_series_storage_file"];
            directory=time_series_directory,
            read_only=time_series_read_only,
        )
        time_series_metadata_store = IS.from_h5_file(
            IS.TimeSeriesMetadataStore,
            time_series_storage.file_path,
            time_series_directory,
        )
    else
        time_series_storage = IS.make_time_series_storage(;
            compression=CompressionSettings(;
                enabled=get(raw, "time_series_compression_enabled", false),
            ),
            directory=time_series_directory,
        )
        time_series_metadata_store = nothing
    end

    time_series_manager = IS.TimeSeriesManager(;
        data_store=time_series_storage,
        read_only=time_series_read_only,
        metadata_store=time_series_metadata_store,
    )
    subsystems = Dict(k => Set(Base.UUID.(v)) for (k, v) in raw["subsystems"])

    # Deserialize with empty supplemental_attribute_manager to start, will be
    # deserialized later after Portfolio is initialized
    supplemental_attribute_manager = IS.SupplementalAttributeManager(
        IS.SupplementalAttributesByType(IS.SupplementalAttributesByType()),
        IS.from_records(IS.SupplementalAttributeAssociations, []),
    )
    internal = IS.deserialize(IS.InfrastructureSystemsInternal, raw["internal"])
    validation_descriptors = if isnothing(validation_descriptor_file)
        []
    else
        IS.read_validation_descriptor(validation_descriptor_file)
    end

    sys = IS.SystemData(
        validation_descriptors,
        time_series_manager,
        subsystems,
        supplemental_attribute_manager,
        internal,
    )
    attributes_by_uuid = Dict{Base.UUID, IS.SupplementalAttribute}()
    for attr_dict in values(supplemental_attribute_manager.data)
        for attr in values(attr_dict)
            uuid = IS.get_uuid(attr)
            if haskey(attributes_by_uuid, uuid)
                error("Bug: Found duplicate supplemental attribute UUID: $uuid")
            end
            attributes_by_uuid[uuid] = attr
        end
    end

    # Note: components need to be deserialized by the parent so that they can go through
    # the proper checks.
    return sys
end

function deserialize(::Type{InvestmentScheduleResults}, raw::Dict)
    openapi_schedule = IS.deserialize_struct(APIServer.InvestmentScheduleResults, raw)

    schedule = Dict()
    for (i, start_date) in enumerate(openapi_schedule.start_dates)
        end_date = openapi_schedule.end_dates[i]
        period_tuple = (Dates.Date(start_date), Dates.Date(end_date))

        schedule[period_tuple] = Dict()
        for capacity in openapi_schedule.results[i]
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

# Function copied over from IS. This version of the function is modified to deserialize using openAPI structs for PSIP supplemental attributes
# This is necessary since the openAPI structs do not have an internal field by default, so new UUIDs are given to supplemental attributes
# when deserialized with the IS version and the associations with PSIP components are broken
function deserialize_attributes(
    portfolio::Portfolio,
    ::Type{IS.SupplementalAttributeManager},
    data::Dict,
    time_series_manager::IS.TimeSeriesManager,
)
    mgr = IS.SupplementalAttributeManager(
        IS.SupplementalAttributesByType(IS.SupplementalAttributesByType()),
        IS.from_records(IS.SupplementalAttributeAssociations, data["associations"]),
    )
    refs = IS.SharedSystemReferences(;
        supplemental_attribute_manager=mgr,
        time_series_manager=time_series_manager,
    )
    for attr_dict in data["attributes"]
        type = IS.get_type_from_serialization_metadata(
            IS.get_serialization_metadata(attr_dict),
        )
        if !haskey(mgr.data, type)
            mgr.data[type] = Dict{Base.UUID, SupplementalAttribute}()
        end
        #attr = deserialize(type, attr_dict)

        api_attr = deserialize_openapi_struct(type, attr_dict)
        attr = build_model_struct(
            api_attr, portfolio, attr_dict["__metadata__"]; serialized=attr_dict,
        )

        uuid = IS.get_uuid(attr)
        if haskey(mgr.data[type], uuid)
            error("Bug: duplicate UUID in attributes container: type=$type uuid=$uuid")
        end
        mgr.data[type][uuid] = attr
        IS.set_shared_system_references!(attr, refs)
    end

    return mgr
end

function deserialize_components!(portfolio::Portfolio, raw)
    # Convert the array of components into type-specific arrays to allow addition by type.
    # Need to maintain an order here and deserialize regions first so they can
    # be referenced when deserializing technologies
    technologies = OrderedDict{Type, Vector{Dict}}()
    regions = OrderedDict{Type, Vector{Dict}}()
    for component in raw["components"]
        type = IS.get_type_from_serialization_data(component)
        if type <: RegionTopology
            components = get(regions, type, nothing)
            if components === nothing
                components = Vector{Dict}()
                regions[type] = components
            end
        else
            components = get(technologies, type, nothing)
            if components === nothing
                components = Vector{Dict}()
                technologies[type] = components
            end
        end
        push!(components, component)
    end
    data = merge(regions, technologies)

    # Add each type to this as we parse.
    parsed_types = Set()

    function is_matching_type(type, types)
        return any(x -> type <: x, types)
    end

    function deserialize_and_add!(;
        skip_types=nothing,
        include_types=nothing,
        post_add_func=nothing,
    )
        for (type, components) in data
            type in parsed_types && continue
            if !isnothing(skip_types) && is_matching_type(type, skip_types)
                continue
            end
            if !isnothing(include_types) && !is_matching_type(type, include_types)
                continue
            end
            for component in components
                handle_deserialization_special_cases!(component, type)
                #TODO: See if component cache is needed
                api_component = deserialize_openapi_struct(type, component)
                model_component =
                    build_model_struct(
                        api_component, portfolio, component["__metadata__"];
                        serialized=component,
                    )

                #TODO: skip_validation currently set to true, review the IS validation
                IS.add_component!(portfolio.data, model_component; skip_validation=true)

                if !isnothing(post_add_func)
                    post_add_func(model_component)
                end
            end
            push!(parsed_types, type)
        end
    end

    deserialize_and_add!()
end

function build_model_struct(
    base_struct, portfolio::Portfolio, metadata::Dict{String, Any};
    serialized=nothing,
)
    vals = Dict{Symbol, Any}()
    struct_type = typeof(base_struct)

    #TODO: Add get_component wrappers for IS functions
    for (name, type) in zip(fieldnames(struct_type), fieldtypes(struct_type))
        if name in ENCODED_FIELDS
            vals[name] = deserialize_custom_types(name, base_struct, portfolio)
        else
            vals[name] = getfield(base_struct, name)
        end
    end

    struct_type_string = metadata["type"]
    struct_type = getproperty(PowerSystemsInvestmentsPortfolios, Symbol(struct_type_string))
    if serialized !== nothing
        if haskey(serialized, "internal")
            vals[:internal] =
                IS.deserialize(InfrastructureSystemsInternal, serialized["internal"])
        end
        if haskey(serialized, "ext")
            vals[:ext] = serialized["ext"]
        end
    end
    if struct_type <: SupplyTechnology
        delete!(vals, :outage_factor)
        serialized !== nothing && haskey(serialized, "outage_factors") ||
            error("SupplyTechnology requires explicit planned/forced outage_factors")
        vals[:outage_factors] = IS.deserialize(
            fieldtype(struct_type, :outage_factors), serialized["outage_factors"],
        )
    end
    # The generated OpenAPI storage schema predates StorageCapitalCost.
    if struct_type <: StorageTechnology
        energy = pop!(vals, :capital_costs_energy)
        charge = pop!(vals, :capital_costs_charge)
        discharge = pop!(vals, :capital_costs_discharge)
        if serialized !== nothing && haskey(serialized, "capital_costs_storage")
            vals[:capital_costs_storage] =
                IS.deserialize(StorageCapitalCost, serialized["capital_costs_storage"])
        else
            vals[:capital_costs_storage] = StorageCapitalCost(
                charge === nothing ? LinearCurve(0.0) : charge,
                discharge === nothing ? LinearCurve(0.0) : discharge,
                energy === nothing ? LinearCurve(0.0) : energy,
                0.0,
            )
        end
    end
    if !hasfield(struct_type, :id)
        delete!(vals, :id)
    end
    if haskey(metadata, "parameters")
        parameter_string = metadata["parameters"][1]
        #TODO: Generalize this later. Will all future parameterizing be with PSY structs?
        parameter = getproperty(PowerSystems, Symbol(parameter_string))
        model_struct = struct_type{parameter}(; vals...)
    else
        model_struct = struct_type(; vals...)
    end

    return model_struct
end

function IS.deserialize(
    ::Type{T},
    data::Dict,
    component_cache::Dict,
) where {T <: IS.InfrastructureSystemsComponent}
    vals = Dict{Symbol, Any}()
    for (name, type) in zip(fieldnames(T), fieldtypes(T))
        field_name = string(name)
        if haskey(data, field_name)
            val = data[field_name]
        else
            continue
        end
        if val isa Dict && haskey(val, IS.METADATA_KEY)
            vals[name] = deserialize_uuid_handling(
                IS.get_type_from_serialization_metadata(IS.get_serialization_metadata(val)),
                val,
                component_cache,
            )
        else
            vals[name] = deserialize_uuid_handling(type, val, component_cache)
        end
    end

    type = IS.get_type_from_serialization_metadata(data[IS.METADATA_KEY])

    base_struct = deserialize_openapi_struct(type, vals...)

    return base_struct
end

# Handle cases where the data types in the OpenAPI struct do not match the PSIP struct
function serialize_custom_types(field, technology::T) where {T <: _CONTAINS_SHOULD_ENCODE}

    #For fields with references to other structs, serialize with
    #the id of that struct and convert enums to strings
    if field in [
        :region,
        :eligible_regions,
        :eligible_resources,
        :eligible_technologies,
        :eligible_demand,
    ]
        comps = getfield(technology, field)
        val = [get_id(c) for c in comps]
    elseif field == :requirements
        val = Int64[get_id(r) for r in get_requirements(technology)]
    elseif field in [:start_region, :end_region, :start_node, :end_node]
        val = get_id(getfield(technology, field))
    elseif field in [:prime_mover_type, :storage_tech, :bus_type]
        val = string(getfield(technology, field))
    elseif field == :fuel
        val = [string(f) for f in getfield(technology, field)]
    elseif field == :heat_rate_mmbtu_per_mwh
        fuel_params = getfield(technology, field)
        val = Dict{String, ValueCurve}()
        for (k, v) in fuel_params
            val[string(k)] = v
        end
    elseif field in [:co2, :cofire_start_limits, :cofire_level_limits]
        fuel_params = getfield(technology, field)
        val = Dict{String, Float64}()
        for (k, v) in fuel_params
            val[string(k)] = v
        end
    elseif field == :uuid
        val = string(IS.get_uuid(technology))
    elseif field == :conformity
        val = string(get_conformity(technology))
    else
        val = getfield(technology, field)
    end

    return val
end
function deserialize_custom_types(name, base_struct::OpenAPI.APIModel, portfolio::Portfolio)
    if name in [:region, :eligible_regions]
        val = collect(
            IS.get_components(
                x -> get_id(x) in getfield(base_struct, name),
                RegionTopology,
                portfolio.data,
            ),
        )
    elseif name == :requirements
        val = collect(
            IS.get_components(
                x -> get_id(x) in getfield(base_struct, name),
                Requirement,
                portfolio.data,
            ),
        )
    elseif name == :eligible_resources
        val = collect(
            IS.get_components(
                x -> get_id(x) in getfield(base_struct, name),
                ResourceTechnology,
                portfolio.data,
            ),
        )
    elseif name == :eligible_technologies
        val = collect(
            IS.get_components(
                x -> get_id(x) in getfield(base_struct, name),
                Technology,
                portfolio.data,
            ),
        )
    elseif name == :eligible_demand
        val = collect(
            IS.get_components(
                x -> get_id(x) in getfield(base_struct, name),
                DemandTechnology,
                portfolio.data,
            ),
        )
    elseif name in [
        :capacity_limits,
        :capacity_limits_discharge,
        :capacity_limits_charge,
        :capacity_limits_energy,
        :duration_limits,
        :angle_limits,
    ]
        data = getfield(base_struct, name)
        if isnothing(data)
            val = nothing
        else
            val = (min=data["min"], max=data["max"])
        end
    elseif name == :efficiency
        data = getfield(base_struct, name)
        val = (in=data["in"], out=data["out"])
    elseif name in [:ramp_limits, :time_limits]
        data = getfield(base_struct, name)
        val = (up=data["up"], down=data["down"])
    elseif name in [:start_region, :end_region]
        val = first(
            IS.get_components(
                x -> get_id(x) in getfield(base_struct, name),
                Zone,
                portfolio.data,
            ),
        )
    elseif name in [:start_node, :end_node]
        val = first(
            IS.get_components(
                x -> get_id(x) in getfield(base_struct, name),
                Node,
                portfolio.data,
            ),
        )
    elseif name == :prime_mover_type
        val = PrimeMovers(getfield(base_struct, name))
    elseif name == :fuel
        val = [ThermalFuels(f) for f in getfield(base_struct, name)]
    elseif name == :bus_type
        val = ACBusTypes(getfield(base_struct, name))
    elseif name == :co2
        data = getfield(base_struct, name)
        val = Dict{ThermalFuels, Float64}()
        for (k, v) in data
            val[ThermalFuels(k)] = v
        end
    elseif name == :heat_rate_mmbtu_per_mwh
        data = getfield(base_struct, name)
        val = Dict{ThermalFuels, ValueCurve}()
        for (k, v) in data
            val[ThermalFuels(k)] = v
        end
    elseif name in [:cofire_level_limits, :cofire_start_limits]
        data = getfield(base_struct, name)
        val = Dict{ThermalFuels, MinMax}()
        for (k, v) in data
            val[ThermalFuels(k)] = (min=v["min"], max=v["max"])
        end
    elseif name == :storage_tech
        val = StorageTech(getfield(base_struct, name))
    elseif name == :uuid
        val = Base.UUID(getfield(base_struct, name))
    elseif name == :conformity
        val = LoadConformity(getfield(base_struct, name))
    end

    return val
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
    to_python=false,
    pretty=false,
    force=false,
    runchecks=false,
)
    IS.prepare_for_serialization_to_file!(portfolio.data, filename; force=force)
    data = to_json(portfolio; pretty=pretty)

    # Additional functionality to write the timeseries metadata, supplemental attributes, etc.
    # to a DB file so that they can be read into a Portfolio in pyPSIP, since that is what is supported by 
    # infrasys. Long-term, we should probably either make it so infrasys supports deserializing without a DB
    # Or add an option to write this DB file in the serialization functions in IS
    if to_python
        directory = dirname(filename)
        metadata_path = joinpath(directory, IS.DB_FILENAME)
        ts_store = portfolio.data.time_series_manager.metadata_store #Is there a getter for this?
        attr_store = portfolio.data.supplemental_attribute_manager.associations #getter?
        dst = SQLite.DB(metadata_path)
        IS.backup(dst, ts_store.db)

        # Add supplemental attribute association to the same DB
        schema = [
            "id INTEGER PRIMARY KEY",
            "attribute_uuid TEXT NOT NULL",
            "attribute_type TEXT NOT NULL",
            "component_uuid TEXT NOT NULL",
            "component_type TEXT NOT NULL",
        ]
        schema_text = join(schema, ",")
        DBInterface.execute(
            dst,
            "CREATE TABLE supplemental_attribute_associations ($(schema_text))",
        )

        # Would probably be better to directly copy the table from one DB to another
        df = DataFrames.DataFrame(
            DBInterface.execute(attr_store.db, "SELECT * FROM supplemental_attributes"),
        )
        df[!, "id"] = 1:DataFrames.nrow(df)

        SQLite.load!(df, dst, "supplemental_attribute_associations")

        cols = DataFrames.DataFrame(
            DBInterface.execute(dst, "PRAGMA table_info(time_series_associations)"),
        )

        #Check if timeseries metadata columns need to be renamed to be consistent with infrasys 
        if in("resolution_ms", cols[!, "name"])
            DBInterface.execute(
                dst,
                "ALTER TABLE time_series_associations RENAME COLUMN resolution_ms TO resolution",
            )
        end
        if in("horizon_ms", cols[!, "name"])
            DBInterface.execute(
                dst,
                "ALTER TABLE time_series_associations RENAME COLUMN horizon_ms TO horizon",
            )
        end

        # Update h5 file to store this updated DB
        metadata = open(metadata_path, "r") do io
            read(io)
        end
        ts_filename = splitext(basename(filename))[1] * "_time_series_storage.h5"
        ts_path = joinpath(directory, ts_filename)
        HDF5.h5open(ts_path, "r+") do file
            if IS.METADATA_TABLE_NAME in keys(file)
                HDF5.delete_object(file, IS.HDF5_TS_METADATA_ROOT_PATH)
            end
            file[IS.HDF5_TS_METADATA_ROOT_PATH] = metadata
        end
    end

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
If assign_new_uuids = true, generate new UUIDs for the portfolio and all components.

Warning: time series data is not restored by this method. If that is needed, use the normal
process to construct the portfolio from a serialized JSON file instead, such as with
`Portfolio("portfolio.json")`.
"""
function IS.from_json(
    io::Union{IO, String},
    ::Type{Portfolio};
    runchecks=true,
    assign_new_uuids=false,
    kwargs...,
)
    data = JSON3.read(io, Dict)
    # These objects could be removed in to_json(portfolio). Doing it here will allow us to
    # keep that JSON string fully consistent with time series and potentially use it in the
    # future.
    for component in data["data"]["components"]
        if haskey(component, "time_series_container")
            empty!(component["time_series_container"])
        end
    end

    portfolio = from_dict(Portfolio, data; kwargs...)
    _post_deserialize_handling(
        portfolio;
        runchecks=runchecks,
        assign_new_uuids=assign_new_uuids,
    )
    return portfolio
end

function _post_deserialize_handling(
    portfolio::Portfolio;
    runchecks=true,
    assign_new_uuids=false,
)
    # runchecks && check(portfolio)
    if assign_new_uuids
        IS.assign_new_uuid!(portfolio)
        for component in get_components(Technology, portfolio)
            assign_new_uuid!(portfolio, component)
        end
        for component in
            IS.get_masked_components(IS.InfrastructureSystemsComponent, portfolio.data)
            assign_new_uuid!(portfolio, component)
        end
        # Note: this does not change UUIDs for time series data because they are
        # shared with components.
    end
end
