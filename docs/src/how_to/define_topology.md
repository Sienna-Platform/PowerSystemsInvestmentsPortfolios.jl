```@meta
CurrentModule = PowerSystemsInvestmentsPortfolios
```

# Define Regions and Topology

Technologies are located with `PowerSystems.jl` topology components. A zonal portfolio uses
`Area` or `LoadZone` regions, and a nodal portfolio uses `ACBus` nodes. The topology is
stored in the portfolio's base system and must be added before any technology that
references it.

PSIP re-exports the topology types (`Area`, `LoadZone`, `ACBus`, `Arc`, ...) together with
`ACBusTypes` and `@u_str`, so no `PSY.` prefix is needed.

## Add zones

Construct each region with `input_basis=u"NU"` (natural units) and attach it with
[`add_topology!`](@ref):

```julia
using PowerSystemsInvestmentsPortfolios

portfolio = Portfolio()

west = Area(; name="West", input_basis=u"NU")
east = Area(; name="East", input_basis=u"NU")

add_topology!(portfolio, west)
add_topology!(portfolio, east)
```

## Add nodes

For a nodal portfolio, add buses. A bus can point to the `Area` and `LoadZone` it belongs
to; add those first.

```julia
lz = LoadZone(;
    name="LZ_1",
    peak_active_power=0.0,
    peak_reactive_power=0.0,
    input_basis=u"NU",
)
add_topology!(portfolio, lz)

bus_a = ACBus(;
    number=1,
    name="bus_a",
    available=true,
    bustype=ACBusTypes.REF,
    angle=0.0,
    magnitude=1.0,
    voltage_limits=(min=0.95, max=1.05),
    base_voltage=345.0,   # kV
    area=west,
    load_zone=lz,
    input_basis=u"NU",
)
add_topology!(portfolio, bus_a)
```

## Reuse the topology of an existing system

When the portfolio is built from a `PSY.System`, that system's topology is already in the
portfolio. Pass its components directly to technologies:

```julia
import PowerSystems as PSY

portfolio = Portfolio(sys)
zones = collect(get_topologies(PSY.LoadZone, portfolio))
```

## Choose the aggregation level

The portfolio's aggregation type records the spatial resolution of the study. It defaults
to `Area`; pass another type as the first constructor argument:

```julia
portfolio = Portfolio(PSY.LoadZone, sys, 2030, 0.07, 0.025, 0.05)
portfolio = Portfolio(PSY.ACBus)
```

## Query and remove topology

```julia
areas = collect(get_topologies(Area, portfolio))
west = get_topology(Area, portfolio, "West")
remove_topology!(portfolio, west)
```

!!! note
    
    A technology whose `region`, `start_region`/`end_region`, or `start_node`/`end_node`
    refers to topology that is not in the portfolio is rejected by
    [`add_technology!`](@ref). `add_region!` and `get_regions` remain as aliases of
    [`add_topology!`](@ref) and [`get_topologies`](@ref).

## See also

  - [Regions and Topology](@ref)
  - [`add_topology!`](@ref)
  - [`get_topologies`](@ref)
