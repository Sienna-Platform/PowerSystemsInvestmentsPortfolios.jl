#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct NodalACTransportTechnology{T <: PSY.Device} <: TransmissionTechnology
        requirements::Vector{Requirement}
        start_node::Node
        power_systems_type::String
        internal::InfrastructureSystemsInternal
        capital_costs::CapitalCost
        ext::Dict
        reactance::Float64
        resistance::Float64
        available::Bool
        voltage::Float64
        name::String
        unit_size::Float64
        end_node::Node
        id::Int64
        capacity_limits::MinMax
        financial_data::TechnologyFinancialData
    end

Nodal representation of candidate AC transmission lines between two regions.

# Arguments
- `requirements::Vector{Requirement}`: (default: `Vector()`) List of requirements (i.e. reserve margin, capacity requirements, energy share requirements) that are associated with a technology
- `start_node::Node`: Start node for transport technology
- `power_systems_type::String`: Corresponding type in PowerSystems.jl to be used in PCM modeling
- `internal::InfrastructureSystemsInternal`: (default: `InfrastructureSystemsInternal()`) (**Do not modify.**) PowerSystemsInvestmentsPortfolios.jl internal reference
- `capital_costs::CapitalCost`: (default: `CapitalCost(nothing)`) Cost of adding new capacity to the nodal transmission line (USD/MW).
- `ext::Dict`: (default: `Dict()`) Optional dictionary to provide additional data
- `reactance::Float64`: (default: `1.0`) Series reactance for a line (ohms)
- `resistance::Float64`: (default: `1.0`) Technology resistance in Ohms
- `available::Bool`: Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`)
- `voltage::Float64`: (default: `230.0`) Voltage rating of transmission line (kV)
- `name::String`: Name
- `unit_size::Float64`: (default: `1.0`) Used for integer investment decisions. Represents the rating capacity of individual new lines (MW)
- `end_node::Node`: End node for transport technology
- `id::Int64`: Numerical Index for AC transport technologies
- `capacity_limits::MinMax`: (default: `(min=0, max=1e8)`) Allowable capacity for a transmission line (MW)
- `financial_data::TechnologyFinancialData`: Struct containing relevant financial information for a technology
"""
mutable struct NodalACTransportTechnology{T <: PSY.Device} <: TransmissionTechnology
    "List of requirements (i.e. reserve margin, capacity requirements, energy share requirements) that are associated with a technology"
    requirements::Vector{Requirement}
    "Start node for transport technology"
    start_node::Node
    "Corresponding type in PowerSystems.jl to be used in PCM modeling"
    power_systems_type::String
    "(**Do not modify.**) PowerSystemsInvestmentsPortfolios.jl internal reference"
    internal::InfrastructureSystemsInternal
    "Cost of adding new capacity to the nodal transmission line (USD/MW)."
    capital_costs::CapitalCost
    "Optional dictionary to provide additional data"
    ext::Dict
    "Series reactance for a line (ohms)"
    reactance::Float64
    "Technology resistance in Ohms"
    resistance::Float64
    "Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`)"
    available::Bool
    "Voltage rating of transmission line (kV)"
    voltage::Float64
    "Name"
    name::String
    "Used for integer investment decisions. Represents the rating capacity of individual new lines (MW)"
    unit_size::Float64
    "End node for transport technology"
    end_node::Node
    "Numerical Index for AC transport technologies"
    id::Int64
    "Allowable capacity for a transmission line (MW)"
    capacity_limits::MinMax
    "Struct containing relevant financial information for a technology"
    financial_data::TechnologyFinancialData
end


function NodalACTransportTechnology{T}(; requirements=Vector(), start_node, power_systems_type, internal=InfrastructureSystemsInternal(), capital_costs=CapitalCost(nothing), ext=Dict(), reactance=1.0, resistance=1.0, available, voltage=230.0, name, unit_size=1.0, end_node, id, capacity_limits=(min=0, max=1e8), financial_data, ) where T <: PSY.Device
    NodalACTransportTechnology{T}(requirements, start_node, power_systems_type, internal, capital_costs, ext, reactance, resistance, available, voltage, name, unit_size, end_node, id, capacity_limits, financial_data, )
end

"""Get [`NodalACTransportTechnology`](@ref) `requirements`."""
get_requirements(value::NodalACTransportTechnology) = value.requirements
"""Get [`NodalACTransportTechnology`](@ref) `start_node`."""
get_start_node(value::NodalACTransportTechnology) = value.start_node
"""Get [`NodalACTransportTechnology`](@ref) `power_systems_type`."""
get_power_systems_type(value::NodalACTransportTechnology) = value.power_systems_type
"""Get [`NodalACTransportTechnology`](@ref) `internal`."""
get_internal(value::NodalACTransportTechnology) = value.internal
"""Get [`NodalACTransportTechnology`](@ref) `capital_costs`."""
get_capital_costs(value::NodalACTransportTechnology) = value.capital_costs
"""Get [`NodalACTransportTechnology`](@ref) `ext`."""
get_ext(value::NodalACTransportTechnology) = value.ext
"""Get [`NodalACTransportTechnology`](@ref) `reactance`."""
get_reactance(value::NodalACTransportTechnology) = value.reactance
"""Get [`NodalACTransportTechnology`](@ref) `resistance`."""
get_resistance(value::NodalACTransportTechnology) = value.resistance
"""Get [`NodalACTransportTechnology`](@ref) `available`."""
get_available(value::NodalACTransportTechnology) = value.available
"""Get [`NodalACTransportTechnology`](@ref) `voltage`."""
get_voltage(value::NodalACTransportTechnology) = value.voltage
"""Get [`NodalACTransportTechnology`](@ref) `name`."""
get_name(value::NodalACTransportTechnology) = value.name
"""Get [`NodalACTransportTechnology`](@ref) `unit_size`."""
get_unit_size(value::NodalACTransportTechnology) = value.unit_size
"""Get [`NodalACTransportTechnology`](@ref) `end_node`."""
get_end_node(value::NodalACTransportTechnology) = value.end_node
"""Get [`NodalACTransportTechnology`](@ref) `id`."""
get_id(value::NodalACTransportTechnology) = value.id
"""Get [`NodalACTransportTechnology`](@ref) `capacity_limits`."""
get_capacity_limits(value::NodalACTransportTechnology) = value.capacity_limits
"""Get [`NodalACTransportTechnology`](@ref) `financial_data`."""
get_financial_data(value::NodalACTransportTechnology) = value.financial_data

"""Set [`NodalACTransportTechnology`](@ref) `requirements`."""
set_requirements!(value::NodalACTransportTechnology, val) = value.requirements = val
"""Set [`NodalACTransportTechnology`](@ref) `start_node`."""
set_start_node!(value::NodalACTransportTechnology, val) = value.start_node = val
"""Set [`NodalACTransportTechnology`](@ref) `power_systems_type`."""
set_power_systems_type!(value::NodalACTransportTechnology, val) = value.power_systems_type = val
"""Set [`NodalACTransportTechnology`](@ref) `internal`."""
set_internal!(value::NodalACTransportTechnology, val) = value.internal = val
"""Set [`NodalACTransportTechnology`](@ref) `capital_costs`."""
set_capital_costs!(value::NodalACTransportTechnology, val) = value.capital_costs = val
"""Set [`NodalACTransportTechnology`](@ref) `ext`."""
set_ext!(value::NodalACTransportTechnology, val) = value.ext = val
"""Set [`NodalACTransportTechnology`](@ref) `reactance`."""
set_reactance!(value::NodalACTransportTechnology, val) = value.reactance = val
"""Set [`NodalACTransportTechnology`](@ref) `resistance`."""
set_resistance!(value::NodalACTransportTechnology, val) = value.resistance = val
"""Set [`NodalACTransportTechnology`](@ref) `available`."""
set_available!(value::NodalACTransportTechnology, val) = value.available = val
"""Set [`NodalACTransportTechnology`](@ref) `voltage`."""
set_voltage!(value::NodalACTransportTechnology, val) = value.voltage = val
"""Set [`NodalACTransportTechnology`](@ref) `name`."""
set_name!(value::NodalACTransportTechnology, val) = value.name = val
"""Set [`NodalACTransportTechnology`](@ref) `unit_size`."""
set_unit_size!(value::NodalACTransportTechnology, val) = value.unit_size = val
"""Set [`NodalACTransportTechnology`](@ref) `end_node`."""
set_end_node!(value::NodalACTransportTechnology, val) = value.end_node = val
"""Set [`NodalACTransportTechnology`](@ref) `id`."""
set_id!(value::NodalACTransportTechnology, val) = value.id = val
"""Set [`NodalACTransportTechnology`](@ref) `capacity_limits`."""
set_capacity_limits!(value::NodalACTransportTechnology, val) = value.capacity_limits = val
"""Set [`NodalACTransportTechnology`](@ref) `financial_data`."""
set_financial_data!(value::NodalACTransportTechnology, val) = value.financial_data = val

function serialize_openapi_struct(technology::NodalACTransportTechnology{T}, vals...) where T <: PSY.Device
    base_struct = APIServer.NodalACTransportTechnology(; vals...)
    return base_struct
end


function deserialize_openapi_struct(::Type{<:NodalACTransportTechnology}, vals::Dict)
    return IS.deserialize_struct(APIServer.NodalACTransportTechnology, vals)
end
