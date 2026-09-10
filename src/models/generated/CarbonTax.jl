#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct CarbonTax <: Requirement
        name::String
        available::Bool
        target_year::Int64
        tax_dollars_per_ton::Float64
        ext::Dict
        internal::InfrastructureSystemsInternal
    end

Policy requirement that defines an additional cost penalty per ton of CO2 produced in the target in the eligible regions

# Arguments
- `name::String`: The requirement name
- `available::Bool`: Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`)
- `target_year::Int64`: (default: `2050`) Year in which carbon tax will be applied
- `tax_dollars_per_ton::Float64`: (default: `0.0`) Cost penalty per ton of CO2 emitted by technologies in the eligible regions during the target year (USD/tCO2)
- `ext::Dict`: (default: `Dict()`) Optional dictionary to provide additional data
- `internal::InfrastructureSystemsInternal`: (default: `InfrastructureSystemsInternal()`) (**Do not modify.**) PowerSystemsInvestmentsPortfolios.jl internal reference
"""
mutable struct CarbonTax <: Requirement
    "The requirement name"
    name::String
    "Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`)"
    available::Bool
    "Year in which carbon tax will be applied"
    target_year::Int64
    "Cost penalty per ton of CO2 emitted by technologies in the eligible regions during the target year (USD/tCO2)"
    tax_dollars_per_ton::Float64
    "Optional dictionary to provide additional data"
    ext::Dict
    "(**Do not modify.**) PowerSystemsInvestmentsPortfolios.jl internal reference"
    internal::InfrastructureSystemsInternal
end


function CarbonTax(; name, available, target_year=2050, tax_dollars_per_ton=0.0, ext=Dict(), internal=InfrastructureSystemsInternal(), )
    CarbonTax(name, available, target_year, tax_dollars_per_ton, ext, internal, )
end

"""Get [`CarbonTax`](@ref) `name`."""
get_name(value::CarbonTax) = value.name
"""Get [`CarbonTax`](@ref) `available`."""
get_available(value::CarbonTax) = value.available
"""Get [`CarbonTax`](@ref) `target_year`."""
get_target_year(value::CarbonTax) = value.target_year
"""Get [`CarbonTax`](@ref) `tax_dollars_per_ton` as a bare number in the requested `units` (e.g. `SU`, `CU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_tax_dollars_per_ton_unitful`](@ref)."""
get_tax_dollars_per_ton(value::CarbonTax, units) = InfrastructureSystems._strip_units(get_value(value, Val(:tax_dollars_per_ton), Val(:usd_per_t), units))
"""Get [`CarbonTax`](@ref) `tax_dollars_per_ton` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `CU`, `MW`). For a bare number see [`get_tax_dollars_per_ton`](@ref)."""
get_tax_dollars_per_ton_unitful(value::CarbonTax, units) = get_value(value, Val(:tax_dollars_per_ton), Val(:usd_per_t), units)
InfrastructureSystems.display_units_arg(::typeof(get_tax_dollars_per_ton), ::Type{CarbonTax}) = InfrastructureSystems.NU
InfrastructureSystems.display_units_arg(::typeof(get_tax_dollars_per_ton_unitful), ::Type{CarbonTax}) = InfrastructureSystems.NU
"""Get [`CarbonTax`](@ref) `ext`."""
get_ext(value::CarbonTax) = value.ext
"""Get [`CarbonTax`](@ref) `internal`."""
get_internal(value::CarbonTax) = value.internal

"""Set [`CarbonTax`](@ref) `name`."""
set_name!(value::CarbonTax, val) = value.name = val
"""Set [`CarbonTax`](@ref) `available`."""
set_available!(value::CarbonTax, val) = value.available = val
"""Set [`CarbonTax`](@ref) `target_year`."""
set_target_year!(value::CarbonTax, val) = value.target_year = val
"""Set [`CarbonTax`](@ref) `tax_dollars_per_ton`."""
set_tax_dollars_per_ton!(value::CarbonTax, val, unit) = value.tax_dollars_per_ton = set_value(value, Val(:tax_dollars_per_ton), val, unit, Val(:usd_per_t))
"""Set [`CarbonTax`](@ref) `ext`."""
set_ext!(value::CarbonTax, val) = value.ext = val
"""Set [`CarbonTax`](@ref) `internal`."""
set_internal!(value::CarbonTax, val) = value.internal = val



function from_openapi(po::PI.CarbonTax, refs::OpenAPIRefs)
    return CarbonTax(;
        name = po.name,
        available = po.available,
        target_year = po.target_year,
        tax_dollars_per_ton = po.tax_dollars_per_ton,
    )
end

function to_openapi(value::CarbonTax, refs::OpenAPIRefs)
    return PI.CarbonTax(;
        id = get_id(value),
        name = get_name(value),
        available = get_available(value),
        target_year = get_target_year(value),
        tax_dollars_per_ton = get_tax_dollars_per_ton(value, IS.NU),
    )
end
