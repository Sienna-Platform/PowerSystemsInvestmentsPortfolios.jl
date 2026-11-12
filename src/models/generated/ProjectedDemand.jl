#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct ProjectedDemand{T <: PSY.StaticInjection} <: DemandTechnology
        requirements::Vector{Requirement}
        available::Bool
        name::String
        curtailment_cost::PSY.ValueCurve
        id::Int64
        max_demand_advance::Float64
        flexible_fraction::Float64
        max_demand_curtailment::Float64
        max_demand_delay::Float64
        conformity::PSY.LoadConformity
        growth_rate::Float64
        power_systems_type::String
        value_of_lost_load::Float64
        internal::InfrastructureSystemsInternal
        ext::Dict
        region::Vector{RegionTopology}
        construction_year::Int64
        shift_cost::PSY.ValueCurve
        peak_demand_mw::Float64
        shift_efficiency::Float64
    end

A projected demand in a region: an exogenous load profile that must be served, with optional voluntary curtailment and time shifting. Its peak comes from its existing loads in the base system or, for a new demand, from peak_demand_mw.

# Arguments
- `requirements::Vector{Requirement}`: (default: `Vector()`) List of requirements (i.e. reserve margin, capacity requirements, energy share requirements) that are associated with a technology
- `available::Bool`: (default: `true`) Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`)
- `name::String`: The technology name
- `curtailment_cost::PSY.ValueCurve`: (default: `LinearCurve(0.0)`) Cost of voluntary curtailment (USD/MWh). A LinearCurve is a single price for all curtailable demand. A PiecewiseIncrementalCurve gives tiers whose x coordinates are fractions of demand, from 0 to max_demand_curtailment, and whose slopes are prices (USD/MWh)
- `id::Int64`: ID for individual projected demand
- `max_demand_advance::Float64`: (default: `0.0`) Maximum number of hours that flexible demand can be served in advance (hours)
- `flexible_fraction::Float64`: (default: `0.0`) Fraction of demand that can be shifted in time
- `max_demand_curtailment::Float64`: (default: `0.0`) Maximum fraction of demand that can be curtailed voluntarily
- `max_demand_delay::Float64`: (default: `0.0`) Maximum number of hours that flexible demand can be delayed (hours)
- `conformity::PSY.LoadConformity`: (default: `PSY.LoadConformity.UNDEFINED`) Whether the demand is conforming (grows by growth_rate) or non-conforming (does not grow). Must be set for new demands.
- `growth_rate::Float64`: (default: `0.0`) The annual growth rate of the demand, used to scale present-day loads into future projections. Only used for conforming loads
- `power_systems_type::String`: Corresponding type in PowerSystems.jl to be used in PCM modeling
- `value_of_lost_load::Float64`: (default: `1e8`) Cost of involuntary shedding of the demand that cannot be curtailed (USD/MWh)
- `internal::InfrastructureSystemsInternal`: (default: `InfrastructureSystemsInternal()`) (**Do not modify.**) PowerSystemsInvestmentsPortfolios.jl internal reference
- `ext::Dict`: (default: `Dict()`) Optional dictionary to provide additional data
- `region::Vector{RegionTopology}`: (default: `Vector()`) Zone or node where the demand is located
- `construction_year::Int64`: (default: `2020`) The year in which a new demand starts. Should only be used for new demands.
- `shift_cost::PSY.ValueCurve`: (default: `LinearCurve(0.0)`) Cost of shifting demand (USD/MWh shifted)
- `peak_demand_mw::Float64`: (default: `0.0`) Peak demand (MW). Demands with existing devices in the base system derive their peak demand from those devices, not from this value.
- `shift_efficiency::Float64`: (default: `1.0`) Fraction of shifted energy that is kept. Represents energy losses due to time shifting
"""
mutable struct ProjectedDemand{T <: PSY.StaticInjection} <: DemandTechnology
    "List of requirements (i.e. reserve margin, capacity requirements, energy share requirements) that are associated with a technology"
    requirements::Vector{Requirement}
    "Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`)"
    available::Bool
    "The technology name"
    name::String
    "Cost of voluntary curtailment (USD/MWh). A LinearCurve is a single price for all curtailable demand. A PiecewiseIncrementalCurve gives tiers whose x coordinates are fractions of demand, from 0 to max_demand_curtailment, and whose slopes are prices (USD/MWh)"
    curtailment_cost::PSY.ValueCurve
    "ID for individual projected demand"
    id::Int64
    "Maximum number of hours that flexible demand can be served in advance (hours)"
    max_demand_advance::Float64
    "Fraction of demand that can be shifted in time"
    flexible_fraction::Float64
    "Maximum fraction of demand that can be curtailed voluntarily"
    max_demand_curtailment::Float64
    "Maximum number of hours that flexible demand can be delayed (hours)"
    max_demand_delay::Float64
    "Whether the demand is conforming (grows by growth_rate) or non-conforming (does not grow). Must be set for new demands."
    conformity::PSY.LoadConformity
    "The annual growth rate of the demand, used to scale present-day loads into future projections. Only used for conforming loads"
    growth_rate::Float64
    "Corresponding type in PowerSystems.jl to be used in PCM modeling"
    power_systems_type::String
    "Cost of involuntary shedding of the demand that cannot be curtailed (USD/MWh)"
    value_of_lost_load::Float64
    "(**Do not modify.**) PowerSystemsInvestmentsPortfolios.jl internal reference"
    internal::InfrastructureSystemsInternal
    "Optional dictionary to provide additional data"
    ext::Dict
    "Zone or node where the demand is located"
    region::Vector{RegionTopology}
    "The year in which a new demand starts. Should only be used for new demands."
    construction_year::Int64
    "Cost of shifting demand (USD/MWh shifted)"
    shift_cost::PSY.ValueCurve
    "Peak demand (MW). Demands with existing devices in the base system derive their peak demand from those devices, not from this value."
    peak_demand_mw::Float64
    "Fraction of shifted energy that is kept. Represents energy losses due to time shifting"
    shift_efficiency::Float64
end


function ProjectedDemand{T}(; requirements=Vector(), available=true, name, curtailment_cost=LinearCurve(0.0), id, max_demand_advance=0.0, flexible_fraction=0.0, max_demand_curtailment=0.0, max_demand_delay=0.0, conformity=PSY.LoadConformity.UNDEFINED, growth_rate=0.0, power_systems_type, value_of_lost_load=1e8, internal=InfrastructureSystemsInternal(), ext=Dict(), region=Vector(), construction_year=2020, shift_cost=LinearCurve(0.0), peak_demand_mw=0.0, shift_efficiency=1.0, ) where T <: PSY.StaticInjection
    ProjectedDemand{T}(requirements, available, name, curtailment_cost, id, max_demand_advance, flexible_fraction, max_demand_curtailment, max_demand_delay, conformity, growth_rate, power_systems_type, value_of_lost_load, internal, ext, region, construction_year, shift_cost, peak_demand_mw, shift_efficiency, )
end

"""Get [`ProjectedDemand`](@ref) `requirements`."""
get_requirements(value::ProjectedDemand) = value.requirements
"""Get [`ProjectedDemand`](@ref) `available`."""
get_available(value::ProjectedDemand) = value.available
"""Get [`ProjectedDemand`](@ref) `name`."""
get_name(value::ProjectedDemand) = value.name
"""Get [`ProjectedDemand`](@ref) `curtailment_cost`."""
get_curtailment_cost(value::ProjectedDemand) = value.curtailment_cost
"""Get [`ProjectedDemand`](@ref) `id`."""
get_id(value::ProjectedDemand) = value.id
"""Get [`ProjectedDemand`](@ref) `max_demand_advance`."""
get_max_demand_advance(value::ProjectedDemand) = value.max_demand_advance
"""Get [`ProjectedDemand`](@ref) `flexible_fraction`."""
get_flexible_fraction(value::ProjectedDemand) = value.flexible_fraction
"""Get [`ProjectedDemand`](@ref) `max_demand_curtailment`."""
get_max_demand_curtailment(value::ProjectedDemand) = value.max_demand_curtailment
"""Get [`ProjectedDemand`](@ref) `max_demand_delay`."""
get_max_demand_delay(value::ProjectedDemand) = value.max_demand_delay
"""Get [`ProjectedDemand`](@ref) `conformity`."""
get_conformity(value::ProjectedDemand) = value.conformity
"""Get [`ProjectedDemand`](@ref) `growth_rate`."""
get_growth_rate(value::ProjectedDemand) = value.growth_rate
"""Get [`ProjectedDemand`](@ref) `power_systems_type`."""
get_power_systems_type(value::ProjectedDemand) = value.power_systems_type
"""Get [`ProjectedDemand`](@ref) `value_of_lost_load`."""
get_value_of_lost_load(value::ProjectedDemand) = value.value_of_lost_load
"""Get [`ProjectedDemand`](@ref) `internal`."""
get_internal(value::ProjectedDemand) = value.internal
"""Get [`ProjectedDemand`](@ref) `ext`."""
get_ext(value::ProjectedDemand) = value.ext
"""Get [`ProjectedDemand`](@ref) `region`."""
get_region(value::ProjectedDemand) = value.region
"""Get [`ProjectedDemand`](@ref) `construction_year`."""
get_construction_year(value::ProjectedDemand) = value.construction_year
"""Get [`ProjectedDemand`](@ref) `shift_cost`."""
get_shift_cost(value::ProjectedDemand) = value.shift_cost
"""Get [`ProjectedDemand`](@ref) `peak_demand_mw`."""
get_peak_demand_mw(value::ProjectedDemand) = value.peak_demand_mw
"""Get [`ProjectedDemand`](@ref) `shift_efficiency`."""
get_shift_efficiency(value::ProjectedDemand) = value.shift_efficiency

"""Set [`ProjectedDemand`](@ref) `requirements`."""
set_requirements!(value::ProjectedDemand, val) = value.requirements = val
"""Set [`ProjectedDemand`](@ref) `available`."""
set_available!(value::ProjectedDemand, val) = value.available = val
"""Set [`ProjectedDemand`](@ref) `name`."""
set_name!(value::ProjectedDemand, val) = value.name = val
"""Set [`ProjectedDemand`](@ref) `curtailment_cost`."""
set_curtailment_cost!(value::ProjectedDemand, val) = value.curtailment_cost = val
"""Set [`ProjectedDemand`](@ref) `id`."""
set_id!(value::ProjectedDemand, val) = value.id = val
"""Set [`ProjectedDemand`](@ref) `max_demand_advance`."""
set_max_demand_advance!(value::ProjectedDemand, val) = value.max_demand_advance = val
"""Set [`ProjectedDemand`](@ref) `flexible_fraction`."""
set_flexible_fraction!(value::ProjectedDemand, val) = value.flexible_fraction = val
"""Set [`ProjectedDemand`](@ref) `max_demand_curtailment`."""
set_max_demand_curtailment!(value::ProjectedDemand, val) = value.max_demand_curtailment = val
"""Set [`ProjectedDemand`](@ref) `max_demand_delay`."""
set_max_demand_delay!(value::ProjectedDemand, val) = value.max_demand_delay = val
"""Set [`ProjectedDemand`](@ref) `conformity`."""
set_conformity!(value::ProjectedDemand, val) = value.conformity = val
"""Set [`ProjectedDemand`](@ref) `growth_rate`."""
set_growth_rate!(value::ProjectedDemand, val) = value.growth_rate = val
"""Set [`ProjectedDemand`](@ref) `power_systems_type`."""
set_power_systems_type!(value::ProjectedDemand, val) = value.power_systems_type = val
"""Set [`ProjectedDemand`](@ref) `value_of_lost_load`."""
set_value_of_lost_load!(value::ProjectedDemand, val) = value.value_of_lost_load = val
"""Set [`ProjectedDemand`](@ref) `internal`."""
set_internal!(value::ProjectedDemand, val) = value.internal = val
"""Set [`ProjectedDemand`](@ref) `ext`."""
set_ext!(value::ProjectedDemand, val) = value.ext = val
"""Set [`ProjectedDemand`](@ref) `region`."""
set_region!(value::ProjectedDemand, val) = value.region = val
"""Set [`ProjectedDemand`](@ref) `construction_year`."""
set_construction_year!(value::ProjectedDemand, val) = value.construction_year = val
"""Set [`ProjectedDemand`](@ref) `shift_cost`."""
set_shift_cost!(value::ProjectedDemand, val) = value.shift_cost = val
"""Set [`ProjectedDemand`](@ref) `peak_demand_mw`."""
set_peak_demand_mw!(value::ProjectedDemand, val) = value.peak_demand_mw = val
"""Set [`ProjectedDemand`](@ref) `shift_efficiency`."""
set_shift_efficiency!(value::ProjectedDemand, val) = value.shift_efficiency = val

function serialize_openapi_struct(technology::ProjectedDemand{T}, vals...) where T <: PSY.StaticInjection
    base_struct = APIServer.ProjectedDemand(; vals...)
    return base_struct
end


function deserialize_openapi_struct(::Type{<:ProjectedDemand}, vals::Dict)
    return IS.deserialize_struct(APIServer.ProjectedDemand, vals)
end
