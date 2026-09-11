#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct ColocatedSupplyStorageTechnology{T <: PSY.Generator} <: ResourceTechnology
        name::String
        power_systems_type::String
        region::Vector{PSY.Topology}
        available::Bool
        financial_data::TechnologyFinancialData
        supply_technology::SupplyTechnology
        storage_technology::StorageTechnology
        inverter_capacity_limits::MinMax
        capital_costs_inverter::CapitalCost
        operation_costs_inverter::IS.ProductionVariableCostCurve
        inverter_efficiency::Float64
        inverter_supply_ratio::Float64
        requirements::Vector{Requirement}
        ext::Dict
        internal::InfrastructureSystemsInternal
    end

Supply Technology that supports a StorageTechnology co-located with wind and solar generation

# Arguments
- `name::String`: The technology name
- `power_systems_type::String`: Corresponding type in PowerSystems.jl to be used in PCM modeling
- `region::Vector{PSY.Topology}`: (default: `Vector()`) Zone or node where the technology operates
- `available::Bool`: (default: `true`) Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`)
- `financial_data::TechnologyFinancialData`: Struct containing relevant financial information for a technology
- `supply_technology::SupplyTechnology`: The underlying supply technology (e.g. wind or solar) co-located with storage
- `storage_technology::StorageTechnology`: The underlying storage technology co-located with the supply technology
- `inverter_capacity_limits::MinMax`: (default: `(min = 0.0, max = 1e8)`) Limits on inverter capacity (MW)
- `capital_costs_inverter::CapitalCost`: Capital and interconnection cost for investing in inverter capacity (USD/MW)
- `operation_costs_inverter::IS.ProductionVariableCostCurve`: Operational costs for using inverter in co-located systems
- `inverter_efficiency::Float64`: Efficiency of AC to DC conversion of inverter
- `inverter_supply_ratio::Float64`: Ratio of generation capacity to grid connection capacity
- `requirements::Vector{Requirement}`: (default: `Vector()`) List of requirements associated with the technology
- `ext::Dict`: (default: `Dict()`) Optional dictionary to provide additional data
- `internal::InfrastructureSystemsInternal`: (default: `InfrastructureSystemsInternal()`) (**Do not modify.**) PowerSystemsInvestmentsPortfolios.jl internal reference
"""
mutable struct ColocatedSupplyStorageTechnology{T <: PSY.Generator} <: ResourceTechnology
    "The technology name"
    name::String
    "Corresponding type in PowerSystems.jl to be used in PCM modeling"
    power_systems_type::String
    "Zone or node where the technology operates"
    region::Vector{PSY.Topology}
    "Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`)"
    available::Bool
    "Struct containing relevant financial information for a technology"
    financial_data::TechnologyFinancialData
    "The underlying supply technology (e.g. wind or solar) co-located with storage"
    supply_technology::SupplyTechnology
    "The underlying storage technology co-located with the supply technology"
    storage_technology::StorageTechnology
    "Limits on inverter capacity (MW)"
    inverter_capacity_limits::MinMax
    "Capital and interconnection cost for investing in inverter capacity (USD/MW)"
    capital_costs_inverter::CapitalCost
    "Operational costs for using inverter in co-located systems"
    operation_costs_inverter::IS.ProductionVariableCostCurve
    "Efficiency of AC to DC conversion of inverter"
    inverter_efficiency::Float64
    "Ratio of generation capacity to grid connection capacity"
    inverter_supply_ratio::Float64
    "List of requirements associated with the technology"
    requirements::Vector{Requirement}
    "Optional dictionary to provide additional data"
    ext::Dict
    "(**Do not modify.**) PowerSystemsInvestmentsPortfolios.jl internal reference"
    internal::InfrastructureSystemsInternal
end


function ColocatedSupplyStorageTechnology{T}(; name, power_systems_type, region=Vector(), available=true, financial_data, supply_technology, storage_technology, inverter_capacity_limits=(min = 0.0, max = 1e8), capital_costs_inverter, operation_costs_inverter, inverter_efficiency, inverter_supply_ratio, requirements=Vector(), ext=Dict(), internal=InfrastructureSystemsInternal(), ) where T <: PSY.Generator
    ColocatedSupplyStorageTechnology{T}(name, power_systems_type, region, available, financial_data, supply_technology, storage_technology, inverter_capacity_limits, capital_costs_inverter, operation_costs_inverter, inverter_efficiency, inverter_supply_ratio, requirements, ext, internal, )
end

"""Get [`ColocatedSupplyStorageTechnology`](@ref) `name`."""
get_name(value::ColocatedSupplyStorageTechnology) = value.name
"""Get [`ColocatedSupplyStorageTechnology`](@ref) `power_systems_type`."""
get_power_systems_type(value::ColocatedSupplyStorageTechnology) = value.power_systems_type
"""Get [`ColocatedSupplyStorageTechnology`](@ref) `region`."""
get_region(value::ColocatedSupplyStorageTechnology) = value.region
"""Get [`ColocatedSupplyStorageTechnology`](@ref) `available`."""
get_available(value::ColocatedSupplyStorageTechnology) = value.available
"""Get [`ColocatedSupplyStorageTechnology`](@ref) `financial_data`."""
get_financial_data(value::ColocatedSupplyStorageTechnology) = value.financial_data
"""Get [`ColocatedSupplyStorageTechnology`](@ref) `supply_technology`."""
get_supply_technology(value::ColocatedSupplyStorageTechnology) = value.supply_technology
"""Get [`ColocatedSupplyStorageTechnology`](@ref) `storage_technology`."""
get_storage_technology(value::ColocatedSupplyStorageTechnology) = value.storage_technology
"""Get [`ColocatedSupplyStorageTechnology`](@ref) `inverter_capacity_limits` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_inverter_capacity_limits_unitful`](@ref)."""
get_inverter_capacity_limits(value::ColocatedSupplyStorageTechnology, units) = InfrastructureSystems._strip_units(get_value(value, Val(:inverter_capacity_limits), Val(:mw), units))
"""Get [`ColocatedSupplyStorageTechnology`](@ref) `inverter_capacity_limits` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_inverter_capacity_limits`](@ref)."""
get_inverter_capacity_limits_unitful(value::ColocatedSupplyStorageTechnology, units) = get_value(value, Val(:inverter_capacity_limits), Val(:mw), units)
InfrastructureSystems.display_units_arg(::typeof(get_inverter_capacity_limits), ::Type{ColocatedSupplyStorageTechnology{T}}) where {T <: PSY.Generator} = InfrastructureSystems.NU
InfrastructureSystems.display_units_arg(::typeof(get_inverter_capacity_limits_unitful), ::Type{ColocatedSupplyStorageTechnology{T}}) where {T <: PSY.Generator} = InfrastructureSystems.NU
"""Get [`ColocatedSupplyStorageTechnology`](@ref) `capital_costs_inverter`."""
get_capital_costs_inverter(value::ColocatedSupplyStorageTechnology) = value.capital_costs_inverter
"""Get [`ColocatedSupplyStorageTechnology`](@ref) `operation_costs_inverter` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_operation_costs_inverter_unitful`](@ref)."""
get_operation_costs_inverter(value::ColocatedSupplyStorageTechnology, units) = InfrastructureSystems._strip_units(get_value(value, Val(:operation_costs_inverter), Val(:usd_per_mwh), units))
"""Get [`ColocatedSupplyStorageTechnology`](@ref) `operation_costs_inverter` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `CU`, `MW`). For a bare number see [`get_operation_costs_inverter`](@ref)."""
get_operation_costs_inverter_unitful(value::ColocatedSupplyStorageTechnology, units) = get_value(value, Val(:operation_costs_inverter), Val(:usd_per_mwh), units)
InfrastructureSystems.display_units_arg(::typeof(get_operation_costs_inverter), ::Type{ColocatedSupplyStorageTechnology{T}}) where {T <: PSY.Generator} = InfrastructureSystems.NU
InfrastructureSystems.display_units_arg(::typeof(get_operation_costs_inverter_unitful), ::Type{ColocatedSupplyStorageTechnology{T}}) where {T <: PSY.Generator} = InfrastructureSystems.NU
"""Get [`ColocatedSupplyStorageTechnology`](@ref) `inverter_efficiency`."""
get_inverter_efficiency(value::ColocatedSupplyStorageTechnology) = value.inverter_efficiency
"""Get [`ColocatedSupplyStorageTechnology`](@ref) `inverter_supply_ratio`."""
get_inverter_supply_ratio(value::ColocatedSupplyStorageTechnology) = value.inverter_supply_ratio
"""Get [`ColocatedSupplyStorageTechnology`](@ref) `requirements`."""
get_requirements(value::ColocatedSupplyStorageTechnology) = value.requirements
"""Get [`ColocatedSupplyStorageTechnology`](@ref) `ext`."""
get_ext(value::ColocatedSupplyStorageTechnology) = value.ext
"""Get [`ColocatedSupplyStorageTechnology`](@ref) `internal`."""
get_internal(value::ColocatedSupplyStorageTechnology) = value.internal

"""Set [`ColocatedSupplyStorageTechnology`](@ref) `name`."""
set_name!(value::ColocatedSupplyStorageTechnology, val) = value.name = val
"""Set [`ColocatedSupplyStorageTechnology`](@ref) `power_systems_type`."""
set_power_systems_type!(value::ColocatedSupplyStorageTechnology, val) = value.power_systems_type = val
"""Set [`ColocatedSupplyStorageTechnology`](@ref) `region`."""
set_region!(value::ColocatedSupplyStorageTechnology, val) = value.region = val
"""Set [`ColocatedSupplyStorageTechnology`](@ref) `available`."""
set_available!(value::ColocatedSupplyStorageTechnology, val) = value.available = val
"""Set [`ColocatedSupplyStorageTechnology`](@ref) `financial_data`."""
set_financial_data!(value::ColocatedSupplyStorageTechnology, val) = value.financial_data = val
"""Set [`ColocatedSupplyStorageTechnology`](@ref) `supply_technology`."""
set_supply_technology!(value::ColocatedSupplyStorageTechnology, val) = value.supply_technology = val
"""Set [`ColocatedSupplyStorageTechnology`](@ref) `storage_technology`."""
set_storage_technology!(value::ColocatedSupplyStorageTechnology, val) = value.storage_technology = val
"""Set [`ColocatedSupplyStorageTechnology`](@ref) `inverter_capacity_limits`."""
set_inverter_capacity_limits!(value::ColocatedSupplyStorageTechnology, val, unit) = value.inverter_capacity_limits = set_value(value, Val(:inverter_capacity_limits), val, unit, Val(:mw))
"""Set [`ColocatedSupplyStorageTechnology`](@ref) `capital_costs_inverter`."""
set_capital_costs_inverter!(value::ColocatedSupplyStorageTechnology, val) = value.capital_costs_inverter = val
"""Set [`ColocatedSupplyStorageTechnology`](@ref) `operation_costs_inverter`."""
set_operation_costs_inverter!(value::ColocatedSupplyStorageTechnology, val, unit) = value.operation_costs_inverter = set_value(value, Val(:operation_costs_inverter), val, unit, Val(:usd_per_mwh))
"""Set [`ColocatedSupplyStorageTechnology`](@ref) `inverter_efficiency`."""
set_inverter_efficiency!(value::ColocatedSupplyStorageTechnology, val) = value.inverter_efficiency = val
"""Set [`ColocatedSupplyStorageTechnology`](@ref) `inverter_supply_ratio`."""
set_inverter_supply_ratio!(value::ColocatedSupplyStorageTechnology, val) = value.inverter_supply_ratio = val
"""Set [`ColocatedSupplyStorageTechnology`](@ref) `requirements`."""
set_requirements!(value::ColocatedSupplyStorageTechnology, val) = value.requirements = val
"""Set [`ColocatedSupplyStorageTechnology`](@ref) `ext`."""
set_ext!(value::ColocatedSupplyStorageTechnology, val) = value.ext = val
"""Set [`ColocatedSupplyStorageTechnology`](@ref) `internal`."""
set_internal!(value::ColocatedSupplyStorageTechnology, val) = value.internal = val


function from_openapi(po::PI.ColocatedSupplyStorageTechnology, refs::OpenAPIRefs)
    parameter = getproperty(PowerSystems, Symbol(po.power_systems_type))
    return ColocatedSupplyStorageTechnology{parameter}(;
        name = po.name,
        power_systems_type = po.power_systems_type,
        region = resolve_refs(refs, po.region, PSY.Topology),
        available = po.available,
        financial_data = convert_nested_data(po.financial_data),
        supply_technology = resolve_ref(refs, po.supply_technology, SupplyTechnology),
        storage_technology = resolve_ref(refs, po.storage_technology, StorageTechnology),
        inverter_capacity_limits = _minmax_from_po(po.inverter_capacity_limits),
        capital_costs_inverter = convert_nested_data(po.capital_costs_inverter),
        operation_costs_inverter = convert_cost(po.operation_costs_inverter)::IS.ProductionVariableCostCurve,
        inverter_efficiency = po.inverter_efficiency,
        inverter_supply_ratio = po.inverter_supply_ratio,
    )
end

function to_openapi(value::ColocatedSupplyStorageTechnology{T}, refs::OpenAPIRefs) where {T <: PSY.Generator}
    return PI.ColocatedSupplyStorageTechnology(;
        id = get_id(value),
        name = get_name(value),
        power_systems_type = string(nameof(T)),
        region = component_ids(refs, get_region(value)),
        available = get_available(value),
        financial_data = convert_nested_data_to_openapi(get_financial_data(value)),
        supply_technology = component_id(refs, get_supply_technology(value)),
        storage_technology = component_id(refs, get_storage_technology(value)),
        inverter_capacity_limits = _minmax_po(get_inverter_capacity_limits(value, IS.NU)),
        capital_costs_inverter = convert_nested_data_to_openapi(get_capital_costs_inverter(value)),
        operation_costs_inverter = convert_cost_to_openapi(get_operation_costs_inverter(value, IS.NU)),
        inverter_efficiency = get_inverter_efficiency(value),
        inverter_supply_ratio = get_inverter_supply_ratio(value),
    )
end
