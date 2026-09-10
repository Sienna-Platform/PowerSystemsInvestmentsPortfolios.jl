#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct Node <: RegionTopology
        name::String
        bus_type::ACBusTypes
        ext::Dict
        internal::InfrastructureSystemsInternal
    end

A unit of spatial aggregation for nodal capacity expansion models. Used to define locations for supply, demand, transport, and storage technologies and relevant policy requirements.

# Arguments
- `name::String`: Name of region
- `bus_type::ACBusTypes`: (default: `ACBusTypes.PQ`) AC Bus Type for a node
- `ext::Dict`: (default: `Dict()`) Optional dictionary to provide additional data
- `internal::InfrastructureSystemsInternal`: (default: `InfrastructureSystemsInternal()`) (**Do not modify.**) PowerSystemsInvestmentsPortfolios.jl internal reference
"""
mutable struct Node <: RegionTopology
    "Name of region"
    name::String
    "AC Bus Type for a node"
    bus_type::ACBusTypes
    "Optional dictionary to provide additional data"
    ext::Dict
    "(**Do not modify.**) PowerSystemsInvestmentsPortfolios.jl internal reference"
    internal::InfrastructureSystemsInternal
end


function Node(; name, bus_type=ACBusTypes.PQ, ext=Dict(), internal=InfrastructureSystemsInternal(), )
    Node(name, bus_type, ext, internal, )
end

"""Get [`Node`](@ref) `name`."""
get_name(value::Node) = value.name
"""Get [`Node`](@ref) `bus_type`."""
get_bus_type(value::Node) = value.bus_type
"""Get [`Node`](@ref) `ext`."""
get_ext(value::Node) = value.ext
"""Get [`Node`](@ref) `internal`."""
get_internal(value::Node) = value.internal

"""Set [`Node`](@ref) `name`."""
set_name!(value::Node, val) = value.name = val
"""Set [`Node`](@ref) `bus_type`."""
set_bus_type!(value::Node, val) = value.bus_type = val
"""Set [`Node`](@ref) `ext`."""
set_ext!(value::Node, val) = value.ext = val
"""Set [`Node`](@ref) `internal`."""
set_internal!(value::Node, val) = value.internal = val
