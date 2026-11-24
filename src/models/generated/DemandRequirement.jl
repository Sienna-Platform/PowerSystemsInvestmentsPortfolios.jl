#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct DemandRequirement{T <: PSY.StaticInjection} <: DemandTechnology
        requirements::Vector{Requirement}
        conformity::PSY.LoadConformity
        growth_rate::Float64
        power_systems_type::String
        value_of_lost_load::Float64
        internal::InfrastructureSystemsInternal
        ext::Dict
        region::Vector{RegionTopology}
        available::Bool
        name::String
        unserved_demand_curve::PSY.ValueCurve
        id::Int64
        new_construction_year::Int64
        new_demand_mw::Float64
    end

Demand requirements for a region.

# Arguments
- `requirements::Vector{Requirement}`: (default: `Vector()`) List of requirements (i.e. reserve margin, capacity requirements, energy share requirements) that are associated with a technology
- `conformity::PSY.LoadConformity`: (default: `PSY.LoadConformity.UNDEFINED`) Indicator of how the demand requirement should conform to the load profile of existing technologies in the system. Should only be used for new demand requirements.
- `growth_rate::Float64`: (default: `0.0`) The annual growth rate of the demand requirement, used to scale present-day loads into future projections. Should only be used for conforming loads
- `power_systems_type::String`: Corresponding type in PowerSystems.jl to be used in PCM modeling
- `value_of_lost_load::Float64`: Value of unserved load (USD/MWh)
- `internal::InfrastructureSystemsInternal`: (default: `InfrastructureSystemsInternal()`) (**Do not modify.**) PowerSystemsInvestmentsPortfolios.jl internal reference
- `ext::Dict`: (default: `Dict()`) Optional dictionary to provide additional data
- `region::Vector{RegionTopology}`: (default: `Vector()`) Zone or node where the demand requirement is located
- `available::Bool`: (default: `true`) Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`)
- `name::String`: The technology name
- `unserved_demand_curve::PSY.ValueCurve`: (default: `LinearCurve(0.0)`) Piecewise curve to scale the cost of unserved load based on the value of lost load
- `id::Int64`: ID for individual demand requirement
- `new_construction_year::Int64`: (default: `2020`) The year in which the new demand requirement will be installed. Should only be used for new demand requirements.
- `new_demand_mw::Float64`: (default: `0.0`) The value of the peak demand to be used for new DemandRequirements.
"""
mutable struct DemandRequirement{T <: PSY.StaticInjection} <: DemandTechnology
    "List of requirements (i.e. reserve margin, capacity requirements, energy share requirements) that are associated with a technology"
    requirements::Vector{Requirement}
    "Indicator of how the demand requirement should conform to the load profile of existing technologies in the system. Should only be used for new demand requirements."
    conformity::PSY.LoadConformity
    "The annual growth rate of the demand requirement, used to scale present-day loads into future projections. Should only be used for conforming loads"
    growth_rate::Float64
    "Corresponding type in PowerSystems.jl to be used in PCM modeling"
    power_systems_type::String
    "Value of unserved load (USD/MWh)"
    value_of_lost_load::Float64
    "(**Do not modify.**) PowerSystemsInvestmentsPortfolios.jl internal reference"
    internal::InfrastructureSystemsInternal
    "Optional dictionary to provide additional data"
    ext::Dict
    "Zone or node where the demand requirement is located"
    region::Vector{RegionTopology}
    "Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`)"
    available::Bool
    "The technology name"
    name::String
    "Piecewise curve to scale the cost of unserved load based on the value of lost load"
    unserved_demand_curve::PSY.ValueCurve
    "ID for individual demand requirement"
    id::Int64
    "The year in which the new demand requirement will be installed. Should only be used for new demand requirements."
    new_construction_year::Int64
    "The value of the peak demand to be used for new DemandRequirements."
    new_demand_mw::Float64
end


function DemandRequirement{T}(; requirements=Vector(), conformity=PSY.LoadConformity.UNDEFINED, growth_rate=0.0, power_systems_type, value_of_lost_load, internal=InfrastructureSystemsInternal(), ext=Dict(), region=Vector(), available=true, name, unserved_demand_curve=LinearCurve(0.0), id, new_construction_year=2020, new_demand_mw=0.0, ) where T <: PSY.StaticInjection
    DemandRequirement{T}(requirements, conformity, growth_rate, power_systems_type, value_of_lost_load, internal, ext, region, available, name, unserved_demand_curve, id, new_construction_year, new_demand_mw, )
end

"""Get [`DemandRequirement`](@ref) `requirements`."""
get_requirements(value::DemandRequirement) = value.requirements
"""Get [`DemandRequirement`](@ref) `conformity`."""
get_conformity(value::DemandRequirement) = value.conformity
"""Get [`DemandRequirement`](@ref) `growth_rate`."""
get_growth_rate(value::DemandRequirement) = value.growth_rate
"""Get [`DemandRequirement`](@ref) `power_systems_type`."""
get_power_systems_type(value::DemandRequirement) = value.power_systems_type
"""Get [`DemandRequirement`](@ref) `value_of_lost_load`."""
get_value_of_lost_load(value::DemandRequirement) = value.value_of_lost_load
"""Get [`DemandRequirement`](@ref) `internal`."""
get_internal(value::DemandRequirement) = value.internal
"""Get [`DemandRequirement`](@ref) `ext`."""
get_ext(value::DemandRequirement) = value.ext
"""Get [`DemandRequirement`](@ref) `region`."""
get_region(value::DemandRequirement) = value.region
"""Get [`DemandRequirement`](@ref) `available`."""
get_available(value::DemandRequirement) = value.available
"""Get [`DemandRequirement`](@ref) `name`."""
get_name(value::DemandRequirement) = value.name
"""Get [`DemandRequirement`](@ref) `unserved_demand_curve`."""
get_unserved_demand_curve(value::DemandRequirement) = value.unserved_demand_curve
"""Get [`DemandRequirement`](@ref) `id`."""
get_id(value::DemandRequirement) = value.id
"""Get [`DemandRequirement`](@ref) `new_construction_year`."""
get_new_construction_year(value::DemandRequirement) = value.new_construction_year
"""Get [`DemandRequirement`](@ref) `new_demand_mw`."""
get_new_demand_mw(value::DemandRequirement) = value.new_demand_mw

"""Set [`DemandRequirement`](@ref) `requirements`."""
set_requirements!(value::DemandRequirement, val) = value.requirements = val
"""Set [`DemandRequirement`](@ref) `conformity`."""
set_conformity!(value::DemandRequirement, val) = value.conformity = val
"""Set [`DemandRequirement`](@ref) `growth_rate`."""
set_growth_rate!(value::DemandRequirement, val) = value.growth_rate = val
"""Set [`DemandRequirement`](@ref) `power_systems_type`."""
set_power_systems_type!(value::DemandRequirement, val) = value.power_systems_type = val
"""Set [`DemandRequirement`](@ref) `value_of_lost_load`."""
set_value_of_lost_load!(value::DemandRequirement, val) = value.value_of_lost_load = val
"""Set [`DemandRequirement`](@ref) `internal`."""
set_internal!(value::DemandRequirement, val) = value.internal = val
"""Set [`DemandRequirement`](@ref) `ext`."""
set_ext!(value::DemandRequirement, val) = value.ext = val
"""Set [`DemandRequirement`](@ref) `region`."""
set_region!(value::DemandRequirement, val) = value.region = val
"""Set [`DemandRequirement`](@ref) `available`."""
set_available!(value::DemandRequirement, val) = value.available = val
"""Set [`DemandRequirement`](@ref) `name`."""
set_name!(value::DemandRequirement, val) = value.name = val
"""Set [`DemandRequirement`](@ref) `unserved_demand_curve`."""
set_unserved_demand_curve!(value::DemandRequirement, val) = value.unserved_demand_curve = val
"""Set [`DemandRequirement`](@ref) `id`."""
set_id!(value::DemandRequirement, val) = value.id = val
"""Set [`DemandRequirement`](@ref) `new_construction_year`."""
set_new_construction_year!(value::DemandRequirement, val) = value.new_construction_year = val
"""Set [`DemandRequirement`](@ref) `new_demand_mw`."""
set_new_demand_mw!(value::DemandRequirement, val) = value.new_demand_mw = val

function serialize_openapi_struct(technology::DemandRequirement{T}, vals...) where T <: PSY.StaticInjection
    base_struct = APIServer.DemandRequirement(; vals...)
    return base_struct
end


function deserialize_openapi_struct(::Type{<:DemandRequirement}, vals::Dict)
    return IS.deserialize_struct(APIServer.DemandRequirement, vals)
end
