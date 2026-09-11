#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct RetrofitPotential <: IS.SupplementalAttribute
        eligible_generators::Vector{String}
        retrofit_fraction::Float64
        retrofit_cost::PSY.ValueCurve
        ext::Dict
        internal::InfrastructureSystemsInternal
    end

Supplemental attribute used to define what existing generators are eligible for retrofit for a SupplyTechnology

# Arguments
- `eligible_generators::Vector{String}`: (default: `Vector()`) Names of individual generation units mapped to this technology that can be retrofitted
- `retrofit_fraction::Float64`: (default: `1.0`) Fraction of existing capacity that is eligible for retrofits
- `retrofit_cost::PSY.ValueCurve`: (default: `PSY.LinearCurve(0.0)`) Cost associated with retrofitting the eligible generators. (USD/MW)
- `ext::Dict`: (default: `Dict()`) Optional dictionary to provide additional data
- `internal::InfrastructureSystemsInternal`: (default: `InfrastructureSystemsInternal()`) (**Do not modify.**) PowerSystemsInvestmentsPortfolios.jl internal reference
"""
mutable struct RetrofitPotential <: IS.SupplementalAttribute
    "Names of individual generation units mapped to this technology that can be retrofitted"
    eligible_generators::Vector{String}
    "Fraction of existing capacity that is eligible for retrofits"
    retrofit_fraction::Float64
    "Cost associated with retrofitting the eligible generators. (USD/MW)"
    retrofit_cost::PSY.ValueCurve
    "Optional dictionary to provide additional data"
    ext::Dict
    "(**Do not modify.**) PowerSystemsInvestmentsPortfolios.jl internal reference"
    internal::InfrastructureSystemsInternal
end


function RetrofitPotential(; eligible_generators=Vector(), retrofit_fraction=1.0, retrofit_cost=PSY.LinearCurve(0.0), ext=Dict(), internal=InfrastructureSystemsInternal(), )
    RetrofitPotential(eligible_generators, retrofit_fraction, retrofit_cost, ext, internal, )
end

# Constructor for demo purposes; non-functional.
function RetrofitPotential(::Nothing)
    RetrofitPotential(;
        eligible_generators=InfrastructureSystemsInternal(),
        retrofit_fraction=InfrastructureSystemsInternal(),
        retrofit_cost=InfrastructureSystemsInternal(),
        ext=InfrastructureSystemsInternal(),
        internal=InfrastructureSystemsInternal(),
    )
end

"""Get [`RetrofitPotential`](@ref) `eligible_generators`."""
get_eligible_generators(value::RetrofitPotential) = value.eligible_generators
"""Get [`RetrofitPotential`](@ref) `retrofit_fraction`."""
get_retrofit_fraction(value::RetrofitPotential) = value.retrofit_fraction
"""Get [`RetrofitPotential`](@ref) `retrofit_cost` as a bare number in the requested `units` (e.g. domain-provided units such as `MW`). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_retrofit_cost_unitful`](@ref)."""
get_retrofit_cost(value::RetrofitPotential, units) = InfrastructureSystems._strip_units(get_value(value, Val(:retrofit_cost), Val(:usd_per_mw), units))
"""Get [`RetrofitPotential`](@ref) `retrofit_cost` as a unit-bearing quantity in the requested `units` (e.g. `MW`). For a bare number see [`get_retrofit_cost`](@ref)."""
get_retrofit_cost_unitful(value::RetrofitPotential, units) = get_value(value, Val(:retrofit_cost), Val(:usd_per_mw), units)
InfrastructureSystems.display_units_arg(::typeof(get_retrofit_cost), ::Type{RetrofitPotential}) = InfrastructureSystems.NU
InfrastructureSystems.display_units_arg(::typeof(get_retrofit_cost_unitful), ::Type{RetrofitPotential}) = InfrastructureSystems.NU
"""Get [`RetrofitPotential`](@ref) `ext`."""
get_ext(value::RetrofitPotential) = value.ext
"""Get [`RetrofitPotential`](@ref) `internal`."""
get_internal(value::RetrofitPotential) = value.internal

"""Set [`RetrofitPotential`](@ref) `eligible_generators`."""
set_eligible_generators!(value::RetrofitPotential, val) = value.eligible_generators = val
"""Set [`RetrofitPotential`](@ref) `retrofit_fraction`."""
set_retrofit_fraction!(value::RetrofitPotential, val) = value.retrofit_fraction = val
"""Set [`RetrofitPotential`](@ref) `retrofit_cost`."""
set_retrofit_cost!(value::RetrofitPotential, val, unit) = value.retrofit_cost = set_value(value, Val(:retrofit_cost), val, unit, Val(:usd_per_mw))
"""Set [`RetrofitPotential`](@ref) `ext`."""
set_ext!(value::RetrofitPotential, val) = value.ext = val
"""Set [`RetrofitPotential`](@ref) `internal`."""
set_internal!(value::RetrofitPotential, val) = value.internal = val



function from_openapi(po::PI.RetrofitPotential, refs::OpenAPIRefs)
    return RetrofitPotential(;
        eligible_generators = po.eligible_generators,
        retrofit_fraction = po.retrofit_fraction,
        retrofit_cost = convert_value_curve(po.retrofit_cost),
    )
end

function to_openapi(value::RetrofitPotential, refs::OpenAPIRefs)
    return PI.RetrofitPotential(;
        id = get_id(value),
        eligible_generators = get_eligible_generators(value),
        retrofit_fraction = get_retrofit_fraction(value),
        retrofit_cost = convert_value_curve_to_openapi(get_retrofit_cost(value, IS.NU)),
    )
end
