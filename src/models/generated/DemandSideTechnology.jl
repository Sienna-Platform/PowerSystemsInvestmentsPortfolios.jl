#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct DemandSideTechnology{T <: PSY.StaticInjection} <: DemandTechnology
        operation_costs::PSY.LoadCost
        requirements::Vector{Requirement}
        power_systems_type::String
        internal::InfrastructureSystemsInternal
        capital_costs::CapitalCost
        price_per_unit::PSY.ValueCurve
        ext::Dict
        lifetime::Int
        region::Vector{RegionTopology}
        available::Bool
        min_power::Float64
        name::String
        unit_size::Float64
        ramp_limits::UpDown
        id::Int64
        technology_efficiency::Float64
        capacity_limits::MinMax
        financial_data::TechnologyFinancialData
    end

An end-use technology that consumes electricity and can be built, such as hydrogen electrolyzers, direct air capture or industrial heat pumps. Its consumption is a decision, valued by what it produces.

# Arguments
- `operation_costs::PSY.LoadCost`: (default: `PSY.LoadCost(nothing)`) Fixed (USD/MW-year) and variable (USD/MWh consumed) O&M costs
- `requirements::Vector{Requirement}`: (default: `Vector()`) List of requirements (i.e. reserve margin, capacity requirements, energy share requirements) that are associated with a technology
- `power_systems_type::String`: Corresponding type in PowerSystems.jl to be used in PCM modeling
- `internal::InfrastructureSystemsInternal`: (default: `InfrastructureSystemsInternal()`) (**Do not modify.**) PowerSystemsInvestmentsPortfolios.jl internal reference
- `capital_costs::CapitalCost`: (default: `CapitalCost(nothing)`) Capital costs for investing in a demand side technology. (USD/MW)
- `price_per_unit::PSY.ValueCurve`: (default: `LinearCurve(0.0)`) Price or value per unit of product. Ex: USD per tonne of hydrogen for electrolyzers
- `ext::Dict`: (default: `Dict()`) Optional dictionary to provide additional data
- `lifetime::Int`: (default: `100`) Maximum number of years a technology can be active once installed (years)
- `region::Vector{RegionTopology}`: (default: `Vector()`) Location where technology is operated
- `available::Bool`: Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`)
- `min_power::Float64`: (default: `0.0`) Minimum consumption as a fraction of installed capacity
- `name::String`: The technology name
- `unit_size::Float64`: (default: `0.0`) Used for discrete investment decisions. Size of each unit being built (MW)
- `ramp_limits::UpDown`: (default: `(up=1.0, down=1.0)`) Maximum decrease and increase in consumption between operation periods. Fraction of installed capacity per hour
- `id::Int64`: ID for demand side technology
- `technology_efficiency::Float64`: (default: `1.0`) MWh of electricity per unit of product. Ex: MWh per tonne of hydrogen for electrolyzers
- `capacity_limits::MinMax`: (default: `(min=0, max=1e8)`) Minimum and maximum allowable installed capacity for a technology (MW)
- `financial_data::TechnologyFinancialData`: Struct containing relevant financial information for a technology
"""
mutable struct DemandSideTechnology{T <: PSY.StaticInjection} <: DemandTechnology
    "Fixed (USD/MW-year) and variable (USD/MWh consumed) O&M costs"
    operation_costs::PSY.LoadCost
    "List of requirements (i.e. reserve margin, capacity requirements, energy share requirements) that are associated with a technology"
    requirements::Vector{Requirement}
    "Corresponding type in PowerSystems.jl to be used in PCM modeling"
    power_systems_type::String
    "(**Do not modify.**) PowerSystemsInvestmentsPortfolios.jl internal reference"
    internal::InfrastructureSystemsInternal
    "Capital costs for investing in a demand side technology. (USD/MW)"
    capital_costs::CapitalCost
    "Price or value per unit of product. Ex: USD per tonne of hydrogen for electrolyzers"
    price_per_unit::PSY.ValueCurve
    "Optional dictionary to provide additional data"
    ext::Dict
    "Maximum number of years a technology can be active once installed (years)"
    lifetime::Int
    "Location where technology is operated"
    region::Vector{RegionTopology}
    "Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`)"
    available::Bool
    "Minimum consumption as a fraction of installed capacity"
    min_power::Float64
    "The technology name"
    name::String
    "Used for discrete investment decisions. Size of each unit being built (MW)"
    unit_size::Float64
    "Maximum decrease and increase in consumption between operation periods. Fraction of installed capacity per hour"
    ramp_limits::UpDown
    "ID for demand side technology"
    id::Int64
    "MWh of electricity per unit of product. Ex: MWh per tonne of hydrogen for electrolyzers"
    technology_efficiency::Float64
    "Minimum and maximum allowable installed capacity for a technology (MW)"
    capacity_limits::MinMax
    "Struct containing relevant financial information for a technology"
    financial_data::TechnologyFinancialData
end


function DemandSideTechnology{T}(; operation_costs=PSY.LoadCost(nothing), requirements=Vector(), power_systems_type, internal=InfrastructureSystemsInternal(), capital_costs=CapitalCost(nothing), price_per_unit=LinearCurve(0.0), ext=Dict(), lifetime=100, region=Vector(), available, min_power=0.0, name, unit_size=0.0, ramp_limits=(up=1.0, down=1.0), id, technology_efficiency=1.0, capacity_limits=(min=0, max=1e8), financial_data, ) where T <: PSY.StaticInjection
    DemandSideTechnology{T}(operation_costs, requirements, power_systems_type, internal, capital_costs, price_per_unit, ext, lifetime, region, available, min_power, name, unit_size, ramp_limits, id, technology_efficiency, capacity_limits, financial_data, )
end

"""Get [`DemandSideTechnology`](@ref) `operation_costs`."""
get_operation_costs(value::DemandSideTechnology) = value.operation_costs
"""Get [`DemandSideTechnology`](@ref) `requirements`."""
get_requirements(value::DemandSideTechnology) = value.requirements
"""Get [`DemandSideTechnology`](@ref) `power_systems_type`."""
get_power_systems_type(value::DemandSideTechnology) = value.power_systems_type
"""Get [`DemandSideTechnology`](@ref) `internal`."""
get_internal(value::DemandSideTechnology) = value.internal
"""Get [`DemandSideTechnology`](@ref) `capital_costs`."""
get_capital_costs(value::DemandSideTechnology) = value.capital_costs
"""Get [`DemandSideTechnology`](@ref) `price_per_unit`."""
get_price_per_unit(value::DemandSideTechnology) = value.price_per_unit
"""Get [`DemandSideTechnology`](@ref) `ext`."""
get_ext(value::DemandSideTechnology) = value.ext
"""Get [`DemandSideTechnology`](@ref) `lifetime`."""
get_lifetime(value::DemandSideTechnology) = value.lifetime
"""Get [`DemandSideTechnology`](@ref) `region`."""
get_region(value::DemandSideTechnology) = value.region
"""Get [`DemandSideTechnology`](@ref) `available`."""
get_available(value::DemandSideTechnology) = value.available
"""Get [`DemandSideTechnology`](@ref) `min_power`."""
get_min_power(value::DemandSideTechnology) = value.min_power
"""Get [`DemandSideTechnology`](@ref) `name`."""
get_name(value::DemandSideTechnology) = value.name
"""Get [`DemandSideTechnology`](@ref) `unit_size`."""
get_unit_size(value::DemandSideTechnology) = value.unit_size
"""Get [`DemandSideTechnology`](@ref) `ramp_limits`."""
get_ramp_limits(value::DemandSideTechnology) = value.ramp_limits
"""Get [`DemandSideTechnology`](@ref) `id`."""
get_id(value::DemandSideTechnology) = value.id
"""Get [`DemandSideTechnology`](@ref) `technology_efficiency`."""
get_technology_efficiency(value::DemandSideTechnology) = value.technology_efficiency
"""Get [`DemandSideTechnology`](@ref) `capacity_limits`."""
get_capacity_limits(value::DemandSideTechnology) = value.capacity_limits
"""Get [`DemandSideTechnology`](@ref) `financial_data`."""
get_financial_data(value::DemandSideTechnology) = value.financial_data

"""Set [`DemandSideTechnology`](@ref) `operation_costs`."""
set_operation_costs!(value::DemandSideTechnology, val) = value.operation_costs = val
"""Set [`DemandSideTechnology`](@ref) `requirements`."""
set_requirements!(value::DemandSideTechnology, val) = value.requirements = val
"""Set [`DemandSideTechnology`](@ref) `power_systems_type`."""
set_power_systems_type!(value::DemandSideTechnology, val) = value.power_systems_type = val
"""Set [`DemandSideTechnology`](@ref) `internal`."""
set_internal!(value::DemandSideTechnology, val) = value.internal = val
"""Set [`DemandSideTechnology`](@ref) `capital_costs`."""
set_capital_costs!(value::DemandSideTechnology, val) = value.capital_costs = val
"""Set [`DemandSideTechnology`](@ref) `price_per_unit`."""
set_price_per_unit!(value::DemandSideTechnology, val) = value.price_per_unit = val
"""Set [`DemandSideTechnology`](@ref) `ext`."""
set_ext!(value::DemandSideTechnology, val) = value.ext = val
"""Set [`DemandSideTechnology`](@ref) `lifetime`."""
set_lifetime!(value::DemandSideTechnology, val) = value.lifetime = val
"""Set [`DemandSideTechnology`](@ref) `region`."""
set_region!(value::DemandSideTechnology, val) = value.region = val
"""Set [`DemandSideTechnology`](@ref) `available`."""
set_available!(value::DemandSideTechnology, val) = value.available = val
"""Set [`DemandSideTechnology`](@ref) `min_power`."""
set_min_power!(value::DemandSideTechnology, val) = value.min_power = val
"""Set [`DemandSideTechnology`](@ref) `name`."""
set_name!(value::DemandSideTechnology, val) = value.name = val
"""Set [`DemandSideTechnology`](@ref) `unit_size`."""
set_unit_size!(value::DemandSideTechnology, val) = value.unit_size = val
"""Set [`DemandSideTechnology`](@ref) `ramp_limits`."""
set_ramp_limits!(value::DemandSideTechnology, val) = value.ramp_limits = val
"""Set [`DemandSideTechnology`](@ref) `id`."""
set_id!(value::DemandSideTechnology, val) = value.id = val
"""Set [`DemandSideTechnology`](@ref) `technology_efficiency`."""
set_technology_efficiency!(value::DemandSideTechnology, val) = value.technology_efficiency = val
"""Set [`DemandSideTechnology`](@ref) `capacity_limits`."""
set_capacity_limits!(value::DemandSideTechnology, val) = value.capacity_limits = val
"""Set [`DemandSideTechnology`](@ref) `financial_data`."""
set_financial_data!(value::DemandSideTechnology, val) = value.financial_data = val

function serialize_openapi_struct(technology::DemandSideTechnology{T}, vals...) where T <: PSY.StaticInjection
    base_struct = APIServer.DemandSideTechnology(; vals...)
    return base_struct
end


function deserialize_openapi_struct(::Type{<:DemandSideTechnology}, vals::Dict)
    return IS.deserialize_struct(APIServer.DemandSideTechnology, vals)
end
