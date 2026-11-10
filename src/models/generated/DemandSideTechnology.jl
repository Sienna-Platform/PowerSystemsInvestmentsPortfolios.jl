#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct DemandSideTechnology{T <: PSY.StaticInjection} <: DemandTechnology
        name::String
        available::Bool
        power_systems_type::String
        region::Vector{PSY.Topology}
        capacity_limits::MinMax
        unit_size::Float64
        capital_costs::CapitalCost
        operation_costs::PSY.LoadCost
        min_power::Float64
        ramp_limits::UpDown
        technology_efficiency::Float64
        price_per_unit::PSY.ValueCurve
        lifetime::Int
        financial_data::TechnologyFinancialData
        requirements::Vector{Requirement}
        ext::Dict
        internal::InfrastructureSystemsInternal
    end

An end-use technology that consumes electricity and can be built, such as hydrogen electrolyzers, direct air capture or industrial heat pumps. Its consumption is a decision, valued by what it produces.

# Arguments
- `name::String`: The technology name
- `available::Bool`: Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`)
- `power_systems_type::String`: Corresponding type in PowerSystems.jl to be used in PCM modeling
- `region::Vector{PSY.Topology}`: (default: `Vector()`) Location where technology is operated
- `capacity_limits::MinMax`: (default: `(min = 0.0, max = 1e8)`) Minimum and maximum allowable installed capacity for a technology (MW)
- `unit_size::Float64`: (default: `0.0`) Used for discrete investment decisions. Size of each unit being built (MW)
- `capital_costs::CapitalCost`: (default: `CapitalCost(nothing)`) Capital costs for investing in a demand side technology. (USD/MW)
- `operation_costs::PSY.LoadCost`: (default: `LoadCost(nothing)`) Fixed (USD/MW-year) and variable (USD/MWh consumed) O&M costs
- `min_power::Float64`: (default: `0.0`) Minimum consumption as a fraction of installed capacity
- `ramp_limits::UpDown`: (default: `(up=1.0, down=1.0)`) Maximum decrease and increase in consumption between operation periods (MW/min)
- `technology_efficiency::Float64`: (default: `1.0`) MWh of electricity per unit of product. Ex: MWh per tonne of hydrogen for electrolyzers
- `price_per_unit::PSY.ValueCurve`: (default: `LinearCurve(0.0)`) Price or value per unit of product. Ex: USD per tonne of hydrogen for electrolyzers. Units: USD/t.
- `lifetime::Int`: (default: `100`) Maximum number of years a technology can be active once installed (years)
- `financial_data::TechnologyFinancialData`: Struct containing relevant financial information for a technology
- `requirements::Vector{Requirement}`: (default: `Vector()`) List of requirements (i.e. reserve margin, capacity requirements, energy share requirements) that are associated with a technology
- `ext::Dict`: (default: `Dict()`) Optional dictionary to provide additional data
- `internal::InfrastructureSystemsInternal`: (default: `InfrastructureSystemsInternal()`) (**Do not modify.**) PowerSystemsInvestmentsPortfolios.jl internal reference
"""
mutable struct DemandSideTechnology{T <: PSY.StaticInjection} <: DemandTechnology
    "The technology name"
    name::String
    "Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`)"
    available::Bool
    "Corresponding type in PowerSystems.jl to be used in PCM modeling"
    power_systems_type::String
    "Location where technology is operated"
    region::Vector{PSY.Topology}
    "Minimum and maximum allowable installed capacity for a technology (MW)"
    capacity_limits::MinMax
    "Used for discrete investment decisions. Size of each unit being built (MW)"
    unit_size::Float64
    "Capital costs for investing in a demand side technology. (USD/MW)"
    capital_costs::CapitalCost
    "Fixed (USD/MW-year) and variable (USD/MWh consumed) O&M costs"
    operation_costs::PSY.LoadCost
    "Minimum consumption as a fraction of installed capacity"
    min_power::Float64
    "Maximum decrease and increase in consumption between operation periods (MW/min)"
    ramp_limits::UpDown
    "MWh of electricity per unit of product. Ex: MWh per tonne of hydrogen for electrolyzers"
    technology_efficiency::Float64
    "Price or value per unit of product. Ex: USD per tonne of hydrogen for electrolyzers. Units: USD/t."
    price_per_unit::PSY.ValueCurve
    "Maximum number of years a technology can be active once installed (years)"
    lifetime::Int
    "Struct containing relevant financial information for a technology"
    financial_data::TechnologyFinancialData
    "List of requirements (i.e. reserve margin, capacity requirements, energy share requirements) that are associated with a technology"
    requirements::Vector{Requirement}
    "Optional dictionary to provide additional data"
    ext::Dict
    "(**Do not modify.**) PowerSystemsInvestmentsPortfolios.jl internal reference"
    internal::InfrastructureSystemsInternal
end


function DemandSideTechnology{T}(; name, available, power_systems_type, region=Vector(), capacity_limits=(min = 0.0, max = 1e8), unit_size=0.0, capital_costs=CapitalCost(nothing), operation_costs=LoadCost(nothing), min_power=0.0, ramp_limits=(up=1.0, down=1.0), technology_efficiency=1.0, price_per_unit=LinearCurve(0.0), lifetime=100, financial_data, requirements=Vector(), ext=Dict(), internal=InfrastructureSystemsInternal(), ) where T <: PSY.StaticInjection
    DemandSideTechnology{T}(name, available, power_systems_type, region, capacity_limits, unit_size, capital_costs, operation_costs, min_power, ramp_limits, technology_efficiency, price_per_unit, lifetime, financial_data, requirements, ext, internal, )
end

"""Get [`DemandSideTechnology`](@ref) `name`."""
get_name(value::DemandSideTechnology) = value.name
"""Get [`DemandSideTechnology`](@ref) `available`."""
get_available(value::DemandSideTechnology) = value.available
"""Get [`DemandSideTechnology`](@ref) `power_systems_type`."""
get_power_systems_type(value::DemandSideTechnology) = value.power_systems_type
"""Get [`DemandSideTechnology`](@ref) `region`."""
get_region(value::DemandSideTechnology) = value.region
"""Get [`DemandSideTechnology`](@ref) `capacity_limits` as a bare number in the requested `units` (e.g. domain-provided units such as `MW`). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_capacity_limits_unitful`](@ref)."""
get_capacity_limits(value::DemandSideTechnology, units) = InfrastructureSystems._strip_units(get_value(value, Val(:capacity_limits), Val(:mw), units))
"""Get [`DemandSideTechnology`](@ref) `capacity_limits` as a unit-bearing quantity in the requested `units` (e.g. `MW`). For a bare number see [`get_capacity_limits`](@ref)."""
get_capacity_limits_unitful(value::DemandSideTechnology, units) = get_value(value, Val(:capacity_limits), Val(:mw), units)
InfrastructureSystems.display_units_arg(::typeof(get_capacity_limits), ::Type{DemandSideTechnology{T}}) where {T <: PSY.StaticInjection} = InfrastructureSystems.NU
InfrastructureSystems.display_units_arg(::typeof(get_capacity_limits_unitful), ::Type{DemandSideTechnology{T}}) where {T <: PSY.StaticInjection} = InfrastructureSystems.NU
"""Get [`DemandSideTechnology`](@ref) `unit_size` as a bare number in the requested `units` (e.g. domain-provided units such as `MW`). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_unit_size_unitful`](@ref)."""
get_unit_size(value::DemandSideTechnology, units) = InfrastructureSystems._strip_units(get_value(value, Val(:unit_size), Val(:mw), units))
"""Get [`DemandSideTechnology`](@ref) `unit_size` as a unit-bearing quantity in the requested `units` (e.g. `MW`). For a bare number see [`get_unit_size`](@ref)."""
get_unit_size_unitful(value::DemandSideTechnology, units) = get_value(value, Val(:unit_size), Val(:mw), units)
InfrastructureSystems.display_units_arg(::typeof(get_unit_size), ::Type{DemandSideTechnology{T}}) where {T <: PSY.StaticInjection} = InfrastructureSystems.NU
InfrastructureSystems.display_units_arg(::typeof(get_unit_size_unitful), ::Type{DemandSideTechnology{T}}) where {T <: PSY.StaticInjection} = InfrastructureSystems.NU
"""Get [`DemandSideTechnology`](@ref) `capital_costs`."""
get_capital_costs(value::DemandSideTechnology) = value.capital_costs
"""Get [`DemandSideTechnology`](@ref) `operation_costs` as a bare number in the requested `units` (e.g. domain-provided units such as `MW`). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_operation_costs_unitful`](@ref)."""
get_operation_costs(value::DemandSideTechnology, units) = InfrastructureSystems._strip_units(get_value(value, Val(:operation_costs), Val(:usd_per_mwh), units))
"""Get [`DemandSideTechnology`](@ref) `operation_costs` as a unit-bearing quantity in the requested `units` (e.g. `MW`). For a bare number see [`get_operation_costs`](@ref)."""
get_operation_costs_unitful(value::DemandSideTechnology, units) = get_value(value, Val(:operation_costs), Val(:usd_per_mwh), units)
InfrastructureSystems.display_units_arg(::typeof(get_operation_costs), ::Type{DemandSideTechnology{T}}) where {T <: PSY.StaticInjection} = InfrastructureSystems.NU
InfrastructureSystems.display_units_arg(::typeof(get_operation_costs_unitful), ::Type{DemandSideTechnology{T}}) where {T <: PSY.StaticInjection} = InfrastructureSystems.NU
"""Get [`DemandSideTechnology`](@ref) `min_power`."""
get_min_power(value::DemandSideTechnology) = value.min_power
"""Get [`DemandSideTechnology`](@ref) `ramp_limits` as a bare number in the requested `units` (e.g. domain-provided units such as `MW`). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_ramp_limits_unitful`](@ref)."""
get_ramp_limits(value::DemandSideTechnology, units) = InfrastructureSystems._strip_units(get_value(value, Val(:ramp_limits), Val(:mw_per_min), units))
"""Get [`DemandSideTechnology`](@ref) `ramp_limits` as a unit-bearing quantity in the requested `units` (e.g. `MW`). For a bare number see [`get_ramp_limits`](@ref)."""
get_ramp_limits_unitful(value::DemandSideTechnology, units) = get_value(value, Val(:ramp_limits), Val(:mw_per_min), units)
InfrastructureSystems.display_units_arg(::typeof(get_ramp_limits), ::Type{DemandSideTechnology{T}}) where {T <: PSY.StaticInjection} = InfrastructureSystems.NU
InfrastructureSystems.display_units_arg(::typeof(get_ramp_limits_unitful), ::Type{DemandSideTechnology{T}}) where {T <: PSY.StaticInjection} = InfrastructureSystems.NU
"""Get [`DemandSideTechnology`](@ref) `technology_efficiency`."""
get_technology_efficiency(value::DemandSideTechnology) = value.technology_efficiency
"""Get [`DemandSideTechnology`](@ref) `price_per_unit` as a bare number in the requested `units` (e.g. domain-provided units such as `MW`). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_price_per_unit_unitful`](@ref)."""
get_price_per_unit(value::DemandSideTechnology, units) = InfrastructureSystems._strip_units(get_value(value, Val(:price_per_unit), Val(:usd_per_t), units))
"""Get [`DemandSideTechnology`](@ref) `price_per_unit` as a unit-bearing quantity in the requested `units` (e.g. `MW`). For a bare number see [`get_price_per_unit`](@ref)."""
get_price_per_unit_unitful(value::DemandSideTechnology, units) = get_value(value, Val(:price_per_unit), Val(:usd_per_t), units)
InfrastructureSystems.display_units_arg(::typeof(get_price_per_unit), ::Type{DemandSideTechnology{T}}) where {T <: PSY.StaticInjection} = InfrastructureSystems.NU
InfrastructureSystems.display_units_arg(::typeof(get_price_per_unit_unitful), ::Type{DemandSideTechnology{T}}) where {T <: PSY.StaticInjection} = InfrastructureSystems.NU
"""Get [`DemandSideTechnology`](@ref) `lifetime` as a bare number in the requested `units` (e.g. domain-provided units such as `MW`). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_lifetime_unitful`](@ref)."""
get_lifetime(value::DemandSideTechnology, units) = InfrastructureSystems._strip_units(get_value(value, Val(:lifetime), Val(:yr), units))
"""Get [`DemandSideTechnology`](@ref) `lifetime` as a unit-bearing quantity in the requested `units` (e.g. `MW`). For a bare number see [`get_lifetime`](@ref)."""
get_lifetime_unitful(value::DemandSideTechnology, units) = get_value(value, Val(:lifetime), Val(:yr), units)
InfrastructureSystems.display_units_arg(::typeof(get_lifetime), ::Type{DemandSideTechnology{T}}) where {T <: PSY.StaticInjection} = InfrastructureSystems.NU
InfrastructureSystems.display_units_arg(::typeof(get_lifetime_unitful), ::Type{DemandSideTechnology{T}}) where {T <: PSY.StaticInjection} = InfrastructureSystems.NU
"""Get [`DemandSideTechnology`](@ref) `financial_data`."""
get_financial_data(value::DemandSideTechnology) = value.financial_data
"""Get [`DemandSideTechnology`](@ref) `requirements`."""
get_requirements(value::DemandSideTechnology) = value.requirements
"""Get [`DemandSideTechnology`](@ref) `ext`."""
get_ext(value::DemandSideTechnology) = value.ext
"""Get [`DemandSideTechnology`](@ref) `internal`."""
get_internal(value::DemandSideTechnology) = value.internal

"""Set [`DemandSideTechnology`](@ref) `name`."""
set_name!(value::DemandSideTechnology, val) = value.name = val
"""Set [`DemandSideTechnology`](@ref) `available`."""
set_available!(value::DemandSideTechnology, val) = value.available = val
"""Set [`DemandSideTechnology`](@ref) `power_systems_type`."""
set_power_systems_type!(value::DemandSideTechnology, val) = value.power_systems_type = val
"""Set [`DemandSideTechnology`](@ref) `region`."""
set_region!(value::DemandSideTechnology, val) = value.region = val
"""Set [`DemandSideTechnology`](@ref) `capacity_limits`."""
set_capacity_limits!(value::DemandSideTechnology, val, unit) = value.capacity_limits = set_value(value, Val(:capacity_limits), val, unit, Val(:mw))
"""Set [`DemandSideTechnology`](@ref) `unit_size`."""
set_unit_size!(value::DemandSideTechnology, val, unit) = value.unit_size = set_value(value, Val(:unit_size), val, unit, Val(:mw))
"""Set [`DemandSideTechnology`](@ref) `capital_costs`."""
set_capital_costs!(value::DemandSideTechnology, val) = value.capital_costs = val
"""Set [`DemandSideTechnology`](@ref) `operation_costs`."""
set_operation_costs!(value::DemandSideTechnology, val, unit) = value.operation_costs = set_value(value, Val(:operation_costs), val, unit, Val(:usd_per_mwh))
"""Set [`DemandSideTechnology`](@ref) `min_power`."""
set_min_power!(value::DemandSideTechnology, val) = value.min_power = val
"""Set [`DemandSideTechnology`](@ref) `ramp_limits`."""
set_ramp_limits!(value::DemandSideTechnology, val, unit) = value.ramp_limits = set_value(value, Val(:ramp_limits), val, unit, Val(:mw_per_min))
"""Set [`DemandSideTechnology`](@ref) `technology_efficiency`."""
set_technology_efficiency!(value::DemandSideTechnology, val) = value.technology_efficiency = val
"""Set [`DemandSideTechnology`](@ref) `price_per_unit`."""
set_price_per_unit!(value::DemandSideTechnology, val, unit) = value.price_per_unit = set_value(value, Val(:price_per_unit), val, unit, Val(:usd_per_t))
"""Set [`DemandSideTechnology`](@ref) `lifetime`."""
set_lifetime!(value::DemandSideTechnology, val, unit) = value.lifetime = set_value(value, Val(:lifetime), val, unit, Val(:yr))
"""Set [`DemandSideTechnology`](@ref) `financial_data`."""
set_financial_data!(value::DemandSideTechnology, val) = value.financial_data = val
"""Set [`DemandSideTechnology`](@ref) `requirements`."""
set_requirements!(value::DemandSideTechnology, val) = value.requirements = val
"""Set [`DemandSideTechnology`](@ref) `ext`."""
set_ext!(value::DemandSideTechnology, val) = value.ext = val
"""Set [`DemandSideTechnology`](@ref) `internal`."""
set_internal!(value::DemandSideTechnology, val) = value.internal = val


function from_openapi(po::PI.DemandSideTechnology, refs::OpenAPIRefs)
    parameter = getproperty(PowerSystems, Symbol(po.power_systems_type))
    return DemandSideTechnology{parameter}(;
        name = po.name,
        available = po.available,
        power_systems_type = po.power_systems_type,
        region = _or_default(resolve_refs(refs, po.region, PSY.Topology), Vector()),
        capacity_limits = _or_default(_minmax_from_po(po.capacity_limits), (min = 0.0, max = 1e8)),
        unit_size = _or_default(po.unit_size, 0.0),
        capital_costs = _or_default(_nested_optional(po.capital_costs), CapitalCost(nothing)),
        operation_costs = _or_default(_cost_optional(po.operation_costs), LoadCost(nothing))::PSY.LoadCost,
        min_power = _or_default(po.min_power, 0.0),
        ramp_limits = _or_default(_updown_from_po(po.ramp_limits), (up=1.0, down=1.0)),
        technology_efficiency = _or_default(po.technology_efficiency, 1.0),
        price_per_unit = _or_default(_value_curve_optional(po.price_per_unit), LinearCurve(0.0)),
        lifetime = _or_default(po.lifetime, 100),
        financial_data = convert_nested_data(po.financial_data),
    )
end

function to_openapi(value::DemandSideTechnology{T}, refs::OpenAPIRefs) where {T <: PSY.StaticInjection}
    return PI.DemandSideTechnology(;
        id = get_id(value),
        name = get_name(value),
        available = get_available(value),
        power_systems_type = string(nameof(T)),
        region = component_ids(refs, get_region(value)),
        capacity_limits = _minmax_po(get_capacity_limits(value, IS.NU)),
        unit_size = get_unit_size(value, IS.NU),
        capital_costs = convert_nested_data_to_openapi(get_capital_costs(value)),
        operation_costs = convert_cost_to_openapi(get_operation_costs(value, IS.NU)),
        min_power = get_min_power(value),
        ramp_limits = _updown_po(get_ramp_limits(value, IS.NU)),
        technology_efficiency = get_technology_efficiency(value),
        price_per_unit = _curve_to_openapi(PI.DemandSideTechnologyPricePerUnit, get_price_per_unit(value, IS.NU)),
        lifetime = get_lifetime(value, IS.NU),
        financial_data = convert_nested_data_to_openapi(get_financial_data(value)),
    )
end
