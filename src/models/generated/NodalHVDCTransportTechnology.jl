#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct NodalHVDCTransportTechnology{T <: PSY.Device} <: TransmissionTechnology
        requirements::Vector{Requirement}
        capital_costs::CapitalCost
        available::Bool
        name::String
        end_node::RegionTopology
        id::Int64
        financial_data::TechnologyFinancialData
        start_node::RegionTopology
        power_systems_type::String
        internal::InfrastructureSystemsInternal
        ext::Dict
        unit_size::Float64
        line_loss::Union{IS.LinearCurve, IS.PiecewiseIncrementalCurve}
        capacity_limits::MinMax
    end

A nodal representation of candidate HVDC transmission lines between two regions.

# Arguments
- `requirements::Vector{Requirement}`: (default: `Vector()`) List of requirements (i.e. reserve margin, capacity requirements, energy share requirements) that are associated with a technology
- `capital_costs::CapitalCost`: (default: `CapitalCost(nothing)`) Cost of adding new capacity to the nodal transmission line. (USD/MW)
- `available::Bool`: Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`)
- `name::String`: Name
- `end_node::RegionTopology`: End node for transport technology
- `id::Int64`: Numerical Index for HVDC lines
- `financial_data::TechnologyFinancialData`: Struct containing relevant financial information for a technology
- `start_node::RegionTopology`: Start node for transport technology
- `power_systems_type::String`: Corresponding type in PowerSystems.jl to be used in PCM modeling
- `internal::InfrastructureSystemsInternal`: (default: `InfrastructureSystemsInternal()`) (**Do not modify.**) PowerSystemsInvestmentsPortfolios.jl internal reference
- `ext::Dict`: (default: `Dict()`) Optional dictionary to provide additional data
- `unit_size::Float64`: (default: `1`) Used for integer investment decisions. Represents the rating capacity of individual new lines (MW)
- `line_loss::Union{IS.LinearCurve, IS.PiecewiseIncrementalCurve}`: (default: `LinearCurve(0.0)`) Loss model coefficients. It accepts a linear model with a constant loss and a proportional loss rate. All terms are defined as fraction of installed nameplate capacity It also accepts a Piecewise loss, with N segments to specify different proportional losses for different segments.
- `capacity_limits::MinMax`: (default: `(min=0, max=1e8)`) Allowable capacity for a transmission line (MW)
"""
mutable struct NodalHVDCTransportTechnology{T <: PSY.Device} <: TransmissionTechnology
    "List of requirements (i.e. reserve margin, capacity requirements, energy share requirements) that are associated with a technology"
    requirements::Vector{Requirement}
    "Cost of adding new capacity to the nodal transmission line. (USD/MW)"
    capital_costs::CapitalCost
    "Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`)"
    available::Bool
    "Name"
    name::String
    "End node for transport technology"
    end_node::RegionTopology
    "Numerical Index for HVDC lines"
    id::Int64
    "Struct containing relevant financial information for a technology"
    financial_data::TechnologyFinancialData
    "Start node for transport technology"
    start_node::RegionTopology
    "Corresponding type in PowerSystems.jl to be used in PCM modeling"
    power_systems_type::String
    "(**Do not modify.**) PowerSystemsInvestmentsPortfolios.jl internal reference"
    internal::InfrastructureSystemsInternal
    "Optional dictionary to provide additional data"
    ext::Dict
    "Used for integer investment decisions. Represents the rating capacity of individual new lines (MW)"
    unit_size::Float64
    "Loss model coefficients. It accepts a linear model with a constant loss and a proportional loss rate. All terms are defined as fraction of installed nameplate capacity It also accepts a Piecewise loss, with N segments to specify different proportional losses for different segments."
    line_loss::Union{IS.LinearCurve, IS.PiecewiseIncrementalCurve}
    "Allowable capacity for a transmission line (MW)"
    capacity_limits::MinMax
end


function NodalHVDCTransportTechnology{T}(; requirements=Vector(), capital_costs=CapitalCost(nothing), available, name, end_node, id, financial_data, start_node, power_systems_type, internal=InfrastructureSystemsInternal(), ext=Dict(), unit_size=1, line_loss=LinearCurve(0.0), capacity_limits=(min=0, max=1e8), ) where T <: PSY.Device
    NodalHVDCTransportTechnology{T}(requirements, capital_costs, available, name, end_node, id, financial_data, start_node, power_systems_type, internal, ext, unit_size, line_loss, capacity_limits, )
end

"""Get [`NodalHVDCTransportTechnology`](@ref) `requirements`."""
get_requirements(value::NodalHVDCTransportTechnology) = value.requirements
"""Get [`NodalHVDCTransportTechnology`](@ref) `capital_costs`."""
get_capital_costs(value::NodalHVDCTransportTechnology) = value.capital_costs
"""Get [`NodalHVDCTransportTechnology`](@ref) `available`."""
get_available(value::NodalHVDCTransportTechnology) = value.available
"""Get [`NodalHVDCTransportTechnology`](@ref) `name`."""
get_name(value::NodalHVDCTransportTechnology) = value.name
"""Get [`NodalHVDCTransportTechnology`](@ref) `end_node`."""
get_end_node(value::NodalHVDCTransportTechnology) = value.end_node
"""Get [`NodalHVDCTransportTechnology`](@ref) `id`."""
get_id(value::NodalHVDCTransportTechnology) = value.id
"""Get [`NodalHVDCTransportTechnology`](@ref) `financial_data`."""
get_financial_data(value::NodalHVDCTransportTechnology) = value.financial_data
"""Get [`NodalHVDCTransportTechnology`](@ref) `start_node`."""
get_start_node(value::NodalHVDCTransportTechnology) = value.start_node
"""Get [`NodalHVDCTransportTechnology`](@ref) `power_systems_type`."""
get_power_systems_type(value::NodalHVDCTransportTechnology) = value.power_systems_type
"""Get [`NodalHVDCTransportTechnology`](@ref) `internal`."""
get_internal(value::NodalHVDCTransportTechnology) = value.internal
"""Get [`NodalHVDCTransportTechnology`](@ref) `ext`."""
get_ext(value::NodalHVDCTransportTechnology) = value.ext
"""Get [`NodalHVDCTransportTechnology`](@ref) `unit_size`."""
get_unit_size(value::NodalHVDCTransportTechnology) = value.unit_size
"""Get [`NodalHVDCTransportTechnology`](@ref) `line_loss`."""
get_line_loss(value::NodalHVDCTransportTechnology) = value.line_loss
"""Get [`NodalHVDCTransportTechnology`](@ref) `capacity_limits`."""
get_capacity_limits(value::NodalHVDCTransportTechnology) = value.capacity_limits

"""Set [`NodalHVDCTransportTechnology`](@ref) `requirements`."""
set_requirements!(value::NodalHVDCTransportTechnology, val) = value.requirements = val
"""Set [`NodalHVDCTransportTechnology`](@ref) `capital_costs`."""
set_capital_costs!(value::NodalHVDCTransportTechnology, val) = value.capital_costs = val
"""Set [`NodalHVDCTransportTechnology`](@ref) `available`."""
set_available!(value::NodalHVDCTransportTechnology, val) = value.available = val
"""Set [`NodalHVDCTransportTechnology`](@ref) `name`."""
set_name!(value::NodalHVDCTransportTechnology, val) = value.name = val
"""Set [`NodalHVDCTransportTechnology`](@ref) `end_node`."""
set_end_node!(value::NodalHVDCTransportTechnology, val) = value.end_node = val
"""Set [`NodalHVDCTransportTechnology`](@ref) `id`."""
set_id!(value::NodalHVDCTransportTechnology, val) = value.id = val
"""Set [`NodalHVDCTransportTechnology`](@ref) `financial_data`."""
set_financial_data!(value::NodalHVDCTransportTechnology, val) = value.financial_data = val
"""Set [`NodalHVDCTransportTechnology`](@ref) `start_node`."""
set_start_node!(value::NodalHVDCTransportTechnology, val) = value.start_node = val
"""Set [`NodalHVDCTransportTechnology`](@ref) `power_systems_type`."""
set_power_systems_type!(value::NodalHVDCTransportTechnology, val) = value.power_systems_type = val
"""Set [`NodalHVDCTransportTechnology`](@ref) `internal`."""
set_internal!(value::NodalHVDCTransportTechnology, val) = value.internal = val
"""Set [`NodalHVDCTransportTechnology`](@ref) `ext`."""
set_ext!(value::NodalHVDCTransportTechnology, val) = value.ext = val
"""Set [`NodalHVDCTransportTechnology`](@ref) `unit_size`."""
set_unit_size!(value::NodalHVDCTransportTechnology, val) = value.unit_size = val
"""Set [`NodalHVDCTransportTechnology`](@ref) `line_loss`."""
set_line_loss!(value::NodalHVDCTransportTechnology, val) = value.line_loss = val
"""Set [`NodalHVDCTransportTechnology`](@ref) `capacity_limits`."""
set_capacity_limits!(value::NodalHVDCTransportTechnology, val) = value.capacity_limits = val

function serialize_openapi_struct(technology::NodalHVDCTransportTechnology{T}, vals...) where T <: PSY.Device
    base_struct = APIServer.NodalHVDCTransportTechnology(; vals...)
    return base_struct
end


function deserialize_openapi_struct(::Type{<:NodalHVDCTransportTechnology}, vals::Dict)
    return IS.deserialize_struct(APIServer.NodalHVDCTransportTechnology, vals)
end
