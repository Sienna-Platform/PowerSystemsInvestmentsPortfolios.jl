#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct RetrofitPotential <: IS.SupplementalAttribute
        retrofit_efficiency::Float64
        eligible_generators::Vector{String}
        internal::InfrastructureSystemsInternal
        ext::Dict
    end

Supplemental attribute linking a retrofit: existing generators of a source SupplyTechnology that can be converted into a retrofit option SupplyTechnology. Attach the same attribute to both the source and the option, one attribute per source and option pair.

# Arguments
- `retrofit_efficiency::Float64`: (default: `1.0`) Capacity of the option technology obtained per unit of source capacity retrofitted (MW/MW), e.g. below 1 when a retrofit derates the plant
- `eligible_generators::Vector{String}`: (default: `Vector()`) Names of the existing generation units of the source technology that can be retrofitted into the option technology
- `internal::InfrastructureSystemsInternal`: (default: `InfrastructureSystemsInternal()`) (**Do not modify.**) PowerSystemsInvestmentsPortfolios.jl internal reference
- `ext::Dict`: (default: `Dict()`) Optional dictionary to provide additional data
"""
mutable struct RetrofitPotential <: IS.SupplementalAttribute
    "Capacity of the option technology obtained per unit of source capacity retrofitted (MW/MW), e.g. below 1 when a retrofit derates the plant"
    retrofit_efficiency::Float64
    "Names of the existing generation units of the source technology that can be retrofitted into the option technology"
    eligible_generators::Vector{String}
    "(**Do not modify.**) PowerSystemsInvestmentsPortfolios.jl internal reference"
    internal::InfrastructureSystemsInternal
    "Optional dictionary to provide additional data"
    ext::Dict
end


function RetrofitPotential(; retrofit_efficiency=1.0, eligible_generators=Vector(), internal=InfrastructureSystemsInternal(), ext=Dict(), )
    RetrofitPotential(retrofit_efficiency, eligible_generators, internal, ext, )
end

# Constructor for demo purposes; non-functional.
function RetrofitPotential(::Nothing)
    RetrofitPotential(;
        retrofit_efficiency=Dict(),
        eligible_generators=Dict(),
        internal=Dict(),
        ext=Dict(),
    )
end

"""Get [`RetrofitPotential`](@ref) `retrofit_efficiency`."""
get_retrofit_efficiency(value::RetrofitPotential) = value.retrofit_efficiency
"""Get [`RetrofitPotential`](@ref) `eligible_generators`."""
get_eligible_generators(value::RetrofitPotential) = value.eligible_generators
"""Get [`RetrofitPotential`](@ref) `internal`."""
get_internal(value::RetrofitPotential) = value.internal
"""Get [`RetrofitPotential`](@ref) `ext`."""
get_ext(value::RetrofitPotential) = value.ext

"""Set [`RetrofitPotential`](@ref) `retrofit_efficiency`."""
set_retrofit_efficiency!(value::RetrofitPotential, val) = value.retrofit_efficiency = val
"""Set [`RetrofitPotential`](@ref) `eligible_generators`."""
set_eligible_generators!(value::RetrofitPotential, val) = value.eligible_generators = val
"""Set [`RetrofitPotential`](@ref) `internal`."""
set_internal!(value::RetrofitPotential, val) = value.internal = val
"""Set [`RetrofitPotential`](@ref) `ext`."""
set_ext!(value::RetrofitPotential, val) = value.ext = val

function serialize_openapi_struct(technology::RetrofitPotential, vals...)
    base_struct = APIServer.RetrofitPotential(; vals...)
    return base_struct
end

function deserialize_openapi_struct(::Type{<:RetrofitPotential}, vals::Dict)
    return IS.deserialize_struct(APIServer.RetrofitPotential, vals)
end
