############################
######### Topology #########
############################

# A portfolio's topology is PowerSystems topology in its base system: zones are the
# portfolio's aggregation type (`Area` by default, or e.g. `LoadZone`) and nodes are buses
# (`ACBus`). Build them with the constructors below (or PowerSystems' `Area(name)`), add them
# with `add_topology!` and query them without PowerSystems accessors.

"""
Return the topology type of the portfolio's zones: its aggregation type (`Area` by default),
or `Area` for a portfolio aggregated by node.
"""
get_zone_type(portfolio::Portfolio) = _zone_type(get_aggregation(portfolio))
_zone_type(aggregation::Type{<:PSY.AggregationTopology}) = aggregation
_zone_type(::Type{<:PSY.ACBus}) = PSY.Area

# Convenience constructors for PowerSystems topology (PowerSystems already has `Area(name)`).
# These add methods to PowerSystems' types.

"""
    LoadZone(name; kwargs...)

Build a `LoadZone` named `name` with no peak power (set peak powers after adding it to a
portfolio with [`add_topology!`](@ref)). Other keywords go to the `LoadZone` constructor.
"""
PSY.LoadZone(name::AbstractString; kwargs...) = PSY.LoadZone(;
    name=name,
    input_basis=u"NU",
    peak_active_power=0.0,
    peak_reactive_power=0.0,
    kwargs...,
)

"""
    ACBus(name; zone=nothing, reference=false, number=0, base_voltage=230.0, kwargs...)

Build a node (an `ACBus`) named `name` in `zone` (an `Area` or `LoadZone`). With
`reference=true` it is the reference bus of its island. Voltages are per unit of
`base_voltage` (kV). A `number` of 0 is replaced with the next free bus number when the bus
is added to a portfolio. Other keywords go to the `ACBus` constructor.
"""
PSY.ACBus(
    name::AbstractString;
    zone::Union{Nothing, PSY.AggregationTopology}=nothing,
    reference::Bool=false,
    number::Int=0,
    base_voltage::Float64=230.0,
    kwargs...,
) = PSY.ACBus(;
    name=name,
    number=number,
    input_basis=u"CU",
    available=true,
    bustype=reference ? PSY.ACBusTypes.REF : PSY.ACBusTypes.PQ,
    angle=0.0,
    magnitude=1.0,
    voltage_limits=(min=0.9, max=1.1),
    base_voltage=base_voltage,
    area=zone isa PSY.Area ? zone : nothing,
    load_zone=zone isa PSY.LoadZone ? zone : nothing,
    kwargs...,
)

# Bus number 0 means "not numbered yet": a bus is numbered when it is added
_assign_bus_number!(portfolio::Portfolio, ::PSY.Topology) = nothing
function _assign_bus_number!(portfolio::Portfolio, bus::PSY.Bus)
    iszero(PSY.get_number(bus)) && PSY.set_number!(bus, _next_bus_number(portfolio))
    return
end

_next_bus_number(portfolio::Portfolio) =
    maximum(PSY.get_number, get_topologies(PSY.Bus, portfolio); init=0) + 1

"""
Return an iterator of the portfolio's zones (see [`get_zone_type`](@ref)).
"""
get_zones(portfolio::Portfolio) = get_topologies(get_zone_type(portfolio), portfolio)

"""
Return the zone named `name`, or `nothing` if there is none.
"""
get_zone(portfolio::Portfolio, name::AbstractString) =
    get_topology(get_zone_type(portfolio), portfolio, name)

"""
Return the zone of `node`, or `nothing` if it has none.
"""
get_zone(portfolio::Portfolio, node::PSY.ACBus) = _bus_zone(get_zone_type(portfolio), node)
_bus_zone(::Type{PSY.Area}, node::PSY.ACBus) = PSY.get_area(node)
_bus_zone(::Type{PSY.LoadZone}, node::PSY.ACBus) = PSY.get_load_zone(node)

"""
Return an iterator of the portfolio's nodes (`ACBus`).
"""
get_nodes(portfolio::Portfolio) = get_topologies(PSY.ACBus, portfolio)

"""
Return the nodes of the portfolio in `zone`.
"""
get_nodes(portfolio::Portfolio, zone::PSY.AggregationTopology) =
    [node for node in get_nodes(portfolio) if get_zone(portfolio, node) === zone]

"""
Return the node named `name`, or `nothing` if there is none.
"""
get_node(portfolio::Portfolio, name::AbstractString) =
    get_topology(PSY.ACBus, portfolio, name)

# Topology a technology is located in, or a line connects
_topologies(technology::Technology) = get_region(technology)
_topologies(line::AggregateTransportTechnology) =
    [get_start_region(line), get_end_region(line)]
_topologies(line::Union{NodalACTransportTechnology, NodalHVDCTransportTechnology}) =
    [get_start_node(line), get_end_node(line)]

"""
Return the technologies of type `T` located in `topology` (a zone or node), or, for lines,
connecting it.

# Examples

```julia
get_technologies(SupplyTechnology, portfolio, west)
```
"""
get_technologies(
    ::Type{T},
    portfolio::Portfolio,
    topology::PSY.Topology,
) where {T <: Technology} = get_technologies(
    technology -> any(t -> t === topology, _topologies(technology)),
    T,
    portfolio,
)

"""
Return the transmission technologies that start or end in `topology` (a zone or node).
"""
get_lines(portfolio::Portfolio, topology::PSY.Topology) =
    get_technologies(TransmissionTechnology, portfolio, topology)

"""
Return the topology of type `T` (e.g. `PSY.Area`, `PSY.ACBus`) that holds an available
technology or ends an available line, sorted by name. The base system can hold other
topology (its own buses, for example), which an investment model ignores.
"""
function get_model_topologies(portfolio::Portfolio, ::Type{T}) where {T <: PSY.Topology}
    used = Set{T}()
    for technology in get_technologies(get_available, Technology, portfolio),
        topology in _topologies(technology)

        topology isa T && push!(used, topology)
    end
    return sort!(collect(used); by=get_name)
end
