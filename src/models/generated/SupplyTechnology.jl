#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct SupplyTechnology{T <: PSY.Generator} <: ResourceTechnology
        name::String
        power_systems_type::String
        region::Vector{PSY.Topology}
        available::Bool
        prime_mover_type::PrimeMovers
        fuel::Vector{ThermalFuels}
        cofire_start_limits::Dict{ThermalFuels, MinMax}
        cofire_level_limits::Dict{ThermalFuels, MinMax}
        capital_costs::CapitalCost
        operation_costs::PSY.OperationalCost
        unit_size::Float64
        capacity_limits::Union{MinMax, Dict{PSY.Topology, MinMax}}
        outage_factor::OutageFactors
        min_generation_fraction::Float64
        ramp_limits::UpDown
        time_limits::UpDown
        start_fuel_mmbtu_per_mw::Float64
        lifetime::Int
        requirements::Vector{Requirement}
        financial_data::TechnologyFinancialData
        ext::Dict
        internal::InfrastructureSystemsInternal
    end

Candidate generation technology for a region. Can represent either a thermal or renewable generation technology

# Arguments
- `name::String`: The technology name
- `power_systems_type::String`: Corresponding type in PowerSystems.jl to be used in PCM modeling
- `region::Vector{PSY.Topology}`: (default: `Vector()`) Location where technology operates. Can be a zone or node.
- `available::Bool`: (default: `true`) Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`)
- `prime_mover_type::PrimeMovers`: (default: `PrimeMovers.OT`) Prime mover technology according to EIA 923.
- `fuel::Vector{ThermalFuels}`: (default: `[ThermalFuels.OTHER]`) Prime mover fuel according to EIA 923.
- `cofire_start_limits::Dict{ThermalFuels, MinMax}`: (default: `Dict()`) Minimum and maximum blending level (%) of each fuel during start-up process for multi-fuel generator
- `cofire_level_limits::Dict{ThermalFuels, MinMax}`: (default: `Dict()`) Minimum and maximum blending level (%) of each fuel during normal generation process for multi-fuel generator
- `capital_costs::CapitalCost`: (default: `CapitalCost(nothing)`) Capital costs for investing in a technology. (USD/MW)
- `operation_costs::PSY.OperationalCost`: (default: `ThermalGenerationCost(nothing)`) Fixed and variable O&M costs for a technology
- `unit_size::Float64`: (default: `0.0`) Used for discrete investment decisions. Size of each unit being built (MW)
- `capacity_limits::Union{MinMax, Dict{PSY.Topology, MinMax}}`: (default: `(min = 0.0, max = 1e8)`) Minimum and maximum allowable installed capacity for a technology (MW)
- `outage_factor::OutageFactors`: (default: `(planned = 0.0, forced = 0.0)`) Planned and forced outage factors for a technology, each a fraction of total availability.
- `min_generation_fraction::Float64`: (default: `0.0`) Minimum generation as a fraction of total capacity
- `ramp_limits::UpDown`: (default: `(up=1.0, down=1.0)`) Maximum decrease and increase in output between operation periods. Fraction of nameplate capacity per hour
- `time_limits::UpDown`: (default: `(up=60.0, down=60.0)`) Minimum amount of time a resource has to stay in the committed or shutdown state (minutes). Units: min.
- `start_fuel_mmbtu_per_mw::Float64`: (default: `0.0`) Startup fuel use per MW of nameplate capacity of each generator (MMBTU/MW per start)
- `lifetime::Int`: (default: `100`) Maximum number of years a technology can be active once installed (years)
- `requirements::Vector{Requirement}`: (default: `Vector()`) List of requirements (i.e. reserve margin, capacity requirements, energy share requirements) that are associated with a technology
- `financial_data::TechnologyFinancialData`: Struct containing relevant financial information for a technology
- `ext::Dict`: (default: `Dict()`) Optional dictionary to provide additional data
- `internal::InfrastructureSystemsInternal`: (default: `InfrastructureSystemsInternal()`) (**Do not modify.**) PowerSystemsInvestmentsPortfolios.jl internal reference
"""
mutable struct SupplyTechnology{T <: PSY.Generator} <: ResourceTechnology
    "The technology name"
    name::String
    "Corresponding type in PowerSystems.jl to be used in PCM modeling"
    power_systems_type::String
    "Location where technology operates. Can be a zone or node."
    region::Vector{PSY.Topology}
    "Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`)"
    available::Bool
    "Prime mover technology according to EIA 923."
    prime_mover_type::PrimeMovers
    "Prime mover fuel according to EIA 923."
    fuel::Vector{ThermalFuels}
    "Minimum and maximum blending level (%) of each fuel during start-up process for multi-fuel generator"
    cofire_start_limits::Dict{ThermalFuels, MinMax}
    "Minimum and maximum blending level (%) of each fuel during normal generation process for multi-fuel generator"
    cofire_level_limits::Dict{ThermalFuels, MinMax}
    "Capital costs for investing in a technology. (USD/MW)"
    capital_costs::CapitalCost
    "Fixed and variable O&M costs for a technology"
    operation_costs::PSY.OperationalCost
    "Used for discrete investment decisions. Size of each unit being built (MW)"
    unit_size::Float64
    "Minimum and maximum allowable installed capacity for a technology (MW)"
    capacity_limits::Union{MinMax, Dict{PSY.Topology, MinMax}}
    "Planned and forced outage factors for a technology, each a fraction of total availability."
    outage_factor::OutageFactors
    "Minimum generation as a fraction of total capacity"
    min_generation_fraction::Float64
    "Maximum decrease and increase in output between operation periods. Fraction of nameplate capacity per hour"
    ramp_limits::UpDown
    "Minimum amount of time a resource has to stay in the committed or shutdown state (minutes). Units: min."
    time_limits::UpDown
    "Startup fuel use per MW of nameplate capacity of each generator (MMBTU/MW per start)"
    start_fuel_mmbtu_per_mw::Float64
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


function SupplyTechnology{T}(; name, power_systems_type, region=Vector(), available=true, prime_mover_type=PrimeMovers.OT, fuel=[ThermalFuels.OTHER], cofire_start_limits=Dict(), cofire_level_limits=Dict(), capital_costs=CapitalCost(nothing), operation_costs=ThermalGenerationCost(nothing), unit_size=0.0, capacity_limits=(min = 0.0, max = 1e8), outage_factor=(planned = 0.0, forced = 0.0), min_generation_fraction=0.0, ramp_limits=(up=1.0, down=1.0), time_limits=(up=60.0, down=60.0), start_fuel_mmbtu_per_mw=0.0, lifetime=100, requirements=Vector(), financial_data, ext=Dict(), internal=InfrastructureSystemsInternal(), ) where T <: PSY.Generator
    SupplyTechnology{T}(name, power_systems_type, region, available, prime_mover_type, fuel, cofire_start_limits, cofire_level_limits, capital_costs, operation_costs, unit_size, capacity_limits, outage_factor, min_generation_fraction, ramp_limits, time_limits, start_fuel_mmbtu_per_mw, lifetime, requirements, financial_data, ext, internal, )
end

"""Get [`SupplyTechnology`](@ref) `name`."""
get_name(value::SupplyTechnology) = value.name
"""Get [`SupplyTechnology`](@ref) `power_systems_type`."""
get_power_systems_type(value::SupplyTechnology) = value.power_systems_type
"""Get [`SupplyTechnology`](@ref) `region`."""
get_region(value::SupplyTechnology) = value.region
"""Get [`SupplyTechnology`](@ref) `available`."""
get_available(value::SupplyTechnology) = value.available
"""Get [`SupplyTechnology`](@ref) `prime_mover_type`."""
get_prime_mover_type(value::SupplyTechnology) = value.prime_mover_type
"""Get [`SupplyTechnology`](@ref) `fuel`."""
get_fuel(value::SupplyTechnology) = value.fuel
"""Get [`SupplyTechnology`](@ref) `cofire_start_limits`."""
get_cofire_start_limits(value::SupplyTechnology) = value.cofire_start_limits
"""Get [`SupplyTechnology`](@ref) `cofire_level_limits`."""
get_cofire_level_limits(value::SupplyTechnology) = value.cofire_level_limits
"""Get [`SupplyTechnology`](@ref) `capital_costs`."""
get_capital_costs(value::SupplyTechnology) = value.capital_costs
"""Get [`SupplyTechnology`](@ref) `operation_costs` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_operation_costs_unitful`](@ref)."""
get_operation_costs(value::SupplyTechnology, units) = InfrastructureSystems._strip_units(get_value(value, Val(:operation_costs), Val(:usd_per_mwh), units))
"""Get [`SupplyTechnology`](@ref) `operation_costs` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_operation_costs`](@ref)."""
get_operation_costs_unitful(value::SupplyTechnology, units) = get_value(value, Val(:operation_costs), Val(:usd_per_mwh), units)
InfrastructureSystems.display_units_arg(::typeof(get_operation_costs), ::Type{SupplyTechnology{T}}) where {T <: PSY.Generator} = InfrastructureSystems.NU
InfrastructureSystems.display_units_arg(::typeof(get_operation_costs_unitful), ::Type{SupplyTechnology{T}}) where {T <: PSY.Generator} = InfrastructureSystems.NU
"""Get [`SupplyTechnology`](@ref) `unit_size` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_unit_size_unitful`](@ref)."""
get_unit_size(value::SupplyTechnology, units) = InfrastructureSystems._strip_units(get_value(value, Val(:unit_size), Val(:mw), units))
"""Get [`SupplyTechnology`](@ref) `unit_size` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_unit_size`](@ref)."""
get_unit_size_unitful(value::SupplyTechnology, units) = get_value(value, Val(:unit_size), Val(:mw), units)
InfrastructureSystems.display_units_arg(::typeof(get_unit_size), ::Type{SupplyTechnology{T}}) where {T <: PSY.Generator} = InfrastructureSystems.NU
InfrastructureSystems.display_units_arg(::typeof(get_unit_size_unitful), ::Type{SupplyTechnology{T}}) where {T <: PSY.Generator} = InfrastructureSystems.NU
"""Get [`SupplyTechnology`](@ref) `capacity_limits` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_capacity_limits_unitful`](@ref)."""
get_capacity_limits(value::SupplyTechnology, units) = InfrastructureSystems._strip_units(get_value(value, Val(:capacity_limits), Val(:mw), units))
"""Get [`SupplyTechnology`](@ref) `capacity_limits` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_capacity_limits`](@ref)."""
get_capacity_limits_unitful(value::SupplyTechnology, units) = get_value(value, Val(:capacity_limits), Val(:mw), units)
InfrastructureSystems.display_units_arg(::typeof(get_capacity_limits), ::Type{SupplyTechnology{T}}) where {T <: PSY.Generator} = InfrastructureSystems.NU
InfrastructureSystems.display_units_arg(::typeof(get_capacity_limits_unitful), ::Type{SupplyTechnology{T}}) where {T <: PSY.Generator} = InfrastructureSystems.NU
"""Get [`SupplyTechnology`](@ref) `outage_factor`."""
get_outage_factor(value::SupplyTechnology) = value.outage_factor
"""Get [`SupplyTechnology`](@ref) `min_generation_fraction`."""
get_min_generation_fraction(value::SupplyTechnology) = value.min_generation_fraction
"""Get [`SupplyTechnology`](@ref) `ramp_limits` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_ramp_limits_unitful`](@ref)."""
get_ramp_limits(value::SupplyTechnology, units) = InfrastructureSystems._strip_units(get_value(value, Val(:ramp_limits), Val(:mw_per_min), units))
"""Get [`SupplyTechnology`](@ref) `ramp_limits` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_ramp_limits`](@ref)."""
get_ramp_limits_unitful(value::SupplyTechnology, units) = get_value(value, Val(:ramp_limits), Val(:mw_per_min), units)
InfrastructureSystems.display_units_arg(::typeof(get_ramp_limits), ::Type{SupplyTechnology{T}}) where {T <: PSY.Generator} = InfrastructureSystems.NU
InfrastructureSystems.display_units_arg(::typeof(get_ramp_limits_unitful), ::Type{SupplyTechnology{T}}) where {T <: PSY.Generator} = InfrastructureSystems.NU
"""Get [`SupplyTechnology`](@ref) `time_limits` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_time_limits_unitful`](@ref)."""
get_time_limits(value::SupplyTechnology, units) = InfrastructureSystems._strip_units(get_value(value, Val(:time_limits), Val(:min), units))
"""Get [`SupplyTechnology`](@ref) `time_limits` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_time_limits`](@ref)."""
get_time_limits_unitful(value::SupplyTechnology, units) = get_value(value, Val(:time_limits), Val(:min), units)
InfrastructureSystems.display_units_arg(::typeof(get_time_limits), ::Type{SupplyTechnology{T}}) where {T <: PSY.Generator} = InfrastructureSystems.NU
InfrastructureSystems.display_units_arg(::typeof(get_time_limits_unitful), ::Type{SupplyTechnology{T}}) where {T <: PSY.Generator} = InfrastructureSystems.NU
"""Get [`SupplyTechnology`](@ref) `start_fuel_mmbtu_per_mw` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_start_fuel_mmbtu_per_mw_unitful`](@ref)."""
get_start_fuel_mmbtu_per_mw(value::SupplyTechnology, units) = InfrastructureSystems._strip_units(get_value(value, Val(:start_fuel_mmbtu_per_mw), Val(:mmbtu_per_mw), units))
"""Get [`SupplyTechnology`](@ref) `start_fuel_mmbtu_per_mw` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_start_fuel_mmbtu_per_mw`](@ref)."""
get_start_fuel_mmbtu_per_mw_unitful(value::SupplyTechnology, units) = get_value(value, Val(:start_fuel_mmbtu_per_mw), Val(:mmbtu_per_mw), units)
InfrastructureSystems.display_units_arg(::typeof(get_start_fuel_mmbtu_per_mw), ::Type{SupplyTechnology{T}}) where {T <: PSY.Generator} = InfrastructureSystems.NU
InfrastructureSystems.display_units_arg(::typeof(get_start_fuel_mmbtu_per_mw_unitful), ::Type{SupplyTechnology{T}}) where {T <: PSY.Generator} = InfrastructureSystems.NU
"""Get [`SupplyTechnology`](@ref) `lifetime` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_lifetime_unitful`](@ref)."""
get_lifetime(value::SupplyTechnology, units) = InfrastructureSystems._strip_units(get_value(value, Val(:lifetime), Val(:yr), units))
"""Get [`SupplyTechnology`](@ref) `lifetime` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_lifetime`](@ref)."""
get_lifetime_unitful(value::SupplyTechnology, units) = get_value(value, Val(:lifetime), Val(:yr), units)
InfrastructureSystems.display_units_arg(::typeof(get_lifetime), ::Type{SupplyTechnology{T}}) where {T <: PSY.Generator} = InfrastructureSystems.NU
InfrastructureSystems.display_units_arg(::typeof(get_lifetime_unitful), ::Type{SupplyTechnology{T}}) where {T <: PSY.Generator} = InfrastructureSystems.NU
"""Get [`SupplyTechnology`](@ref) `requirements`."""
get_requirements(value::SupplyTechnology) = value.requirements
"""Get [`SupplyTechnology`](@ref) `financial_data`."""
get_financial_data(value::SupplyTechnology) = value.financial_data
"""Get [`SupplyTechnology`](@ref) `ext`."""
get_ext(value::SupplyTechnology) = value.ext
"""Get [`SupplyTechnology`](@ref) `internal`."""
get_internal(value::SupplyTechnology) = value.internal

"""Set [`SupplyTechnology`](@ref) `name`."""
set_name!(value::SupplyTechnology, val) = value.name = val
"""Set [`SupplyTechnology`](@ref) `power_systems_type`."""
set_power_systems_type!(value::SupplyTechnology, val) = value.power_systems_type = val
"""Set [`SupplyTechnology`](@ref) `region`."""
set_region!(value::SupplyTechnology, val) = value.region = val
"""Set [`SupplyTechnology`](@ref) `available`."""
set_available!(value::SupplyTechnology, val) = value.available = val
"""Set [`SupplyTechnology`](@ref) `prime_mover_type`."""
set_prime_mover_type!(value::SupplyTechnology, val) = value.prime_mover_type = val
"""Set [`SupplyTechnology`](@ref) `fuel`."""
set_fuel!(value::SupplyTechnology, val) = value.fuel = val
"""Set [`SupplyTechnology`](@ref) `cofire_start_limits`."""
set_cofire_start_limits!(value::SupplyTechnology, val) = value.cofire_start_limits = val
"""Set [`SupplyTechnology`](@ref) `cofire_level_limits`."""
set_cofire_level_limits!(value::SupplyTechnology, val) = value.cofire_level_limits = val
"""Set [`SupplyTechnology`](@ref) `capital_costs`."""
set_capital_costs!(value::SupplyTechnology, val) = value.capital_costs = val
"""Set [`SupplyTechnology`](@ref) `operation_costs`."""
set_operation_costs!(value::SupplyTechnology, val, unit) = value.operation_costs = set_value(value, Val(:operation_costs), val, unit, Val(:usd_per_mwh))
"""Set [`SupplyTechnology`](@ref) `unit_size`."""
set_unit_size!(value::SupplyTechnology, val, unit) = value.unit_size = set_value(value, Val(:unit_size), val, unit, Val(:mw))
"""Set [`SupplyTechnology`](@ref) `capacity_limits`."""
set_capacity_limits!(value::SupplyTechnology, val, unit) = value.capacity_limits = set_value(value, Val(:capacity_limits), val, unit, Val(:mw))
"""Set [`SupplyTechnology`](@ref) `outage_factor`."""
set_outage_factor!(value::SupplyTechnology, val) = value.outage_factor = val
"""Set [`SupplyTechnology`](@ref) `min_generation_fraction`."""
set_min_generation_fraction!(value::SupplyTechnology, val) = value.min_generation_fraction = val
"""Set [`SupplyTechnology`](@ref) `ramp_limits`."""
set_ramp_limits!(value::SupplyTechnology, val, unit) = value.ramp_limits = set_value(value, Val(:ramp_limits), val, unit, Val(:mw_per_min))
"""Set [`SupplyTechnology`](@ref) `time_limits`."""
set_time_limits!(value::SupplyTechnology, val, unit) = value.time_limits = set_value(value, Val(:time_limits), val, unit, Val(:min))
"""Set [`SupplyTechnology`](@ref) `start_fuel_mmbtu_per_mw`."""
set_start_fuel_mmbtu_per_mw!(value::SupplyTechnology, val, unit) = value.start_fuel_mmbtu_per_mw = set_value(value, Val(:start_fuel_mmbtu_per_mw), val, unit, Val(:mmbtu_per_mw))
"""Set [`SupplyTechnology`](@ref) `lifetime`."""
set_lifetime!(value::SupplyTechnology, val, unit) = value.lifetime = set_value(value, Val(:lifetime), val, unit, Val(:yr))
"""Set [`SupplyTechnology`](@ref) `requirements`."""
set_requirements!(value::SupplyTechnology, val) = value.requirements = val
"""Set [`SupplyTechnology`](@ref) `financial_data`."""
set_financial_data!(value::SupplyTechnology, val) = value.financial_data = val
"""Set [`SupplyTechnology`](@ref) `ext`."""
set_ext!(value::SupplyTechnology, val) = value.ext = val
"""Set [`SupplyTechnology`](@ref) `internal`."""
set_internal!(value::SupplyTechnology, val) = value.internal = val


function from_openapi(po::PI.SupplyTechnology, refs::OpenAPIRefs)
    parameter = getproperty(PowerSystems, Symbol(po.power_systems_type))
    return SupplyTechnology{parameter}(;
        name = po.name,
        power_systems_type = po.power_systems_type,
        region = resolve_refs(refs, po.region, PSY.Topology),
        available = po.available,
        prime_mover_type = PrimeMovers(po.prime_mover_type),
        fuel = [ThermalFuels(v) for v in po.fuel],
        cofire_start_limits = Dict(ThermalFuels(k) => _minmax_from_po(v) for (k, v) in po.cofire_start_limits),
        cofire_level_limits = Dict(ThermalFuels(k) => _minmax_from_po(v) for (k, v) in po.cofire_level_limits),
        capital_costs = convert_nested_data(po.capital_costs),
        operation_costs = convert_cost(po.operation_costs)::PSY.OperationalCost,
        unit_size = po.unit_size,
        capacity_limits = _capacity_bound_from_po(po.capacity_limits, refs),
        outage_factor = _outagefactors_from_po(po.outage_factor),
        min_generation_fraction = po.min_generation_fraction,
        ramp_limits = _updown_from_po(po.ramp_limits),
        time_limits = _updown_from_po(po.time_limits),
        start_fuel_mmbtu_per_mw = po.start_fuel_mmbtu_per_mw,
        lifetime = po.lifetime,
        financial_data = convert_nested_data(po.financial_data),
    )
end

function to_openapi(value::SupplyTechnology{T}, refs::OpenAPIRefs) where {T <: PSY.Generator}
    return PI.SupplyTechnology(;
        id = get_id(value),
        name = get_name(value),
        power_systems_type = string(nameof(T)),
        region = component_ids(refs, get_region(value)),
        available = get_available(value),
        prime_mover_type = string(get_prime_mover_type(value)),
        fuel = [string(v) for v in get_fuel(value)],
        cofire_start_limits = Dict(string(k) => _minmax_po(v) for (k, v) in get_cofire_start_limits(value)),
        cofire_level_limits = Dict(string(k) => _minmax_po(v) for (k, v) in get_cofire_level_limits(value)),
        capital_costs = convert_nested_data_to_openapi(get_capital_costs(value)),
        operation_costs = convert_cost_to_openapi(get_operation_costs(value, IS.NU)),
        unit_size = get_unit_size(value, IS.NU),
        capacity_limits = PI.SupplyTechnologyCapacityLimits(_capacity_bound_po_value(get_capacity_limits(value, IS.NU), refs)),
        outage_factor = _outagefactors_po(get_outage_factor(value)),
        min_generation_fraction = get_min_generation_fraction(value),
        ramp_limits = _updown_po(get_ramp_limits(value, IS.NU)),
        time_limits = _updown_po(get_time_limits(value, IS.NU)),
        start_fuel_mmbtu_per_mw = get_start_fuel_mmbtu_per_mw(value, IS.NU),
        lifetime = get_lifetime(value, IS.NU),
        financial_data = convert_nested_data_to_openapi(get_financial_data(value)),
    )
end
