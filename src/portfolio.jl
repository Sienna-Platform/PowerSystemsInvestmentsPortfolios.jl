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
get_technology(portfolio::Portfolio, uuid::Base.UUID) =
    IS.get_component(portfolio.data, uuid)
get_technology(portfolio::Portfolio, uuid::String) =
    IS.get_component(portfolio.data, Base.UUID(uuid))

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
    return IS.add_time_series!(portfolio.data, component, time_series; features...)
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
    return IS.add_time_series!(portfolio.data, technologies, time_series; features...)
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
Add a RegionTopology to the portfolio.

Throws ArgumentError if the region's name is already stored for its concrete type.
Throws ArgumentError if any region-specific rule is violated.
Throws InvalidValue if any of the region's field values are outside of defined valid
range.

# Examples

```julia
portfolio = Portfolio(...)

# Add a single technology.
add_region!(portfolio, zone)

# Add many at once.
foreach(x -> add_region!(portfolio, x), Iterators.flatten((buses, generators)))
```
"""
function add_region!(
    portfolio::Portfolio,
    zone::T;
    skip_validation=false,
    kwargs...,
) where {T <: RegionTopology}
    deserialization_in_progress = _is_deserialization_in_progress(portfolio)
    skip_validation = _validate_or_skip!(portfolio, zone, skip_validation)
    IS.add_component!(
        portfolio.data,
        zone;
        allow_existing_time_series=deserialization_in_progress,
        skip_validation=skip_validation,
        kwargs...,
    )

    return
end

"""
Returns an iterator of regions. T can be concrete or abstract.
Call collect on the result if an array is desired.

# Examples

```julia
iter = Portfolio.get_regions(RegionTopology, portfolio)
regions = collect(Portfolio.get_regions(RegionTopology, portfolio))
```

"""

function get_regions(::Type{T}, portfolio::Portfolio;) where {T <: RegionTopology}
    return IS.get_components(T, portfolio.data)
end

"""
Get the region of type T with name. Returns nothing if no region matches. If T is an abstract
type then the names of regions across all subtypes of T must be unique.

Throws ArgumentError if T is not a concrete type and there is more than one region with
requested name
"""
function get_region(
    ::Type{T},
    portfolio::Portfolio,
    name::AbstractString,
) where {T <: RegionTopology}
    return IS.get_component(T, portfolio.data, name)
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
Return the supplemental attribute with the given uuid.

Throws ArgumentError if the attribute is not stored.
"""
function get_supplemental_attribute(p::Portfolio, uuid::Base.UUID)
    return IS.get_supplemental_attribute(p.data, uuid)
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
