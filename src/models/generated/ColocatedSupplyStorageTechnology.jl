#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct ColocatedSupplyStorageTechnology{T <: PSY.Generator} <: ResourceTechnology
        name::String
        power_systems_type::String
        region::Vector{RegionTopology}
        available::Bool
        capital_costs_solar::PSY.ValueCurve
        operation_costs_solar::PSY.RenewableGenerationCost
        capacity_limits_solar::MinMax
        lifetime_solar::Int
        capital_costs_wind::PSY.ValueCurve
        operation_costs_wind::PSY.RenewableGenerationCost
        capacity_limits_wind::MinMax
        lifetime_wind::Int
        capital_costs_energy::PSY.ValueCurve
        capital_costs_power::PSY.ValueCurve
        operation_costs_energy::PSY.StorageCost
        operation_costs_power::PSY.StorageCost
        capacity_power_limits::MinMax
        capacity_energy_limits::MinMax
        duration_limits::MinMax
        efficiency_storage::InOut
        losses_storage::Float64
        lifetime_storage::Int
        financial_data::TechnologyFinancialData
        max_inverter_capacity::Float64
        min_inverter_capacity::Float64
        capital_costs_inverter::PSY.ValueCurve
        operation_costs_inverter::IS.ProductionVariableCostCurve
        inverter_efficiency::Float64
        inverter_supply_ratio::Float64
        ext::Dict
        internal::InfrastructureSystemsInternal
    end

Supply Technology that supports a StorageTechnology co-located with wind and solar generation

# Arguments
- `name::String`: The technology name
- `power_systems_type::String`: Corresponding type in PowerSystems.jl to be used in PCM modeling
- `region::Vector{RegionTopology}`: (default: `Vector()`) Zone where tech operates in
- `available::Bool`: (default: `true`) Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`)
- `capital_costs_solar::PSY.ValueCurve`: (default: `LinearCurve(0.0)`) Capital costs for investing in a technology. (USD/MW)
- `operation_costs_solar::PSY.RenewableGenerationCost`: (default: `RenewableGenerationCost(nothing)`) Fixed and variable O&M costs for a technology
- `capacity_limits_solar::MinMax`: (default: `(min=0, max=1e8)`) Maximum allowable installed capacity for a technology (MW)
- `lifetime_solar::Int`: (default: `100`) Maximum number of years a technology can be active once installed (years)
- `capital_costs_wind::PSY.ValueCurve`: (default: `LinearCurve(0.0)`) Capital costs for investing in a technology. (USD/MW)
- `operation_costs_wind::PSY.RenewableGenerationCost`: (default: `RenewableGenerationCost(nothing)`) Fixed and variable O&M costs for a technology
- `capacity_limits_wind::MinMax`: (default: `(min=0, max=1e8)`) Maximum allowable installed capacity for a technology (MW)
- `lifetime_wind::Int`: (default: `100`) Maximum number of years a technology can be active once installed (years)
- `capital_costs_energy::PSY.ValueCurve`: (default: `LinearCurve(0.0)`) Capital costs for investing in a storage technology's energy capacity. (USD/MWh)
- `capital_costs_power::PSY.ValueCurve`: (default: `LinearCurve(0.0)`) Capital costs for investing in a storage technology's charge/discharge capacity. (USD/MW)
- `operation_costs_energy::PSY.StorageCost`: (default: `StorageCost(nothing)`) Fixed and variable O&M costs for a storage technology
- `operation_costs_power::PSY.StorageCost`: (default: `StorageCost(nothing)`) Fixed and variable O&M costs for the storage power component. Units: USD/MWh.
- `capacity_power_limits::MinMax`: (default: `(min=0,max=1e8)`) allowable installed power capacity for a storage technology (MW)
- `capacity_energy_limits::MinMax`: (default: `(min=0,max=1e8)`) allowable installed energy capacity for a storage technology (MWh)
- `duration_limits::MinMax`: (default: `(min=0,max=60000)`) Minimum and maximum duration limits for the storage component (minutes). Units: min.
- `efficiency_storage::InOut`: (default: `(in=1, out=1)`) Efficiency of charging storage (fraction of total charge (in) and discharge (out) capacity
- `losses_storage::Float64`: (default: `0.0`) Power loss (fraction of stored energy per hour)
- `lifetime_storage::Int`: (default: `100`) Maximum number of years a technology can be active once installed (years)
- `financial_data::TechnologyFinancialData`: Struct containing relevant financial information for a technology
- `max_inverter_capacity::Float64`: (default: `1e8`) Limit on inverter capacity (MW)
- `min_inverter_capacity::Float64`: (default: `1e8`) Minimum inverter capacity (MW)
- `capital_costs_inverter::PSY.ValueCurve`: Capitals costs for investing in inverter capacity (USD/MW)
- `operation_costs_inverter::IS.ProductionVariableCostCurve`: Operational costs for using inverter in co-located systems
- `inverter_efficiency::Float64`: Efficiency of AC to DC conversion of inverter
- `inverter_supply_ratio::Float64`: Ratio of generation capacity to grid connection capacity
- `ext::Dict`: (default: `Dict()`) Optional dictionary to provide additional data
- `internal::InfrastructureSystemsInternal`: (default: `InfrastructureSystemsInternal()`) (**Do not modify.**) PowerSystemsInvestmentsPortfolios.jl internal reference
"""
mutable struct ColocatedSupplyStorageTechnology{T <: PSY.Generator} <: ResourceTechnology
    "The technology name"
    name::String
    "Corresponding type in PowerSystems.jl to be used in PCM modeling"
    power_systems_type::String
    "Zone where tech operates in"
    region::Vector{RegionTopology}
    "Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`)"
    available::Bool
    "Capital costs for investing in a technology. (USD/MW)"
    capital_costs_solar::PSY.ValueCurve
    "Fixed and variable O&M costs for a technology"
    operation_costs_solar::PSY.RenewableGenerationCost
    "Maximum allowable installed capacity for a technology (MW)"
    capacity_limits_solar::MinMax
    "Maximum number of years a technology can be active once installed (years)"
    lifetime_solar::Int
    "Capital costs for investing in a technology. (USD/MW)"
    capital_costs_wind::PSY.ValueCurve
    "Fixed and variable O&M costs for a technology"
    operation_costs_wind::PSY.RenewableGenerationCost
    "Maximum allowable installed capacity for a technology (MW)"
    capacity_limits_wind::MinMax
    "Maximum number of years a technology can be active once installed (years)"
    lifetime_wind::Int
    "Capital costs for investing in a storage technology's energy capacity. (USD/MWh)"
    capital_costs_energy::PSY.ValueCurve
    "Capital costs for investing in a storage technology's charge/discharge capacity. (USD/MW)"
    capital_costs_power::PSY.ValueCurve
    "Fixed and variable O&M costs for a storage technology"
    operation_costs_energy::PSY.StorageCost
    "Fixed and variable O&M costs for the storage power component. Units: USD/MWh."
    operation_costs_power::PSY.StorageCost
    "allowable installed power capacity for a storage technology (MW)"
    capacity_power_limits::MinMax
    "allowable installed energy capacity for a storage technology (MWh)"
    capacity_energy_limits::MinMax
    "Minimum and maximum duration limits for the storage component (minutes). Units: min."
    duration_limits::MinMax
    "Efficiency of charging storage (fraction of total charge (in) and discharge (out) capacity"
    efficiency_storage::InOut
    "Power loss (fraction of stored energy per hour)"
    losses_storage::Float64
    "Maximum number of years a technology can be active once installed (years)"
    lifetime_storage::Int
    "Struct containing relevant financial information for a technology"
    financial_data::TechnologyFinancialData
    "Limit on inverter capacity (MW)"
    max_inverter_capacity::Float64
    "Minimum inverter capacity (MW)"
    min_inverter_capacity::Float64
    "Capitals costs for investing in inverter capacity (USD/MW)"
    capital_costs_inverter::PSY.ValueCurve
    "Operational costs for using inverter in co-located systems"
    operation_costs_inverter::IS.ProductionVariableCostCurve
    "Efficiency of AC to DC conversion of inverter"
    inverter_efficiency::Float64
    "Ratio of generation capacity to grid connection capacity"
    inverter_supply_ratio::Float64
    "Optional dictionary to provide additional data"
    ext::Dict
    "(**Do not modify.**) PowerSystemsInvestmentsPortfolios.jl internal reference"
    internal::InfrastructureSystemsInternal
end


function ColocatedSupplyStorageTechnology{T}(; name, power_systems_type, region=Vector(), available=true, capital_costs_solar=LinearCurve(0.0), operation_costs_solar=RenewableGenerationCost(nothing), capacity_limits_solar=(min=0, max=1e8), lifetime_solar=100, capital_costs_wind=LinearCurve(0.0), operation_costs_wind=RenewableGenerationCost(nothing), capacity_limits_wind=(min=0, max=1e8), lifetime_wind=100, capital_costs_energy=LinearCurve(0.0), capital_costs_power=LinearCurve(0.0), operation_costs_energy=StorageCost(nothing), operation_costs_power=StorageCost(nothing), capacity_power_limits=(min=0,max=1e8), capacity_energy_limits=(min=0,max=1e8), duration_limits=(min=0,max=60000), efficiency_storage=(in=1, out=1), losses_storage=0.0, lifetime_storage=100, financial_data, max_inverter_capacity=1e8, min_inverter_capacity=1e8, capital_costs_inverter, operation_costs_inverter, inverter_efficiency, inverter_supply_ratio, ext=Dict(), internal=InfrastructureSystemsInternal(), ) where T <: PSY.Generator
    ColocatedSupplyStorageTechnology{T}(name, power_systems_type, region, available, capital_costs_solar, operation_costs_solar, capacity_limits_solar, lifetime_solar, capital_costs_wind, operation_costs_wind, capacity_limits_wind, lifetime_wind, capital_costs_energy, capital_costs_power, operation_costs_energy, operation_costs_power, capacity_power_limits, capacity_energy_limits, duration_limits, efficiency_storage, losses_storage, lifetime_storage, financial_data, max_inverter_capacity, min_inverter_capacity, capital_costs_inverter, operation_costs_inverter, inverter_efficiency, inverter_supply_ratio, ext, internal, )
end

"""Get [`ColocatedSupplyStorageTechnology`](@ref) `name`."""
get_name(value::ColocatedSupplyStorageTechnology) = value.name
"""Get [`ColocatedSupplyStorageTechnology`](@ref) `power_systems_type`."""
get_power_systems_type(value::ColocatedSupplyStorageTechnology) = value.power_systems_type
"""Get [`ColocatedSupplyStorageTechnology`](@ref) `region`."""
get_region(value::ColocatedSupplyStorageTechnology) = value.region
"""Get [`ColocatedSupplyStorageTechnology`](@ref) `available`."""
get_available(value::ColocatedSupplyStorageTechnology) = value.available
"""Get [`ColocatedSupplyStorageTechnology`](@ref) `capital_costs_solar` as a bare number in the requested `units` (e.g. `SU`, `CU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_capital_costs_solar_unitful`](@ref)."""
get_capital_costs_solar(value::ColocatedSupplyStorageTechnology, units) = InfrastructureSystems._strip_units(get_value(value, Val(:capital_costs_solar), Val(:usd_per_mw), units))
"""Get [`ColocatedSupplyStorageTechnology`](@ref) `capital_costs_solar` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `CU`, `MW`). For a bare number see [`get_capital_costs_solar`](@ref)."""
get_capital_costs_solar_unitful(value::ColocatedSupplyStorageTechnology, units) = get_value(value, Val(:capital_costs_solar), Val(:usd_per_mw), units)
InfrastructureSystems.display_units_arg(::typeof(get_capital_costs_solar), ::Type{ColocatedSupplyStorageTechnology{T}}) where {T <: PSY.Generator} = InfrastructureSystems.NU
InfrastructureSystems.display_units_arg(::typeof(get_capital_costs_solar_unitful), ::Type{ColocatedSupplyStorageTechnology{T}}) where {T <: PSY.Generator} = InfrastructureSystems.NU
"""Get [`ColocatedSupplyStorageTechnology`](@ref) `operation_costs_solar` as a bare number in the requested `units` (e.g. `SU`, `CU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_operation_costs_solar_unitful`](@ref)."""
get_operation_costs_solar(value::ColocatedSupplyStorageTechnology, units) = InfrastructureSystems._strip_units(get_value(value, Val(:operation_costs_solar), Val(:usd_per_mwh), units))
"""Get [`ColocatedSupplyStorageTechnology`](@ref) `operation_costs_solar` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `CU`, `MW`). For a bare number see [`get_operation_costs_solar`](@ref)."""
get_operation_costs_solar_unitful(value::ColocatedSupplyStorageTechnology, units) = get_value(value, Val(:operation_costs_solar), Val(:usd_per_mwh), units)
InfrastructureSystems.display_units_arg(::typeof(get_operation_costs_solar), ::Type{ColocatedSupplyStorageTechnology{T}}) where {T <: PSY.Generator} = InfrastructureSystems.NU
InfrastructureSystems.display_units_arg(::typeof(get_operation_costs_solar_unitful), ::Type{ColocatedSupplyStorageTechnology{T}}) where {T <: PSY.Generator} = InfrastructureSystems.NU
"""Get [`ColocatedSupplyStorageTechnology`](@ref) `capacity_limits_solar` as a bare number in the requested `units` (e.g. `SU`, `CU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_capacity_limits_solar_unitful`](@ref)."""
get_capacity_limits_solar(value::ColocatedSupplyStorageTechnology, units) = InfrastructureSystems._strip_units(get_value(value, Val(:capacity_limits_solar), Val(:mw), units))
"""Get [`ColocatedSupplyStorageTechnology`](@ref) `capacity_limits_solar` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `CU`, `MW`). For a bare number see [`get_capacity_limits_solar`](@ref)."""
get_capacity_limits_solar_unitful(value::ColocatedSupplyStorageTechnology, units) = get_value(value, Val(:capacity_limits_solar), Val(:mw), units)
InfrastructureSystems.display_units_arg(::typeof(get_capacity_limits_solar), ::Type{ColocatedSupplyStorageTechnology{T}}) where {T <: PSY.Generator} = InfrastructureSystems.NU
InfrastructureSystems.display_units_arg(::typeof(get_capacity_limits_solar_unitful), ::Type{ColocatedSupplyStorageTechnology{T}}) where {T <: PSY.Generator} = InfrastructureSystems.NU
"""Get [`ColocatedSupplyStorageTechnology`](@ref) `lifetime_solar` as a bare number in the requested `units` (e.g. `SU`, `CU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_lifetime_solar_unitful`](@ref)."""
get_lifetime_solar(value::ColocatedSupplyStorageTechnology, units) = InfrastructureSystems._strip_units(get_value(value, Val(:lifetime_solar), Val(:yr), units))
"""Get [`ColocatedSupplyStorageTechnology`](@ref) `lifetime_solar` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `CU`, `MW`). For a bare number see [`get_lifetime_solar`](@ref)."""
get_lifetime_solar_unitful(value::ColocatedSupplyStorageTechnology, units) = get_value(value, Val(:lifetime_solar), Val(:yr), units)
InfrastructureSystems.display_units_arg(::typeof(get_lifetime_solar), ::Type{ColocatedSupplyStorageTechnology{T}}) where {T <: PSY.Generator} = InfrastructureSystems.NU
InfrastructureSystems.display_units_arg(::typeof(get_lifetime_solar_unitful), ::Type{ColocatedSupplyStorageTechnology{T}}) where {T <: PSY.Generator} = InfrastructureSystems.NU
"""Get [`ColocatedSupplyStorageTechnology`](@ref) `capital_costs_wind` as a bare number in the requested `units` (e.g. `SU`, `CU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_capital_costs_wind_unitful`](@ref)."""
get_capital_costs_wind(value::ColocatedSupplyStorageTechnology, units) = InfrastructureSystems._strip_units(get_value(value, Val(:capital_costs_wind), Val(:usd_per_mw), units))
"""Get [`ColocatedSupplyStorageTechnology`](@ref) `capital_costs_wind` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `CU`, `MW`). For a bare number see [`get_capital_costs_wind`](@ref)."""
get_capital_costs_wind_unitful(value::ColocatedSupplyStorageTechnology, units) = get_value(value, Val(:capital_costs_wind), Val(:usd_per_mw), units)
InfrastructureSystems.display_units_arg(::typeof(get_capital_costs_wind), ::Type{ColocatedSupplyStorageTechnology{T}}) where {T <: PSY.Generator} = InfrastructureSystems.NU
InfrastructureSystems.display_units_arg(::typeof(get_capital_costs_wind_unitful), ::Type{ColocatedSupplyStorageTechnology{T}}) where {T <: PSY.Generator} = InfrastructureSystems.NU
"""Get [`ColocatedSupplyStorageTechnology`](@ref) `operation_costs_wind` as a bare number in the requested `units` (e.g. `SU`, `CU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_operation_costs_wind_unitful`](@ref)."""
get_operation_costs_wind(value::ColocatedSupplyStorageTechnology, units) = InfrastructureSystems._strip_units(get_value(value, Val(:operation_costs_wind), Val(:usd_per_mwh), units))
"""Get [`ColocatedSupplyStorageTechnology`](@ref) `operation_costs_wind` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `CU`, `MW`). For a bare number see [`get_operation_costs_wind`](@ref)."""
get_operation_costs_wind_unitful(value::ColocatedSupplyStorageTechnology, units) = get_value(value, Val(:operation_costs_wind), Val(:usd_per_mwh), units)
InfrastructureSystems.display_units_arg(::typeof(get_operation_costs_wind), ::Type{ColocatedSupplyStorageTechnology{T}}) where {T <: PSY.Generator} = InfrastructureSystems.NU
InfrastructureSystems.display_units_arg(::typeof(get_operation_costs_wind_unitful), ::Type{ColocatedSupplyStorageTechnology{T}}) where {T <: PSY.Generator} = InfrastructureSystems.NU
"""Get [`ColocatedSupplyStorageTechnology`](@ref) `capacity_limits_wind` as a bare number in the requested `units` (e.g. `SU`, `CU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_capacity_limits_wind_unitful`](@ref)."""
get_capacity_limits_wind(value::ColocatedSupplyStorageTechnology, units) = InfrastructureSystems._strip_units(get_value(value, Val(:capacity_limits_wind), Val(:mw), units))
"""Get [`ColocatedSupplyStorageTechnology`](@ref) `capacity_limits_wind` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `CU`, `MW`). For a bare number see [`get_capacity_limits_wind`](@ref)."""
get_capacity_limits_wind_unitful(value::ColocatedSupplyStorageTechnology, units) = get_value(value, Val(:capacity_limits_wind), Val(:mw), units)
InfrastructureSystems.display_units_arg(::typeof(get_capacity_limits_wind), ::Type{ColocatedSupplyStorageTechnology{T}}) where {T <: PSY.Generator} = InfrastructureSystems.NU
InfrastructureSystems.display_units_arg(::typeof(get_capacity_limits_wind_unitful), ::Type{ColocatedSupplyStorageTechnology{T}}) where {T <: PSY.Generator} = InfrastructureSystems.NU
"""Get [`ColocatedSupplyStorageTechnology`](@ref) `lifetime_wind` as a bare number in the requested `units` (e.g. `SU`, `CU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_lifetime_wind_unitful`](@ref)."""
get_lifetime_wind(value::ColocatedSupplyStorageTechnology, units) = InfrastructureSystems._strip_units(get_value(value, Val(:lifetime_wind), Val(:yr), units))
"""Get [`ColocatedSupplyStorageTechnology`](@ref) `lifetime_wind` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `CU`, `MW`). For a bare number see [`get_lifetime_wind`](@ref)."""
get_lifetime_wind_unitful(value::ColocatedSupplyStorageTechnology, units) = get_value(value, Val(:lifetime_wind), Val(:yr), units)
InfrastructureSystems.display_units_arg(::typeof(get_lifetime_wind), ::Type{ColocatedSupplyStorageTechnology{T}}) where {T <: PSY.Generator} = InfrastructureSystems.NU
InfrastructureSystems.display_units_arg(::typeof(get_lifetime_wind_unitful), ::Type{ColocatedSupplyStorageTechnology{T}}) where {T <: PSY.Generator} = InfrastructureSystems.NU
"""Get [`ColocatedSupplyStorageTechnology`](@ref) `capital_costs_energy` as a bare number in the requested `units` (e.g. `SU`, `CU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_capital_costs_energy_unitful`](@ref)."""
get_capital_costs_energy(value::ColocatedSupplyStorageTechnology, units) = InfrastructureSystems._strip_units(get_value(value, Val(:capital_costs_energy), Val(:usd_per_mwh), units))
"""Get [`ColocatedSupplyStorageTechnology`](@ref) `capital_costs_energy` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `CU`, `MW`). For a bare number see [`get_capital_costs_energy`](@ref)."""
get_capital_costs_energy_unitful(value::ColocatedSupplyStorageTechnology, units) = get_value(value, Val(:capital_costs_energy), Val(:usd_per_mwh), units)
InfrastructureSystems.display_units_arg(::typeof(get_capital_costs_energy), ::Type{ColocatedSupplyStorageTechnology{T}}) where {T <: PSY.Generator} = InfrastructureSystems.NU
InfrastructureSystems.display_units_arg(::typeof(get_capital_costs_energy_unitful), ::Type{ColocatedSupplyStorageTechnology{T}}) where {T <: PSY.Generator} = InfrastructureSystems.NU
"""Get [`ColocatedSupplyStorageTechnology`](@ref) `capital_costs_power` as a bare number in the requested `units` (e.g. `SU`, `CU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_capital_costs_power_unitful`](@ref)."""
get_capital_costs_power(value::ColocatedSupplyStorageTechnology, units) = InfrastructureSystems._strip_units(get_value(value, Val(:capital_costs_power), Val(:usd_per_mw), units))
"""Get [`ColocatedSupplyStorageTechnology`](@ref) `capital_costs_power` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `CU`, `MW`). For a bare number see [`get_capital_costs_power`](@ref)."""
get_capital_costs_power_unitful(value::ColocatedSupplyStorageTechnology, units) = get_value(value, Val(:capital_costs_power), Val(:usd_per_mw), units)
InfrastructureSystems.display_units_arg(::typeof(get_capital_costs_power), ::Type{ColocatedSupplyStorageTechnology{T}}) where {T <: PSY.Generator} = InfrastructureSystems.NU
InfrastructureSystems.display_units_arg(::typeof(get_capital_costs_power_unitful), ::Type{ColocatedSupplyStorageTechnology{T}}) where {T <: PSY.Generator} = InfrastructureSystems.NU
"""Get [`ColocatedSupplyStorageTechnology`](@ref) `operation_costs_energy` as a bare number in the requested `units` (e.g. `SU`, `CU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_operation_costs_energy_unitful`](@ref)."""
get_operation_costs_energy(value::ColocatedSupplyStorageTechnology, units) = InfrastructureSystems._strip_units(get_value(value, Val(:operation_costs_energy), Val(:usd_per_mwh), units))
"""Get [`ColocatedSupplyStorageTechnology`](@ref) `operation_costs_energy` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `CU`, `MW`). For a bare number see [`get_operation_costs_energy`](@ref)."""
get_operation_costs_energy_unitful(value::ColocatedSupplyStorageTechnology, units) = get_value(value, Val(:operation_costs_energy), Val(:usd_per_mwh), units)
InfrastructureSystems.display_units_arg(::typeof(get_operation_costs_energy), ::Type{ColocatedSupplyStorageTechnology{T}}) where {T <: PSY.Generator} = InfrastructureSystems.NU
InfrastructureSystems.display_units_arg(::typeof(get_operation_costs_energy_unitful), ::Type{ColocatedSupplyStorageTechnology{T}}) where {T <: PSY.Generator} = InfrastructureSystems.NU
"""Get [`ColocatedSupplyStorageTechnology`](@ref) `operation_costs_power` as a bare number in the requested `units` (e.g. `SU`, `CU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_operation_costs_power_unitful`](@ref)."""
get_operation_costs_power(value::ColocatedSupplyStorageTechnology, units) = InfrastructureSystems._strip_units(get_value(value, Val(:operation_costs_power), Val(:usd_per_mwh), units))
"""Get [`ColocatedSupplyStorageTechnology`](@ref) `operation_costs_power` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `CU`, `MW`). For a bare number see [`get_operation_costs_power`](@ref)."""
get_operation_costs_power_unitful(value::ColocatedSupplyStorageTechnology, units) = get_value(value, Val(:operation_costs_power), Val(:usd_per_mwh), units)
InfrastructureSystems.display_units_arg(::typeof(get_operation_costs_power), ::Type{ColocatedSupplyStorageTechnology{T}}) where {T <: PSY.Generator} = InfrastructureSystems.NU
InfrastructureSystems.display_units_arg(::typeof(get_operation_costs_power_unitful), ::Type{ColocatedSupplyStorageTechnology{T}}) where {T <: PSY.Generator} = InfrastructureSystems.NU
"""Get [`ColocatedSupplyStorageTechnology`](@ref) `capacity_power_limits` as a bare number in the requested `units` (e.g. `SU`, `CU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_capacity_power_limits_unitful`](@ref)."""
get_capacity_power_limits(value::ColocatedSupplyStorageTechnology, units) = InfrastructureSystems._strip_units(get_value(value, Val(:capacity_power_limits), Val(:mw), units))
"""Get [`ColocatedSupplyStorageTechnology`](@ref) `capacity_power_limits` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `CU`, `MW`). For a bare number see [`get_capacity_power_limits`](@ref)."""
get_capacity_power_limits_unitful(value::ColocatedSupplyStorageTechnology, units) = get_value(value, Val(:capacity_power_limits), Val(:mw), units)
InfrastructureSystems.display_units_arg(::typeof(get_capacity_power_limits), ::Type{ColocatedSupplyStorageTechnology{T}}) where {T <: PSY.Generator} = InfrastructureSystems.NU
InfrastructureSystems.display_units_arg(::typeof(get_capacity_power_limits_unitful), ::Type{ColocatedSupplyStorageTechnology{T}}) where {T <: PSY.Generator} = InfrastructureSystems.NU
"""Get [`ColocatedSupplyStorageTechnology`](@ref) `capacity_energy_limits` as a bare number in the requested `units` (e.g. `SU`, `CU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_capacity_energy_limits_unitful`](@ref)."""
get_capacity_energy_limits(value::ColocatedSupplyStorageTechnology, units) = InfrastructureSystems._strip_units(get_value(value, Val(:capacity_energy_limits), Val(:mwh), units))
"""Get [`ColocatedSupplyStorageTechnology`](@ref) `capacity_energy_limits` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `CU`, `MW`). For a bare number see [`get_capacity_energy_limits`](@ref)."""
get_capacity_energy_limits_unitful(value::ColocatedSupplyStorageTechnology, units) = get_value(value, Val(:capacity_energy_limits), Val(:mwh), units)
InfrastructureSystems.display_units_arg(::typeof(get_capacity_energy_limits), ::Type{ColocatedSupplyStorageTechnology{T}}) where {T <: PSY.Generator} = InfrastructureSystems.NU
InfrastructureSystems.display_units_arg(::typeof(get_capacity_energy_limits_unitful), ::Type{ColocatedSupplyStorageTechnology{T}}) where {T <: PSY.Generator} = InfrastructureSystems.NU
"""Get [`ColocatedSupplyStorageTechnology`](@ref) `duration_limits` as a bare number in the requested `units` (e.g. `SU`, `CU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_duration_limits_unitful`](@ref)."""
get_duration_limits(value::ColocatedSupplyStorageTechnology, units) = InfrastructureSystems._strip_units(get_value(value, Val(:duration_limits), Val(:min), units))
"""Get [`ColocatedSupplyStorageTechnology`](@ref) `duration_limits` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `CU`, `MW`). For a bare number see [`get_duration_limits`](@ref)."""
get_duration_limits_unitful(value::ColocatedSupplyStorageTechnology, units) = get_value(value, Val(:duration_limits), Val(:min), units)
InfrastructureSystems.display_units_arg(::typeof(get_duration_limits), ::Type{ColocatedSupplyStorageTechnology{T}}) where {T <: PSY.Generator} = InfrastructureSystems.NU
InfrastructureSystems.display_units_arg(::typeof(get_duration_limits_unitful), ::Type{ColocatedSupplyStorageTechnology{T}}) where {T <: PSY.Generator} = InfrastructureSystems.NU
"""Get [`ColocatedSupplyStorageTechnology`](@ref) `efficiency_storage`."""
get_efficiency_storage(value::ColocatedSupplyStorageTechnology) = value.efficiency_storage
"""Get [`ColocatedSupplyStorageTechnology`](@ref) `losses_storage`."""
get_losses_storage(value::ColocatedSupplyStorageTechnology) = value.losses_storage
"""Get [`ColocatedSupplyStorageTechnology`](@ref) `lifetime_storage` as a bare number in the requested `units` (e.g. `SU`, `CU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_lifetime_storage_unitful`](@ref)."""
get_lifetime_storage(value::ColocatedSupplyStorageTechnology, units) = InfrastructureSystems._strip_units(get_value(value, Val(:lifetime_storage), Val(:yr), units))
"""Get [`ColocatedSupplyStorageTechnology`](@ref) `lifetime_storage` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `CU`, `MW`). For a bare number see [`get_lifetime_storage`](@ref)."""
get_lifetime_storage_unitful(value::ColocatedSupplyStorageTechnology, units) = get_value(value, Val(:lifetime_storage), Val(:yr), units)
InfrastructureSystems.display_units_arg(::typeof(get_lifetime_storage), ::Type{ColocatedSupplyStorageTechnology{T}}) where {T <: PSY.Generator} = InfrastructureSystems.NU
InfrastructureSystems.display_units_arg(::typeof(get_lifetime_storage_unitful), ::Type{ColocatedSupplyStorageTechnology{T}}) where {T <: PSY.Generator} = InfrastructureSystems.NU
"""Get [`ColocatedSupplyStorageTechnology`](@ref) `financial_data`."""
get_financial_data(value::ColocatedSupplyStorageTechnology) = value.financial_data
"""Get [`ColocatedSupplyStorageTechnology`](@ref) `max_inverter_capacity` as a bare number in the requested `units` (e.g. `SU`, `CU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_max_inverter_capacity_unitful`](@ref)."""
get_max_inverter_capacity(value::ColocatedSupplyStorageTechnology, units) = InfrastructureSystems._strip_units(get_value(value, Val(:max_inverter_capacity), Val(:mw), units))
"""Get [`ColocatedSupplyStorageTechnology`](@ref) `max_inverter_capacity` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `CU`, `MW`). For a bare number see [`get_max_inverter_capacity`](@ref)."""
get_max_inverter_capacity_unitful(value::ColocatedSupplyStorageTechnology, units) = get_value(value, Val(:max_inverter_capacity), Val(:mw), units)
InfrastructureSystems.display_units_arg(::typeof(get_max_inverter_capacity), ::Type{ColocatedSupplyStorageTechnology{T}}) where {T <: PSY.Generator} = InfrastructureSystems.NU
InfrastructureSystems.display_units_arg(::typeof(get_max_inverter_capacity_unitful), ::Type{ColocatedSupplyStorageTechnology{T}}) where {T <: PSY.Generator} = InfrastructureSystems.NU
"""Get [`ColocatedSupplyStorageTechnology`](@ref) `min_inverter_capacity` as a bare number in the requested `units` (e.g. `SU`, `CU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_min_inverter_capacity_unitful`](@ref)."""
get_min_inverter_capacity(value::ColocatedSupplyStorageTechnology, units) = InfrastructureSystems._strip_units(get_value(value, Val(:min_inverter_capacity), Val(:mw), units))
"""Get [`ColocatedSupplyStorageTechnology`](@ref) `min_inverter_capacity` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `CU`, `MW`). For a bare number see [`get_min_inverter_capacity`](@ref)."""
get_min_inverter_capacity_unitful(value::ColocatedSupplyStorageTechnology, units) = get_value(value, Val(:min_inverter_capacity), Val(:mw), units)
InfrastructureSystems.display_units_arg(::typeof(get_min_inverter_capacity), ::Type{ColocatedSupplyStorageTechnology{T}}) where {T <: PSY.Generator} = InfrastructureSystems.NU
InfrastructureSystems.display_units_arg(::typeof(get_min_inverter_capacity_unitful), ::Type{ColocatedSupplyStorageTechnology{T}}) where {T <: PSY.Generator} = InfrastructureSystems.NU
"""Get [`ColocatedSupplyStorageTechnology`](@ref) `capital_costs_inverter` as a bare number in the requested `units` (e.g. `SU`, `CU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_capital_costs_inverter_unitful`](@ref)."""
get_capital_costs_inverter(value::ColocatedSupplyStorageTechnology, units) = InfrastructureSystems._strip_units(get_value(value, Val(:capital_costs_inverter), Val(:usd_per_mw), units))
"""Get [`ColocatedSupplyStorageTechnology`](@ref) `capital_costs_inverter` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `CU`, `MW`). For a bare number see [`get_capital_costs_inverter`](@ref)."""
get_capital_costs_inverter_unitful(value::ColocatedSupplyStorageTechnology, units) = get_value(value, Val(:capital_costs_inverter), Val(:usd_per_mw), units)
InfrastructureSystems.display_units_arg(::typeof(get_capital_costs_inverter), ::Type{ColocatedSupplyStorageTechnology{T}}) where {T <: PSY.Generator} = InfrastructureSystems.NU
InfrastructureSystems.display_units_arg(::typeof(get_capital_costs_inverter_unitful), ::Type{ColocatedSupplyStorageTechnology{T}}) where {T <: PSY.Generator} = InfrastructureSystems.NU
"""Get [`ColocatedSupplyStorageTechnology`](@ref) `operation_costs_inverter` as a bare number in the requested `units` (e.g. `SU`, `CU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_operation_costs_inverter_unitful`](@ref)."""
get_operation_costs_inverter(value::ColocatedSupplyStorageTechnology, units) = InfrastructureSystems._strip_units(get_value(value, Val(:operation_costs_inverter), Val(:usd_per_mwh), units))
"""Get [`ColocatedSupplyStorageTechnology`](@ref) `operation_costs_inverter` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `CU`, `MW`). For a bare number see [`get_operation_costs_inverter`](@ref)."""
get_operation_costs_inverter_unitful(value::ColocatedSupplyStorageTechnology, units) = get_value(value, Val(:operation_costs_inverter), Val(:usd_per_mwh), units)
InfrastructureSystems.display_units_arg(::typeof(get_operation_costs_inverter), ::Type{ColocatedSupplyStorageTechnology{T}}) where {T <: PSY.Generator} = InfrastructureSystems.NU
InfrastructureSystems.display_units_arg(::typeof(get_operation_costs_inverter_unitful), ::Type{ColocatedSupplyStorageTechnology{T}}) where {T <: PSY.Generator} = InfrastructureSystems.NU
"""Get [`ColocatedSupplyStorageTechnology`](@ref) `inverter_efficiency`."""
get_inverter_efficiency(value::ColocatedSupplyStorageTechnology) = value.inverter_efficiency
"""Get [`ColocatedSupplyStorageTechnology`](@ref) `inverter_supply_ratio`."""
get_inverter_supply_ratio(value::ColocatedSupplyStorageTechnology) = value.inverter_supply_ratio
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
"""Set [`ColocatedSupplyStorageTechnology`](@ref) `capital_costs_solar`."""
set_capital_costs_solar!(value::ColocatedSupplyStorageTechnology, val, unit) = value.capital_costs_solar = set_value(value, Val(:capital_costs_solar), val, unit, Val(:usd_per_mw))
"""Set [`ColocatedSupplyStorageTechnology`](@ref) `operation_costs_solar`."""
set_operation_costs_solar!(value::ColocatedSupplyStorageTechnology, val, unit) = value.operation_costs_solar = set_value(value, Val(:operation_costs_solar), val, unit, Val(:usd_per_mwh))
"""Set [`ColocatedSupplyStorageTechnology`](@ref) `capacity_limits_solar`."""
set_capacity_limits_solar!(value::ColocatedSupplyStorageTechnology, val, unit) = value.capacity_limits_solar = set_value(value, Val(:capacity_limits_solar), val, unit, Val(:mw))
"""Set [`ColocatedSupplyStorageTechnology`](@ref) `lifetime_solar`."""
set_lifetime_solar!(value::ColocatedSupplyStorageTechnology, val, unit) = value.lifetime_solar = set_value(value, Val(:lifetime_solar), val, unit, Val(:yr))
"""Set [`ColocatedSupplyStorageTechnology`](@ref) `capital_costs_wind`."""
set_capital_costs_wind!(value::ColocatedSupplyStorageTechnology, val, unit) = value.capital_costs_wind = set_value(value, Val(:capital_costs_wind), val, unit, Val(:usd_per_mw))
"""Set [`ColocatedSupplyStorageTechnology`](@ref) `operation_costs_wind`."""
set_operation_costs_wind!(value::ColocatedSupplyStorageTechnology, val, unit) = value.operation_costs_wind = set_value(value, Val(:operation_costs_wind), val, unit, Val(:usd_per_mwh))
"""Set [`ColocatedSupplyStorageTechnology`](@ref) `capacity_limits_wind`."""
set_capacity_limits_wind!(value::ColocatedSupplyStorageTechnology, val, unit) = value.capacity_limits_wind = set_value(value, Val(:capacity_limits_wind), val, unit, Val(:mw))
"""Set [`ColocatedSupplyStorageTechnology`](@ref) `lifetime_wind`."""
set_lifetime_wind!(value::ColocatedSupplyStorageTechnology, val, unit) = value.lifetime_wind = set_value(value, Val(:lifetime_wind), val, unit, Val(:yr))
"""Set [`ColocatedSupplyStorageTechnology`](@ref) `capital_costs_energy`."""
set_capital_costs_energy!(value::ColocatedSupplyStorageTechnology, val, unit) = value.capital_costs_energy = set_value(value, Val(:capital_costs_energy), val, unit, Val(:usd_per_mwh))
"""Set [`ColocatedSupplyStorageTechnology`](@ref) `capital_costs_power`."""
set_capital_costs_power!(value::ColocatedSupplyStorageTechnology, val, unit) = value.capital_costs_power = set_value(value, Val(:capital_costs_power), val, unit, Val(:usd_per_mw))
"""Set [`ColocatedSupplyStorageTechnology`](@ref) `operation_costs_energy`."""
set_operation_costs_energy!(value::ColocatedSupplyStorageTechnology, val, unit) = value.operation_costs_energy = set_value(value, Val(:operation_costs_energy), val, unit, Val(:usd_per_mwh))
"""Set [`ColocatedSupplyStorageTechnology`](@ref) `operation_costs_power`."""
set_operation_costs_power!(value::ColocatedSupplyStorageTechnology, val, unit) = value.operation_costs_power = set_value(value, Val(:operation_costs_power), val, unit, Val(:usd_per_mwh))
"""Set [`ColocatedSupplyStorageTechnology`](@ref) `capacity_power_limits`."""
set_capacity_power_limits!(value::ColocatedSupplyStorageTechnology, val, unit) = value.capacity_power_limits = set_value(value, Val(:capacity_power_limits), val, unit, Val(:mw))
"""Set [`ColocatedSupplyStorageTechnology`](@ref) `capacity_energy_limits`."""
set_capacity_energy_limits!(value::ColocatedSupplyStorageTechnology, val, unit) = value.capacity_energy_limits = set_value(value, Val(:capacity_energy_limits), val, unit, Val(:mwh))
"""Set [`ColocatedSupplyStorageTechnology`](@ref) `duration_limits`."""
set_duration_limits!(value::ColocatedSupplyStorageTechnology, val, unit) = value.duration_limits = set_value(value, Val(:duration_limits), val, unit, Val(:min))
"""Set [`ColocatedSupplyStorageTechnology`](@ref) `efficiency_storage`."""
set_efficiency_storage!(value::ColocatedSupplyStorageTechnology, val) = value.efficiency_storage = val
"""Set [`ColocatedSupplyStorageTechnology`](@ref) `losses_storage`."""
set_losses_storage!(value::ColocatedSupplyStorageTechnology, val) = value.losses_storage = val
"""Set [`ColocatedSupplyStorageTechnology`](@ref) `lifetime_storage`."""
set_lifetime_storage!(value::ColocatedSupplyStorageTechnology, val, unit) = value.lifetime_storage = set_value(value, Val(:lifetime_storage), val, unit, Val(:yr))
"""Set [`ColocatedSupplyStorageTechnology`](@ref) `financial_data`."""
set_financial_data!(value::ColocatedSupplyStorageTechnology, val) = value.financial_data = val
"""Set [`ColocatedSupplyStorageTechnology`](@ref) `max_inverter_capacity`."""
set_max_inverter_capacity!(value::ColocatedSupplyStorageTechnology, val, unit) = value.max_inverter_capacity = set_value(value, Val(:max_inverter_capacity), val, unit, Val(:mw))
"""Set [`ColocatedSupplyStorageTechnology`](@ref) `min_inverter_capacity`."""
set_min_inverter_capacity!(value::ColocatedSupplyStorageTechnology, val, unit) = value.min_inverter_capacity = set_value(value, Val(:min_inverter_capacity), val, unit, Val(:mw))
"""Set [`ColocatedSupplyStorageTechnology`](@ref) `capital_costs_inverter`."""
set_capital_costs_inverter!(value::ColocatedSupplyStorageTechnology, val, unit) = value.capital_costs_inverter = set_value(value, Val(:capital_costs_inverter), val, unit, Val(:usd_per_mw))
"""Set [`ColocatedSupplyStorageTechnology`](@ref) `operation_costs_inverter`."""
set_operation_costs_inverter!(value::ColocatedSupplyStorageTechnology, val, unit) = value.operation_costs_inverter = set_value(value, Val(:operation_costs_inverter), val, unit, Val(:usd_per_mwh))
"""Set [`ColocatedSupplyStorageTechnology`](@ref) `inverter_efficiency`."""
set_inverter_efficiency!(value::ColocatedSupplyStorageTechnology, val) = value.inverter_efficiency = val
"""Set [`ColocatedSupplyStorageTechnology`](@ref) `inverter_supply_ratio`."""
set_inverter_supply_ratio!(value::ColocatedSupplyStorageTechnology, val) = value.inverter_supply_ratio = val
"""Set [`ColocatedSupplyStorageTechnology`](@ref) `ext`."""
set_ext!(value::ColocatedSupplyStorageTechnology, val) = value.ext = val
"""Set [`ColocatedSupplyStorageTechnology`](@ref) `internal`."""
set_internal!(value::ColocatedSupplyStorageTechnology, val) = value.internal = val


function from_openapi(po::PI.ColocatedSupplyStorageTechnology, refs::OpenAPIRefs)
    parameter = getproperty(PowerSystems, Symbol(po.power_systems_type))
    return ColocatedSupplyStorageTechnology{parameter}(;
        name = po.name,
        power_systems_type = po.power_systems_type,
        region = resolve_refs(refs, po.region, RegionTopology),
        available = po.available,
        capital_costs_solar = convert_value_curve(po.capital_costs_solar),
        operation_costs_solar = convert_cost(po.operation_costs_solar)::PSY.RenewableGenerationCost,
        capacity_limits_solar = _minmax_from_po(po.capacity_limits_solar),
        lifetime_solar = po.lifetime_solar,
        capital_costs_wind = convert_value_curve(po.capital_costs_wind),
        operation_costs_wind = convert_cost(po.operation_costs_wind)::PSY.RenewableGenerationCost,
        capacity_limits_wind = _minmax_from_po(po.capacity_limits_wind),
        lifetime_wind = po.lifetime_wind,
        capital_costs_energy = convert_value_curve(po.capital_costs_energy),
        capital_costs_power = convert_value_curve(po.capital_costs_power),
        operation_costs_energy = convert_cost(po.operation_costs_energy)::PSY.StorageCost,
        operation_costs_power = convert_cost(po.operation_costs_power)::PSY.StorageCost,
        capacity_power_limits = _minmax_from_po(po.capacity_power_limits),
        capacity_energy_limits = _minmax_from_po(po.capacity_energy_limits),
        duration_limits = _minmax_from_po(po.duration_limits),
        efficiency_storage = _inout_from_po(po.efficiency_storage),
        losses_storage = po.losses_storage,
        lifetime_storage = po.lifetime_storage,
        financial_data = convert_nested_data(po.financial_data),
        max_inverter_capacity = po.max_inverter_capacity,
        min_inverter_capacity = po.min_inverter_capacity,
        capital_costs_inverter = convert_value_curve(po.capital_costs_inverter),
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
        capital_costs_solar = convert_value_curve_to_openapi(get_capital_costs_solar(value, IS.NU)),
        operation_costs_solar = convert_cost_to_openapi(get_operation_costs_solar(value, IS.NU)),
        capacity_limits_solar = _minmax_po(get_capacity_limits_solar(value, IS.NU)),
        lifetime_solar = get_lifetime_solar(value, IS.NU),
        capital_costs_wind = convert_value_curve_to_openapi(get_capital_costs_wind(value, IS.NU)),
        operation_costs_wind = convert_cost_to_openapi(get_operation_costs_wind(value, IS.NU)),
        capacity_limits_wind = _minmax_po(get_capacity_limits_wind(value, IS.NU)),
        lifetime_wind = get_lifetime_wind(value, IS.NU),
        capital_costs_energy = convert_value_curve_to_openapi(get_capital_costs_energy(value, IS.NU)),
        capital_costs_power = convert_value_curve_to_openapi(get_capital_costs_power(value, IS.NU)),
        operation_costs_energy = convert_cost_to_openapi(get_operation_costs_energy(value, IS.NU)),
        operation_costs_power = convert_cost_to_openapi(get_operation_costs_power(value, IS.NU)),
        capacity_power_limits = _minmax_po(get_capacity_power_limits(value, IS.NU)),
        capacity_energy_limits = _minmax_po(get_capacity_energy_limits(value, IS.NU)),
        duration_limits = _minmax_po(get_duration_limits(value, IS.NU)),
        efficiency_storage = _inout_po(get_efficiency_storage(value)),
        losses_storage = get_losses_storage(value),
        lifetime_storage = get_lifetime_storage(value, IS.NU),
        financial_data = convert_nested_data_to_openapi(get_financial_data(value)),
        max_inverter_capacity = get_max_inverter_capacity(value, IS.NU),
        min_inverter_capacity = get_min_inverter_capacity(value, IS.NU),
        capital_costs_inverter = convert_value_curve_to_openapi(get_capital_costs_inverter(value, IS.NU)),
        operation_costs_inverter = convert_cost_to_openapi(get_operation_costs_inverter(value, IS.NU)),
        inverter_efficiency = get_inverter_efficiency(value),
        inverter_supply_ratio = get_inverter_supply_ratio(value),
    )
end
