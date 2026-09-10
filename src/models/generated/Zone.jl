#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct Zone <: RegionTopology
        name::String
        ext::Dict
        internal::InfrastructureSystemsInternal
    end

A unit of spatial aggregation for zonal capacity expansion models. Used to define locations for supply, demand, transport, and storage technologies and relevant policy requirements.

# Arguments
- `name::String`: Name of region
- `ext::Dict`: (default: `Dict()`) Optional dictionary to provide additional data
- `internal::InfrastructureSystemsInternal`: (default: `InfrastructureSystemsInternal()`) (**Do not modify.**) PowerSystemsInvestmentsPortfolios.jl internal reference
"""
mutable struct Zone <: RegionTopology
    "Name of region"
    name::String
    "Optional dictionary to provide additional data"
    ext::Dict
    "(**Do not modify.**) PowerSystemsInvestmentsPortfolios.jl internal reference"
    internal::InfrastructureSystemsInternal
end


function Zone(; name, ext=Dict(), internal=InfrastructureSystemsInternal(), )
    Zone(name, ext, internal, )
end

"""Get [`Zone`](@ref) `name`."""
get_name(value::Zone) = value.name
"""Get [`Zone`](@ref) `ext`."""
get_ext(value::Zone) = value.ext
"""Get [`Zone`](@ref) `internal`."""
get_internal(value::Zone) = value.internal

"""Set [`Zone`](@ref) `name`."""
set_name!(value::Zone, val) = value.name = val
"""Set [`Zone`](@ref) `ext`."""
set_ext!(value::Zone, val) = value.ext = val
"""Set [`Zone`](@ref) `internal`."""
set_internal!(value::Zone, val) = value.internal = val
