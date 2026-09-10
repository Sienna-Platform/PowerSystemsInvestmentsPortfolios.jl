const PORTFOLIO_KWARGS =
    Set((:name, :description, :data_source, :run_checks, :unit_portfolio))

const DATA_FORMAT_VERSION = "0.1.0"

const DEFAULT_AGGREGATION = PSY.Area

"""
Create a default empty PowerSystems.System for portfolio initialization.
"""
function DEFAULT_SYSTEM()
    return PSY.System(100.0)
end

"""
    PortfolioMetadata

Stores metadata about the portfolio.

# Fields

  - `name::Union{Nothing, String}`: Name of the portfolio
  - `description::Union{Nothing, String}`: Description of the portfolio
  - `data_source::Union{Nothing, String}`: Source of the portfolio data
"""
mutable struct PortfolioMetadata <: IS.InfrastructureSystemsType
    name::Union{Nothing, String}
    description::Union{Nothing, String}
    data_source::Union{Nothing, String}
end

"""
    PortfolioFinancialData

Stores financial data about the portfolio.

# Fields

  - `base_year::Int64`: Base economic year. All costs will be converted to a net present value in this year.
  - `discount_rate::Float64`: Discount rate for financial calculations
  - `inflation_rate::Float64`: Inflation rate for cost adjustments
  - `interest_rate::Float64`: Interest rate for financing calculations
"""
mutable struct PortfolioFinancialData <: IS.InfrastructureSystemsType
    base_year::Int64
    discount_rate::Float64
    inflation_rate::Float64
    interest_rate::Float64
end

mutable struct Portfolio <: IS.InfrastructureSystemsType
    aggregation::Type{<:Union{PSY.ACBus, PSY.AggregationTopology}}
    data::IS.SystemData # Inputs to the model
    base_system::PSY.System #Base system storing existing data
    investment_schedule::Union{Nothing, InvestmentScheduleResults} # Investment decisions container i.e., model outputs. Container TBD
    time_series_directory::Union{Nothing, String}
    financial_data::Union{Nothing, PortfolioFinancialData}
    metadata::PortfolioMetadata
    internal::IS.InfrastructureSystemsInternal

    function Portfolio(
        aggregation,
        data,
        base_system::PSY.System,
        investment_schedule::Union{Nothing, InvestmentScheduleResults},
        internal::IS.InfrastructureSystemsInternal;
        time_series_directory=nothing,
        financial_data=nothing,
        name=nothing,
        description=nothing,
        data_source=nothing,
        kwargs...,
    )
        return new(
            aggregation,
            data,
            base_system,
            investment_schedule,
            time_series_directory,
            financial_data,
            PortfolioMetadata(name, description, data_source),
            internal,
        )
    end
end

"""
Construct an empty `Portfolio`. Useful for building a Portfolio from scratch.
"""
function Portfolio(; kwargs...)
    data = PSY._create_system_data_from_kwargs(; kwargs...)
    return Portfolio(
        DEFAULT_AGGREGATION,
        data,
        DEFAULT_SYSTEM(),
        nothing,
        IS.InfrastructureSystemsInternal();
        kwargs...,
    )
end

"""
Construct an empty `Portfolio` specifying aggregation. Useful for building a Portfolio from scratch.
"""
function Portfolio(aggregation; kwargs...)
    data = PSY._create_system_data_from_kwargs(; kwargs...)
    return Portfolio(
        aggregation,
        data,
        DEFAULT_SYSTEM(),
        nothing,
        IS.InfrastructureSystemsInternal();
        kwargs...,
    )
end

"""
Construct an empty `Portfolio` specifying base_system. Useful for building a Portfolio from scratch.
"""
function Portfolio(base_system::PSY.System; kwargs...)
    data = PSY._create_system_data_from_kwargs(; kwargs...)
    return Portfolio(
        DEFAULT_AGGREGATION,
        data,
        base_system,
        nothing,
        IS.InfrastructureSystemsInternal();
        kwargs...,
    )
end

"""
Construct an empty `Portfolio` specifying financial data. Useful for building a Portfolio from scratch.
"""
function Portfolio(base_year, discount_rate, inflation_rate, interest_rate; kwargs...)
    data = PSY._create_system_data_from_kwargs(; kwargs...)
    return Portfolio(
        DEFAULT_AGGREGATION,
        data,
        DEFAULT_SYSTEM(),
        nothing,
        InfrastructureSystemsInternal();
        financial_data=PortfolioFinancialData(
            base_year,
            discount_rate,
            inflation_rate,
            interest_rate,
        ),
        kwargs...,
    )
end

"""
Construct an empty `Portfolio` specifying financial data and a base system. Useful for building a Portfolio from scratch.
"""
function Portfolio(
    aggregation,
    base_system,
    base_year,
    discount_rate,
    inflation_rate,
    interest_rate;
    kwargs...,
)
    data = PSY._create_system_data_from_kwargs(; kwargs...)
    return Portfolio(
        aggregation,
        data,
        base_system,
        nothing,
        InfrastructureSystemsInternal();
        financial_data=PortfolioFinancialData(
            base_year,
            discount_rate,
            inflation_rate,
            interest_rate,
        ),
        kwargs...,
    )
end

"""
Construct an empty `Portfolio` specifying financial data. Useful for building a Portfolio from scratch and used in the database parser.
"""
function Portfolio(
    aggregation,
    base_year,
    discount_rate,
    inflation_rate,
    interest_rate;
    kwargs...,
)
    data = PSY._create_system_data_from_kwargs(; kwargs...)
    return Portfolio(
        aggregation,
        data,
        DEFAULT_SYSTEM(),
        nothing,
        InfrastructureSystemsInternal();
        financial_data=PortfolioFinancialData(
            base_year,
            discount_rate,
            inflation_rate,
            interest_rate,
        ),
        kwargs...,
    )
end

"""
Construct an empty `Portfolio` specifying aggregation and data. Useful for building a Portfolio from scratch and used in the database parser.
"""
function Portfolio(data, aggregation; kwargs...)
    return Portfolio(
        aggregation,
        data,
        DEFAULT_SYSTEM(),
        nothing,
        InfrastructureSystemsInternal();
        kwargs...,
    )
end

"""
Return the internal of the portfolio
"""
IS.get_internal(val::Portfolio) = val.internal

"""
Return a user-modifiable dictionary to store extra information.
"""
get_ext(val::Portfolio) = IS.get_ext(val.internal)

"""
Get the base system of the portfolio.
"""
get_base_system(val::Portfolio) = val.base_system

"""
Get the aggregation level of the portfolio.
"""
get_aggregation(val::Portfolio) = val.aggregation

"""
Set the name of the portfolio.
"""
set_name!(val::Portfolio, name::AbstractString) = val.metadata.name = name

"""
Get the name of the portfolio.
"""
get_name(val::Portfolio) = val.metadata.name

"""
Get the financial data of the portfolio.
"""
get_financial_data(val::Portfolio) = val.financial_data

"""
Get the base year of the portfolio.
"""
get_base_year(val::Portfolio) = val.financial_data.base_year

"""
Get the discount rate.
"""
get_discount_rate(val::Portfolio) = val.financial_data.discount_rate

"""
Get the inflation rate.
"""
get_inflation_rate(val::Portfolio) = val.financial_data.inflation_rate

"""
Get the interest rate.
"""
get_interest_rate(val::Portfolio) = val.financial_data.interest_rate

"""
Get the description of the portfolio.
"""
get_description(val::Portfolio) = val.metadata.description

"""
Get the investment schedule of the portfolio.
"""
get_investment_schedule(val::Portfolio) = val.investment_schedule

"""
Return true if checks are enabled on the system.
"""
get_runchecks(val::Portfolio) = val.runchecks[]

"""
Set the description of the portfolio.
"""
set_description!(val::Portfolio, description::AbstractString) =
    val.metadata.description = description

"""
Set the financial data of the portfolio.
"""
set_financial_data!(val::Portfolio, financial_data::PortfolioFinancialData) =
    val.financial_data = financial_data

"""
Set the base year of the portfolio.
"""
set_base_year!(val::Portfolio, base_year::Int64) = val.financial_data.base_year = base_year

"""
Set the discount rate of the portfolio.
"""
set_discount_rate!(val::Portfolio, discount_rate::Float64) =
    val.financial_data.discount_rate = discount_rate

"""
Set the inflation rate of the portfolio.
"""
set_inflation_rate!(val::Portfolio, inflation_rate::Float64) =
    val.financial_data.inflation_rate = inflation_rate

"""
Set the interest rate of the portfolio.
"""
set_interest_rate!(val::Portfolio, interest_rate::Float64) =
    val.financial_data.interest_rate = interest_rate

"""
Set the investment schedule of the portfolio.
"""
set_investment_schedule!(val::Portfolio, investment_schedule::InvestmentScheduleResults) =
    val.investment_schedule = investment_schedule

"""
Set the base system of the portfolio.
"""
set_base_system!(val::Portfolio, system::PSY.System) = val.base_system = system

"""
Add a technology to the portfolio.

Throws ArgumentError if the technology's name is already stored for its concrete type.
Throws ArgumentError if any Technology-specific rule is violated.
Throws InvalidValue if any of the technology's field values are outside of defined valid
range.

# Examples

```julia
portfolio = Portfolio(...)

# Add a single technology.
add_technology!(portfolio, bus)

# Add many at once.
foreach(x -> add_technology!(portfolio, x), Iterators.flatten((buses, generators)))
```
"""
# Holdover from the pre-document serialization path (mirrors PowerSystems' own definition in
# base.jl). The document-based import never sets this flag, so it defaults to `false`; it stays
# as the defensive default `add_technology!` reads for `allow_existing_time_series`.
_is_deserialization_in_progress(portfolio::Portfolio) =
    get(get_ext(portfolio), "deserialization_in_progress", false)

function add_technology!(
    portfolio::Portfolio,
    technology::T;
    skip_validation=false,
    kwargs...,
) where {T <: Technology}

    #check_topology(portfolio.data, component)
    #check_component_addition(portfolio.data, technology; kwargs...)

    deserialization_in_progress = _is_deserialization_in_progress(portfolio)
    # TODO: Attach requirements to technologies or other structs
    #if !deserialization_in_progress
    # Services are attached to devices at deserialization time.
    #    check_for_services_on_addition(portfolio, technology)
    #end

    skip_validation = _validate_or_skip!(portfolio, technology, skip_validation)
    _kwargs = Dict(k => v for (k, v) in kwargs if k !== :static_injector)

    IS.add_component!(
        portfolio.data,
        technology;
        allow_existing_time_series=deserialization_in_progress,
        skip_validation=skip_validation,
        kwargs...,
    )

    return
end

"""
Add many technologies to the portfolio at once.

Throws ArgumentError if the technology's name is already stored for its concrete type.
Throws ArgumentError if any Technology-specific rule is violated.
Throws InvalidValue if any of the technology's field values are outside of defined valid
range.

# Examples

```julia
portfolio = Portfolio(100.0)

generators = [gen1, gen2, gen3]
foreach(x -> add_technologies!(portfolio, x), Iterators.flatten((buses, generators)))
```
"""
function add_technologies!(::Portfolio, technologies)
    foreach(x -> add_technology!(portfolio, x), technologies)
    return
end

"""
Get the technology of type T with name. Returns nothing if no technology matches. If T is an abstract
type then the names of technologies across all subtypes of T must be unique.

See [`get_technologies_by_name`](@ref) for abstract types with non-unique names across subtypes.

Throws ArgumentError if T is not a concrete type and there is more than one technology with
requested name
"""
function get_technology(
    ::Type{T},
    portfolio::Portfolio,
    name::AbstractString,
) where {T <: Technology}
    return IS.get_component(T, portfolio.data, name)
end

"""
Returns an iterator of technologies. T can be concrete or abstract.
Call collect on the result if an array is desired.

# Examples

```julia
iter = Portfolio.get_technologies(ThermalStandard, portfolio)
iter = Portfolio.get_technologies(Generator, portfolio)
thermal_gens = get_technologies(ThermalStandard, portfolio) do gen
    get_available(gen)
end
generators = collect(Portfolio.get_technologies(Generator, portfolio))
```

See also: [`iterate_technologies`](@ref)
"""
function get_technologies(::Type{T}, portfolio::Portfolio;) where {T <: Technology}
    return IS.get_components(T, portfolio.data)
end

"""
Returns an iterator of technologies. T can be concrete or abstract. Specifiy a filter function to
limits the technologies that can be considered. Call collect on the result if an array is desired.

# Examples

```julia
iter = Portfolio.get_technologies(x -> Portfolio.get_available(x), Generator, portfolio)
thermal_gens = get_technologies(ThermalStandard, portfolio) do gen
    get_available(gen)
end
generators = collect(Portfolio.get_technologies(Generator, portfolio))
```

See also: [`iterate_technologies`](@ref)
"""
function get_technologies(
    filter_func::Function,
    ::Type{T},
    portfolio::Portfolio,
) where {T <: Technology}
    return IS.get_components(filter_func, T, portfolio.data)
end

# These are helper functions for debugging problems.
# Searches components linearly, and so is slow compared to the other get_component functions
get_technology(portfolio::Portfolio, id::Int) = IS.get_component(portfolio.data, id)

function _get_technologies_by_name(
    abstract_types,
    data::IS.SystemData,
    name::AbstractString,
)
    _components = []
    for subtype in abstract_types
        component = IS.get_component(subtype, data, name)
        if !isnothing(component)
            push!(_components, component)
        end
    end

    return _components
end

"""
Get the technologies of abstract type T with name. Note that PowerSystemInvestmentPortfolios enforces unique
names on each concrete type but not across concrete types.

See [`get_technology`](@ref) if the concrete type is known.

Throws ArgumentError if T is not an abstract type.
"""
function get_technologies_by_name(
    ::Type{T},
    portfolio::Portfolio,
    name::AbstractString,
) where {T <: Technology}
    return IS.get_components_by_name(T, portfolio.data, name)
end

"""
Gets the technologies of type T where [`get_available`](@ref) is true. Requires type T to have the method get_available implemented.
"""

function get_available_technologies(::Type{T}, portfolio::Portfolio) where {T <: Technology}
    return get_technologies(x -> get_available(x), T, portfolio)
end

"""
Like [`get_technology`](@ref) but also returns `nothing` if the component is not [`get_available`](@ref).
"""
function get_available_technology(
    ::Type{T},
    port::Portfolio,
    args...;
    kwargs...,
) where {T <: Technology}
    return IS.get_available_component(T, port.data, args...; kwargs...)
end

"""
Return true if the component is attached to the system.
"""
function is_attached(technology::T, portfolio::Portfolio) where {T <: Technology}
    return is_attached(T, get_name(technology), portfolio)
end

"""
Return true if the component is attached to the system.
"""
function is_attached(::Type{T}, name, portfolio::Portfolio) where {T <: Technology}
    return !isnothing(get_technology(T, portfolio, name))
end

"""
Throws ArgumentError if the component is not attached to the system.
"""
function throw_if_not_attached(technology::Technology, portfolio::Portfolio)
    if !is_attached(technology, portfolio)
        throw(ArgumentError("$(summary(technology)) is not attached to the system"))
    end
end

"""
Iterates over all techonologies.

# Examples

```julia
for tech in iterate_technologies(portfolio)
    @show tech
end
```

See also: [`get_technologies`](@ref)
"""
function iterate_technologies(portfolio::Portfolio)
    return IS.iterate_components(portfolio.data)
end

"""
Remove all technologies from the portfolio.
"""
function clear_technologies!(portfolio::Portfolio)
    return IS.clear_components!(portfolio.data)
end

"""
Remove all technologies of type T from the portfolio.

Throws ArgumentError if the type is not stored.
"""
function remove_technologies!(portfolio::Portfolio, ::Type{T}) where {T <: Technology}
    components = IS.remove_components!(T, portfolio.data)
    for component in components
        handle_component_removal!(portfolio, component)
    end
    return components
end

"""
Remove all technologies of type T from the portfolio. Provide a filter function to
only remove technologies matching the filter.

Throws ArgumentError if the type is not stored.
"""
function remove_technologies!(
    filter_func::Function,
    portfolio::Portfolio,
    ::Type{T},
) where {T <: Technology}
    components = collect(get_technologies(filter_func, T, portfolio))
    for component in components
        remove_technology!(portfolio, component)
    end
    return components
end

handle_technology_removal!(::Portfolio, technology::Technology) = nothing

function handle_component_removal!(portfolio::Portfolio, technology::Technology)
    _handle_technology_removal_common!(technology)
    # This may have to be refactored if handle_component_removal! needs to be implemented
    # for a subtype.
    # TODO: Check if clear_services makes sense for technologies
    # clear_services!(technology)
    return
end

"""
Clear unit system information from a technology. Currently a no-op placeholder.
"""
clear_units!(::Technology) = nothing

function _handle_technology_removal_common!(technology)
    clear_units!(technology)
end

###################################
########### Time Series ###########
###################################

"""
Add time series data to a technology.

Throws ArgumentError if the component is not stored in the portfolio.
"""
function add_time_series!(
    portfolio::Portfolio,
    component::Technology,
    time_series::PSY.TimeSeriesData;
    features...,
)
    feature_dict =
        isempty(features) ? nothing :
        Dict{String, Any}(string(k) => v for (k, v) in features)
    return IS.add_time_series!(
        portfolio.data,
        component,
        time_series;
        features=feature_dict,
    )
end

"""
Add the same time series data to multiple components.

This is significantly more efficent than calling `add_time_series!` for each component
individually with the same data because in this case, only one time series array is stored.

Throws ArgumentError if a component is not stored in the portfolio.
"""
function add_time_series!(
    portfolio::Portfolio,
    technologies,
    time_series::PSY.TimeSeriesData;
    features...,
)
    feature_dict =
        isempty(features) ? nothing :
        Dict{String, Any}(string(k) => v for (k, v) in features)
    return IS.add_time_series!(
        portfolio.data,
        technologies,
        time_series;
        features=feature_dict,
    )
end

"""
Return the compression settings used for portfolio data such as time series arrays.
"""
get_compression_settings(portfolio::Portfolio) = IS.get_compression_settings(portfolio.data)

"""
Return the resolution for all time series.
"""
get_time_series_resolution(portfolio::Portfolio) =
    IS.get_time_series_resolutions(portfolio.data)

"""
Remove all time series data from the portfolio.
"""
function clear_time_series!(portfolio::Portfolio)
    return IS.clear_time_series!(portfolio.data)
end

"""
Return an iterator of time series in order of initial time.

Note that passing a filter function can be much slower than the other filtering parameters
because it reads time series data from media.

Call `collect` on the result to get an array.

# Arguments

  - `data::SystemData`: system
  - `filter_func = nothing`: Only return time series for which this returns true.
  - `type = nothing`: Only return time series with this type.
  - `name = nothing`: Only return time series matching this value.

# Examples

```julia
for time_series in get_time_series_multiple(sys)
    @show time_series
end

ts = collect(get_time_series_multiple(sys; type=SingleTimeSeries))
```
"""
function IS.get_time_series_multiple(
    port::Portfolio,
    filter_func=nothing;
    type=nothing,
    name=nothing,
)
    return get_time_series_multiple(port.data, filter_func; type=type, name=name)
end

"""
Returns counts of time series including attachments to components and supplemental
attributes.
"""
get_time_series_counts(port::Portfolio) = IS.get_time_series_counts(port.data)

"""
Remove the time series data for a component and time series type.
"""
function remove_time_series!(
    portfolio::Portfolio,
    ::Type{T},
    component::Technology,
    name::String,
) where {T <: PSY.TimeSeriesData}
    return IS.remove_time_series!(portfolio.data, T, component, name)
end

"""
Remove all the time series data for a time series type.
"""
function remove_time_series!(
    portfolio::Portfolio,
    ::Type{T},
) where {T <: PSY.TimeSeriesData}
    return IS.remove_time_series!(portfolio.data, T)
end

"""
Remove a technology from the portfolio by its value.

Throws ArgumentError if the technology is not stored.
"""
function remove_technology!(portfolio::Portfolio, technology::T) where {T <: Technology}
    check_technology_removal(portfolio, technology)
    IS.remove_component!(portfolio.data, technology)
    handle_technology_removal!(portfolio, technology)
    return
end

"""
Remove a technology from the portfolio by its name.

Throws ArgumentError if the component is not stored.
"""
function remove_technology!(
    ::Type{T},
    portfolio::Portfolio,
    name::AbstractString,
) where {T <: Technology}
    tech = IS.remove_component!(T, portfolio.data, name)
    handle_technology_removal!(portfolio, tech)
    return
end

"""
Throws ArgumentError if a PowerSystemsInvestmentPorfolio rule blocks removal from the system.
"""
function check_technology_removal(
    portfolio::Portfolio,
    technology::T,
) where {T <: Technology}
    # TODO: Implement checks if needed
    if 1 == 2
        throw(
            ArgumentError(
                "Tech $(get_name(technology)) cannot be removed for a specific logic",
            ),
        )
        return
    end
end

"""
Check to see if the technology of type T with name exists.
"""
function has_technology(
    ::Type{T},
    portfolio::Portfolio,
    name::AbstractString,
) where {T <: Portfolio}
    return IS.has_component(T, portfolio.data.components, name)
end

###########################
######### Regions #########
###########################

"""
Attach a PowerSystems topology component (`Area`, `LoadZone`, bus, arc, ...) to the
portfolio. The component is stored in the portfolio's base system; callers never need to
reach into `base_system` directly.

The portfolio's convention is natural units, but `Area`/`LoadZone` (and other system-base
topology) store `peak_active_power`/`peak_reactive_power` internally in device base. To keep
the natural-units contract, pass those fields as `add_topology!` keyword arguments in
natural units (MW / MVAr) rather than to the raw `PSY.*` constructor: they are applied
through the units-tagged setters *after* attachment, once the system base power is synced. A
nonzero power value left on the raw constructor is device-base and triggers a warning.

Throws ArgumentError if the component's name is already stored for its concrete type, any
PowerSystems rule is violated, or a power keyword is given for a topology type that has no
such (system-base) field.

# Examples

```julia
portfolio = Portfolio(...)

# Add a bus (no power fields; base_voltage is natural kV).
add_topology!(portfolio, ACBus(; name="bus_1", base_voltage=138.0, ...))

# Add an Area with its peak power in natural units (MW / MVAr).
add_topology!(
    portfolio,
    PSY.Area(; name="west");
    peak_active_power=250.0,
    peak_reactive_power=50.0,
)

# Add many at once.
foreach(x -> add_topology!(portfolio, x), buses)
```
"""
function add_topology!(
    portfolio::Portfolio,
    topology::PSY.Topology;
    peak_active_power=nothing,
    peak_reactive_power=nothing,
    kwargs...,
)
    _check_topology_power_units(topology, peak_active_power, peak_reactive_power)
    PSY.add_component!(portfolio.base_system, topology; kwargs...)
    # Attachment has synced the system base power, so the units-tagged setters can now
    # convert these natural-units (MW / MVAr) values into the component's device-base storage.
    isnothing(peak_active_power) ||
        PSY.set_peak_active_power!(topology, peak_active_power * PSY.MW)
    isnothing(peak_reactive_power) ||
        PSY.set_peak_reactive_power!(topology, peak_reactive_power * PSY.MVAr)
    return
end

# Guard the natural-units power keywords of `add_topology!`. They only apply to system-base
# topology (`Area`, `LoadZone`, ...) whose power fields per-unitize against the system base;
# for anything else they are meaningless and rejected. When the keyword is omitted but the
# raw constructor already stored a nonzero (device-base) power, warn: that value is not in
# the natural units the portfolio otherwise uses.
function _check_topology_power_units(topology, peak_active_power, peak_reactive_power)
    is_system_base = PSY.base_power_kind(topology) isa PSY.SystemBasePower
    if !is_system_base
        if !isnothing(peak_active_power) || !isnothing(peak_reactive_power)
            throw(
                ArgumentError(
                    "peak_active_power / peak_reactive_power keywords are only valid for " *
                    "system-base topology (e.g. Area, LoadZone); got $(typeof(topology)).",
                ),
            )
        end
        return
    end
    for (field, provided) in (
        (:peak_active_power, peak_active_power),
        (:peak_reactive_power, peak_reactive_power),
    )
        isnothing(provided) || continue
        hasproperty(topology, field) || continue
        getproperty(topology, field) == 0 && continue
        @warn(
            "add_topology!: $(summary(topology)) was constructed with a nonzero $field " *
            "that is stored in device base, not the natural units the portfolio uses. " *
            "Pass $field in natural units (MW / MVAr) as an add_topology! keyword instead.",
            maxlog = 1,
        )
    end
    return
end

# Backwards-compatible alias for the older "region" naming.
add_region!(portfolio::Portfolio, topology::PSY.Topology; kwargs...) =
    add_topology!(portfolio, topology; kwargs...)

"""
Returns an iterator of the portfolio's topology components of type `T` (concrete or
abstract). Call `collect` on the result if an array is desired.

# Examples

```julia
iter = Portfolio.get_topologies(PSY.Topology, portfolio)
areas = collect(Portfolio.get_topologies(PSY.Area, portfolio))
```
"""
function get_topologies(::Type{T}, portfolio::Portfolio) where {T <: PSY.Topology}
    return PSY.get_components(T, portfolio.base_system)
end

# Backwards-compatible alias for the older "region" naming.
get_regions(::Type{T}, portfolio::Portfolio) where {T <: PSY.Topology} =
    get_topologies(T, portfolio)

"""
Get the topology component of type `T` with `name`. Returns `nothing` if none matches. If
`T` is abstract then names across all subtypes of `T` must be unique.

Throws ArgumentError if `T` is not concrete and more than one component has the requested
name.
"""
function get_topology(
    ::Type{T},
    portfolio::Portfolio,
    name::AbstractString,
) where {T <: PSY.Topology}
    return PSY.get_component(T, portfolio.base_system, name)
end

# Backwards-compatible alias for the older "region" naming. Adds a method to the existing
# `get_region` generic (whose other methods are per-technology accessors).
get_region(
    ::Type{T},
    portfolio::Portfolio,
    name::AbstractString,
) where {T <: PSY.Topology} = get_topology(T, portfolio, name)

"""
Remove a topology component from the portfolio's base system.
"""
function remove_topology!(portfolio::Portfolio, topology::PSY.Topology)
    PSY.remove_component!(portfolio.base_system, topology)
    return
end

################################
######### Requirements #########
################################

"""
Add policy requirement to portfolio
"""
function add_requirement!(portfolio::Portfolio, req::Requirement)
    #return PSY.add_service!(portfolio.data, req)
    #skip_validation = false
    #skip_validation = _validate_or_skip!(sys, service, skip_validation)
    return IS.add_component!(portfolio.data, req, skip_validation=false)
end

"""
Returns an iterator of requirements. T can be concrete or abstract.
Call collect on the result if an array is desired.

# Examples

```julia
iter = Portfolio.get_requirements(Requirement, portfolio)
requirements = collect(Portfolio.get_requirements(Requirement, portfolio))
```
"""
function get_requirements(::Type{T}, portfolio::Portfolio;) where {T <: Requirement}
    return IS.get_components(T, portfolio.data)
end

function get_requirements(portfolio::Portfolio)
    return get_requirements(Requirement, portfolio)
end

"""
Get the requirement of type T with name. Returns nothing if no requirement matches. If T is an abstract
type then the names of requirements across all subtypes of T must be unique.

Throws ArgumentError if T is not a concrete type and there is more than one requirement with
requested name
"""
function get_requirement(
    ::Type{T},
    portfolio::Portfolio,
    name::AbstractString,
) where {T <: Requirement}
    return IS.get_component(T, portfolio.data, name)
end

"""
Return a vector of devices contributing to the requirement.
"""
function get_contributing_technologies(
    port::Portfolio,
    requirement::T,
) where {T <: Requirement}
    #throw_if_not_attached(requirement, port)
    return [
        x for x in get_technologies(supports_requirements, Technology, port) if
        has_requirement(x, requirement)
    ]
end

###########################################
######### Supplemental Attributes #########
###########################################

get_id(val::IS.SupplementalAttribute) = IS.get_id(val)
set_id!(val::IS.SupplementalAttribute, id) = IS.set_id!(val, id)

"""
Add a supplemental attribute to a technology. The attribute may already be attached to a
different component.
"""
function add_supplemental_attribute!(
    p::Portfolio,
    component::IS.InfrastructureSystemsComponent,
    attribute::IS.SupplementalAttribute,
)
    return IS.add_supplemental_attribute!(p.data, component, attribute)
end

"""
Remove the supplemental attribute from the component. The attribute will be removed from the
system if it is not attached to any other component.
"""
function remove_supplemental_attribute!(
    p::Portfolio,
    component::IS.InfrastructureSystemsComponent,
    attribute::IS.SupplementalAttribute,
)
    return IS.remove_supplemental_attribute!(p.data, component, attribute)
end

"""
Remove all supplemental attributes with the given type from the system.
"""
function remove_supplemental_attributes!(
    ::Type{T},
    p::Portfolio,
) where {T <: IS.SupplementalAttribute}
    return IS.remove_supplemental_attributes!(p.data, T)
end

"""
Return the supplemental attribute with the given id.

Throws ArgumentError if the attribute is not stored.
"""
function get_supplemental_attribute(p::Portfolio, id::Int)
    return IS.get_supplemental_attribute(p.data, id)
end

"""
Return a vector of supplemental attributes of the given type

Throws ArgumentError if the attribute is not stored.
"""
function get_supplemental_attributes(
    ::Type{T},
    p::Portfolio,
) where {T <: IS.SupplementalAttribute}
    return IS.get_supplemental_attributes(T, p.data)
end

"""
Return a Vector of supplemental_attributes. T can be concrete or abstract.

# Arguments

  - `T`: supplemental_attribute type
  - `supplemental_attributes::SupplementalAttributes`: SupplementalAttributes in the portfolio
"""
function get_supplemental_attributes(
    ::Type{T},
    supplemental_attributes::IS.InfrastructureSystemsComponent,
) where {T <: IS.SupplementalAttribute}
    return IS.get_supplemental_attributes(T, supplemental_attributes)
end

"""
Return the internal of a supplemental attribute, required to add to IS for SupplementalAttributes to work
"""
IS.get_internal(val::IS.SupplementalAttribute) = val.internal
