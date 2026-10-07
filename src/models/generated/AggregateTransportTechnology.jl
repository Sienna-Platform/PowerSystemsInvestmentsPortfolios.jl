#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct AggregateTransportTechnology{T <: PSY.Device} <: TransmissionTechnology
        requirements::Vector{Requirement}
        start_region::RegionTopology
        capital_costs::CapitalCost
        available::Bool
        name::String
        id::Int64
        end_region::RegionTopology
        financial_data::TechnologyFinancialData
        power_systems_type::String
        internal::InfrastructureSystemsInternal
        ext::Dict
        unit_size::Float64
        line_loss::Float64
        capacity_limits::MinMax
    end

An aggregated representation of a transmission interchange between two regions.

# Arguments
- `requirements::Vector{Requirement}`: (default: `Vector()`) List of requirements (i.e. reserve margin, capacity requirements, energy share requirements) that are associated with a technology
- `start_region::RegionTopology`: Start region for transport technology
- `capital_costs::CapitalCost`: (default: `CapitalCost(nothing)`) Cost of adding new capacity to the nodal transmission line. (USD/MW)
- `available::Bool`: Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`)
- `name::String`: Name
- `id::Int64`: Numerical Index for AC transport technologies
- `end_region::RegionTopology`: End region for transport technology
- `financial_data::TechnologyFinancialData`: Struct containing relevant financial information for a technology
- `power_systems_type::String`: Corresponding type in PowerSystems.jl to be used in PCM modeling
- `internal::InfrastructureSystemsInternal`: (default: `InfrastructureSystemsInternal()`) (**Do not modify.**) PowerSystemsInvestmentsPortfolios.jl internal reference
- `ext::Dict`: (default: `Dict()`) Optional dictionary to provide additional data
- `unit_size::Float64`: (default: `1`) Used for integer investment decisions. Represents the rating capacity of individual new lines (MW)
- `line_loss::Float64`: (default: `0.0`) Transmission loss for each transport technology (%)
- `capacity_limits::MinMax`: (default: `(min=0, max=1e8)`) Allowable capacity for a transmission line (MW)
"""
mutable struct AggregateTransportTechnology{T <: PSY.Device} <: TransmissionTechnology
    "List of requirements (i.e. reserve margin, capacity requirements, energy share requirements) that are associated with a technology"
    requirements::Vector{Requirement}
    "Start region for transport technology"
    start_region::RegionTopology
    "Cost of adding new capacity to the nodal transmission line. (USD/MW)"
    capital_costs::CapitalCost
    "Indicator of whether the component is connected and online (`true`) or disconnected, offline, or down (`false`)"
    available::Bool
    "Name"
    name::String
    "Numerical Index for AC transport technologies"
    id::Int64
    "End region for transport technology"
    end_region::RegionTopology
    "Struct containing relevant financial information for a technology"
    financial_data::TechnologyFinancialData
    "Corresponding type in PowerSystems.jl to be used in PCM modeling"
    power_systems_type::String
    "(**Do not modify.**) PowerSystemsInvestmentsPortfolios.jl internal reference"
    internal::InfrastructureSystemsInternal
    "Optional dictionary to provide additional data"
    ext::Dict
    "Used for integer investment decisions. Represents the rating capacity of individual new lines (MW)"
    unit_size::Float64
    "Transmission loss for each transport technology (%)"
    line_loss::Float64
    "Allowable capacity for a transmission line (MW)"
    capacity_limits::MinMax
end


function AggregateTransportTechnology{T}(; requirements=Vector(), start_region, capital_costs=CapitalCost(nothing), available, name, id, end_region, financial_data, power_systems_type, internal=InfrastructureSystemsInternal(), ext=Dict(), unit_size=1, line_loss=0.0, capacity_limits=(min=0, max=1e8), ) where T <: PSY.Device
    AggregateTransportTechnology{T}(requirements, start_region, capital_costs, available, name, id, end_region, financial_data, power_systems_type, internal, ext, unit_size, line_loss, capacity_limits, )
end

"""Get [`AggregateTransportTechnology`](@ref) `requirements`."""
get_requirements(value::AggregateTransportTechnology) = value.requirements
"""Get [`AggregateTransportTechnology`](@ref) `start_region`."""
get_start_region(value::AggregateTransportTechnology) = value.start_region
"""Get [`AggregateTransportTechnology`](@ref) `capital_costs`."""
get_capital_costs(value::AggregateTransportTechnology) = value.capital_costs
"""Get [`AggregateTransportTechnology`](@ref) `available`."""
get_available(value::AggregateTransportTechnology) = value.available
"""Get [`AggregateTransportTechnology`](@ref) `name`."""
get_name(value::AggregateTransportTechnology) = value.name
"""Get [`AggregateTransportTechnology`](@ref) `id`."""
get_id(value::AggregateTransportTechnology) = value.id
"""Get [`AggregateTransportTechnology`](@ref) `end_region`."""
get_end_region(value::AggregateTransportTechnology) = value.end_region
"""Get [`AggregateTransportTechnology`](@ref) `financial_data`."""
get_financial_data(value::AggregateTransportTechnology) = value.financial_data
"""Get [`AggregateTransportTechnology`](@ref) `power_systems_type`."""
get_power_systems_type(value::AggregateTransportTechnology) = value.power_systems_type
"""Get [`AggregateTransportTechnology`](@ref) `internal`."""
get_internal(value::AggregateTransportTechnology) = value.internal
"""Get [`AggregateTransportTechnology`](@ref) `ext`."""
get_ext(value::AggregateTransportTechnology) = value.ext
"""Get [`AggregateTransportTechnology`](@ref) `unit_size`."""
get_unit_size(value::AggregateTransportTechnology) = value.unit_size
"""Get [`AggregateTransportTechnology`](@ref) `line_loss`."""
get_line_loss(value::AggregateTransportTechnology) = value.line_loss
"""Get [`AggregateTransportTechnology`](@ref) `capacity_limits`."""
get_capacity_limits(value::AggregateTransportTechnology) = value.capacity_limits

"""Set [`AggregateTransportTechnology`](@ref) `requirements`."""
set_requirements!(value::AggregateTransportTechnology, val) = value.requirements = val
"""Set [`AggregateTransportTechnology`](@ref) `start_region`."""
set_start_region!(value::AggregateTransportTechnology, val) = value.start_region = val
"""Set [`AggregateTransportTechnology`](@ref) `capital_costs`."""
set_capital_costs!(value::AggregateTransportTechnology, val) = value.capital_costs = val
"""Set [`AggregateTransportTechnology`](@ref) `available`."""
set_available!(value::AggregateTransportTechnology, val) = value.available = val
"""Set [`AggregateTransportTechnology`](@ref) `name`."""
set_name!(value::AggregateTransportTechnology, val) = value.name = val
"""Set [`AggregateTransportTechnology`](@ref) `id`."""
set_id!(value::AggregateTransportTechnology, val) = value.id = val
"""Set [`AggregateTransportTechnology`](@ref) `end_region`."""
set_end_region!(value::AggregateTransportTechnology, val) = value.end_region = val
"""Set [`AggregateTransportTechnology`](@ref) `financial_data`."""
set_financial_data!(value::AggregateTransportTechnology, val) = value.financial_data = val
"""Set [`AggregateTransportTechnology`](@ref) `power_systems_type`."""
set_power_systems_type!(value::AggregateTransportTechnology, val) = value.power_systems_type = val
"""Set [`AggregateTransportTechnology`](@ref) `internal`."""
set_internal!(value::AggregateTransportTechnology, val) = value.internal = val
"""Set [`AggregateTransportTechnology`](@ref) `ext`."""
set_ext!(value::AggregateTransportTechnology, val) = value.ext = val
"""Set [`AggregateTransportTechnology`](@ref) `unit_size`."""
set_unit_size!(value::AggregateTransportTechnology, val) = value.unit_size = val
"""Set [`AggregateTransportTechnology`](@ref) `line_loss`."""
set_line_loss!(value::AggregateTransportTechnology, val) = value.line_loss = val
"""Set [`AggregateTransportTechnology`](@ref) `capacity_limits`."""
set_capacity_limits!(value::AggregateTransportTechnology, val) = value.capacity_limits = val

function serialize_openapi_struct(technology::AggregateTransportTechnology{T}, vals...) where T <: PSY.Device
    base_struct = APIServer.AggregateTransportTechnology(; vals...)
    return base_struct
end


function deserialize_openapi_struct(::Type{<:AggregateTransportTechnology}, vals::Dict)
    return IS.deserialize_struct(APIServer.AggregateTransportTechnology, vals)
end
