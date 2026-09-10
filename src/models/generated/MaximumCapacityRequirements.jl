#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct MaximumCapacityRequirements <: Requirement
        name::String
        available::Bool
        max_capacity_mw::Float64
        target_year::Int64
        ext::Dict
        internal::InfrastructureSystemsInternal
    end

Policy requirement that the total capacity of all technologies in `eligible_resources` in the target year is less than the specified limit in MW

# Arguments
- `name::String`: The technology name
- `available::Bool`: Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`)
- `max_capacity_mw::Float64`: (default: `0.0`) Maximum total capacity across all eligible resources (MW)
- `target_year::Int64`: (default: `2050`) Year in which the capacity requirement will be applied
- `ext::Dict`: (default: `Dict()`) Optional dictionary to provide additional data
- `internal::InfrastructureSystemsInternal`: (default: `InfrastructureSystemsInternal()`) (**Do not modify.**) PowerSystemsInvestmentsPortfolios.jl internal reference
"""
mutable struct MaximumCapacityRequirements <: Requirement
    "The technology name"
    name::String
    "Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`)"
    available::Bool
    "Maximum total capacity across all eligible resources (MW)"
    max_capacity_mw::Float64
    "Year in which the capacity requirement will be applied"
    target_year::Int64
    "Optional dictionary to provide additional data"
    ext::Dict
    "(**Do not modify.**) PowerSystemsInvestmentsPortfolios.jl internal reference"
    internal::InfrastructureSystemsInternal
end


function MaximumCapacityRequirements(; name, available, max_capacity_mw=0.0, target_year=2050, ext=Dict(), internal=InfrastructureSystemsInternal(), )
    MaximumCapacityRequirements(name, available, max_capacity_mw, target_year, ext, internal, )
end

"""Get [`MaximumCapacityRequirements`](@ref) `name`."""
get_name(value::MaximumCapacityRequirements) = value.name
"""Get [`MaximumCapacityRequirements`](@ref) `available`."""
get_available(value::MaximumCapacityRequirements) = value.available
"""Get [`MaximumCapacityRequirements`](@ref) `max_capacity_mw` as a bare number in the requested `units` (e.g. `SU`, `CU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_max_capacity_mw_unitful`](@ref)."""
get_max_capacity_mw(value::MaximumCapacityRequirements, units) = InfrastructureSystems._strip_units(get_value(value, Val(:max_capacity_mw), Val(:mw), units))
"""Get [`MaximumCapacityRequirements`](@ref) `max_capacity_mw` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `CU`, `MW`). For a bare number see [`get_max_capacity_mw`](@ref)."""
get_max_capacity_mw_unitful(value::MaximumCapacityRequirements, units) = get_value(value, Val(:max_capacity_mw), Val(:mw), units)
InfrastructureSystems.display_units_arg(::typeof(get_max_capacity_mw), ::Type{MaximumCapacityRequirements}) = InfrastructureSystems.NU
InfrastructureSystems.display_units_arg(::typeof(get_max_capacity_mw_unitful), ::Type{MaximumCapacityRequirements}) = InfrastructureSystems.NU
"""Get [`MaximumCapacityRequirements`](@ref) `target_year`."""
get_target_year(value::MaximumCapacityRequirements) = value.target_year
"""Get [`MaximumCapacityRequirements`](@ref) `ext`."""
get_ext(value::MaximumCapacityRequirements) = value.ext
"""Get [`MaximumCapacityRequirements`](@ref) `internal`."""
get_internal(value::MaximumCapacityRequirements) = value.internal

"""Set [`MaximumCapacityRequirements`](@ref) `name`."""
set_name!(value::MaximumCapacityRequirements, val) = value.name = val
"""Set [`MaximumCapacityRequirements`](@ref) `available`."""
set_available!(value::MaximumCapacityRequirements, val) = value.available = val
"""Set [`MaximumCapacityRequirements`](@ref) `max_capacity_mw`."""
set_max_capacity_mw!(value::MaximumCapacityRequirements, val, unit) = value.max_capacity_mw = set_value(value, Val(:max_capacity_mw), val, unit, Val(:mw))
"""Set [`MaximumCapacityRequirements`](@ref) `target_year`."""
set_target_year!(value::MaximumCapacityRequirements, val) = value.target_year = val
"""Set [`MaximumCapacityRequirements`](@ref) `ext`."""
set_ext!(value::MaximumCapacityRequirements, val) = value.ext = val
"""Set [`MaximumCapacityRequirements`](@ref) `internal`."""
set_internal!(value::MaximumCapacityRequirements, val) = value.internal = val



function from_openapi(po::PI.MaximumCapacityRequirements, refs::OpenAPIRefs)
    return MaximumCapacityRequirements(;
        name = po.name,
        available = po.available,
        max_capacity_mw = po.max_capacity_mw,
        target_year = po.target_year,
    )
end

function to_openapi(value::MaximumCapacityRequirements, refs::OpenAPIRefs)
    return PI.MaximumCapacityRequirements(;
        id = get_id(value),
        name = get_name(value),
        available = get_available(value),
        max_capacity_mw = get_max_capacity_mw(value, IS.NU),
        target_year = get_target_year(value),
    )
end
