#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct ProjectedDemand{T <: PSY.StaticInjection} <: DemandTechnology
        name::String
        available::Bool
        power_systems_type::String
        region::Vector{PSY.Topology}
        peak_demand_mw::Float64
        construction_year::Int64
        growth_rate::Float64
        conformity::PSY.LoadConformity.Value
        max_demand_curtailment::Float64
        curtailment_cost::PSY.ValueCurve
        value_of_lost_load::Float64
        flexible_fraction::Float64
        max_demand_delay::Float64
        max_demand_advance::Float64
        shift_efficiency::Float64
        shift_cost::PSY.ValueCurve
        requirements::Vector{Requirement}
        ext::Dict
        internal::InfrastructureSystemsInternal
    end

A projected demand in a region: an exogenous load profile that must be served, with optional voluntary curtailment and time shifting. Its peak comes from its existing loads in the base system or, for a new demand, from peak_demand_mw.

# Arguments
- `name::String`: The demand name
- `available::Bool`: (default: `true`) Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`)
- `power_systems_type::String`: Corresponding type in PowerSystems.jl to be used in PCM modeling
- `region::Vector{PSY.Topology}`: (default: `Vector()`) Zone or node where the demand is located
- `peak_demand_mw::Float64`: (default: `0.0`) Peak demand (MW). Demands with existing devices in the base system derive their peak demand from those devices, not from this value.
- `construction_year::Int64`: (default: `2020`) The year in which a new demand starts. Should only be used for new demands.
- `growth_rate::Float64`: (default: `0.0`) The annual growth rate of the demand, used to scale present-day loads into future projections. Only used for conforming loads
- `conformity::PSY.LoadConformity.Value`: (default: `LoadConformity.UNDEFINED`) Whether the demand is conforming (grows by growth_rate) or non-conforming (does not grow). Must be set for new demands.
- `max_demand_curtailment::Float64`: (default: `0.0`) Maximum fraction of demand that can be curtailed voluntarily
- `curtailment_cost::PSY.ValueCurve`: (default: `LinearCurve(0.0)`) Cost of voluntary curtailment (USD/MWh). A LinearCurve is a single price for all curtailable demand. A PiecewiseIncrementalCurve gives tiers whose x coordinates are fractions of demand, from 0 to max_demand_curtailment, and whose slopes are prices (USD/MWh)
- `value_of_lost_load::Float64`: (default: `1e8`) Cost of involuntary shedding of the demand that cannot be curtailed (USD/MWh)
- `flexible_fraction::Float64`: (default: `0.0`) Fraction of demand that can be shifted in time
- `max_demand_delay::Float64`: (default: `0.0`) Maximum time that flexible demand can be delayed (minutes)
- `max_demand_advance::Float64`: (default: `0.0`) Maximum time that flexible demand can be served in advance (minutes)
- `shift_efficiency::Float64`: (default: `1.0`) Fraction of shifted energy that is kept. Represents energy losses due to time shifting
- `shift_cost::PSY.ValueCurve`: (default: `LinearCurve(0.0)`) Cost of shifting demand (USD/MWh shifted)
- `requirements::Vector{Requirement}`: (default: `Vector()`) List of requirements (i.e. reserve margin, capacity requirements, energy share requirements) that are associated with a technology
- `ext::Dict`: (default: `Dict()`) Optional dictionary to provide additional data
- `internal::InfrastructureSystemsInternal`: (default: `InfrastructureSystemsInternal()`) (**Do not modify.**) PowerSystemsInvestmentsPortfolios.jl internal reference
"""
mutable struct ProjectedDemand{T <: PSY.StaticInjection} <: DemandTechnology
    "The demand name"
    name::String
    "Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`)"
    available::Bool
    "Corresponding type in PowerSystems.jl to be used in PCM modeling"
    power_systems_type::String
    "Zone or node where the demand is located"
    region::Vector{PSY.Topology}
    "Peak demand (MW). Demands with existing devices in the base system derive their peak demand from those devices, not from this value."
    peak_demand_mw::Float64
    "The year in which a new demand starts. Should only be used for new demands."
    construction_year::Int64
    "The annual growth rate of the demand, used to scale present-day loads into future projections. Only used for conforming loads"
    growth_rate::Float64
    "Whether the demand is conforming (grows by growth_rate) or non-conforming (does not grow). Must be set for new demands."
    conformity::PSY.LoadConformity.Value
    "Maximum fraction of demand that can be curtailed voluntarily"
    max_demand_curtailment::Float64
    "Cost of voluntary curtailment (USD/MWh). A LinearCurve is a single price for all curtailable demand. A PiecewiseIncrementalCurve gives tiers whose x coordinates are fractions of demand, from 0 to max_demand_curtailment, and whose slopes are prices (USD/MWh)"
    curtailment_cost::PSY.ValueCurve
    "Cost of involuntary shedding of the demand that cannot be curtailed (USD/MWh)"
    value_of_lost_load::Float64
    "Fraction of demand that can be shifted in time"
    flexible_fraction::Float64
    "Maximum time that flexible demand can be delayed (minutes)"
    max_demand_delay::Float64
    "Maximum time that flexible demand can be served in advance (minutes)"
    max_demand_advance::Float64
    "Fraction of shifted energy that is kept. Represents energy losses due to time shifting"
    shift_efficiency::Float64
    "Cost of shifting demand (USD/MWh shifted)"
    shift_cost::PSY.ValueCurve
    "List of requirements (i.e. reserve margin, capacity requirements, energy share requirements) that are associated with a technology"
    requirements::Vector{Requirement}
    "Optional dictionary to provide additional data"
    ext::Dict
    "(**Do not modify.**) PowerSystemsInvestmentsPortfolios.jl internal reference"
    internal::InfrastructureSystemsInternal
end


function ProjectedDemand{T}(; name, available=true, power_systems_type, region=Vector(), peak_demand_mw=0.0, construction_year=2020, growth_rate=0.0, conformity=LoadConformity.UNDEFINED, max_demand_curtailment=0.0, curtailment_cost=LinearCurve(0.0), value_of_lost_load=1e8, flexible_fraction=0.0, max_demand_delay=0.0, max_demand_advance=0.0, shift_efficiency=1.0, shift_cost=LinearCurve(0.0), requirements=Vector(), ext=Dict(), internal=InfrastructureSystemsInternal(), ) where T <: PSY.StaticInjection
    ProjectedDemand{T}(name, available, power_systems_type, region, peak_demand_mw, construction_year, growth_rate, conformity, max_demand_curtailment, curtailment_cost, value_of_lost_load, flexible_fraction, max_demand_delay, max_demand_advance, shift_efficiency, shift_cost, requirements, ext, internal, )
end

"""Get [`ProjectedDemand`](@ref) `name`."""
get_name(value::ProjectedDemand) = value.name
"""Get [`ProjectedDemand`](@ref) `available`."""
get_available(value::ProjectedDemand) = value.available
"""Get [`ProjectedDemand`](@ref) `power_systems_type`."""
get_power_systems_type(value::ProjectedDemand) = value.power_systems_type
"""Get [`ProjectedDemand`](@ref) `region`."""
get_region(value::ProjectedDemand) = value.region
"""Get [`ProjectedDemand`](@ref) `peak_demand_mw` as a bare number in the requested `units` (e.g. domain-provided units such as `MW`). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_peak_demand_mw_unitful`](@ref)."""
get_peak_demand_mw(value::ProjectedDemand, units) = InfrastructureSystems._strip_units(get_value(value, Val(:peak_demand_mw), Val(:mw), units))
"""Get [`ProjectedDemand`](@ref) `peak_demand_mw` as a unit-bearing quantity in the requested `units` (e.g. `MW`). For a bare number see [`get_peak_demand_mw`](@ref)."""
get_peak_demand_mw_unitful(value::ProjectedDemand, units) = get_value(value, Val(:peak_demand_mw), Val(:mw), units)
get_peak_demand_mw(value::ProjectedDemand) = _units_arg_required(get_peak_demand_mw, Val(:mw))
InfrastructureSystems.display_units_arg(::typeof(get_peak_demand_mw), ::Type{ProjectedDemand{T}}) where {T <: PSY.StaticInjection} = u"NU"
InfrastructureSystems.display_units_arg(::typeof(get_peak_demand_mw_unitful), ::Type{ProjectedDemand{T}}) where {T <: PSY.StaticInjection} = u"NU"
"""Get [`ProjectedDemand`](@ref) `construction_year`."""
get_construction_year(value::ProjectedDemand) = value.construction_year
"""Get [`ProjectedDemand`](@ref) `growth_rate`."""
get_growth_rate(value::ProjectedDemand) = value.growth_rate
"""Get [`ProjectedDemand`](@ref) `conformity`."""
get_conformity(value::ProjectedDemand) = value.conformity
"""Get [`ProjectedDemand`](@ref) `max_demand_curtailment`."""
get_max_demand_curtailment(value::ProjectedDemand) = value.max_demand_curtailment
"""Get [`ProjectedDemand`](@ref) `curtailment_cost` as a bare number in the requested `units` (e.g. domain-provided units such as `MW`). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_curtailment_cost_unitful`](@ref)."""
get_curtailment_cost(value::ProjectedDemand, units) = InfrastructureSystems._strip_units(get_value(value, Val(:curtailment_cost), Val(:usd_per_mwh), units))
"""Get [`ProjectedDemand`](@ref) `curtailment_cost` as a unit-bearing quantity in the requested `units` (e.g. `MW`). For a bare number see [`get_curtailment_cost`](@ref)."""
get_curtailment_cost_unitful(value::ProjectedDemand, units) = get_value(value, Val(:curtailment_cost), Val(:usd_per_mwh), units)
get_curtailment_cost(value::ProjectedDemand) = _units_arg_required(get_curtailment_cost, Val(:usd_per_mwh))
InfrastructureSystems.display_units_arg(::typeof(get_curtailment_cost), ::Type{ProjectedDemand{T}}) where {T <: PSY.StaticInjection} = u"NU"
InfrastructureSystems.display_units_arg(::typeof(get_curtailment_cost_unitful), ::Type{ProjectedDemand{T}}) where {T <: PSY.StaticInjection} = u"NU"
"""Get [`ProjectedDemand`](@ref) `value_of_lost_load` as a bare number in the requested `units` (e.g. domain-provided units such as `MW`). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_value_of_lost_load_unitful`](@ref)."""
get_value_of_lost_load(value::ProjectedDemand, units) = InfrastructureSystems._strip_units(get_value(value, Val(:value_of_lost_load), Val(:usd_per_mwh_scalar), units))
"""Get [`ProjectedDemand`](@ref) `value_of_lost_load` as a unit-bearing quantity in the requested `units` (e.g. `MW`). For a bare number see [`get_value_of_lost_load`](@ref)."""
get_value_of_lost_load_unitful(value::ProjectedDemand, units) = get_value(value, Val(:value_of_lost_load), Val(:usd_per_mwh_scalar), units)
get_value_of_lost_load(value::ProjectedDemand) = _units_arg_required(get_value_of_lost_load, Val(:usd_per_mwh_scalar))
InfrastructureSystems.display_units_arg(::typeof(get_value_of_lost_load), ::Type{ProjectedDemand{T}}) where {T <: PSY.StaticInjection} = u"NU"
InfrastructureSystems.display_units_arg(::typeof(get_value_of_lost_load_unitful), ::Type{ProjectedDemand{T}}) where {T <: PSY.StaticInjection} = u"NU"
"""Get [`ProjectedDemand`](@ref) `flexible_fraction`."""
get_flexible_fraction(value::ProjectedDemand) = value.flexible_fraction
"""Get [`ProjectedDemand`](@ref) `max_demand_delay` as a bare number in the requested `units` (e.g. domain-provided units such as `MW`). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_max_demand_delay_unitful`](@ref)."""
get_max_demand_delay(value::ProjectedDemand, units) = InfrastructureSystems._strip_units(get_value(value, Val(:max_demand_delay), Val(:min), units))
"""Get [`ProjectedDemand`](@ref) `max_demand_delay` as a unit-bearing quantity in the requested `units` (e.g. `MW`). For a bare number see [`get_max_demand_delay`](@ref)."""
get_max_demand_delay_unitful(value::ProjectedDemand, units) = get_value(value, Val(:max_demand_delay), Val(:min), units)
get_max_demand_delay(value::ProjectedDemand) = _units_arg_required(get_max_demand_delay, Val(:min))
InfrastructureSystems.display_units_arg(::typeof(get_max_demand_delay), ::Type{ProjectedDemand{T}}) where {T <: PSY.StaticInjection} = u"NU"
InfrastructureSystems.display_units_arg(::typeof(get_max_demand_delay_unitful), ::Type{ProjectedDemand{T}}) where {T <: PSY.StaticInjection} = u"NU"
"""Get [`ProjectedDemand`](@ref) `max_demand_advance` as a bare number in the requested `units` (e.g. domain-provided units such as `MW`). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_max_demand_advance_unitful`](@ref)."""
get_max_demand_advance(value::ProjectedDemand, units) = InfrastructureSystems._strip_units(get_value(value, Val(:max_demand_advance), Val(:min), units))
"""Get [`ProjectedDemand`](@ref) `max_demand_advance` as a unit-bearing quantity in the requested `units` (e.g. `MW`). For a bare number see [`get_max_demand_advance`](@ref)."""
get_max_demand_advance_unitful(value::ProjectedDemand, units) = get_value(value, Val(:max_demand_advance), Val(:min), units)
get_max_demand_advance(value::ProjectedDemand) = _units_arg_required(get_max_demand_advance, Val(:min))
InfrastructureSystems.display_units_arg(::typeof(get_max_demand_advance), ::Type{ProjectedDemand{T}}) where {T <: PSY.StaticInjection} = u"NU"
InfrastructureSystems.display_units_arg(::typeof(get_max_demand_advance_unitful), ::Type{ProjectedDemand{T}}) where {T <: PSY.StaticInjection} = u"NU"
"""Get [`ProjectedDemand`](@ref) `shift_efficiency`."""
get_shift_efficiency(value::ProjectedDemand) = value.shift_efficiency
"""Get [`ProjectedDemand`](@ref) `shift_cost` as a bare number in the requested `units` (e.g. domain-provided units such as `MW`). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_shift_cost_unitful`](@ref)."""
get_shift_cost(value::ProjectedDemand, units) = InfrastructureSystems._strip_units(get_value(value, Val(:shift_cost), Val(:usd_per_mwh), units))
"""Get [`ProjectedDemand`](@ref) `shift_cost` as a unit-bearing quantity in the requested `units` (e.g. `MW`). For a bare number see [`get_shift_cost`](@ref)."""
get_shift_cost_unitful(value::ProjectedDemand, units) = get_value(value, Val(:shift_cost), Val(:usd_per_mwh), units)
get_shift_cost(value::ProjectedDemand) = _units_arg_required(get_shift_cost, Val(:usd_per_mwh))
InfrastructureSystems.display_units_arg(::typeof(get_shift_cost), ::Type{ProjectedDemand{T}}) where {T <: PSY.StaticInjection} = u"NU"
InfrastructureSystems.display_units_arg(::typeof(get_shift_cost_unitful), ::Type{ProjectedDemand{T}}) where {T <: PSY.StaticInjection} = u"NU"
"""Get [`ProjectedDemand`](@ref) `requirements`."""
get_requirements(value::ProjectedDemand) = value.requirements
"""Get [`ProjectedDemand`](@ref) `ext`."""
get_ext(value::ProjectedDemand) = value.ext
"""Get [`ProjectedDemand`](@ref) `internal`."""
get_internal(value::ProjectedDemand) = value.internal

"""Set [`ProjectedDemand`](@ref) `name`."""
set_name!(value::ProjectedDemand, val) = value.name = val
"""Set [`ProjectedDemand`](@ref) `available`."""
set_available!(value::ProjectedDemand, val) = value.available = val
"""Set [`ProjectedDemand`](@ref) `power_systems_type`."""
set_power_systems_type!(value::ProjectedDemand, val) = value.power_systems_type = val
"""Set [`ProjectedDemand`](@ref) `region`."""
set_region!(value::ProjectedDemand, val) = value.region = val
"""Set [`ProjectedDemand`](@ref) `peak_demand_mw` from a units-tagged value (e.g. `100.0u"MW"`); a curve is given in natural units."""
set_peak_demand_mw!(value::ProjectedDemand, val) = value.peak_demand_mw = set_value(value, Val(:peak_demand_mw), val, Val(:mw))
"""Set [`ProjectedDemand`](@ref) `construction_year`."""
set_construction_year!(value::ProjectedDemand, val) = value.construction_year = val
"""Set [`ProjectedDemand`](@ref) `growth_rate`."""
set_growth_rate!(value::ProjectedDemand, val) = value.growth_rate = val
"""Set [`ProjectedDemand`](@ref) `conformity`."""
set_conformity!(value::ProjectedDemand, val) = value.conformity = val
"""Set [`ProjectedDemand`](@ref) `max_demand_curtailment`."""
set_max_demand_curtailment!(value::ProjectedDemand, val) = value.max_demand_curtailment = val
"""Set [`ProjectedDemand`](@ref) `curtailment_cost` from a units-tagged value (e.g. `100.0u"MW"`); a curve is given in natural units."""
set_curtailment_cost!(value::ProjectedDemand, val) = value.curtailment_cost = set_value(value, Val(:curtailment_cost), val, Val(:usd_per_mwh))
"""Set [`ProjectedDemand`](@ref) `value_of_lost_load` from a units-tagged value (e.g. `100.0u"MW"`); a curve is given in natural units."""
set_value_of_lost_load!(value::ProjectedDemand, val) = value.value_of_lost_load = set_value(value, Val(:value_of_lost_load), val, Val(:usd_per_mwh_scalar))
"""Set [`ProjectedDemand`](@ref) `flexible_fraction`."""
set_flexible_fraction!(value::ProjectedDemand, val) = value.flexible_fraction = val
"""Set [`ProjectedDemand`](@ref) `max_demand_delay` from a units-tagged value (e.g. `100.0u"MW"`); a curve is given in natural units."""
set_max_demand_delay!(value::ProjectedDemand, val) = value.max_demand_delay = set_value(value, Val(:max_demand_delay), val, Val(:min))
"""Set [`ProjectedDemand`](@ref) `max_demand_advance` from a units-tagged value (e.g. `100.0u"MW"`); a curve is given in natural units."""
set_max_demand_advance!(value::ProjectedDemand, val) = value.max_demand_advance = set_value(value, Val(:max_demand_advance), val, Val(:min))
"""Set [`ProjectedDemand`](@ref) `shift_efficiency`."""
set_shift_efficiency!(value::ProjectedDemand, val) = value.shift_efficiency = val
"""Set [`ProjectedDemand`](@ref) `shift_cost` from a units-tagged value (e.g. `100.0u"MW"`); a curve is given in natural units."""
set_shift_cost!(value::ProjectedDemand, val) = value.shift_cost = set_value(value, Val(:shift_cost), val, Val(:usd_per_mwh))
"""Set [`ProjectedDemand`](@ref) `requirements`."""
set_requirements!(value::ProjectedDemand, val) = value.requirements = val
"""Set [`ProjectedDemand`](@ref) `ext`."""
set_ext!(value::ProjectedDemand, val) = value.ext = val
"""Set [`ProjectedDemand`](@ref) `internal`."""
set_internal!(value::ProjectedDemand, val) = value.internal = val


function from_openapi(po::PI.ProjectedDemand, refs::OpenAPIRefs)
    parameter = getproperty(PowerSystems, Symbol(po.power_systems_type))
    return ProjectedDemand{parameter}(;
        name = po.name,
        available = _or_default(po.available, true),
        power_systems_type = po.power_systems_type,
        region = _or_default(resolve_refs(refs, po.region, PSY.Topology), Vector()),
        peak_demand_mw = _or_default(po.peak_demand_mw, 0.0),
        construction_year = _or_default(po.construction_year, 2020),
        growth_rate = _or_default(po.growth_rate, 0.0),
        conformity = _or_default(_enum_from_po(po.conformity, PSY.LoadConformity.Value), LoadConformity.UNDEFINED),
        max_demand_curtailment = _or_default(po.max_demand_curtailment, 0.0),
        curtailment_cost = _or_default(_value_curve_optional(po.curtailment_cost), LinearCurve(0.0)),
        value_of_lost_load = _or_default(po.value_of_lost_load, 1e8),
        flexible_fraction = _or_default(po.flexible_fraction, 0.0),
        max_demand_delay = _or_default(po.max_demand_delay, 0.0),
        max_demand_advance = _or_default(po.max_demand_advance, 0.0),
        shift_efficiency = _or_default(po.shift_efficiency, 1.0),
        shift_cost = _or_default(_value_curve_optional(po.shift_cost), LinearCurve(0.0)),
    )
end

function to_openapi(value::ProjectedDemand{T}, refs::OpenAPIRefs) where {T <: PSY.StaticInjection}
    return PI.ProjectedDemand(;
        id = get_id(value),
        name = get_name(value),
        available = get_available(value),
        power_systems_type = string(nameof(T)),
        region = component_ids(refs, get_region(value)),
        peak_demand_mw = get_peak_demand_mw(value, u"NU"),
        construction_year = get_construction_year(value),
        growth_rate = get_growth_rate(value),
        conformity = string(get_conformity(value)),
        max_demand_curtailment = get_max_demand_curtailment(value),
        curtailment_cost = _curve_to_openapi(PI.ProjectedDemandCurtailmentCost, get_curtailment_cost(value, u"NU")),
        value_of_lost_load = get_value_of_lost_load(value, u"NU"),
        flexible_fraction = get_flexible_fraction(value),
        max_demand_delay = get_max_demand_delay(value, u"NU"),
        max_demand_advance = get_max_demand_advance(value, u"NU"),
        shift_efficiency = get_shift_efficiency(value),
        shift_cost = _curve_to_openapi(PI.ProjectedDemandShiftCost, get_shift_cost(value, u"NU")),
    )
end
