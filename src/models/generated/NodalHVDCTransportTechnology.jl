#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct NodalHVDCTransportTechnology{T <: PSY.Device} <: TransmissionTechnology
        name::String
        available::Bool
        power_systems_type::String
        start_node::PSY.Bus
        end_node::PSY.Bus
        capacity_limits::MinMax
        unit_size::Float64
        capital_costs::CapitalCost
        line_loss::Union{IS.LinearCurve, IS.PiecewiseIncrementalCurve}
        requirements::Vector{Requirement}
        financial_data::TechnologyFinancialData
        ext::Dict
        internal::InfrastructureSystemsInternal
    end

A nodal representation of candidate HVDC transmission lines between two regions.

# Arguments
- `name::String`: Name
- `available::Bool`: Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`)
- `power_systems_type::String`: Corresponding type in PowerSystems.jl to be used in PCM modeling
- `start_node::PSY.Bus`: Start node for transport technology
- `end_node::PSY.Bus`: End node for transport technology
- `capacity_limits::MinMax`: (default: `(min=0, max=1e8)`) Allowable capacity for a transmission line (MW)
- `unit_size::Float64`: (default: `1`) Used for integer investment decisions. Represents the rating capacity of individual new lines (MW)
- `capital_costs::CapitalCost`: (default: `CapitalCost(nothing)`) Cost of adding new capacity to the nodal transmission line. (USD/MW)
- `line_loss::Union{IS.LinearCurve, IS.PiecewiseIncrementalCurve}`: (default: `LinearCurve(0.0)`) Loss model coefficients. It accepts a linear model with a constant loss and a proportional loss rate. All terms are defined as fraction of installed nameplate capacity It also accepts a Piecewise loss, with N segments to specify different proportional losses for different segments.
- `requirements::Vector{Requirement}`: (default: `Vector()`) List of requirements (i.e. reserve margin, capacity requirements, energy share requirements) that are associated with a technology
- `financial_data::TechnologyFinancialData`: Struct containing relevant financial information for a technology
- `ext::Dict`: (default: `Dict()`) Optional dictionary to provide additional data
- `internal::InfrastructureSystemsInternal`: (default: `InfrastructureSystemsInternal()`) (**Do not modify.**) PowerSystemsInvestmentsPortfolios.jl internal reference
"""
mutable struct NodalHVDCTransportTechnology{T <: PSY.Device} <: TransmissionTechnology
    "Name"
    name::String
    "Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`)"
    available::Bool
    "Corresponding type in PowerSystems.jl to be used in PCM modeling"
    power_systems_type::String
    "Start node for transport technology"
    start_node::PSY.Bus
    "End node for transport technology"
    end_node::PSY.Bus
    "Allowable capacity for a transmission line (MW)"
    capacity_limits::MinMax
    "Used for integer investment decisions. Represents the rating capacity of individual new lines (MW)"
    unit_size::Float64
    "Cost of adding new capacity to the nodal transmission line. (USD/MW)"
    capital_costs::CapitalCost
    "Loss model coefficients. It accepts a linear model with a constant loss and a proportional loss rate. All terms are defined as fraction of installed nameplate capacity It also accepts a Piecewise loss, with N segments to specify different proportional losses for different segments."
    line_loss::Union{IS.LinearCurve, IS.PiecewiseIncrementalCurve}
    "List of requirements (i.e. reserve margin, capacity requirements, energy share requirements) that are associated with a technology"
    requirements::Vector{Requirement}
    "Struct containing relevant financial information for a technology"
    financial_data::TechnologyFinancialData
    "Optional dictionary to provide additional data"
    ext::Dict
    "(**Do not modify.**) PowerSystemsInvestmentsPortfolios.jl internal reference"
    internal::InfrastructureSystemsInternal
end


function NodalHVDCTransportTechnology{T}(; name, available, power_systems_type, start_node, end_node, capacity_limits=(min=0, max=1e8), unit_size=1, capital_costs=CapitalCost(nothing), line_loss=LinearCurve(0.0), requirements=Vector(), financial_data, ext=Dict(), internal=InfrastructureSystemsInternal(), ) where T <: PSY.Device
    NodalHVDCTransportTechnology{T}(name, available, power_systems_type, start_node, end_node, capacity_limits, unit_size, capital_costs, line_loss, requirements, financial_data, ext, internal, )
end

"""Get [`NodalHVDCTransportTechnology`](@ref) `name`."""
get_name(value::NodalHVDCTransportTechnology) = value.name
"""Get [`NodalHVDCTransportTechnology`](@ref) `available`."""
get_available(value::NodalHVDCTransportTechnology) = value.available
"""Get [`NodalHVDCTransportTechnology`](@ref) `power_systems_type`."""
get_power_systems_type(value::NodalHVDCTransportTechnology) = value.power_systems_type
"""Get [`NodalHVDCTransportTechnology`](@ref) `start_node`."""
get_start_node(value::NodalHVDCTransportTechnology) = value.start_node
"""Get [`NodalHVDCTransportTechnology`](@ref) `end_node`."""
get_end_node(value::NodalHVDCTransportTechnology) = value.end_node
"""Get [`NodalHVDCTransportTechnology`](@ref) `capacity_limits` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_capacity_limits_unitful`](@ref)."""
get_capacity_limits(value::NodalHVDCTransportTechnology, units) = InfrastructureSystems._strip_units(get_value(value, Val(:capacity_limits), Val(:mw), units))
"""Get [`NodalHVDCTransportTechnology`](@ref) `capacity_limits` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_capacity_limits`](@ref)."""
get_capacity_limits_unitful(value::NodalHVDCTransportTechnology, units) = get_value(value, Val(:capacity_limits), Val(:mw), units)
InfrastructureSystems.display_units_arg(::typeof(get_capacity_limits), ::Type{NodalHVDCTransportTechnology{T}}) where {T <: PSY.Device} = InfrastructureSystems.NU
InfrastructureSystems.display_units_arg(::typeof(get_capacity_limits_unitful), ::Type{NodalHVDCTransportTechnology{T}}) where {T <: PSY.Device} = InfrastructureSystems.NU
"""Get [`NodalHVDCTransportTechnology`](@ref) `unit_size` as a bare number in the requested `units` (e.g. `SU`, `DU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`get_unit_size_unitful`](@ref)."""
get_unit_size(value::NodalHVDCTransportTechnology, units) = InfrastructureSystems._strip_units(get_value(value, Val(:unit_size), Val(:mw), units))
"""Get [`NodalHVDCTransportTechnology`](@ref) `unit_size` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `DU`, `MW`). For a bare number see [`get_unit_size`](@ref)."""
get_unit_size_unitful(value::NodalHVDCTransportTechnology, units) = get_value(value, Val(:unit_size), Val(:mw), units)
InfrastructureSystems.display_units_arg(::typeof(get_unit_size), ::Type{NodalHVDCTransportTechnology{T}}) where {T <: PSY.Device} = InfrastructureSystems.NU
InfrastructureSystems.display_units_arg(::typeof(get_unit_size_unitful), ::Type{NodalHVDCTransportTechnology{T}}) where {T <: PSY.Device} = InfrastructureSystems.NU
"""Get [`NodalHVDCTransportTechnology`](@ref) `capital_costs`."""
get_capital_costs(value::NodalHVDCTransportTechnology) = value.capital_costs
"""Get [`NodalHVDCTransportTechnology`](@ref) `line_loss`."""
get_line_loss(value::NodalHVDCTransportTechnology) = value.line_loss
"""Get [`NodalHVDCTransportTechnology`](@ref) `requirements`."""
get_requirements(value::NodalHVDCTransportTechnology) = value.requirements
"""Get [`NodalHVDCTransportTechnology`](@ref) `financial_data`."""
get_financial_data(value::NodalHVDCTransportTechnology) = value.financial_data
"""Get [`NodalHVDCTransportTechnology`](@ref) `ext`."""
get_ext(value::NodalHVDCTransportTechnology) = value.ext
"""Get [`NodalHVDCTransportTechnology`](@ref) `internal`."""
get_internal(value::NodalHVDCTransportTechnology) = value.internal

"""Set [`NodalHVDCTransportTechnology`](@ref) `name`."""
set_name!(value::NodalHVDCTransportTechnology, val) = value.name = val
"""Set [`NodalHVDCTransportTechnology`](@ref) `available`."""
set_available!(value::NodalHVDCTransportTechnology, val) = value.available = val
"""Set [`NodalHVDCTransportTechnology`](@ref) `power_systems_type`."""
set_power_systems_type!(value::NodalHVDCTransportTechnology, val) = value.power_systems_type = val
"""Set [`NodalHVDCTransportTechnology`](@ref) `start_node`."""
set_start_node!(value::NodalHVDCTransportTechnology, val) = value.start_node = val
"""Set [`NodalHVDCTransportTechnology`](@ref) `end_node`."""
set_end_node!(value::NodalHVDCTransportTechnology, val) = value.end_node = val
"""Set [`NodalHVDCTransportTechnology`](@ref) `capacity_limits`."""
set_capacity_limits!(value::NodalHVDCTransportTechnology, val, unit) = value.capacity_limits = set_value(value, Val(:capacity_limits), val, unit, Val(:mw))
"""Set [`NodalHVDCTransportTechnology`](@ref) `unit_size`."""
set_unit_size!(value::NodalHVDCTransportTechnology, val, unit) = value.unit_size = set_value(value, Val(:unit_size), val, unit, Val(:mw))
"""Set [`NodalHVDCTransportTechnology`](@ref) `capital_costs`."""
set_capital_costs!(value::NodalHVDCTransportTechnology, val) = value.capital_costs = val
"""Set [`NodalHVDCTransportTechnology`](@ref) `line_loss`."""
set_line_loss!(value::NodalHVDCTransportTechnology, val) = value.line_loss = val
"""Set [`NodalHVDCTransportTechnology`](@ref) `requirements`."""
set_requirements!(value::NodalHVDCTransportTechnology, val) = value.requirements = val
"""Set [`NodalHVDCTransportTechnology`](@ref) `financial_data`."""
set_financial_data!(value::NodalHVDCTransportTechnology, val) = value.financial_data = val
"""Set [`NodalHVDCTransportTechnology`](@ref) `ext`."""
set_ext!(value::NodalHVDCTransportTechnology, val) = value.ext = val
"""Set [`NodalHVDCTransportTechnology`](@ref) `internal`."""
set_internal!(value::NodalHVDCTransportTechnology, val) = value.internal = val


function from_openapi(po::PI.NodalHVDCTransportTechnology, refs::OpenAPIRefs)
    parameter = getproperty(PowerSystems, Symbol(po.power_systems_type))
    return NodalHVDCTransportTechnology{parameter}(;
        name = po.name,
        available = po.available,
        power_systems_type = po.power_systems_type,
        start_node = resolve_ref(refs, po.start_node, PSY.Bus),
        end_node = resolve_ref(refs, po.end_node, PSY.Bus),
        capacity_limits = _minmax_from_po(po.capacity_limits),
        unit_size = po.unit_size,
        capital_costs = convert_nested_data(po.capital_costs),
        line_loss = convert_value_curve(po.line_loss),
        financial_data = convert_nested_data(po.financial_data),
    )
end

function to_openapi(value::NodalHVDCTransportTechnology{T}, refs::OpenAPIRefs) where {T <: PSY.Device}
    return PI.NodalHVDCTransportTechnology(;
        id = get_id(value),
        name = get_name(value),
        available = get_available(value),
        power_systems_type = string(nameof(T)),
        start_node = component_id(refs, get_start_node(value)),
        end_node = component_id(refs, get_end_node(value)),
        capacity_limits = _minmax_po(get_capacity_limits(value, IS.NU)),
        unit_size = get_unit_size(value, IS.NU),
        capital_costs = convert_nested_data_to_openapi(get_capital_costs(value)),
        line_loss = convert_value_curve_to_openapi(get_line_loss(value)),
        financial_data = convert_nested_data_to_openapi(get_financial_data(value)),
    )
end
