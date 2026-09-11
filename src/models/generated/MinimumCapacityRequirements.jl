#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct MinimumCapacityRequirements <: Requirement
        name::String
        available::Bool
        min_capacity_mw::Float64
        target_year::Int64
        ext::Dict
        internal::InfrastructureSystemsInternal
    end

Policy requirement that the total capacity of all technologies in `eligible_technologies` in the target year is greater than or equal to the specific minimum in MW

# Arguments
- `name::String`: The requirement name
- `available::Bool`: Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`)
- `min_capacity_mw::Float64`: (default: `0.0`) Minimum total capacity across all eligible resources (MW)
- `target_year::Int64`: (default: `2050`) Year in which the capacity requirement will be applied
- `ext::Dict`: (default: `Dict()`) Optional dictionary to provide additional data
- `internal::InfrastructureSystemsInternal`: (default: `InfrastructureSystemsInternal()`) (**Do not modify.**) PowerSystemsInvestmentsPortfolios.jl internal reference
"""
mutable struct MinimumCapacityRequirements <: Requirement
    "The requirement name"
    name::String
    "Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`)"
    available::Bool
    "Minimum total capacity across all eligible resources (MW)"
    min_capacity_mw::Float64
    "Year in which the capacity requirement will be applied"
    target_year::Int64
    "Optional dictionary to provide additional data"
    ext::Dict
    "(**Do not modify.**) PowerSystemsInvestmentsPortfolios.jl internal reference"
    internal::InfrastructureSystemsInternal
end


function MinimumCapacityRequirements(; name, available, min_capacity_mw=0.0, target_year=2050, ext=Dict(), internal=InfrastructureSystemsInternal(), )
    MinimumCapacityRequirements(name, available, min_capacity_mw, target_year, ext, internal, )
end

"""Get [`MinimumCapacityRequirements`](@ref) `name`."""
get_name(value::MinimumCapacityRequirements) = value.name
"""Get [`MinimumCapacityRequirements`](@ref) `available`."""
get_available(value::MinimumCapacityRequirements) = value.available
"""Get [`MinimumCapacityRequirements`](@ref) `min_capacity_mw` as a bare number in the requested `units` (e.g. `SU`, `CU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_min_capacity_mw_unitful`](@ref)."""
get_min_capacity_mw(value::MinimumCapacityRequirements, units) = InfrastructureSystems._strip_units(get_value(value, Val(:min_capacity_mw), Val(:mw), units))
"""Get [`MinimumCapacityRequirements`](@ref) `min_capacity_mw` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `CU`, `MW`). For a bare number see [`get_min_capacity_mw`](@ref)."""
get_min_capacity_mw_unitful(value::MinimumCapacityRequirements, units) = get_value(value, Val(:min_capacity_mw), Val(:mw), units)
InfrastructureSystems.display_units_arg(::typeof(get_min_capacity_mw), ::Type{MinimumCapacityRequirements}) = InfrastructureSystems.NU
InfrastructureSystems.display_units_arg(::typeof(get_min_capacity_mw_unitful), ::Type{MinimumCapacityRequirements}) = InfrastructureSystems.NU
"""Get [`MinimumCapacityRequirements`](@ref) `target_year`."""
get_target_year(value::MinimumCapacityRequirements) = value.target_year
"""Get [`MinimumCapacityRequirements`](@ref) `ext`."""
get_ext(value::MinimumCapacityRequirements) = value.ext
"""Get [`MinimumCapacityRequirements`](@ref) `internal`."""
get_internal(value::MinimumCapacityRequirements) = value.internal

"""Set [`MinimumCapacityRequirements`](@ref) `name`."""
set_name!(value::MinimumCapacityRequirements, val) = value.name = val
"""Set [`MinimumCapacityRequirements`](@ref) `available`."""
set_available!(value::MinimumCapacityRequirements, val) = value.available = val
"""Set [`MinimumCapacityRequirements`](@ref) `min_capacity_mw`."""
set_min_capacity_mw!(value::MinimumCapacityRequirements, val, unit) = value.min_capacity_mw = set_value(value, Val(:min_capacity_mw), val, unit, Val(:mw))
"""Set [`MinimumCapacityRequirements`](@ref) `target_year`."""
set_target_year!(value::MinimumCapacityRequirements, val) = value.target_year = val
"""Set [`MinimumCapacityRequirements`](@ref) `ext`."""
set_ext!(value::MinimumCapacityRequirements, val) = value.ext = val
"""Set [`MinimumCapacityRequirements`](@ref) `internal`."""
set_internal!(value::MinimumCapacityRequirements, val) = value.internal = val



function from_openapi(po::PI.MinimumCapacityRequirements, refs::OpenAPIRefs)
    return MinimumCapacityRequirements(;
        name = po.name,
        available = po.available,
        min_capacity_mw = po.min_capacity_mw,
        target_year = po.target_year,
    )
end

function to_openapi(value::MinimumCapacityRequirements, refs::OpenAPIRefs)
    return PI.MinimumCapacityRequirements(;
        id = get_id(value),
        name = get_name(value),
        available = get_available(value),
        min_capacity_mw = get_min_capacity_mw(value, IS.NU),
        target_year = get_target_year(value),
    )
end
