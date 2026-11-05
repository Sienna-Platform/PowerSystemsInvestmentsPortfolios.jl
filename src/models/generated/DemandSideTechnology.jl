#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct DemandSideTechnology{T <: PSY.StaticInjection} <: DemandTechnology
        requirements::Vector{Requirement}
        capital_costs::CapitalCost
        price_per_unit::PSY.ValueCurve
        lifetime::Int
        available::Bool
        name::String
        id::Int64
        technology_efficiency::Float64
        financial_data::TechnologyFinancialData
        operation_costs::PSY.LoadCost
        power_systems_type::String
        internal::InfrastructureSystemsInternal
        ext::Dict
        region::Vector{RegionTopology}
        min_power::Float64
        unit_size::Float64
        ramp_limits::UpDown
        capacity_limits::MinMax
    end

An end-use technology that consumes electricity and can be built, such as hydrogen electrolyzers, direct air capture or industrial heat pumps. Its consumption is a decision, valued by what it produces.

# Arguments
- `requirements::Vector{Requirement}`: (default: `Vector()`) List of requirements (i.e. reserve margin, capacity requirements, energy share requirements) that are associated with a technology
- `capital_costs::CapitalCost`: (default: `CapitalCost(nothing)`) Capital costs for investing in a demand side technology. (USD/MW)
- `price_per_unit::PSY.ValueCurve`: (default: `LinearCurve(0.0)`) Price or value per unit of product. Ex: USD per tonne of hydrogen for electrolyzers
- `lifetime::Int`: (default: `100`) Maximum number of years a technology can be active once installed (years)
- `available::Bool`: Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`)
- `name::String`: The technology name
- `id::Int64`: ID for demand side technology
- `technology_efficiency::Float64`: (default: `1.0`) MWh of electricity per unit of product. Ex: MWh per tonne of hydrogen for electrolyzers
- `financial_data::TechnologyFinancialData`: Struct containing relevant financial information for a technology
- `operation_costs::PSY.LoadCost`: (default: `PSY.LoadCost(nothing)`) Fixed (USD/MW-year) and variable (USD/MWh consumed) O&M costs
- `power_systems_type::String`: Corresponding type in PowerSystems.jl to be used in PCM modeling
- `internal::InfrastructureSystemsInternal`: (default: `InfrastructureSystemsInternal()`) (**Do not modify.**) PowerSystemsInvestmentsPortfolios.jl internal reference
- `ext::Dict`: (default: `Dict()`) Optional dictionary to provide additional data
- `region::Vector{RegionTopology}`: (default: `Vector()`) Location where technology is operated
- `min_power::Float64`: (default: `0.0`) Minimum consumption as a fraction of installed capacity
- `unit_size::Float64`: (default: `0.0`) Used for discrete investment decisions. Size of each unit being built (MW)
- `ramp_limits::UpDown`: (default: `(up=1.0, down=1.0)`) Maximum decrease and increase in consumption between operation periods. Fraction of installed capacity per hour
- `capacity_limits::MinMax`: (default: `(min=0, max=1e8)`) Minimum and maximum allowable installed capacity for a technology (MW)
"""
mutable struct DemandSideTechnology{T <: PSY.StaticInjection} <: DemandTechnology
    "List of requirements (i.e. reserve margin, capacity requirements, energy share requirements) that are associated with a technology"
    requirements::Vector{Requirement}
    "Capital costs for investing in a demand side technology. (USD/MW)"
    capital_costs::CapitalCost
    "Price or value per unit of product. Ex: USD per tonne of hydrogen for electrolyzers"
    price_per_unit::PSY.ValueCurve
    "Maximum number of years a technology can be active once installed (years)"
    lifetime::Int
    "Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`)"
    available::Bool
    "The technology name"
    name::String
    "ID for demand side technology"
    id::Int64
    "MWh of electricity per unit of product. Ex: MWh per tonne of hydrogen for electrolyzers"
    technology_efficiency::Float64
    "Struct containing relevant financial information for a technology"
    financial_data::TechnologyFinancialData
    "Fixed (USD/MW-year) and variable (USD/MWh consumed) O&M costs"
    operation_costs::PSY.LoadCost
    "Corresponding type in PowerSystems.jl to be used in PCM modeling"
    power_systems_type::String
    "(**Do not modify.**) PowerSystemsInvestmentsPortfolios.jl internal reference"
    internal::InfrastructureSystemsInternal
    "Optional dictionary to provide additional data"
    ext::Dict
    "Location where technology is operated"
    region::Vector{RegionTopology}
    "Minimum consumption as a fraction of installed capacity"
    min_power::Float64
    "Used for discrete investment decisions. Size of each unit being built (MW)"
    unit_size::Float64
    "Maximum decrease and increase in consumption between operation periods. Fraction of installed capacity per hour"
    ramp_limits::UpDown
    "Minimum and maximum allowable installed capacity for a technology (MW)"
    capacity_limits::MinMax
end


function DemandSideTechnology{T}(; requirements=Vector(), capital_costs=CapitalCost(nothing), price_per_unit=LinearCurve(0.0), lifetime=100, available, name, id, technology_efficiency=1.0, financial_data, operation_costs=PSY.LoadCost(nothing), power_systems_type, internal=InfrastructureSystemsInternal(), ext=Dict(), region=Vector(), min_power=0.0, unit_size=0.0, ramp_limits=(up=1.0, down=1.0), capacity_limits=(min=0, max=1e8), ) where T <: PSY.StaticInjection
    DemandSideTechnology{T}(requirements, capital_costs, price_per_unit, lifetime, available, name, id, technology_efficiency, financial_data, operation_costs, power_systems_type, internal, ext, region, min_power, unit_size, ramp_limits, capacity_limits, )
end

"""Get [`DemandSideTechnology`](@ref) `requirements`."""
get_requirements(value::DemandSideTechnology) = value.requirements
"""Get [`DemandSideTechnology`](@ref) `capital_costs`."""
get_capital_costs(value::DemandSideTechnology) = value.capital_costs
"""Get [`DemandSideTechnology`](@ref) `price_per_unit`."""
get_price_per_unit(value::DemandSideTechnology) = value.price_per_unit
"""Get [`DemandSideTechnology`](@ref) `lifetime`."""
get_lifetime(value::DemandSideTechnology) = value.lifetime
"""Get [`DemandSideTechnology`](@ref) `available`."""
get_available(value::DemandSideTechnology) = value.available
"""Get [`DemandSideTechnology`](@ref) `name`."""
get_name(value::DemandSideTechnology) = value.name
"""Get [`DemandSideTechnology`](@ref) `id`."""
get_id(value::DemandSideTechnology) = value.id
"""Get [`DemandSideTechnology`](@ref) `technology_efficiency`."""
get_technology_efficiency(value::DemandSideTechnology) = value.technology_efficiency
"""Get [`DemandSideTechnology`](@ref) `financial_data`."""
get_financial_data(value::DemandSideTechnology) = value.financial_data
"""Get [`DemandSideTechnology`](@ref) `operation_costs`."""
get_operation_costs(value::DemandSideTechnology) = value.operation_costs
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
"""Get [`DemandSideTechnology`](@ref) `unit_size`."""
get_unit_size(value::DemandSideTechnology) = value.unit_size
"""Get [`DemandSideTechnology`](@ref) `ramp_limits`."""
get_ramp_limits(value::DemandSideTechnology) = value.ramp_limits
"""Get [`DemandSideTechnology`](@ref) `capacity_limits`."""
get_capacity_limits(value::DemandSideTechnology) = value.capacity_limits

"""Set [`DemandSideTechnology`](@ref) `requirements`."""
set_requirements!(value::DemandSideTechnology, val) = value.requirements = val
"""Set [`DemandSideTechnology`](@ref) `capital_costs`."""
set_capital_costs!(value::DemandSideTechnology, val) = value.capital_costs = val
"""Set [`DemandSideTechnology`](@ref) `price_per_unit`."""
set_price_per_unit!(value::DemandSideTechnology, val) = value.price_per_unit = val
"""Set [`DemandSideTechnology`](@ref) `lifetime`."""
set_lifetime!(value::DemandSideTechnology, val) = value.lifetime = val
"""Set [`DemandSideTechnology`](@ref) `available`."""
set_available!(value::DemandSideTechnology, val) = value.available = val
"""Set [`DemandSideTechnology`](@ref) `name`."""
set_name!(value::DemandSideTechnology, val) = value.name = val
"""Set [`DemandSideTechnology`](@ref) `id`."""
set_id!(value::DemandSideTechnology, val) = value.id = val
"""Set [`DemandSideTechnology`](@ref) `technology_efficiency`."""
set_technology_efficiency!(value::DemandSideTechnology, val) = value.technology_efficiency = val
"""Set [`DemandSideTechnology`](@ref) `financial_data`."""
set_financial_data!(value::DemandSideTechnology, val) = value.financial_data = val
"""Set [`DemandSideTechnology`](@ref) `operation_costs`."""
set_operation_costs!(value::DemandSideTechnology, val) = value.operation_costs = val
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
"""Set [`DemandSideTechnology`](@ref) `unit_size`."""
set_unit_size!(value::DemandSideTechnology, val) = value.unit_size = val
"""Set [`DemandSideTechnology`](@ref) `ramp_limits`."""
set_ramp_limits!(value::DemandSideTechnology, val) = value.ramp_limits = val
"""Set [`DemandSideTechnology`](@ref) `capacity_limits`."""
set_capacity_limits!(value::DemandSideTechnology, val) = value.capacity_limits = val

function serialize_openapi_struct(technology::DemandSideTechnology{T}, vals...) where T <: PSY.StaticInjection
    base_struct = APIServer.DemandSideTechnology(; vals...)
    return base_struct
end


function deserialize_openapi_struct(::Type{<:DemandSideTechnology}, vals::Dict)
    return IS.deserialize_struct(APIServer.DemandSideTechnology, vals)
end
