#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct EnergyShareRequirements <: Requirement
        name::String
        available::Bool
        target_year::Int64
        generation_fraction_requirement::Float64
        ext::Dict
        internal::InfrastructureSystemsInternal
    end

Policy requirement that the total generation of `eligible_technologies` must be greater than or equal to a pre-determined fraction of the total demand in eligible zones, such that `sum(P)_eligible_technologies >= total_fraction * sum(D)_eligible_regions`

# Arguments
- `name::String`: The policy name
- `available::Bool`: Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`)
- `target_year::Int64`: (default: `2050`) Year in which the energy share requirement will be applied
- `generation_fraction_requirement::Float64`: (default: `0.0`) Fraction of total annual demand across all eligible zones that needs to be met by eligible resources.
- `ext::Dict`: (default: `Dict()`) Optional dictionary to provide additional data
- `internal::InfrastructureSystemsInternal`: (default: `InfrastructureSystemsInternal()`) (**Do not modify.**) PowerSystemsInvestmentsPortfolios.jl internal reference
"""
mutable struct EnergyShareRequirements <: Requirement
    "The policy name"
    name::String
    "Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`)"
    available::Bool
    "Year in which the energy share requirement will be applied"
    target_year::Int64
    "Fraction of total annual demand across all eligible zones that needs to be met by eligible resources."
    generation_fraction_requirement::Float64
    "Optional dictionary to provide additional data"
    ext::Dict
    "(**Do not modify.**) PowerSystemsInvestmentsPortfolios.jl internal reference"
    internal::InfrastructureSystemsInternal
end


function EnergyShareRequirements(; name, available, target_year=2050, generation_fraction_requirement=0.0, ext=Dict(), internal=InfrastructureSystemsInternal(), )
    EnergyShareRequirements(name, available, target_year, generation_fraction_requirement, ext, internal, )
end

"""Get [`EnergyShareRequirements`](@ref) `name`."""
get_name(value::EnergyShareRequirements) = value.name
"""Get [`EnergyShareRequirements`](@ref) `available`."""
get_available(value::EnergyShareRequirements) = value.available
"""Get [`EnergyShareRequirements`](@ref) `target_year`."""
get_target_year(value::EnergyShareRequirements) = value.target_year
"""Get [`EnergyShareRequirements`](@ref) `generation_fraction_requirement`."""
get_generation_fraction_requirement(value::EnergyShareRequirements) = value.generation_fraction_requirement
"""Get [`EnergyShareRequirements`](@ref) `ext`."""
get_ext(value::EnergyShareRequirements) = value.ext
"""Get [`EnergyShareRequirements`](@ref) `internal`."""
get_internal(value::EnergyShareRequirements) = value.internal

"""Set [`EnergyShareRequirements`](@ref) `name`."""
set_name!(value::EnergyShareRequirements, val) = value.name = val
"""Set [`EnergyShareRequirements`](@ref) `available`."""
set_available!(value::EnergyShareRequirements, val) = value.available = val
"""Set [`EnergyShareRequirements`](@ref) `target_year`."""
set_target_year!(value::EnergyShareRequirements, val) = value.target_year = val
"""Set [`EnergyShareRequirements`](@ref) `generation_fraction_requirement`."""
set_generation_fraction_requirement!(value::EnergyShareRequirements, val) = value.generation_fraction_requirement = val
"""Set [`EnergyShareRequirements`](@ref) `ext`."""
set_ext!(value::EnergyShareRequirements, val) = value.ext = val
"""Set [`EnergyShareRequirements`](@ref) `internal`."""
set_internal!(value::EnergyShareRequirements, val) = value.internal = val



function from_openapi(po::PI.EnergyShareRequirements, refs::OpenAPIRefs)
    return EnergyShareRequirements(;
        name = po.name,
        available = po.available,
        target_year = _or_default(po.target_year, 2050),
        generation_fraction_requirement = _or_default(po.generation_fraction_requirement, 0.0),
    )
end

function to_openapi(value::EnergyShareRequirements, refs::OpenAPIRefs)
    return PI.EnergyShareRequirements(;
        id = get_id(value),
        name = get_name(value),
        available = get_available(value),
        target_year = get_target_year(value),
        generation_fraction_requirement = get_generation_fraction_requirement(value),
    )
end
