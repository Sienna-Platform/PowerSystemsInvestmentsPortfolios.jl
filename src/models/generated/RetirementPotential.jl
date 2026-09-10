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
- `eligible_generators::Vector{String}`: (default: `Vector()`) Names of individual generation units mapped to a technology that are eligible for retirement
- `planned_retirement_year::Dict{String, Int64}`: (default: `Dict{String, Int64}()`) Optional dictionary to indicate the year in which the forced/planned retirement will occur
- `build_year::Dict{String, Int64}`: (default: `Dict{String, Int64}()`) Optional dictionary to indicate the year in which existing generators in the base system were built
- `retirement_cost::PSY.ValueCurve`: (default: `LinearCurve(0.0)`) Cost associated with retiring the eligible generators, in USD/MW
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
    "Cost associated with retiring the eligible generators, in USD/MW"
    retirement_cost::PSY.ValueCurve
    "Optional dictionary to provide additional data"
    ext::Dict
    "(**Do not modify.**) PowerSystemsInvestmentsPortfolios.jl internal reference"
    internal::InfrastructureSystemsInternal
end


function RetirementPotential(; eligible_generators=Vector(), planned_retirement_year=Dict{String, Int64}(), build_year=Dict{String, Int64}(), retirement_cost=LinearCurve(0.0), ext=Dict(), internal=InfrastructureSystemsInternal(), )
    RetirementPotential(eligible_generators, planned_retirement_year, build_year, retirement_cost, ext, internal, )
end

# Constructor for demo purposes; non-functional.
function RetirementPotential(::Nothing)
    RetirementPotential(;
        eligible_generators=InfrastructureSystemsInternal(),
        planned_retirement_year=InfrastructureSystemsInternal(),
        build_year=InfrastructureSystemsInternal(),
        retirement_cost=InfrastructureSystemsInternal(),
        ext=InfrastructureSystemsInternal(),
        internal=InfrastructureSystemsInternal(),
    )
end

"""Get [`RetirementPotential`](@ref) `eligible_generators`."""
get_eligible_generators(value::RetirementPotential) = value.eligible_generators
"""Get [`RetirementPotential`](@ref) `planned_retirement_year`."""
get_planned_retirement_year(value::RetirementPotential) = value.planned_retirement_year
"""Get [`RetirementPotential`](@ref) `build_year`."""
get_build_year(value::RetirementPotential) = value.build_year
"""Get [`RetirementPotential`](@ref) `retirement_cost`."""
get_retirement_cost(value::RetirementPotential) = value.retirement_cost
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
set_retirement_cost!(value::RetirementPotential, val) = value.retirement_cost = val
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
        retirement_cost = convert_value_curve_to_openapi(get_retirement_cost(value)),
    )
end
