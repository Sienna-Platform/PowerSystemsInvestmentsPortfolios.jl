#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct TopologyMapping <: IS.SupplementalAttribute
        internal::InfrastructureSystemsInternal
        buses::Vector{String}
        id::Int64
        ext::Dict
    end

Supplemental attributed used to store mapping between the PSIP Zone and the associated buses in the base system.

# Arguments
- `internal::InfrastructureSystemsInternal`: (default: `InfrastructureSystemsInternal()`) (**Do not modify.**) PowerSystemsInvestmentsPortfolios.jl internal reference
- `buses::Vector{String}`: (default: `Vector()`) List of buses in the base system that are associated with a zone
- `id::Int64`: ID for individual component
- `ext::Dict`: (default: `Dict()`) Optional dictionary to provide additional data
"""
mutable struct TopologyMapping <: IS.SupplementalAttribute
    "(**Do not modify.**) PowerSystemsInvestmentsPortfolios.jl internal reference"
    internal::InfrastructureSystemsInternal
    "List of buses in the base system that are associated with a zone"
    buses::Vector{String}
    "ID for individual component"
    id::Int64
    "Optional dictionary to provide additional data"
    ext::Dict
end


function TopologyMapping(; internal=InfrastructureSystemsInternal(), buses=Vector(), id, ext=Dict(), )
    TopologyMapping(internal, buses, id, ext, )
end

"""Get [`TopologyMapping`](@ref) `internal`."""
get_internal(value::TopologyMapping) = value.internal
"""Get [`TopologyMapping`](@ref) `buses`."""
get_buses(value::TopologyMapping) = value.buses
"""Get [`TopologyMapping`](@ref) `id`."""
get_id(value::TopologyMapping) = value.id
"""Get [`TopologyMapping`](@ref) `ext`."""
get_ext(value::TopologyMapping) = value.ext

"""Set [`TopologyMapping`](@ref) `internal`."""
set_internal!(value::TopologyMapping, val) = value.internal = val
"""Set [`TopologyMapping`](@ref) `buses`."""
set_buses!(value::TopologyMapping, val) = value.buses = val
"""Set [`TopologyMapping`](@ref) `id`."""
set_id!(value::TopologyMapping, val) = value.id = val
"""Set [`TopologyMapping`](@ref) `ext`."""
set_ext!(value::TopologyMapping, val) = value.ext = val

function serialize_openapi_struct(technology::TopologyMapping, vals...)
    base_struct = APIServer.TopologyMapping(; vals...)
    return base_struct
end

function deserialize_openapi_struct(::Type{<:TopologyMapping}, vals::Dict)
    return IS.deserialize_struct(APIServer.TopologyMapping, vals)
end
