#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct DemandRequirement{T <: PSY.StaticInjection} <: DemandTechnology
        name::String
        available::Bool
        power_systems_type::String
        new_demand_mw::Float64
        new_construction_year::Int64
        growth_rate::Float64
        conformity::PSY.LoadConformity
        value_of_lost_load::Float64
        unserved_demand_curve::PSY.ValueCurve
        region::Vector{PSY.Topology}
        requirements::Vector{Requirement}
        ext::Dict
        internal::InfrastructureSystemsInternal
    end

Demand requirements for a region.

# Arguments
- `name::String`: The technology name
- `available::Bool`: (default: `true`) Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`)
- `power_systems_type::String`: Corresponding type in PowerSystems.jl to be used in PCM modeling
- `new_demand_mw::Float64`: (default: `0.0`) The value of the peak demand to be used for new DemandRequirements (MW).
- `new_construction_year::Int64`: (default: `2020`) The year in which the new demand requirement will be installed. Should only be used for new demand requirements.
- `growth_rate::Float64`: (default: `0.0`) The annual growth rate of the demand requirement, used to scale present-day loads into future projections. Should only be used for conforming loads
- `conformity::PSY.LoadConformity`: (default: `PSY.LoadConformity.UNDEFINED`) Indicator of how the demand requirement should conform to the load profile of existing technologies in the system. Should only be used for new demand requirements.
- `value_of_lost_load::Float64`: (default: `1e8`) Value of unserved load (USD/MWh)
- `unserved_demand_curve::PSY.ValueCurve`: (default: `LinearCurve(0.0)`) Piecewise curve to scale the cost of unserved load based on the value of lost load
- `region::Vector{PSY.Topology}`: (default: `Vector()`) Zone or node where the demand requirement is located
- `requirements::Vector{Requirement}`: (default: `Vector()`) List of requirements (i.e. reserve margin, capacity requirements, energy share requirements) that are associated with a technology
- `ext::Dict`: (default: `Dict()`) Optional dictionary to provide additional data
- `internal::InfrastructureSystemsInternal`: (default: `InfrastructureSystemsInternal()`) (**Do not modify.**) PowerSystemsInvestmentsPortfolios.jl internal reference
"""
mutable struct DemandRequirement{T <: PSY.StaticInjection} <: DemandTechnology
    "The technology name"
    name::String
    "Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`)"
    available::Bool
    "Corresponding type in PowerSystems.jl to be used in PCM modeling"
    power_systems_type::String
    "The value of the peak demand to be used for new DemandRequirements (MW)."
    new_demand_mw::Float64
    "The year in which the new demand requirement will be installed. Should only be used for new demand requirements."
    new_construction_year::Int64
    "The annual growth rate of the demand requirement, used to scale present-day loads into future projections. Should only be used for conforming loads"
    growth_rate::Float64
    "Indicator of how the demand requirement should conform to the load profile of existing technologies in the system. Should only be used for new demand requirements."
    conformity::PSY.LoadConformity
    "Value of unserved load (USD/MWh)"
    value_of_lost_load::Float64
    "Piecewise curve to scale the cost of unserved load based on the value of lost load"
    unserved_demand_curve::PSY.ValueCurve
    "Zone or node where the demand requirement is located"
    region::Vector{PSY.Topology}
    "List of requirements (i.e. reserve margin, capacity requirements, energy share requirements) that are associated with a technology"
    requirements::Vector{Requirement}
    "Optional dictionary to provide additional data"
    ext::Dict
    "(**Do not modify.**) PowerSystemsInvestmentsPortfolios.jl internal reference"
    internal::InfrastructureSystemsInternal
end


function DemandRequirement{T}(; name, available=true, power_systems_type, new_demand_mw=0.0, new_construction_year=2020, growth_rate=0.0, conformity=PSY.LoadConformity.UNDEFINED, value_of_lost_load=1e8, unserved_demand_curve=LinearCurve(0.0), region=Vector(), requirements=Vector(), ext=Dict(), internal=InfrastructureSystemsInternal(), ) where T <: PSY.StaticInjection
    DemandRequirement{T}(name, available, power_systems_type, new_demand_mw, new_construction_year, growth_rate, conformity, value_of_lost_load, unserved_demand_curve, region, requirements, ext, internal, )
end

"""Get [`DemandRequirement`](@ref) `name`."""
get_name(value::DemandRequirement) = value.name
"""Get [`DemandRequirement`](@ref) `available`."""
get_available(value::DemandRequirement) = value.available
"""Get [`DemandRequirement`](@ref) `power_systems_type`."""
get_power_systems_type(value::DemandRequirement) = value.power_systems_type
"""Get [`DemandRequirement`](@ref) `new_demand_mw` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_new_demand_mw_unitful`](@ref)."""
get_new_demand_mw(value::DemandRequirement, units) = InfrastructureSystems._strip_units(get_value(value, Val(:new_demand_mw), Val(:mw), units))
"""Get [`DemandRequirement`](@ref) `new_demand_mw` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_new_demand_mw`](@ref)."""
get_new_demand_mw_unitful(value::DemandRequirement, units) = get_value(value, Val(:new_demand_mw), Val(:mw), units)
InfrastructureSystems.display_units_arg(::typeof(get_new_demand_mw), ::Type{DemandRequirement{T}}) where {T <: PSY.StaticInjection} = InfrastructureSystems.NU
InfrastructureSystems.display_units_arg(::typeof(get_new_demand_mw_unitful), ::Type{DemandRequirement{T}}) where {T <: PSY.StaticInjection} = InfrastructureSystems.NU
"""Get [`DemandRequirement`](@ref) `new_construction_year`."""
get_new_construction_year(value::DemandRequirement) = value.new_construction_year
"""Get [`DemandRequirement`](@ref) `growth_rate`."""
get_growth_rate(value::DemandRequirement) = value.growth_rate
"""Get [`DemandRequirement`](@ref) `conformity`."""
get_conformity(value::DemandRequirement) = value.conformity
"""Get [`DemandRequirement`](@ref) `value_of_lost_load` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_value_of_lost_load_unitful`](@ref)."""
get_value_of_lost_load(value::DemandRequirement, units) = InfrastructureSystems._strip_units(get_value(value, Val(:value_of_lost_load), Val(:usd_per_mwh_scalar), units))
"""Get [`DemandRequirement`](@ref) `value_of_lost_load` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_value_of_lost_load`](@ref)."""
get_value_of_lost_load_unitful(value::DemandRequirement, units) = get_value(value, Val(:value_of_lost_load), Val(:usd_per_mwh_scalar), units)
InfrastructureSystems.display_units_arg(::typeof(get_value_of_lost_load), ::Type{DemandRequirement{T}}) where {T <: PSY.StaticInjection} = InfrastructureSystems.NU
InfrastructureSystems.display_units_arg(::typeof(get_value_of_lost_load_unitful), ::Type{DemandRequirement{T}}) where {T <: PSY.StaticInjection} = InfrastructureSystems.NU
"""Get [`DemandRequirement`](@ref) `unserved_demand_curve` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_unserved_demand_curve_unitful`](@ref)."""
get_unserved_demand_curve(value::DemandRequirement, units) = InfrastructureSystems._strip_units(get_value(value, Val(:unserved_demand_curve), Val(:usd_per_mwh), units))
"""Get [`DemandRequirement`](@ref) `unserved_demand_curve` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_unserved_demand_curve`](@ref)."""
get_unserved_demand_curve_unitful(value::DemandRequirement, units) = get_value(value, Val(:unserved_demand_curve), Val(:usd_per_mwh), units)
InfrastructureSystems.display_units_arg(::typeof(get_unserved_demand_curve), ::Type{DemandRequirement{T}}) where {T <: PSY.StaticInjection} = InfrastructureSystems.NU
InfrastructureSystems.display_units_arg(::typeof(get_unserved_demand_curve_unitful), ::Type{DemandRequirement{T}}) where {T <: PSY.StaticInjection} = InfrastructureSystems.NU
"""Get [`DemandRequirement`](@ref) `region`."""
get_region(value::DemandRequirement) = value.region
"""Get [`DemandRequirement`](@ref) `requirements`."""
get_requirements(value::DemandRequirement) = value.requirements
"""Get [`DemandRequirement`](@ref) `ext`."""
get_ext(value::DemandRequirement) = value.ext
"""Get [`DemandRequirement`](@ref) `internal`."""
get_internal(value::DemandRequirement) = value.internal

"""Set [`DemandRequirement`](@ref) `name`."""
set_name!(value::DemandRequirement, val) = value.name = val
"""Set [`DemandRequirement`](@ref) `available`."""
set_available!(value::DemandRequirement, val) = value.available = val
"""Set [`DemandRequirement`](@ref) `power_systems_type`."""
set_power_systems_type!(value::DemandRequirement, val) = value.power_systems_type = val
"""Set [`DemandRequirement`](@ref) `new_demand_mw`."""
set_new_demand_mw!(value::DemandRequirement, val, unit) = value.new_demand_mw = set_value(value, Val(:new_demand_mw), val, unit, Val(:mw))
"""Set [`DemandRequirement`](@ref) `new_construction_year`."""
set_new_construction_year!(value::DemandRequirement, val) = value.new_construction_year = val
"""Set [`DemandRequirement`](@ref) `growth_rate`."""
set_growth_rate!(value::DemandRequirement, val) = value.growth_rate = val
"""Set [`DemandRequirement`](@ref) `conformity`."""
set_conformity!(value::DemandRequirement, val) = value.conformity = val
"""Set [`DemandRequirement`](@ref) `value_of_lost_load`."""
set_value_of_lost_load!(value::DemandRequirement, val, unit) = value.value_of_lost_load = set_value(value, Val(:value_of_lost_load), val, unit, Val(:usd_per_mwh_scalar))
"""Set [`DemandRequirement`](@ref) `unserved_demand_curve`."""
set_unserved_demand_curve!(value::DemandRequirement, val, unit) = value.unserved_demand_curve = set_value(value, Val(:unserved_demand_curve), val, unit, Val(:usd_per_mwh))
"""Set [`DemandRequirement`](@ref) `region`."""
set_region!(value::DemandRequirement, val) = value.region = val
"""Set [`DemandRequirement`](@ref) `requirements`."""
set_requirements!(value::DemandRequirement, val) = value.requirements = val
"""Set [`DemandRequirement`](@ref) `ext`."""
set_ext!(value::DemandRequirement, val) = value.ext = val
"""Set [`DemandRequirement`](@ref) `internal`."""
set_internal!(value::DemandRequirement, val) = value.internal = val


function from_openapi(po::PI.DemandRequirement, refs::OpenAPIRefs)
    parameter = getproperty(PowerSystems, Symbol(po.power_systems_type))
    return DemandRequirement{parameter}(;
        name = po.name,
        available = po.available,
        power_systems_type = po.power_systems_type,
        new_demand_mw = po.new_demand_mw,
        new_construction_year = po.new_construction_year,
        growth_rate = po.growth_rate,
        conformity = PSY.LoadConformity(po.conformity),
        value_of_lost_load = po.value_of_lost_load,
        unserved_demand_curve = convert_value_curve(po.unserved_demand_curve),
        region = resolve_refs(refs, po.region, PSY.Topology),
    )
end

function to_openapi(value::DemandRequirement{T}, refs::OpenAPIRefs) where {T <: PSY.StaticInjection}
    return PI.DemandRequirement(;
        id = get_id(value),
        name = get_name(value),
        available = get_available(value),
        power_systems_type = string(nameof(T)),
        new_demand_mw = get_new_demand_mw(value, IS.NU),
        new_construction_year = get_new_construction_year(value),
        growth_rate = get_growth_rate(value),
        conformity = string(get_conformity(value)),
        value_of_lost_load = get_value_of_lost_load(value, IS.NU),
        unserved_demand_curve = convert_value_curve_to_openapi(get_unserved_demand_curve(value, IS.NU)),
        region = component_ids(refs, get_region(value)),
    )
end
