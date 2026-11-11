```@meta
CurrentModule = PowerSystemsInvestmentsPortfolios
```

# Define Zones and Nodes

Technologies are located in **zones** (a zonal portfolio) or at **nodes** (a nodal
portfolio). Both are `PowerSystems.jl` topology stored in the portfolio's base system: a zone
is the portfolio's aggregation type ([`get_zone_type`](@ref), `Area` by default) and a node is
an `ACBus`. Add them before any technology that references them.

## Add zones and nodes

Build zones and nodes with their constructors, then add them with [`add_topology!`](@ref)
like any other component:

```julia
using PowerSystemsInvestmentsPortfolios

portfolio = Portfolio()

west = Area("West")
east = Area("East")
add_topology!(portfolio, west)
add_topology!(portfolio, east)
set_peak_active_power!(east, 250.0u"MW")   # after adding: peaks are per unit of the system base

bus1 = ACBus("bus1"; zone=west, reference=true)
bus2 = ACBus("bus2"; zone=west, base_voltage=345.0)   # kV
add_topology!(portfolio, bus1)
add_topology!(portfolio, bus2)
```

Use zones of the portfolio's zone type (`LoadZone("LZ")` for a portfolio aggregated by load
zone). Each island of a nodal network needs one reference node (`reference=true`). Bus
numbers are assigned when a node is added unless you pass `number`. Other keywords go to the
`Area`/`LoadZone`/`ACBus` constructors.

## Query zones and nodes

```julia
get_zones(portfolio)            # all zones
get_zone(portfolio, "West")     # a zone by name
get_nodes(portfolio)            # all nodes
get_nodes(portfolio, west)      # the nodes in a zone
get_node(portfolio, "bus1")     # a node by name
get_zone(portfolio, bus1)       # the zone of a node
get_name(west)                  # "West"
```

Technologies and lines by location:

```julia
get_technologies(SupplyTechnology, portfolio, west)   # technologies in a zone or at a node
get_lines(portfolio, bus1)                            # lines that start or end there
```

## Reuse the topology of an existing system

When the portfolio is built from a `PSY.System`, that system's topology is already in the
portfolio, and the functions above find it. The base system can hold topology no technology
uses (its other buses, for example); [`get_model_topologies`](@ref) returns only the zones or
nodes an investment model builds over:

```julia
portfolio = Portfolio(sys)
get_model_topologies(portfolio, ACBus)
```

## Choose the aggregation level

The portfolio's aggregation type records the spatial resolution of the study and decides
what a zone is. It defaults to `Area`; pass another type as the first constructor argument:

```julia
portfolio = Portfolio(LoadZone, sys, 2030, 0.07, 0.025, 0.05)   # zones are LoadZones
```

## Other topology

Any `PowerSystems.jl` topology (arcs, DC buses, ...) can be attached with
[`add_topology!`](@ref) and queried with [`get_topologies`](@ref) /
[`get_topology`](@ref); [`remove_topology!`](@ref) removes it.

!!! note
    
    A technology whose `region`, `start_region`/`end_region`, or `start_node`/`end_node`
    refers to topology that is not in the portfolio is rejected by
    [`add_technology!`](@ref).

## See also

  - [Regions and Topology](@ref)
  - [`add_topology!`](@ref)
  - [`get_zones`](@ref), [`get_nodes`](@ref)
