#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct AggregateTransportTechnology{T <: PSY.Device} <: TransmissionTechnology
        name::String
        available::Bool
        power_systems_type::String
        start_region::RegionTopology
        end_region::RegionTopology
        capacity_limits::MinMax
        unit_size::Float64
        capital_costs::PSY.ValueCurve
        line_loss::Float64
        requirements::Vector{Requirement}
        financial_data::TechnologyFinancialData
        ext::Dict
        internal::InfrastructureSystemsInternal
    end

An aggregated representation of a transmission interchange between two regions.

# Arguments
- `name::String`: Name
- `available::Bool`: Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`)
- `power_systems_type::String`: Corresponding type in PowerSystems.jl to be used in PCM modeling
- `start_region::RegionTopology`: Start region for transport technology
- `end_region::RegionTopology`: End region for transport technology
- `capacity_limits::MinMax`: (default: `(min=0, max=1e8)`) Allowable capacity for a transmission line (MW)
- `unit_size::Float64`: (default: `1`) Used for integer investment decisions. Represents the rating capacity of individual new lines (MW)
- `capital_costs::PSY.ValueCurve`: (default: `LinearCurve(0.0)`) Cost of adding new capacity to the nodal transmission line. (USD/MW)
- `line_loss::Float64`: (default: `0.0`) Transmission loss for each transport technology (%)
- `requirements::Vector{Requirement}`: (default: `Vector()`) List of requirements (i.e. reserve margin, capacity requirements, energy share requirements) that are associated with a technology
- `financial_data::TechnologyFinancialData`: Struct containing relevant financial information for a technology
- `ext::Dict`: (default: `Dict()`) Optional dictionary to provide additional data
- `internal::InfrastructureSystemsInternal`: (default: `InfrastructureSystemsInternal()`) (**Do not modify.**) PowerSystemsInvestmentsPortfolios.jl internal reference
"""
mutable struct AggregateTransportTechnology{T <: PSY.Device} <: TransmissionTechnology
    "Name"
    name::String
    "Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`)"
    available::Bool
    "Corresponding type in PowerSystems.jl to be used in PCM modeling"
    power_systems_type::String
    "Start region for transport technology"
    start_region::RegionTopology
    "End region for transport technology"
    end_region::RegionTopology
    "Allowable capacity for a transmission line (MW)"
    capacity_limits::MinMax
    "Used for integer investment decisions. Represents the rating capacity of individual new lines (MW)"
    unit_size::Float64
    "Cost of adding new capacity to the nodal transmission line. (USD/MW)"
    capital_costs::PSY.ValueCurve
    "Transmission loss for each transport technology (%)"
    line_loss::Float64
    "List of requirements (i.e. reserve margin, capacity requirements, energy share requirements) that are associated with a technology"
    requirements::Vector{Requirement}
    "Struct containing relevant financial information for a technology"
    financial_data::TechnologyFinancialData
    "Optional dictionary to provide additional data"
    ext::Dict
    "(**Do not modify.**) PowerSystemsInvestmentsPortfolios.jl internal reference"
    internal::InfrastructureSystemsInternal
end


function AggregateTransportTechnology{T}(; name, available, power_systems_type, start_region, end_region, capacity_limits=(min=0, max=1e8), unit_size=1, capital_costs=LinearCurve(0.0), line_loss=0.0, requirements=Vector(), financial_data, ext=Dict(), internal=InfrastructureSystemsInternal(), ) where T <: PSY.Device
    AggregateTransportTechnology{T}(name, available, power_systems_type, start_region, end_region, capacity_limits, unit_size, capital_costs, line_loss, requirements, financial_data, ext, internal, )
end

"""Get [`AggregateTransportTechnology`](@ref) `name`."""
get_name(value::AggregateTransportTechnology) = value.name
"""Get [`AggregateTransportTechnology`](@ref) `available`."""
get_available(value::AggregateTransportTechnology) = value.available
"""Get [`AggregateTransportTechnology`](@ref) `power_systems_type`."""
get_power_systems_type(value::AggregateTransportTechnology) = value.power_systems_type
"""Get [`AggregateTransportTechnology`](@ref) `start_region`."""
get_start_region(value::AggregateTransportTechnology) = value.start_region
"""Get [`AggregateTransportTechnology`](@ref) `end_region`."""
get_end_region(value::AggregateTransportTechnology) = value.end_region
"""Get [`AggregateTransportTechnology`](@ref) `capacity_limits` as a bare number in the requested `units` (e.g. `SU`, `CU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_capacity_limits_unitful`](@ref)."""
get_capacity_limits(value::AggregateTransportTechnology, units) = InfrastructureSystems._strip_units(get_value(value, Val(:capacity_limits), Val(:mw), units))
"""Get [`AggregateTransportTechnology`](@ref) `capacity_limits` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `CU`, `MW`). For a bare number see [`get_capacity_limits`](@ref)."""
get_capacity_limits_unitful(value::AggregateTransportTechnology, units) = get_value(value, Val(:capacity_limits), Val(:mw), units)
InfrastructureSystems.display_units_arg(::typeof(get_capacity_limits), ::Type{AggregateTransportTechnology{T}}) where {T <: PSY.Device} = InfrastructureSystems.NU
InfrastructureSystems.display_units_arg(::typeof(get_capacity_limits_unitful), ::Type{AggregateTransportTechnology{T}}) where {T <: PSY.Device} = InfrastructureSystems.NU
"""Get [`AggregateTransportTechnology`](@ref) `unit_size` as a bare number in the requested `units` (e.g. `SU`, `CU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_unit_size_unitful`](@ref)."""
get_unit_size(value::AggregateTransportTechnology, units) = InfrastructureSystems._strip_units(get_value(value, Val(:unit_size), Val(:mw), units))
"""Get [`AggregateTransportTechnology`](@ref) `unit_size` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `CU`, `MW`). For a bare number see [`get_unit_size`](@ref)."""
get_unit_size_unitful(value::AggregateTransportTechnology, units) = get_value(value, Val(:unit_size), Val(:mw), units)
InfrastructureSystems.display_units_arg(::typeof(get_unit_size), ::Type{AggregateTransportTechnology{T}}) where {T <: PSY.Device} = InfrastructureSystems.NU
InfrastructureSystems.display_units_arg(::typeof(get_unit_size_unitful), ::Type{AggregateTransportTechnology{T}}) where {T <: PSY.Device} = InfrastructureSystems.NU
"""Get [`AggregateTransportTechnology`](@ref) `capital_costs` as a bare number in the requested `units` (e.g. `SU`, `CU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_capital_costs_unitful`](@ref)."""
get_capital_costs(value::AggregateTransportTechnology, units) = InfrastructureSystems._strip_units(get_value(value, Val(:capital_costs), Val(:usd_per_mw), units))
"""Get [`AggregateTransportTechnology`](@ref) `capital_costs` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `CU`, `MW`). For a bare number see [`get_capital_costs`](@ref)."""
get_capital_costs_unitful(value::AggregateTransportTechnology, units) = get_value(value, Val(:capital_costs), Val(:usd_per_mw), units)
InfrastructureSystems.display_units_arg(::typeof(get_capital_costs), ::Type{AggregateTransportTechnology{T}}) where {T <: PSY.Device} = InfrastructureSystems.NU
InfrastructureSystems.display_units_arg(::typeof(get_capital_costs_unitful), ::Type{AggregateTransportTechnology{T}}) where {T <: PSY.Device} = InfrastructureSystems.NU
"""Get [`AggregateTransportTechnology`](@ref) `line_loss`."""
get_line_loss(value::AggregateTransportTechnology) = value.line_loss
"""Get [`AggregateTransportTechnology`](@ref) `requirements`."""
get_requirements(value::AggregateTransportTechnology) = value.requirements
"""Get [`AggregateTransportTechnology`](@ref) `financial_data`."""
get_financial_data(value::AggregateTransportTechnology) = value.financial_data
"""Get [`AggregateTransportTechnology`](@ref) `ext`."""
get_ext(value::AggregateTransportTechnology) = value.ext
"""Get [`AggregateTransportTechnology`](@ref) `internal`."""
get_internal(value::AggregateTransportTechnology) = value.internal

"""Set [`AggregateTransportTechnology`](@ref) `name`."""
set_name!(value::AggregateTransportTechnology, val) = value.name = val
"""Set [`AggregateTransportTechnology`](@ref) `available`."""
set_available!(value::AggregateTransportTechnology, val) = value.available = val
"""Set [`AggregateTransportTechnology`](@ref) `power_systems_type`."""
set_power_systems_type!(value::AggregateTransportTechnology, val) = value.power_systems_type = val
"""Set [`AggregateTransportTechnology`](@ref) `start_region`."""
set_start_region!(value::AggregateTransportTechnology, val) = value.start_region = val
"""Set [`AggregateTransportTechnology`](@ref) `end_region`."""
set_end_region!(value::AggregateTransportTechnology, val) = value.end_region = val
"""Set [`AggregateTransportTechnology`](@ref) `capacity_limits`."""
set_capacity_limits!(value::AggregateTransportTechnology, val, unit) = value.capacity_limits = set_value(value, Val(:capacity_limits), val, unit, Val(:mw))
"""Set [`AggregateTransportTechnology`](@ref) `unit_size`."""
set_unit_size!(value::AggregateTransportTechnology, val, unit) = value.unit_size = set_value(value, Val(:unit_size), val, unit, Val(:mw))
"""Set [`AggregateTransportTechnology`](@ref) `capital_costs`."""
set_capital_costs!(value::AggregateTransportTechnology, val, unit) = value.capital_costs = set_value(value, Val(:capital_costs), val, unit, Val(:usd_per_mw))
"""Set [`AggregateTransportTechnology`](@ref) `line_loss`."""
set_line_loss!(value::AggregateTransportTechnology, val) = value.line_loss = val
"""Set [`AggregateTransportTechnology`](@ref) `requirements`."""
set_requirements!(value::AggregateTransportTechnology, val) = value.requirements = val
"""Set [`AggregateTransportTechnology`](@ref) `financial_data`."""
set_financial_data!(value::AggregateTransportTechnology, val) = value.financial_data = val
"""Set [`AggregateTransportTechnology`](@ref) `ext`."""
set_ext!(value::AggregateTransportTechnology, val) = value.ext = val
"""Set [`AggregateTransportTechnology`](@ref) `internal`."""
set_internal!(value::AggregateTransportTechnology, val) = value.internal = val


function from_openapi(po::PI.AggregateTransportTechnology, refs::OpenAPIRefs)
    parameter = getproperty(PowerSystems, Symbol(po.power_systems_type))
    return AggregateTransportTechnology{parameter}(;
        name = po.name,
        available = po.available,
        power_systems_type = po.power_systems_type,
        start_region = resolve_ref(refs, po.start_region, RegionTopology),
        end_region = resolve_ref(refs, po.end_region, RegionTopology),
        capacity_limits = _minmax_from_po(po.capacity_limits),
        unit_size = po.unit_size,
        capital_costs = convert_value_curve(po.capital_costs),
        line_loss = po.line_loss,
        requirements = resolve_refs(refs, po.requirements, Requirement),
        financial_data = convert_nested_data(po.financial_data),
    )
end

function to_openapi(value::AggregateTransportTechnology{T}, refs::OpenAPIRefs) where {T <: PSY.Device}
    return PI.AggregateTransportTechnology(;
        id = get_id(value),
        name = get_name(value),
        available = get_available(value),
        power_systems_type = string(nameof(T)),
        start_region = component_id(refs, get_start_region(value)),
        end_region = component_id(refs, get_end_region(value)),
        capacity_limits = _minmax_po(get_capacity_limits(value, IS.NU)),
        unit_size = get_unit_size(value, IS.NU),
        capital_costs = convert_value_curve_to_openapi(get_capital_costs(value, IS.NU)),
        line_loss = get_line_loss(value),
        requirements = component_ids(refs, get_requirements(value)),
        financial_data = convert_nested_data_to_openapi(get_financial_data(value)),
    )
end
