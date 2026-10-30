#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct RetrofitPotential <: IS.SupplementalAttribute
        eligible_generators::Vector{String}
        internal::InfrastructureSystemsInternal
        id::Int64
        ext::Dict
    end

Supplemental attribute used to define what existing generators are eligible for retrofit for a SupplyTechnology

# Arguments
- `eligible_generators::Vector{String}`: (default: `Vector()`) Names of individual generation units mapped to this technology that can be retrofitted
- `internal::InfrastructureSystemsInternal`: (default: `InfrastructureSystemsInternal()`) (**Do not modify.**) PowerSystemsInvestmentsPortfolios.jl internal reference
- `id::Int64`: ID for individual component
- `ext::Dict`: (default: `Dict()`) Optional dictionary to provide additional data
"""
mutable struct RetrofitPotential <: IS.SupplementalAttribute
    "Names of individual generation units mapped to this technology that can be retrofitted"
    eligible_generators::Vector{String}
    "(**Do not modify.**) PowerSystemsInvestmentsPortfolios.jl internal reference"
    internal::InfrastructureSystemsInternal
    "ID for individual component"
    id::Int64
    "Optional dictionary to provide additional data"
    ext::Dict
end


function RetrofitPotential(; eligible_generators=Vector(), internal=InfrastructureSystemsInternal(), id, ext=Dict(), )
    RetrofitPotential(eligible_generators, internal, id, ext, )
end

"""Get [`RetrofitPotential`](@ref) `eligible_generators`."""
get_eligible_generators(value::RetrofitPotential) = value.eligible_generators
"""Get [`RetrofitPotential`](@ref) `internal`."""
get_internal(value::RetrofitPotential) = value.internal
"""Get [`RetrofitPotential`](@ref) `id`."""
get_id(value::RetrofitPotential) = value.id
"""Get [`RetrofitPotential`](@ref) `ext`."""
get_ext(value::RetrofitPotential) = value.ext

"""Set [`RetrofitPotential`](@ref) `eligible_generators`."""
set_eligible_generators!(value::RetrofitPotential, val) = value.eligible_generators = val
"""Set [`RetrofitPotential`](@ref) `internal`."""
set_internal!(value::RetrofitPotential, val) = value.internal = val
"""Set [`RetrofitPotential`](@ref) `id`."""
set_id!(value::RetrofitPotential, val) = value.id = val
"""Set [`RetrofitPotential`](@ref) `ext`."""
set_ext!(value::RetrofitPotential, val) = value.ext = val

function serialize_openapi_struct(technology::RetrofitPotential, vals...)
    base_struct = APIServer.RetrofitPotential(; vals...)
    return base_struct
end

function deserialize_openapi_struct(::Type{<:RetrofitPotential}, vals::Dict)
    return IS.deserialize_struct(APIServer.RetrofitPotential, vals)
end
