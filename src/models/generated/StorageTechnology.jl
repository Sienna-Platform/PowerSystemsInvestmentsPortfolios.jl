#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct StorageTechnology{T <: PSY.Storage} <: ResourceTechnology
        name::String
        region::Vector{PSY.Topology}
        available::Bool
        power_systems_type::String
        prime_mover_type::PrimeMovers
        storage_tech::StorageTech
        capital_costs::StorageCapitalCost
        operation_costs::PSY.StorageCost
        min_discharge_fraction::Float64
        unit_size_charge::Union{Nothing, Float64}
        unit_size_discharge::Float64
        unit_size_energy::Float64
        capacity_limits_charge::Union{MinMax, Dict{PSY.Topology, MinMax}}
        capacity_limits_discharge::Union{MinMax, Dict{PSY.Topology, MinMax}}
        capacity_limits_energy::Union{MinMax, Dict{PSY.Topology, MinMax}}
        duration_limits::MinMax
        efficiency::InOut
        losses::Float64
        lifetime::Int
        requirements::Vector{Requirement}
        financial_data::TechnologyFinancialData
        ext::Dict
        internal::InfrastructureSystemsInternal
    end

Candidate storage technology in a region.

# Arguments
- `name::String`: The technology name
- `region::Vector{PSY.Topology}`: (default: `Vector()`) Location where technology is operated
- `available::Bool`: Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`)
- `power_systems_type::String`: Corresponding type in PowerSystems.jl to be used in PCM modeling
- `prime_mover_type::PrimeMovers`: (default: `PrimeMovers.OT`) Prime mover technology according to EIA 923.
- `storage_tech::StorageTech`: Storage Technology Complementary to EIA 923.
- `capital_costs::StorageCapitalCost`: (default: `StorageCapitalCost(nothing)`) Capital costs for investing in a storage technology's charge, discharge, and energy capacity.
- `operation_costs::PSY.StorageCost`: (default: `StorageCost(nothing)`) Fixed and variable O&M costs for a technology
- `min_discharge_fraction::Float64`: (default: `0.0`) Minimum discharge as a fraction of total discharge capacity
- `unit_size_charge::Union{Nothing, Float64}`: (default: `nothing`) Used for discrete investment decisions. Unit size of charging capacity (MW)
- `unit_size_discharge::Float64`: (default: `0.0`) Used for discrete investment decisions. Size of each unit of discharging capacity being built (MW)
- `unit_size_energy::Float64`: (default: `0.0`) Used for discrete investment decisions. Size of each unit being built (MWh)
- `capacity_limits_charge::Union{MinMax, Dict{PSY.Topology, MinMax}}`: (default: `(min = 0.0, max = 1e8)`) allowable installed power capacity for a storage technology (MW)
- `capacity_limits_discharge::Union{MinMax, Dict{PSY.Topology, MinMax}}`: (default: `(min = 0.0, max = 1e8)`) allowable installed power capacity for a storage technology (MW)
- `capacity_limits_energy::Union{MinMax, Dict{PSY.Topology, MinMax}}`: (default: `(min = 0.0, max = 1e8)`) allowable installed energy capacity for a storage technology (MWh)
- `duration_limits::MinMax`: (default: `(min=0,max=60000.0)`) Minimum and maximum duration limits (energy to discharge capacity ratio) for a storage technology (minutes). Units: min.
- `efficiency::InOut`: (default: `(in=1, out=1)`) Efficiency of charging storage, fraction of total charge (in) and discharge (out) capacity
- `losses::Float64`: (default: `0.0`) Self-discharge of storage (fraction of energy stored per hour)
- `lifetime::Int`: (default: `100`) Maximum number of years a technology can be active once installed (years)
- `requirements::Vector{Requirement}`: (default: `Vector()`) List of requirements (i.e. reserve margin, capacity requirements, energy share requirements) that are associated with a technology
- `financial_data::TechnologyFinancialData`: Struct containing relevant financial information for a technology
- `ext::Dict`: (default: `Dict()`) Optional dictionary to provide additional data
- `internal::InfrastructureSystemsInternal`: (default: `InfrastructureSystemsInternal()`) (**Do not modify.**) PowerSystemsInvestmentsPortfolios.jl internal reference
"""
mutable struct StorageTechnology{T <: PSY.Storage} <: ResourceTechnology
    "The technology name"
    name::String
    "Location where technology is operated"
    region::Vector{PSY.Topology}
    "Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`)"
    available::Bool
    "Corresponding type in PowerSystems.jl to be used in PCM modeling"
    power_systems_type::String
    "Prime mover technology according to EIA 923."
    prime_mover_type::PrimeMovers
    "Storage Technology Complementary to EIA 923."
    storage_tech::StorageTech
    "Capital costs for investing in a storage technology's charge, discharge, and energy capacity."
    capital_costs::StorageCapitalCost
    "Fixed and variable O&M costs for a technology"
    operation_costs::PSY.StorageCost
    "Minimum discharge as a fraction of total discharge capacity"
    min_discharge_fraction::Float64
    "Used for discrete investment decisions. Unit size of charging capacity (MW)"
    unit_size_charge::Union{Nothing, Float64}
    "Used for discrete investment decisions. Size of each unit of discharging capacity being built (MW)"
    unit_size_discharge::Float64
    "Used for discrete investment decisions. Size of each unit being built (MWh)"
    unit_size_energy::Float64
    "allowable installed power capacity for a storage technology (MW)"
    capacity_limits_charge::Union{MinMax, Dict{PSY.Topology, MinMax}}
    "allowable installed power capacity for a storage technology (MW)"
    capacity_limits_discharge::Union{MinMax, Dict{PSY.Topology, MinMax}}
    "allowable installed energy capacity for a storage technology (MWh)"
    capacity_limits_energy::Union{MinMax, Dict{PSY.Topology, MinMax}}
    "Minimum and maximum duration limits (energy to discharge capacity ratio) for a storage technology (minutes). Units: min."
    duration_limits::MinMax
    "Efficiency of charging storage, fraction of total charge (in) and discharge (out) capacity"
    efficiency::InOut
    "Self-discharge of storage (fraction of energy stored per hour)"
    losses::Float64
    "Maximum number of years a technology can be active once installed (years)"
    lifetime::Int
    "List of requirements (i.e. reserve margin, capacity requirements, energy share requirements) that are associated with a technology"
    requirements::Vector{Requirement}
    "Struct containing relevant financial information for a technology"
    financial_data::TechnologyFinancialData
    "Optional dictionary to provide additional data"
    ext::Dict
    "(**Do not modify.**) PowerSystemsInvestmentsPortfolios.jl internal reference"
    internal::InfrastructureSystemsInternal
end


function StorageTechnology{T}(; name, region=Vector(), available, power_systems_type, prime_mover_type=PrimeMovers.OT, storage_tech, capital_costs=StorageCapitalCost(nothing), operation_costs=StorageCost(nothing), min_discharge_fraction=0.0, unit_size_charge=nothing, unit_size_discharge=0.0, unit_size_energy=0.0, capacity_limits_charge=(min = 0.0, max = 1e8), capacity_limits_discharge=(min = 0.0, max = 1e8), capacity_limits_energy=(min = 0.0, max = 1e8), duration_limits=(min=0,max=60000.0), efficiency=(in=1, out=1), losses=0.0, lifetime=100, requirements=Vector(), financial_data, ext=Dict(), internal=InfrastructureSystemsInternal(), ) where T <: PSY.Storage
    StorageTechnology{T}(name, region, available, power_systems_type, prime_mover_type, storage_tech, capital_costs, operation_costs, min_discharge_fraction, unit_size_charge, unit_size_discharge, unit_size_energy, capacity_limits_charge, capacity_limits_discharge, capacity_limits_energy, duration_limits, efficiency, losses, lifetime, requirements, financial_data, ext, internal, )
end

"""Get [`StorageTechnology`](@ref) `name`."""
get_name(value::StorageTechnology) = value.name
"""Get [`StorageTechnology`](@ref) `region`."""
get_region(value::StorageTechnology) = value.region
"""Get [`StorageTechnology`](@ref) `available`."""
get_available(value::StorageTechnology) = value.available
"""Get [`StorageTechnology`](@ref) `power_systems_type`."""
get_power_systems_type(value::StorageTechnology) = value.power_systems_type
"""Get [`StorageTechnology`](@ref) `prime_mover_type`."""
get_prime_mover_type(value::StorageTechnology) = value.prime_mover_type
"""Get [`StorageTechnology`](@ref) `storage_tech`."""
get_storage_tech(value::StorageTechnology) = value.storage_tech
"""Get [`StorageTechnology`](@ref) `capital_costs`."""
get_capital_costs(value::StorageTechnology) = value.capital_costs
"""Get [`StorageTechnology`](@ref) `operation_costs` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_operation_costs_unitful`](@ref)."""
get_operation_costs(value::StorageTechnology, units) = InfrastructureSystems._strip_units(get_value(value, Val(:operation_costs), Val(:usd_per_mwh), units))
"""Get [`StorageTechnology`](@ref) `operation_costs` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `CU`, `MW`). For a bare number see [`get_operation_costs`](@ref)."""
get_operation_costs_unitful(value::StorageTechnology, units) = get_value(value, Val(:operation_costs), Val(:usd_per_mwh), units)
InfrastructureSystems.display_units_arg(::typeof(get_operation_costs), ::Type{StorageTechnology{T}}) where {T <: PSY.Storage} = InfrastructureSystems.NU
InfrastructureSystems.display_units_arg(::typeof(get_operation_costs_unitful), ::Type{StorageTechnology{T}}) where {T <: PSY.Storage} = InfrastructureSystems.NU
"""Get [`StorageTechnology`](@ref) `min_discharge_fraction`."""
get_min_discharge_fraction(value::StorageTechnology) = value.min_discharge_fraction
"""Get [`StorageTechnology`](@ref) `unit_size_charge` as a bare number in the requested `units` (e.g. `SU`, `CU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_unit_size_charge_unitful`](@ref)."""
get_unit_size_charge(value::StorageTechnology, units) = InfrastructureSystems._strip_units(get_value(value, Val(:unit_size_charge), Val(:mw), units))
"""Get [`StorageTechnology`](@ref) `unit_size_charge` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `CU`, `MW`). For a bare number see [`get_unit_size_charge`](@ref)."""
get_unit_size_charge_unitful(value::StorageTechnology, units) = get_value(value, Val(:unit_size_charge), Val(:mw), units)
InfrastructureSystems.display_units_arg(::typeof(get_unit_size_charge), ::Type{StorageTechnology{T}}) where {T <: PSY.Storage} = InfrastructureSystems.NU
InfrastructureSystems.display_units_arg(::typeof(get_unit_size_charge_unitful), ::Type{StorageTechnology{T}}) where {T <: PSY.Storage} = InfrastructureSystems.NU
"""Get [`StorageTechnology`](@ref) `unit_size_discharge` as a bare number in the requested `units` (e.g. `SU`, `CU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_unit_size_discharge_unitful`](@ref)."""
get_unit_size_discharge(value::StorageTechnology, units) = InfrastructureSystems._strip_units(get_value(value, Val(:unit_size_discharge), Val(:mw), units))
"""Get [`StorageTechnology`](@ref) `unit_size_discharge` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `CU`, `MW`). For a bare number see [`get_unit_size_discharge`](@ref)."""
get_unit_size_discharge_unitful(value::StorageTechnology, units) = get_value(value, Val(:unit_size_discharge), Val(:mw), units)
InfrastructureSystems.display_units_arg(::typeof(get_unit_size_discharge), ::Type{StorageTechnology{T}}) where {T <: PSY.Storage} = InfrastructureSystems.NU
InfrastructureSystems.display_units_arg(::typeof(get_unit_size_discharge_unitful), ::Type{StorageTechnology{T}}) where {T <: PSY.Storage} = InfrastructureSystems.NU
"""Get [`StorageTechnology`](@ref) `unit_size_energy` as a bare number in the requested `units` (e.g. `SU`, `CU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_unit_size_energy_unitful`](@ref)."""
get_unit_size_energy(value::StorageTechnology, units) = InfrastructureSystems._strip_units(get_value(value, Val(:unit_size_energy), Val(:mwh), units))
"""Get [`StorageTechnology`](@ref) `unit_size_energy` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `CU`, `MW`). For a bare number see [`get_unit_size_energy`](@ref)."""
get_unit_size_energy_unitful(value::StorageTechnology, units) = get_value(value, Val(:unit_size_energy), Val(:mwh), units)
InfrastructureSystems.display_units_arg(::typeof(get_unit_size_energy), ::Type{StorageTechnology{T}}) where {T <: PSY.Storage} = InfrastructureSystems.NU
InfrastructureSystems.display_units_arg(::typeof(get_unit_size_energy_unitful), ::Type{StorageTechnology{T}}) where {T <: PSY.Storage} = InfrastructureSystems.NU
"""Get [`StorageTechnology`](@ref) `capacity_limits_charge` as a bare number in the requested `units` (e.g. `SU`, `CU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_capacity_limits_charge_unitful`](@ref)."""
get_capacity_limits_charge(value::StorageTechnology, units) = InfrastructureSystems._strip_units(get_value(value, Val(:capacity_limits_charge), Val(:mw), units))
"""Get [`StorageTechnology`](@ref) `capacity_limits_charge` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `CU`, `MW`). For a bare number see [`get_capacity_limits_charge`](@ref)."""
get_capacity_limits_charge_unitful(value::StorageTechnology, units) = get_value(value, Val(:capacity_limits_charge), Val(:mw), units)
InfrastructureSystems.display_units_arg(::typeof(get_capacity_limits_charge), ::Type{StorageTechnology{T}}) where {T <: PSY.Storage} = InfrastructureSystems.NU
InfrastructureSystems.display_units_arg(::typeof(get_capacity_limits_charge_unitful), ::Type{StorageTechnology{T}}) where {T <: PSY.Storage} = InfrastructureSystems.NU
"""Get [`StorageTechnology`](@ref) `capacity_limits_discharge` as a bare number in the requested `units` (e.g. `SU`, `CU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_capacity_limits_discharge_unitful`](@ref)."""
get_capacity_limits_discharge(value::StorageTechnology, units) = InfrastructureSystems._strip_units(get_value(value, Val(:capacity_limits_discharge), Val(:mw), units))
"""Get [`StorageTechnology`](@ref) `capacity_limits_discharge` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `CU`, `MW`). For a bare number see [`get_capacity_limits_discharge`](@ref)."""
get_capacity_limits_discharge_unitful(value::StorageTechnology, units) = get_value(value, Val(:capacity_limits_discharge), Val(:mw), units)
InfrastructureSystems.display_units_arg(::typeof(get_capacity_limits_discharge), ::Type{StorageTechnology{T}}) where {T <: PSY.Storage} = InfrastructureSystems.NU
InfrastructureSystems.display_units_arg(::typeof(get_capacity_limits_discharge_unitful), ::Type{StorageTechnology{T}}) where {T <: PSY.Storage} = InfrastructureSystems.NU
"""Get [`StorageTechnology`](@ref) `capacity_limits_energy` as a bare number in the requested `units` (e.g. `SU`, `CU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_capacity_limits_energy_unitful`](@ref)."""
get_capacity_limits_energy(value::StorageTechnology, units) = InfrastructureSystems._strip_units(get_value(value, Val(:capacity_limits_energy), Val(:mwh), units))
"""Get [`StorageTechnology`](@ref) `capacity_limits_energy` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `CU`, `MW`). For a bare number see [`get_capacity_limits_energy`](@ref)."""
get_capacity_limits_energy_unitful(value::StorageTechnology, units) = get_value(value, Val(:capacity_limits_energy), Val(:mwh), units)
InfrastructureSystems.display_units_arg(::typeof(get_capacity_limits_energy), ::Type{StorageTechnology{T}}) where {T <: PSY.Storage} = InfrastructureSystems.NU
InfrastructureSystems.display_units_arg(::typeof(get_capacity_limits_energy_unitful), ::Type{StorageTechnology{T}}) where {T <: PSY.Storage} = InfrastructureSystems.NU
"""Get [`StorageTechnology`](@ref) `duration_limits` as a bare number in the requested `units` (e.g. `SU`, `CU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_duration_limits_unitful`](@ref)."""
get_duration_limits(value::StorageTechnology, units) = InfrastructureSystems._strip_units(get_value(value, Val(:duration_limits), Val(:min), units))
"""Get [`StorageTechnology`](@ref) `duration_limits` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `CU`, `MW`). For a bare number see [`get_duration_limits`](@ref)."""
get_duration_limits_unitful(value::StorageTechnology, units) = get_value(value, Val(:duration_limits), Val(:min), units)
InfrastructureSystems.display_units_arg(::typeof(get_duration_limits), ::Type{StorageTechnology{T}}) where {T <: PSY.Storage} = InfrastructureSystems.NU
InfrastructureSystems.display_units_arg(::typeof(get_duration_limits_unitful), ::Type{StorageTechnology{T}}) where {T <: PSY.Storage} = InfrastructureSystems.NU
"""Get [`StorageTechnology`](@ref) `efficiency`."""
get_efficiency(value::StorageTechnology) = value.efficiency
"""Get [`StorageTechnology`](@ref) `losses`."""
get_losses(value::StorageTechnology) = value.losses
"""Get [`StorageTechnology`](@ref) `lifetime` as a bare number in the requested `units` (e.g. `SU`, `CU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_lifetime_unitful`](@ref)."""
get_lifetime(value::StorageTechnology, units) = InfrastructureSystems._strip_units(get_value(value, Val(:lifetime), Val(:yr), units))
"""Get [`StorageTechnology`](@ref) `lifetime` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `CU`, `MW`). For a bare number see [`get_lifetime`](@ref)."""
get_lifetime_unitful(value::StorageTechnology, units) = get_value(value, Val(:lifetime), Val(:yr), units)
InfrastructureSystems.display_units_arg(::typeof(get_lifetime), ::Type{StorageTechnology{T}}) where {T <: PSY.Storage} = InfrastructureSystems.NU
InfrastructureSystems.display_units_arg(::typeof(get_lifetime_unitful), ::Type{StorageTechnology{T}}) where {T <: PSY.Storage} = InfrastructureSystems.NU
"""Get [`StorageTechnology`](@ref) `requirements`."""
get_requirements(value::StorageTechnology) = value.requirements
"""Get [`StorageTechnology`](@ref) `financial_data`."""
get_financial_data(value::StorageTechnology) = value.financial_data
"""Get [`StorageTechnology`](@ref) `ext`."""
get_ext(value::StorageTechnology) = value.ext
"""Get [`StorageTechnology`](@ref) `internal`."""
get_internal(value::StorageTechnology) = value.internal

"""Set [`StorageTechnology`](@ref) `name`."""
set_name!(value::StorageTechnology, val) = value.name = val
"""Set [`StorageTechnology`](@ref) `region`."""
set_region!(value::StorageTechnology, val) = value.region = val
"""Set [`StorageTechnology`](@ref) `available`."""
set_available!(value::StorageTechnology, val) = value.available = val
"""Set [`StorageTechnology`](@ref) `power_systems_type`."""
set_power_systems_type!(value::StorageTechnology, val) = value.power_systems_type = val
"""Set [`StorageTechnology`](@ref) `prime_mover_type`."""
set_prime_mover_type!(value::StorageTechnology, val) = value.prime_mover_type = val
"""Set [`StorageTechnology`](@ref) `storage_tech`."""
set_storage_tech!(value::StorageTechnology, val) = value.storage_tech = val
"""Set [`StorageTechnology`](@ref) `capital_costs`."""
set_capital_costs!(value::StorageTechnology, val) = value.capital_costs = val
"""Set [`StorageTechnology`](@ref) `operation_costs`."""
set_operation_costs!(value::StorageTechnology, val, unit) = value.operation_costs = set_value(value, Val(:operation_costs), val, unit, Val(:usd_per_mwh))
"""Set [`StorageTechnology`](@ref) `min_discharge_fraction`."""
set_min_discharge_fraction!(value::StorageTechnology, val) = value.min_discharge_fraction = val
"""Set [`StorageTechnology`](@ref) `unit_size_charge`."""
set_unit_size_charge!(value::StorageTechnology, val, unit) = value.unit_size_charge = set_value(value, Val(:unit_size_charge), val, unit, Val(:mw))
"""Set [`StorageTechnology`](@ref) `unit_size_discharge`."""
set_unit_size_discharge!(value::StorageTechnology, val, unit) = value.unit_size_discharge = set_value(value, Val(:unit_size_discharge), val, unit, Val(:mw))
"""Set [`StorageTechnology`](@ref) `unit_size_energy`."""
set_unit_size_energy!(value::StorageTechnology, val, unit) = value.unit_size_energy = set_value(value, Val(:unit_size_energy), val, unit, Val(:mwh))
"""Set [`StorageTechnology`](@ref) `capacity_limits_charge`."""
set_capacity_limits_charge!(value::StorageTechnology, val, unit) = value.capacity_limits_charge = set_value(value, Val(:capacity_limits_charge), val, unit, Val(:mw))
"""Set [`StorageTechnology`](@ref) `capacity_limits_discharge`."""
set_capacity_limits_discharge!(value::StorageTechnology, val, unit) = value.capacity_limits_discharge = set_value(value, Val(:capacity_limits_discharge), val, unit, Val(:mw))
"""Set [`StorageTechnology`](@ref) `capacity_limits_energy`."""
set_capacity_limits_energy!(value::StorageTechnology, val, unit) = value.capacity_limits_energy = set_value(value, Val(:capacity_limits_energy), val, unit, Val(:mwh))
"""Set [`StorageTechnology`](@ref) `duration_limits`."""
set_duration_limits!(value::StorageTechnology, val, unit) = value.duration_limits = set_value(value, Val(:duration_limits), val, unit, Val(:min))
"""Set [`StorageTechnology`](@ref) `efficiency`."""
set_efficiency!(value::StorageTechnology, val) = value.efficiency = val
"""Set [`StorageTechnology`](@ref) `losses`."""
set_losses!(value::StorageTechnology, val) = value.losses = val
"""Set [`StorageTechnology`](@ref) `lifetime`."""
set_lifetime!(value::StorageTechnology, val, unit) = value.lifetime = set_value(value, Val(:lifetime), val, unit, Val(:yr))
"""Set [`StorageTechnology`](@ref) `requirements`."""
set_requirements!(value::StorageTechnology, val) = value.requirements = val
"""Set [`StorageTechnology`](@ref) `financial_data`."""
set_financial_data!(value::StorageTechnology, val) = value.financial_data = val
"""Set [`StorageTechnology`](@ref) `ext`."""
set_ext!(value::StorageTechnology, val) = value.ext = val
"""Set [`StorageTechnology`](@ref) `internal`."""
set_internal!(value::StorageTechnology, val) = value.internal = val


function from_openapi(po::PI.StorageTechnology, refs::OpenAPIRefs)
    parameter = getproperty(PowerSystems, Symbol(po.power_systems_type))
    return StorageTechnology{parameter}(;
        name = po.name,
        region = resolve_refs(refs, po.region, PSY.Topology),
        available = po.available,
        power_systems_type = po.power_systems_type,
        prime_mover_type = PrimeMovers(po.prime_mover_type),
        storage_tech = StorageTech(po.storage_tech),
        capital_costs = convert_nested_data(po.capital_costs),
        operation_costs = convert_cost(po.operation_costs)::PSY.StorageCost,
        min_discharge_fraction = po.min_discharge_fraction,
        unit_size_charge = po.unit_size_charge,
        unit_size_discharge = po.unit_size_discharge,
        unit_size_energy = po.unit_size_energy,
        capacity_limits_charge = _capacity_bound_from_po(po.capacity_limits_charge, refs),
        capacity_limits_discharge = _capacity_bound_from_po(po.capacity_limits_discharge, refs),
        capacity_limits_energy = _capacity_bound_from_po(po.capacity_limits_energy, refs),
        duration_limits = _minmax_from_po(po.duration_limits),
        efficiency = _inout_from_po(po.efficiency),
        losses = po.losses,
        lifetime = po.lifetime,
        financial_data = convert_nested_data(po.financial_data),
    )
end

function to_openapi(value::StorageTechnology{T}, refs::OpenAPIRefs) where {T <: PSY.Storage}
    return PI.StorageTechnology(;
        id = get_id(value),
        name = get_name(value),
        region = component_ids(refs, get_region(value)),
        available = get_available(value),
        power_systems_type = string(nameof(T)),
        prime_mover_type = string(get_prime_mover_type(value)),
        storage_tech = string(get_storage_tech(value)),
        capital_costs = convert_nested_data_to_openapi(get_capital_costs(value)),
        operation_costs = convert_cost_to_openapi(get_operation_costs(value, IS.NU)),
        min_discharge_fraction = get_min_discharge_fraction(value),
        unit_size_charge = get_unit_size_charge(value, IS.NU),
        unit_size_discharge = get_unit_size_discharge(value, IS.NU),
        unit_size_energy = get_unit_size_energy(value, IS.NU),
        capacity_limits_charge = PI.StorageTechnologyCapacityLimitsCharge(_capacity_bound_po_value(get_capacity_limits_charge(value, IS.NU), refs)),
        capacity_limits_discharge = PI.StorageTechnologyCapacityLimitsDischarge(_capacity_bound_po_value(get_capacity_limits_discharge(value, IS.NU), refs)),
        capacity_limits_energy = PI.StorageTechnologyCapacityLimitsEnergy(_capacity_bound_po_value(get_capacity_limits_energy(value, IS.NU), refs)),
        duration_limits = _minmax_po(get_duration_limits(value, IS.NU)),
        efficiency = _inout_po(get_efficiency(value)),
        losses = get_losses(value),
        lifetime = get_lifetime(value, IS.NU),
        financial_data = convert_nested_data_to_openapi(get_financial_data(value)),
    )
end
