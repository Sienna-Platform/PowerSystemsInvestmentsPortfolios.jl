#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct RetirementPotential <: IS.SupplementalAttribute
        eligible_generators::Vector{String}
        planned_retirement_year::Dict{String, Int64}
        build_year::Dict{String, Int64}
        retirement_cost::PSY.ValueCurve
        ext::Dict
        internal::InfrastructureSystemsInternal
    end

Supplemental attribute used to define what existing generators are eligible for retirement for a SupplyTechnology

# Arguments
- `eligible_generators::Vector{String}`: Names of individual generation units mapped to a technology that are eligible for retirement
- `planned_retirement_year::Dict{String, Int64}`: (default: `Dict{String, Int64}()`) Optional dictionary to indicate the year in which the forced/planned retirement will occur
- `build_year::Dict{String, Int64}`: (default: `Dict{String, Int64}()`) Optional dictionary to indicate the year in which existing generators in the base system were built
- `retirement_cost::PSY.ValueCurve`: Cost associated with retiring the eligible generators. (USD/MW)
- `ext::Dict`: (default: `Dict()`) Optional dictionary to provide additional data
- `internal::InfrastructureSystemsInternal`: (default: `InfrastructureSystemsInternal()`) (**Do not modify.**) PowerSystemsInvestmentsPortfolios.jl internal reference
"""
mutable struct RetirementPotential <: IS.SupplementalAttribute
    "Names of individual generation units mapped to a technology that are eligible for retirement"
    eligible_generators::Vector{String}
    "Optional dictionary to indicate the year in which the forced/planned retirement will occur"
    planned_retirement_year::Dict{String, Int64}
    "Optional dictionary to indicate the year in which existing generators in the base system were built"
    build_year::Dict{String, Int64}
    "Cost associated with retiring the eligible generators. (USD/MW)"
    retirement_cost::PSY.ValueCurve
    "Optional dictionary to provide additional data"
    ext::Dict
    "(**Do not modify.**) PowerSystemsInvestmentsPortfolios.jl internal reference"
    internal::InfrastructureSystemsInternal
end


function RetirementPotential(; eligible_generators, planned_retirement_year=Dict{String, Int64}(), build_year=Dict{String, Int64}(), retirement_cost, ext=Dict(), internal=InfrastructureSystemsInternal(), )
    RetirementPotential(eligible_generators, planned_retirement_year, build_year, retirement_cost, ext, internal, )
end

"""Get [`RetirementPotential`](@ref) `eligible_generators`."""
get_eligible_generators(value::RetirementPotential) = value.eligible_generators
"""Get [`RetirementPotential`](@ref) `planned_retirement_year`."""
get_planned_retirement_year(value::RetirementPotential) = value.planned_retirement_year
"""Get [`RetirementPotential`](@ref) `build_year`."""
get_build_year(value::RetirementPotential) = value.build_year
"""Get [`RetirementPotential`](@ref) `retirement_cost` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_retirement_cost_unitful`](@ref)."""
get_retirement_cost(value::RetirementPotential, units) = InfrastructureSystems._strip_units(get_value(value, Val(:retirement_cost), Val(:usd_per_mw), units))
"""Get [`RetirementPotential`](@ref) `retirement_cost` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_retirement_cost`](@ref)."""
get_retirement_cost_unitful(value::RetirementPotential, units) = get_value(value, Val(:retirement_cost), Val(:usd_per_mw), units)
InfrastructureSystems.display_units_arg(::typeof(get_retirement_cost), ::Type{RetirementPotential}) = InfrastructureSystems.NU
InfrastructureSystems.display_units_arg(::typeof(get_retirement_cost_unitful), ::Type{RetirementPotential}) = InfrastructureSystems.NU
"""Get [`RetirementPotential`](@ref) `ext`."""
get_ext(value::RetirementPotential) = value.ext
"""Get [`RetirementPotential`](@ref) `internal`."""
get_internal(value::RetirementPotential) = value.internal

"""Set [`RetirementPotential`](@ref) `eligible_generators`."""
set_eligible_generators!(value::RetirementPotential, val) = value.eligible_generators = val
"""Set [`RetirementPotential`](@ref) `planned_retirement_year`."""
set_planned_retirement_year!(value::RetirementPotential, val) = value.planned_retirement_year = val
"""Set [`RetirementPotential`](@ref) `build_year`."""
set_build_year!(value::RetirementPotential, val) = value.build_year = val
"""Set [`RetirementPotential`](@ref) `retirement_cost`."""
set_retirement_cost!(value::RetirementPotential, val, unit) = value.retirement_cost = set_value(value, Val(:retirement_cost), val, unit, Val(:usd_per_mw))
"""Set [`RetirementPotential`](@ref) `ext`."""
set_ext!(value::RetirementPotential, val) = value.ext = val
"""Set [`RetirementPotential`](@ref) `internal`."""
set_internal!(value::RetirementPotential, val) = value.internal = val



function from_openapi(po::PI.RetirementPotential, refs::OpenAPIRefs)
    return RetirementPotential(;
        eligible_generators = po.eligible_generators,
        planned_retirement_year = po.planned_retirement_year,
        build_year = po.build_year,
        retirement_cost = convert_value_curve(po.retirement_cost),
    )
end

function to_openapi(value::RetirementPotential, refs::OpenAPIRefs)
    return PI.RetirementPotential(;
        id = get_id(value),
        eligible_generators = get_eligible_generators(value),
        planned_retirement_year = get_planned_retirement_year(value),
        build_year = get_build_year(value),
        retirement_cost = convert_value_curve_to_openapi(get_retirement_cost(value, IS.NU)),
    )
end
