#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct AggregateRetirementPotential <: IS.SupplementalAttribute
        internal::InfrastructureSystemsInternal
        id::Int64
        ext::Dict
        retirement_potential::Float64
    end

Supplemental attribute used to define a total amount of existing capacity that can be retired for a technology

# Arguments
- `internal::InfrastructureSystemsInternal`: (default: `InfrastructureSystemsInternal()`) (**Do not modify.**) PowerSystemsInvestmentsPortfolios.jl internal reference
- `id::Int64`: ID for individual component
- `ext::Dict`: (default: `Dict()`) Optional dictionary to provide additional data
- `retirement_potential::Float64`: (default: `0.0`) Amount of pre-existing capacity for a technology that is eligible for retirement
"""
mutable struct AggregateRetirementPotential <: IS.SupplementalAttribute
    "(**Do not modify.**) PowerSystemsInvestmentsPortfolios.jl internal reference"
    internal::InfrastructureSystemsInternal
    "ID for individual component"
    id::Int64
    "Optional dictionary to provide additional data"
    ext::Dict
    "Amount of pre-existing capacity for a technology that is eligible for retirement"
    retirement_potential::Float64
end


function AggregateRetirementPotential(; internal=InfrastructureSystemsInternal(), id, ext=Dict(), retirement_potential=0.0, )
    AggregateRetirementPotential(internal, id, ext, retirement_potential, )
end

"""Get [`AggregateRetirementPotential`](@ref) `internal`."""
get_internal(value::AggregateRetirementPotential) = value.internal
"""Get [`AggregateRetirementPotential`](@ref) `id`."""
get_id(value::AggregateRetirementPotential) = value.id
"""Get [`AggregateRetirementPotential`](@ref) `ext`."""
get_ext(value::AggregateRetirementPotential) = value.ext
"""Get [`AggregateRetirementPotential`](@ref) `retirement_potential`."""
get_retirement_potential(value::AggregateRetirementPotential) = value.retirement_potential

"""Set [`AggregateRetirementPotential`](@ref) `internal`."""
set_internal!(value::AggregateRetirementPotential, val) = value.internal = val
"""Set [`AggregateRetirementPotential`](@ref) `id`."""
set_id!(value::AggregateRetirementPotential, val) = value.id = val
"""Set [`AggregateRetirementPotential`](@ref) `ext`."""
set_ext!(value::AggregateRetirementPotential, val) = value.ext = val
"""Set [`AggregateRetirementPotential`](@ref) `retirement_potential`."""
set_retirement_potential!(value::AggregateRetirementPotential, val) = value.retirement_potential = val

function serialize_openapi_struct(technology::AggregateRetirementPotential, vals...)
    base_struct = APIServer.AggregateRetirementPotential(; vals...)
    return base_struct
end

function deserialize_openapi_struct(::Type{<:AggregateRetirementPotential}, vals::Dict)
    return IS.deserialize_struct(APIServer.AggregateRetirementPotential, vals)
end
