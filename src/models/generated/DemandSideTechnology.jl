#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct DemandSideTechnology{T <: PSY.StaticInjection} <: DemandTechnology
        requirements::Vector{Requirement}
        capital_costs::CapitalCost
        price_per_unit::PSY.ValueCurve
        available::Bool
        name::String
        shift_variable_cost::PSY.ValueCurve
        curtailment_cost::PSY.ValueCurve
        id::Int64
        technology_efficiency::Float64
        max_demand_advance::Float64
        demand_energy_efficiency::Float64
        max_demand_curtailment::Float64
        max_demand_delay::Float64
        power_systems_type::String
        internal::InfrastructureSystemsInternal
        ext::Dict
        region::Vector{RegionTopology}
        min_power::Float64
        peak_demand_mw::Float64
    end

Represents demand side technologies such as electric vehicles or hydrogen electrolyzers.

# Arguments
- `requirements::Vector{Requirement}`: (default: `Vector()`) List of requirements (i.e. reserve margin, capacity requirements, energy share requirements) that are associated with a technology
- `capital_costs::CapitalCost`: (default: `CapitalCost(nothing)`) Capital costs for investing in a demand side technology. (USD/MW)
- `price_per_unit::PSY.ValueCurve`: (default: `LinearCurve(0.0)`) Price or value per unit of output. Ex: USD per ton of hydrogen for electrolyzers
- `available::Bool`: Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`)
- `name::String`: The technology name
- `shift_variable_cost::PSY.ValueCurve`: (default: `LinearCurve(0.0)`) Variable operation and maintenance costs associated with flexible demand deferral/advancement
- `curtailment_cost::PSY.ValueCurve`: (default: `LinearCurve(0.0)`) Energy cost of curtailed demand, USD per Mwh
- `id::Int64`: ID for demand side technology
- `technology_efficiency::Float64`: (default: `1.0`) MWh of electricity per unit of output. Ex: MWh per ton of hydrogen for electrolyzers
- `max_demand_advance::Float64`: (default: `0.0`) Maximum number of hours that demand can be scheduled in advance of the original schedule (hours).
- `demand_energy_efficiency::Float64`: (default: `1.0`) Energy efficiency associated with time shifting demand. Represents energy losses due to time shifting
- `max_demand_curtailment::Float64`: (default: `0.0`) Maximum fraction of demand that can be curtailed
- `max_demand_delay::Float64`: (default: `0.0`) Maximum number of hours that demand can be deferred or delayed (hours).
- `power_systems_type::String`: Corresponding type in PowerSystems.jl to be used in PCM modeling
- `internal::InfrastructureSystemsInternal`: (default: `InfrastructureSystemsInternal()`) (**Do not modify.**) PowerSystemsInvestmentsPortfolios.jl internal reference
- `ext::Dict`: (default: `Dict()`) Optional dictionary to provide additional data
- `region::Vector{RegionTopology}`: (default: `Vector()`) Location where technology is operated
- `min_power::Float64`: (default: `0.0`) Minimum operation of demandside unit as a fraction of peak demand
- `peak_demand_mw::Float64`: (default: `0.0`) Peak demand value in MW
"""
mutable struct DemandSideTechnology{T <: PSY.StaticInjection} <: DemandTechnology
    "List of requirements (i.e. reserve margin, capacity requirements, energy share requirements) that are associated with a technology"
    requirements::Vector{Requirement}
    "Capital costs for investing in a demand side technology. (USD/MW)"
    capital_costs::CapitalCost
    "Price or value per unit of output. Ex: USD per ton of hydrogen for electrolyzers"
    price_per_unit::PSY.ValueCurve
    "Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`)"
    available::Bool
    "The technology name"
    name::String
    "Variable operation and maintenance costs associated with flexible demand deferral/advancement"
    shift_variable_cost::PSY.ValueCurve
    "Energy cost of curtailed demand, USD per Mwh"
    curtailment_cost::PSY.ValueCurve
    "ID for demand side technology"
    id::Int64
    "MWh of electricity per unit of output. Ex: MWh per ton of hydrogen for electrolyzers"
    technology_efficiency::Float64
    "Maximum number of hours that demand can be scheduled in advance of the original schedule (hours)."
    max_demand_advance::Float64
    "Energy efficiency associated with time shifting demand. Represents energy losses due to time shifting"
    demand_energy_efficiency::Float64
    "Maximum fraction of demand that can be curtailed"
    max_demand_curtailment::Float64
    "Maximum number of hours that demand can be deferred or delayed (hours)."
    max_demand_delay::Float64
    "Corresponding type in PowerSystems.jl to be used in PCM modeling"
    power_systems_type::String
    "(**Do not modify.**) PowerSystemsInvestmentsPortfolios.jl internal reference"
    internal::InfrastructureSystemsInternal
    "Optional dictionary to provide additional data"
    ext::Dict
    "Location where technology is operated"
    region::Vector{RegionTopology}
    "Minimum operation of demandside unit as a fraction of peak demand"
    min_power::Float64
    "Peak demand value in MW"
    peak_demand_mw::Float64
end


function DemandSideTechnology{T}(; requirements=Vector(), capital_costs=CapitalCost(nothing), price_per_unit=LinearCurve(0.0), available, name, shift_variable_cost=LinearCurve(0.0), curtailment_cost=LinearCurve(0.0), id, technology_efficiency=1.0, max_demand_advance=0.0, demand_energy_efficiency=1.0, max_demand_curtailment=0.0, max_demand_delay=0.0, power_systems_type, internal=InfrastructureSystemsInternal(), ext=Dict(), region=Vector(), min_power=0.0, peak_demand_mw=0.0, ) where T <: PSY.StaticInjection
    DemandSideTechnology{T}(requirements, capital_costs, price_per_unit, available, name, shift_variable_cost, curtailment_cost, id, technology_efficiency, max_demand_advance, demand_energy_efficiency, max_demand_curtailment, max_demand_delay, power_systems_type, internal, ext, region, min_power, peak_demand_mw, )
end

"""Get [`DemandSideTechnology`](@ref) `requirements`."""
get_requirements(value::DemandSideTechnology) = value.requirements
"""Get [`DemandSideTechnology`](@ref) `capital_costs`."""
get_capital_costs(value::DemandSideTechnology) = value.capital_costs
"""Get [`DemandSideTechnology`](@ref) `price_per_unit`."""
get_price_per_unit(value::DemandSideTechnology) = value.price_per_unit
"""Get [`DemandSideTechnology`](@ref) `available`."""
get_available(value::DemandSideTechnology) = value.available
"""Get [`DemandSideTechnology`](@ref) `name`."""
get_name(value::DemandSideTechnology) = value.name
"""Get [`DemandSideTechnology`](@ref) `shift_variable_cost`."""
get_shift_variable_cost(value::DemandSideTechnology) = value.shift_variable_cost
"""Get [`DemandSideTechnology`](@ref) `curtailment_cost`."""
get_curtailment_cost(value::DemandSideTechnology) = value.curtailment_cost
"""Get [`DemandSideTechnology`](@ref) `id`."""
get_id(value::DemandSideTechnology) = value.id
"""Get [`DemandSideTechnology`](@ref) `technology_efficiency`."""
get_technology_efficiency(value::DemandSideTechnology) = value.technology_efficiency
"""Get [`DemandSideTechnology`](@ref) `max_demand_advance`."""
get_max_demand_advance(value::DemandSideTechnology) = value.max_demand_advance
"""Get [`DemandSideTechnology`](@ref) `demand_energy_efficiency`."""
get_demand_energy_efficiency(value::DemandSideTechnology) = value.demand_energy_efficiency
"""Get [`DemandSideTechnology`](@ref) `max_demand_curtailment`."""
get_max_demand_curtailment(value::DemandSideTechnology) = value.max_demand_curtailment
"""Get [`DemandSideTechnology`](@ref) `max_demand_delay`."""
get_max_demand_delay(value::DemandSideTechnology) = value.max_demand_delay
"""Get [`DemandSideTechnology`](@ref) `power_systems_type`."""
get_power_systems_type(value::DemandSideTechnology) = value.power_systems_type
"""Get [`DemandSideTechnology`](@ref) `internal`."""
get_internal(value::DemandSideTechnology) = value.internal
"""Get [`DemandSideTechnology`](@ref) `ext`."""
get_ext(value::DemandSideTechnology) = value.ext
"""Get [`DemandSideTechnology`](@ref) `region`."""
get_region(value::DemandSideTechnology) = value.region
"""Get [`DemandSideTechnology`](@ref) `min_power`."""
get_min_power(value::DemandSideTechnology) = value.min_power
"""Get [`DemandSideTechnology`](@ref) `peak_demand_mw`."""
get_peak_demand_mw(value::DemandSideTechnology) = value.peak_demand_mw

"""Set [`DemandSideTechnology`](@ref) `requirements`."""
set_requirements!(value::DemandSideTechnology, val) = value.requirements = val
"""Set [`DemandSideTechnology`](@ref) `capital_costs`."""
set_capital_costs!(value::DemandSideTechnology, val) = value.capital_costs = val
"""Set [`DemandSideTechnology`](@ref) `price_per_unit`."""
set_price_per_unit!(value::DemandSideTechnology, val) = value.price_per_unit = val
"""Set [`DemandSideTechnology`](@ref) `available`."""
set_available!(value::DemandSideTechnology, val) = value.available = val
"""Set [`DemandSideTechnology`](@ref) `name`."""
set_name!(value::DemandSideTechnology, val) = value.name = val
"""Set [`DemandSideTechnology`](@ref) `shift_variable_cost`."""
set_shift_variable_cost!(value::DemandSideTechnology, val) = value.shift_variable_cost = val
"""Set [`DemandSideTechnology`](@ref) `curtailment_cost`."""
set_curtailment_cost!(value::DemandSideTechnology, val) = value.curtailment_cost = val
"""Set [`DemandSideTechnology`](@ref) `id`."""
set_id!(value::DemandSideTechnology, val) = value.id = val
"""Set [`DemandSideTechnology`](@ref) `technology_efficiency`."""
set_technology_efficiency!(value::DemandSideTechnology, val) = value.technology_efficiency = val
"""Set [`DemandSideTechnology`](@ref) `max_demand_advance`."""
set_max_demand_advance!(value::DemandSideTechnology, val) = value.max_demand_advance = val
"""Set [`DemandSideTechnology`](@ref) `demand_energy_efficiency`."""
set_demand_energy_efficiency!(value::DemandSideTechnology, val) = value.demand_energy_efficiency = val
"""Set [`DemandSideTechnology`](@ref) `max_demand_curtailment`."""
set_max_demand_curtailment!(value::DemandSideTechnology, val) = value.max_demand_curtailment = val
"""Set [`DemandSideTechnology`](@ref) `max_demand_delay`."""
set_max_demand_delay!(value::DemandSideTechnology, val) = value.max_demand_delay = val
"""Set [`DemandSideTechnology`](@ref) `power_systems_type`."""
set_power_systems_type!(value::DemandSideTechnology, val) = value.power_systems_type = val
"""Set [`DemandSideTechnology`](@ref) `internal`."""
set_internal!(value::DemandSideTechnology, val) = value.internal = val
"""Set [`DemandSideTechnology`](@ref) `ext`."""
set_ext!(value::DemandSideTechnology, val) = value.ext = val
"""Set [`DemandSideTechnology`](@ref) `region`."""
set_region!(value::DemandSideTechnology, val) = value.region = val
"""Set [`DemandSideTechnology`](@ref) `min_power`."""
set_min_power!(value::DemandSideTechnology, val) = value.min_power = val
"""Set [`DemandSideTechnology`](@ref) `peak_demand_mw`."""
set_peak_demand_mw!(value::DemandSideTechnology, val) = value.peak_demand_mw = val

function serialize_openapi_struct(technology::DemandSideTechnology{T}, vals...) where T <: PSY.StaticInjection
    base_struct = APIServer.DemandSideTechnology(; vals...)
    return base_struct
end


function deserialize_openapi_struct(::Type{<:DemandSideTechnology}, vals::Dict)
    return IS.deserialize_struct(APIServer.DemandSideTechnology, vals)
end
