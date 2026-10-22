```@meta
CurrentModule = PowerSystemsInvestmentsPortfolios
```

# Regions and Topology

## Topology comes from PowerSystems

PSIP does not define its own region types. A technology is located with the same topology
components a `PowerSystems.jl` `System` uses:

| PowerSystems type | Role in a portfolio                                        |
|:----------------- |:---------------------------------------------------------- |
| `PSY.Area`        | A planning zone in a zonal model (the default aggregation) |
| `PSY.LoadZone`    | A planning zone in a zonal model                           |
| `PSY.ACBus`       | A node in a nodal model                                    |
| `PSY.Arc`         | A connection between two buses in the base system          |

These components live in the portfolio's **base system**. [`add_topology!`](@ref) stores a
component there, and [`get_topologies`](@ref) and [`get_topology`](@ref) read it back. Because
the portfolio and the base system share the same objects, a technology located in `Area`
"West" and an existing generator on a bus in "West" refer to the same region — there is no
name matching between two separate sets of regions.

PSIP re-exports these types, so they can be used without the `PSY.` prefix.

## How technologies reference topology

| Technology                                                                   | Field(s)                     | Type                      |
|:---------------------------------------------------------------------------- |:---------------------------- |:------------------------- |
| Supply, storage, co-located, demand                                          | `region`                     | `Vector{PSY.Topology}`    |
| [`AggregateTransportTechnology`](@ref)                                       | `start_region`, `end_region` | `PSY.AggregationTopology` |
| [`NodalACTransportTechnology`](@ref), [`NodalHVDCTransportTechnology`](@ref) | `start_node`, `end_node`     | `PSY.Bus`                 |

When a technology is added, PSIP checks that:

  - a supply, storage, co-located, or demand technology has at least one region, with no
    duplicates;
  - every region and transport endpoint is already in the portfolio.

So topology is always added before the technologies located in it.

## Technologies in several regions

A `region` vector can hold several regions. A supply technology located in more than one
region represents capacity that can be built in any of them, and its `capacity_limits` can
be given per region as a `Dict{PSY.Topology, MinMax}`. Most technologies have a single
region.

## Aggregation level

The portfolio records its spatial resolution as an aggregation type — `PSY.Area` by default,
or another `PSY.AggregationTopology` subtype or `PSY.ACBus`. It is set when the portfolio is
constructed:

```julia
portfolio = Portfolio(PSY.LoadZone, base_sys, 2030, 0.07, 0.025, 0.05)
```

| Aggregation type     | Spatial unit | Typical transmission technology                                              |
|:-------------------- |:------------ |:---------------------------------------------------------------------------- |
| `PSY.Area` (default) | Area         | [`AggregateTransportTechnology`](@ref)                                       |
| `PSY.LoadZone`       | Load zone    | [`AggregateTransportTechnology`](@ref)                                       |
| `PSY.ACBus`          | Bus          | [`NodalACTransportTechnology`](@ref), [`NodalHVDCTransportTechnology`](@ref) |

Nodal models need more data — bus types, line impedances, voltages — and produce much larger
optimization problems, so zonal aggregation is the usual choice for capacity expansion.

## Units of topology data

PowerSystems 6 topology constructors take an `input_basis`. Pass `u"NU"` to give values
such as a bus `base_voltage` in natural units (kV), consistent with the rest of a portfolio.

## See Also

  - [Define Regions and Topology](@ref)
  - [`add_topology!`](@ref)
  - [`AggregateTransportTechnology`](@ref)
  - [`NodalACTransportTechnology`](@ref)
