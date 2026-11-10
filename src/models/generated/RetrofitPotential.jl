#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct RetrofitPotential <: IS.SupplementalAttribute
        eligible_generators::Vector{String}
        retrofit_efficiency::Float64
        retrofit_cost::PSY.ValueCurve
        ext::Dict
        internal::InfrastructureSystemsInternal
    end

Supplemental attribute linking a retrofit: existing generators of a source SupplyTechnology that can be converted into a retrofit option SupplyTechnology. Attach the same attribute to both the source and the option, one attribute per source and option pair.

# Arguments
- `eligible_generators::Vector{String}`: Names of the existing generation units of the source technology that can be retrofitted into the option technology
- `retrofit_efficiency::Float64`: (default: `1.0`) Capacity of the option technology obtained per unit of source capacity retrofitted (MW/MW), e.g. below 1 when a retrofit derates the plant
- `retrofit_cost::PSY.ValueCurve`: (default: `LinearCurve(0.0)`) Cost associated with retrofitting the eligible generators. (USD/MW)
- `ext::Dict`: (default: `Dict()`) Optional dictionary to provide additional data
- `internal::InfrastructureSystemsInternal`: (default: `InfrastructureSystemsInternal()`) (**Do not modify.**) PowerSystemsInvestmentsPortfolios.jl internal reference
"""
mutable struct RetrofitPotential <: IS.SupplementalAttribute
    "Names of the existing generation units of the source technology that can be retrofitted into the option technology"
    eligible_generators::Vector{String}
    "Capacity of the option technology obtained per unit of source capacity retrofitted (MW/MW), e.g. below 1 when a retrofit derates the plant"
    retrofit_efficiency::Float64
    "Cost associated with retrofitting the eligible generators. (USD/MW)"
    retrofit_cost::PSY.ValueCurve
    "Optional dictionary to provide additional data"
    ext::Dict
    "(**Do not modify.**) PowerSystemsInvestmentsPortfolios.jl internal reference"
    internal::InfrastructureSystemsInternal
end


function RetrofitPotential(; eligible_generators, retrofit_efficiency=1.0, retrofit_cost=LinearCurve(0.0), ext=Dict(), internal=InfrastructureSystemsInternal(), )
    RetrofitPotential(eligible_generators, retrofit_efficiency, retrofit_cost, ext, internal, )
end

"""Get [`RetrofitPotential`](@ref) `eligible_generators`."""
get_eligible_generators(value::RetrofitPotential) = value.eligible_generators
"""Get [`RetrofitPotential`](@ref) `retrofit_efficiency`."""
get_retrofit_efficiency(value::RetrofitPotential) = value.retrofit_efficiency
"""Get [`RetrofitPotential`](@ref) `retrofit_cost` as a bare number in the requested `units` (e.g. domain-provided units such as `MW`). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_retrofit_cost_unitful`](@ref)."""
get_retrofit_cost(value::RetrofitPotential, units) = InfrastructureSystems._strip_units(get_value(value, Val(:retrofit_cost), Val(:usd_per_mw), units))
"""Get [`RetrofitPotential`](@ref) `retrofit_cost` as a unit-bearing quantity in the requested `units` (e.g. `MW`). For a bare number see [`get_retrofit_cost`](@ref)."""
get_retrofit_cost_unitful(value::RetrofitPotential, units) = get_value(value, Val(:retrofit_cost), Val(:usd_per_mw), units)
get_retrofit_cost(value::RetrofitPotential) = _units_arg_required(get_retrofit_cost, Val(:usd_per_mw))
InfrastructureSystems.display_units_arg(::typeof(get_retrofit_cost), ::Type{RetrofitPotential}) = u"NU"
InfrastructureSystems.display_units_arg(::typeof(get_retrofit_cost_unitful), ::Type{RetrofitPotential}) = u"NU"
"""Get [`RetrofitPotential`](@ref) `ext`."""
get_ext(value::RetrofitPotential) = value.ext
"""Get [`RetrofitPotential`](@ref) `internal`."""
get_internal(value::RetrofitPotential) = value.internal

"""Set [`RetrofitPotential`](@ref) `eligible_generators`."""
set_eligible_generators!(value::RetrofitPotential, val) = value.eligible_generators = val
"""Set [`RetrofitPotential`](@ref) `retrofit_efficiency`."""
set_retrofit_efficiency!(value::RetrofitPotential, val) = value.retrofit_efficiency = val
"""Set [`RetrofitPotential`](@ref) `retrofit_cost` from a units-tagged value (e.g. `100.0u"MW"`); a curve is given in natural units."""
set_retrofit_cost!(value::RetrofitPotential, val) = value.retrofit_cost = set_value(value, Val(:retrofit_cost), val, Val(:usd_per_mw))
"""Set [`RetrofitPotential`](@ref) `ext`."""
set_ext!(value::RetrofitPotential, val) = value.ext = val
"""Set [`RetrofitPotential`](@ref) `internal`."""
set_internal!(value::RetrofitPotential, val) = value.internal = val



function from_openapi(po::PI.RetrofitPotential, refs::OpenAPIRefs)
    return RetrofitPotential(;
        eligible_generators = po.eligible_generators,
        retrofit_efficiency = _or_default(po.retrofit_efficiency, 1.0),
        retrofit_cost = _or_default(_value_curve_optional(po.retrofit_cost), LinearCurve(0.0)),
    )
end

function to_openapi(value::RetrofitPotential, refs::OpenAPIRefs)
    return PI.RetrofitPotential(;
        id = get_id(value),
        eligible_generators = get_eligible_generators(value),
        retrofit_efficiency = get_retrofit_efficiency(value),
        retrofit_cost = _curve_to_openapi(PI.RetrofitPotentialRetrofitCost, get_retrofit_cost(value, u"NU")),
    )
end
