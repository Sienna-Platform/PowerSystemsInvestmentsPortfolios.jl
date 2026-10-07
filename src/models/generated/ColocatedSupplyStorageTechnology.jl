#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct ColocatedSupplyStorageTechnology{T <: PSY.Generator} <: ResourceTechnology
        requirements::Vector{Requirement}
        lifetime_storage::Int
        capital_costs_storage::StorageCapitalCost
        available::Bool
        operation_costs_solar::PSY.OperationalCost
        capacity_limits_wind::MinMax
        name::String
        capacity_power_limits::MinMax
        capacity_energy_limits::MinMax
        lifetime_wind::Int
        duration_limits::MinMax
        min_inverter_capacity::Float64
        operation_costs_inverter::PSY.OperationalCost
        id::Int64
        financial_data::TechnologyFinancialData
        inverter_efficiency::Float64
        power_systems_type::String
        capacity_limits_solar::MinMax
        internal::InfrastructureSystemsInternal
        operation_costs_storage::PSY.OperationalCost
        operation_costs_wind::PSY.OperationalCost
        efficiency_storage::InOut
        ext::Dict
        region::Vector{RegionTopology}
        losses_storage::Float64
        inverter_supply_ratio::Float64
        capital_costs_wind::CapitalCost
        lifetime_solar::Int
        capital_costs_inverter::CapitalCost
        max_inverter_capacity::Float64
        capital_costs_solar::CapitalCost
    end

Supply Technology that supports a StorageTechnology co-located with wind and solar generation

# Arguments
- `requirements::Vector{Requirement}`: (default: `Vector()`) List of requirements (i.e. reserve margin, capacity requirements, energy share requirements) that are associated with a technology
- `lifetime_storage::Int`: (default: `100`) Maximum number of years a technology can be active once installed (years)
- `capital_costs_storage::StorageCapitalCost`: (default: `StorageCapitalCost(nothing)`) Capital costs for investing in a storage technology's energy capacity. (USD/MWh)
- `available::Bool`: (default: `True`) Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`)
- `operation_costs_solar::PSY.OperationalCost`: (default: `ThermalGenerationCost(nothing)`) Fixed and variable O&M costs for a technology
- `capacity_limits_wind::MinMax`: (default: `(min=0, max=1e8)`) Maximum allowable installed capacity for a technology (MW)
- `name::String`: The technology name
- `capacity_power_limits::MinMax`: (default: `(min=0,max=1e8)`) allowable installed power capacity for a storage technology (MW)
- `capacity_energy_limits::MinMax`: (default: `(min=0,max=1e8)`) allowable installed energy capacity for a storage technology (MWh)
- `lifetime_wind::Int`: (default: `100`) Maximum number of years a technology can be active once installed (years)
- `duration_limits::MinMax`: (default: `(min=0,max=1000)`) Minimum required durattion for a storage technology (hours)
- `min_inverter_capacity::Float64`: (default: `1e8`) Minimum inverter capacity (MW)
- `operation_costs_inverter::PSY.OperationalCost`: Operational costs for using inverter in co-located systems
- `id::Int64`: ID for individual generator
- `financial_data::TechnologyFinancialData`: Struct containing relevant financial information for a technology
- `inverter_efficiency::Float64`: Efficiency of AC to DC conversion of inverter
- `power_systems_type::String`: Corresponding type in PowerSystems.jl to be used in PCM modeling
- `capacity_limits_solar::MinMax`: (default: `(min=0, max=1e8)`) Maximum allowable installed capacity for a technology (MW)
- `internal::InfrastructureSystemsInternal`: (default: `InfrastructureSystemsInternal()`) (**Do not modify.**) PowerSystemsInvestmentsPortfolios.jl internal reference
- `operation_costs_storage::PSY.OperationalCost`: (default: `StorageCost(nothing)`) Fixed and variable O&M costs for a storage technology
- `operation_costs_wind::PSY.OperationalCost`: (default: `ThermalGenerationCost(nothing)`) Fixed and variable O&M costs for a technology
- `efficiency_storage::InOut`: (default: `(in=1, out=1)`) Efficiency of charging storage (fraction of total charge (in) and discharge (out) capacity
- `ext::Dict`: (default: `Dict()`) Optional dictionary to provide additional data
- `region::Vector{RegionTopology}`: (default: `Vector()`) Zone where tech operates in
- `losses_storage::Float64`: (default: `0.0`) Power loss (fraction of stored energy per hour)
- `inverter_supply_ratio::Float64`: Ratio of generation capacity to grid connection capacity
- `capital_costs_wind::CapitalCost`: (default: `CapitalCost(nothing)`) Capital costs for investing in a technology. (USD/MW)
- `lifetime_solar::Int`: (default: `100`) Maximum number of years a technology can be active once installed (years)
- `capital_costs_inverter::CapitalCost`: Capitals costs for investing in inverter capacity (USD/MW)
- `max_inverter_capacity::Float64`: (default: `1e8`) Limit on inverter capacity (MW)
- `capital_costs_solar::CapitalCost`: (default: `CapitalCost(nothing)`) Capital costs for investing in a technology. (USD/MW)
"""
mutable struct ColocatedSupplyStorageTechnology{T <: PSY.Generator} <: ResourceTechnology
    "List of requirements (i.e. reserve margin, capacity requirements, energy share requirements) that are associated with a technology"
    requirements::Vector{Requirement}
    "Maximum number of years a technology can be active once installed (years)"
    lifetime_storage::Int
    "Capital costs for investing in a storage technology's energy capacity. (USD/MWh)"
    capital_costs_storage::StorageCapitalCost
    "Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`)"
    available::Bool
    "Fixed and variable O&M costs for a technology"
    operation_costs_solar::PSY.OperationalCost
    "Maximum allowable installed capacity for a technology (MW)"
    capacity_limits_wind::MinMax
    "The technology name"
    name::String
    "allowable installed power capacity for a storage technology (MW)"
    capacity_power_limits::MinMax
    "allowable installed energy capacity for a storage technology (MWh)"
    capacity_energy_limits::MinMax
    "Maximum number of years a technology can be active once installed (years)"
    lifetime_wind::Int
    "Minimum required durattion for a storage technology (hours)"
    duration_limits::MinMax
    "Minimum inverter capacity (MW)"
    min_inverter_capacity::Float64
    "Operational costs for using inverter in co-located systems"
    operation_costs_inverter::PSY.OperationalCost
    "ID for individual generator"
    id::Int64
    "Struct containing relevant financial information for a technology"
    financial_data::TechnologyFinancialData
    "Efficiency of AC to DC conversion of inverter"
    inverter_efficiency::Float64
    "Corresponding type in PowerSystems.jl to be used in PCM modeling"
    power_systems_type::String
    "Maximum allowable installed capacity for a technology (MW)"
    capacity_limits_solar::MinMax
    "(**Do not modify.**) PowerSystemsInvestmentsPortfolios.jl internal reference"
    internal::InfrastructureSystemsInternal
    "Fixed and variable O&M costs for a storage technology"
    operation_costs_storage::PSY.OperationalCost
    "Fixed and variable O&M costs for a technology"
    operation_costs_wind::PSY.OperationalCost
    "Efficiency of charging storage (fraction of total charge (in) and discharge (out) capacity"
    efficiency_storage::InOut
    "Optional dictionary to provide additional data"
    ext::Dict
    "Zone where tech operates in"
    region::Vector{RegionTopology}
    "Power loss (fraction of stored energy per hour)"
    losses_storage::Float64
    "Ratio of generation capacity to grid connection capacity"
    inverter_supply_ratio::Float64
    "Capital costs for investing in a technology. (USD/MW)"
    capital_costs_wind::CapitalCost
    "Maximum number of years a technology can be active once installed (years)"
    lifetime_solar::Int
    "Capitals costs for investing in inverter capacity (USD/MW)"
    capital_costs_inverter::CapitalCost
    "Limit on inverter capacity (MW)"
    max_inverter_capacity::Float64
    "Capital costs for investing in a technology. (USD/MW)"
    capital_costs_solar::CapitalCost
end


function ColocatedSupplyStorageTechnology{T}(; requirements=Vector(), lifetime_storage=100, capital_costs_storage=StorageCapitalCost(nothing), available=True, operation_costs_solar=ThermalGenerationCost(nothing), capacity_limits_wind=(min=0, max=1e8), name, capacity_power_limits=(min=0,max=1e8), capacity_energy_limits=(min=0,max=1e8), lifetime_wind=100, duration_limits=(min=0,max=1000), min_inverter_capacity=1e8, operation_costs_inverter, id, financial_data, inverter_efficiency, power_systems_type, capacity_limits_solar=(min=0, max=1e8), internal=InfrastructureSystemsInternal(), operation_costs_storage=StorageCost(nothing), operation_costs_wind=ThermalGenerationCost(nothing), efficiency_storage=(in=1, out=1), ext=Dict(), region=Vector(), losses_storage=0.0, inverter_supply_ratio, capital_costs_wind=CapitalCost(nothing), lifetime_solar=100, capital_costs_inverter, max_inverter_capacity=1e8, capital_costs_solar=CapitalCost(nothing), ) where T <: PSY.Generator
    ColocatedSupplyStorageTechnology{T}(requirements, lifetime_storage, capital_costs_storage, available, operation_costs_solar, capacity_limits_wind, name, capacity_power_limits, capacity_energy_limits, lifetime_wind, duration_limits, min_inverter_capacity, operation_costs_inverter, id, financial_data, inverter_efficiency, power_systems_type, capacity_limits_solar, internal, operation_costs_storage, operation_costs_wind, efficiency_storage, ext, region, losses_storage, inverter_supply_ratio, capital_costs_wind, lifetime_solar, capital_costs_inverter, max_inverter_capacity, capital_costs_solar, )
end

"""Get [`ColocatedSupplyStorageTechnology`](@ref) `requirements`."""
get_requirements(value::ColocatedSupplyStorageTechnology) = value.requirements
"""Get [`ColocatedSupplyStorageTechnology`](@ref) `lifetime_storage`."""
get_lifetime_storage(value::ColocatedSupplyStorageTechnology) = value.lifetime_storage
"""Get [`ColocatedSupplyStorageTechnology`](@ref) `capital_costs_storage`."""
get_capital_costs_storage(value::ColocatedSupplyStorageTechnology) = value.capital_costs_storage
"""Get [`ColocatedSupplyStorageTechnology`](@ref) `available`."""
get_available(value::ColocatedSupplyStorageTechnology) = value.available
"""Get [`ColocatedSupplyStorageTechnology`](@ref) `operation_costs_solar`."""
get_operation_costs_solar(value::ColocatedSupplyStorageTechnology) = value.operation_costs_solar
"""Get [`ColocatedSupplyStorageTechnology`](@ref) `capacity_limits_wind`."""
get_capacity_limits_wind(value::ColocatedSupplyStorageTechnology) = value.capacity_limits_wind
"""Get [`ColocatedSupplyStorageTechnology`](@ref) `name`."""
get_name(value::ColocatedSupplyStorageTechnology) = value.name
"""Get [`ColocatedSupplyStorageTechnology`](@ref) `capacity_power_limits`."""
get_capacity_power_limits(value::ColocatedSupplyStorageTechnology) = value.capacity_power_limits
"""Get [`ColocatedSupplyStorageTechnology`](@ref) `capacity_energy_limits`."""
get_capacity_energy_limits(value::ColocatedSupplyStorageTechnology) = value.capacity_energy_limits
"""Get [`ColocatedSupplyStorageTechnology`](@ref) `lifetime_wind`."""
get_lifetime_wind(value::ColocatedSupplyStorageTechnology) = value.lifetime_wind
"""Get [`ColocatedSupplyStorageTechnology`](@ref) `duration_limits`."""
get_duration_limits(value::ColocatedSupplyStorageTechnology) = value.duration_limits
"""Get [`ColocatedSupplyStorageTechnology`](@ref) `min_inverter_capacity`."""
get_min_inverter_capacity(value::ColocatedSupplyStorageTechnology) = value.min_inverter_capacity
"""Get [`ColocatedSupplyStorageTechnology`](@ref) `operation_costs_inverter`."""
get_operation_costs_inverter(value::ColocatedSupplyStorageTechnology) = value.operation_costs_inverter
"""Get [`ColocatedSupplyStorageTechnology`](@ref) `id`."""
get_id(value::ColocatedSupplyStorageTechnology) = value.id
"""Get [`ColocatedSupplyStorageTechnology`](@ref) `financial_data`."""
get_financial_data(value::ColocatedSupplyStorageTechnology) = value.financial_data
"""Get [`ColocatedSupplyStorageTechnology`](@ref) `inverter_efficiency`."""
get_inverter_efficiency(value::ColocatedSupplyStorageTechnology) = value.inverter_efficiency
"""Get [`ColocatedSupplyStorageTechnology`](@ref) `power_systems_type`."""
get_power_systems_type(value::ColocatedSupplyStorageTechnology) = value.power_systems_type
"""Get [`ColocatedSupplyStorageTechnology`](@ref) `capacity_limits_solar`."""
get_capacity_limits_solar(value::ColocatedSupplyStorageTechnology) = value.capacity_limits_solar
"""Get [`ColocatedSupplyStorageTechnology`](@ref) `internal`."""
get_internal(value::ColocatedSupplyStorageTechnology) = value.internal
"""Get [`ColocatedSupplyStorageTechnology`](@ref) `operation_costs_storage`."""
get_operation_costs_storage(value::ColocatedSupplyStorageTechnology) = value.operation_costs_storage
"""Get [`ColocatedSupplyStorageTechnology`](@ref) `operation_costs_wind`."""
get_operation_costs_wind(value::ColocatedSupplyStorageTechnology) = value.operation_costs_wind
"""Get [`ColocatedSupplyStorageTechnology`](@ref) `efficiency_storage`."""
get_efficiency_storage(value::ColocatedSupplyStorageTechnology) = value.efficiency_storage
"""Get [`ColocatedSupplyStorageTechnology`](@ref) `ext`."""
get_ext(value::ColocatedSupplyStorageTechnology) = value.ext
"""Get [`ColocatedSupplyStorageTechnology`](@ref) `region`."""
get_region(value::ColocatedSupplyStorageTechnology) = value.region
"""Get [`ColocatedSupplyStorageTechnology`](@ref) `losses_storage`."""
get_losses_storage(value::ColocatedSupplyStorageTechnology) = value.losses_storage
"""Get [`ColocatedSupplyStorageTechnology`](@ref) `inverter_supply_ratio`."""
get_inverter_supply_ratio(value::ColocatedSupplyStorageTechnology) = value.inverter_supply_ratio
"""Get [`ColocatedSupplyStorageTechnology`](@ref) `capital_costs_wind`."""
get_capital_costs_wind(value::ColocatedSupplyStorageTechnology) = value.capital_costs_wind
"""Get [`ColocatedSupplyStorageTechnology`](@ref) `lifetime_solar`."""
get_lifetime_solar(value::ColocatedSupplyStorageTechnology) = value.lifetime_solar
"""Get [`ColocatedSupplyStorageTechnology`](@ref) `capital_costs_inverter`."""
get_capital_costs_inverter(value::ColocatedSupplyStorageTechnology) = value.capital_costs_inverter
"""Get [`ColocatedSupplyStorageTechnology`](@ref) `max_inverter_capacity`."""
get_max_inverter_capacity(value::ColocatedSupplyStorageTechnology) = value.max_inverter_capacity
"""Get [`ColocatedSupplyStorageTechnology`](@ref) `capital_costs_solar`."""
get_capital_costs_solar(value::ColocatedSupplyStorageTechnology) = value.capital_costs_solar

"""Set [`ColocatedSupplyStorageTechnology`](@ref) `requirements`."""
set_requirements!(value::ColocatedSupplyStorageTechnology, val) = value.requirements = val
"""Set [`ColocatedSupplyStorageTechnology`](@ref) `lifetime_storage`."""
set_lifetime_storage!(value::ColocatedSupplyStorageTechnology, val) = value.lifetime_storage = val
"""Set [`ColocatedSupplyStorageTechnology`](@ref) `capital_costs_storage`."""
set_capital_costs_storage!(value::ColocatedSupplyStorageTechnology, val) = value.capital_costs_storage = val
"""Set [`ColocatedSupplyStorageTechnology`](@ref) `available`."""
set_available!(value::ColocatedSupplyStorageTechnology, val) = value.available = val
"""Set [`ColocatedSupplyStorageTechnology`](@ref) `operation_costs_solar`."""
set_operation_costs_solar!(value::ColocatedSupplyStorageTechnology, val) = value.operation_costs_solar = val
"""Set [`ColocatedSupplyStorageTechnology`](@ref) `capacity_limits_wind`."""
set_capacity_limits_wind!(value::ColocatedSupplyStorageTechnology, val) = value.capacity_limits_wind = val
"""Set [`ColocatedSupplyStorageTechnology`](@ref) `name`."""
set_name!(value::ColocatedSupplyStorageTechnology, val) = value.name = val
"""Set [`ColocatedSupplyStorageTechnology`](@ref) `capacity_power_limits`."""
set_capacity_power_limits!(value::ColocatedSupplyStorageTechnology, val) = value.capacity_power_limits = val
"""Set [`ColocatedSupplyStorageTechnology`](@ref) `capacity_energy_limits`."""
set_capacity_energy_limits!(value::ColocatedSupplyStorageTechnology, val) = value.capacity_energy_limits = val
"""Set [`ColocatedSupplyStorageTechnology`](@ref) `lifetime_wind`."""
set_lifetime_wind!(value::ColocatedSupplyStorageTechnology, val) = value.lifetime_wind = val
"""Set [`ColocatedSupplyStorageTechnology`](@ref) `duration_limits`."""
set_duration_limits!(value::ColocatedSupplyStorageTechnology, val) = value.duration_limits = val
"""Set [`ColocatedSupplyStorageTechnology`](@ref) `min_inverter_capacity`."""
set_min_inverter_capacity!(value::ColocatedSupplyStorageTechnology, val) = value.min_inverter_capacity = val
"""Set [`ColocatedSupplyStorageTechnology`](@ref) `operation_costs_inverter`."""
set_operation_costs_inverter!(value::ColocatedSupplyStorageTechnology, val) = value.operation_costs_inverter = val
"""Set [`ColocatedSupplyStorageTechnology`](@ref) `id`."""
set_id!(value::ColocatedSupplyStorageTechnology, val) = value.id = val
"""Set [`ColocatedSupplyStorageTechnology`](@ref) `financial_data`."""
set_financial_data!(value::ColocatedSupplyStorageTechnology, val) = value.financial_data = val
"""Set [`ColocatedSupplyStorageTechnology`](@ref) `inverter_efficiency`."""
set_inverter_efficiency!(value::ColocatedSupplyStorageTechnology, val) = value.inverter_efficiency = val
"""Set [`ColocatedSupplyStorageTechnology`](@ref) `power_systems_type`."""
set_power_systems_type!(value::ColocatedSupplyStorageTechnology, val) = value.power_systems_type = val
"""Set [`ColocatedSupplyStorageTechnology`](@ref) `capacity_limits_solar`."""
set_capacity_limits_solar!(value::ColocatedSupplyStorageTechnology, val) = value.capacity_limits_solar = val
"""Set [`ColocatedSupplyStorageTechnology`](@ref) `internal`."""
set_internal!(value::ColocatedSupplyStorageTechnology, val) = value.internal = val
"""Set [`ColocatedSupplyStorageTechnology`](@ref) `operation_costs_storage`."""
set_operation_costs_storage!(value::ColocatedSupplyStorageTechnology, val) = value.operation_costs_storage = val
"""Set [`ColocatedSupplyStorageTechnology`](@ref) `operation_costs_wind`."""
set_operation_costs_wind!(value::ColocatedSupplyStorageTechnology, val) = value.operation_costs_wind = val
"""Set [`ColocatedSupplyStorageTechnology`](@ref) `efficiency_storage`."""
set_efficiency_storage!(value::ColocatedSupplyStorageTechnology, val) = value.efficiency_storage = val
"""Set [`ColocatedSupplyStorageTechnology`](@ref) `ext`."""
set_ext!(value::ColocatedSupplyStorageTechnology, val) = value.ext = val
"""Set [`ColocatedSupplyStorageTechnology`](@ref) `region`."""
set_region!(value::ColocatedSupplyStorageTechnology, val) = value.region = val
"""Set [`ColocatedSupplyStorageTechnology`](@ref) `losses_storage`."""
set_losses_storage!(value::ColocatedSupplyStorageTechnology, val) = value.losses_storage = val
"""Set [`ColocatedSupplyStorageTechnology`](@ref) `inverter_supply_ratio`."""
set_inverter_supply_ratio!(value::ColocatedSupplyStorageTechnology, val) = value.inverter_supply_ratio = val
"""Set [`ColocatedSupplyStorageTechnology`](@ref) `capital_costs_wind`."""
set_capital_costs_wind!(value::ColocatedSupplyStorageTechnology, val) = value.capital_costs_wind = val
"""Set [`ColocatedSupplyStorageTechnology`](@ref) `lifetime_solar`."""
set_lifetime_solar!(value::ColocatedSupplyStorageTechnology, val) = value.lifetime_solar = val
"""Set [`ColocatedSupplyStorageTechnology`](@ref) `capital_costs_inverter`."""
set_capital_costs_inverter!(value::ColocatedSupplyStorageTechnology, val) = value.capital_costs_inverter = val
"""Set [`ColocatedSupplyStorageTechnology`](@ref) `max_inverter_capacity`."""
set_max_inverter_capacity!(value::ColocatedSupplyStorageTechnology, val) = value.max_inverter_capacity = val
"""Set [`ColocatedSupplyStorageTechnology`](@ref) `capital_costs_solar`."""
set_capital_costs_solar!(value::ColocatedSupplyStorageTechnology, val) = value.capital_costs_solar = val

function serialize_openapi_struct(technology::ColocatedSupplyStorageTechnology{T}, vals...) where T <: PSY.Generator
    base_struct = APIServer.ColocatedSupplyStorageTechnology(; vals...)
    return base_struct
end


function deserialize_openapi_struct(::Type{<:ColocatedSupplyStorageTechnology}, vals::Dict)
    return IS.deserialize_struct(APIServer.ColocatedSupplyStorageTechnology, vals)
end
