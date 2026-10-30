#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct AggregateRetrofitPotential <: IS.SupplementalAttribute
        retrofit_id::Int64
        retrofit_fraction::Float64
        internal::InfrastructureSystemsInternal
        retrofit_potential::Float64
        id::Int64
        ext::Dict
    end

Supplemental attribute used to define a total amount of capacity that can be retrofit for a SupplyTechnology

# Arguments
- `retrofit_id::Int64`: (default: `0`) Unique identifier to group retrofittable source technologies with retrofit options inside the same zone.
- `retrofit_fraction::Float64`: (default: `0.0`) Fraction of existing capacity that is eligible for retrofits. Alternative to retrofit_potential
- `internal::InfrastructureSystemsInternal`: (default: `InfrastructureSystemsInternal()`) (**Do not modify.**) PowerSystemsInvestmentsPortfolios.jl internal reference
- `retrofit_potential::Float64`: (default: `0.0`) Amount of existing capacity for technology that can be retrofitted
- `id::Int64`: ID for individual component
- `ext::Dict`: (default: `Dict()`) Optional dictionary to provide additional data
"""
mutable struct AggregateRetrofitPotential <: IS.SupplementalAttribute
    "Unique identifier to group retrofittable source technologies with retrofit options inside the same zone."
    retrofit_id::Int64
    "Fraction of existing capacity that is eligible for retrofits. Alternative to retrofit_potential"
    retrofit_fraction::Float64
    "(**Do not modify.**) PowerSystemsInvestmentsPortfolios.jl internal reference"
    internal::InfrastructureSystemsInternal
    "Amount of existing capacity for technology that can be retrofitted"
    retrofit_potential::Float64
    "ID for individual component"
    id::Int64
    "Optional dictionary to provide additional data"
    ext::Dict
end


function AggregateRetrofitPotential(; retrofit_id=0, retrofit_fraction=0.0, internal=InfrastructureSystemsInternal(), retrofit_potential=0.0, id, ext=Dict(), )
    AggregateRetrofitPotential(retrofit_id, retrofit_fraction, internal, retrofit_potential, id, ext, )
end

"""Get [`AggregateRetrofitPotential`](@ref) `retrofit_id`."""
get_retrofit_id(value::AggregateRetrofitPotential) = value.retrofit_id
"""Get [`AggregateRetrofitPotential`](@ref) `retrofit_fraction`."""
get_retrofit_fraction(value::AggregateRetrofitPotential) = value.retrofit_fraction
"""Get [`AggregateRetrofitPotential`](@ref) `internal`."""
get_internal(value::AggregateRetrofitPotential) = value.internal
"""Get [`AggregateRetrofitPotential`](@ref) `retrofit_potential`."""
get_retrofit_potential(value::AggregateRetrofitPotential) = value.retrofit_potential
"""Get [`AggregateRetrofitPotential`](@ref) `id`."""
get_id(value::AggregateRetrofitPotential) = value.id
"""Get [`AggregateRetrofitPotential`](@ref) `ext`."""
get_ext(value::AggregateRetrofitPotential) = value.ext

"""Set [`AggregateRetrofitPotential`](@ref) `retrofit_id`."""
set_retrofit_id!(value::AggregateRetrofitPotential, val) = value.retrofit_id = val
"""Set [`AggregateRetrofitPotential`](@ref) `retrofit_fraction`."""
set_retrofit_fraction!(value::AggregateRetrofitPotential, val) = value.retrofit_fraction = val
"""Set [`AggregateRetrofitPotential`](@ref) `internal`."""
set_internal!(value::AggregateRetrofitPotential, val) = value.internal = val
"""Set [`AggregateRetrofitPotential`](@ref) `retrofit_potential`."""
set_retrofit_potential!(value::AggregateRetrofitPotential, val) = value.retrofit_potential = val
"""Set [`AggregateRetrofitPotential`](@ref) `id`."""
set_id!(value::AggregateRetrofitPotential, val) = value.id = val
"""Set [`AggregateRetrofitPotential`](@ref) `ext`."""
set_ext!(value::AggregateRetrofitPotential, val) = value.ext = val

function serialize_openapi_struct(technology::AggregateRetrofitPotential, vals...)
    base_struct = APIServer.AggregateRetrofitPotential(; vals...)
    return base_struct
end

function deserialize_openapi_struct(::Type{<:AggregateRetrofitPotential}, vals::Dict)
    return IS.deserialize_struct(APIServer.AggregateRetrofitPotential, vals)
end
