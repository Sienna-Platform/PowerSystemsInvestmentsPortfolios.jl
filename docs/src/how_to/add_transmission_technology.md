```@meta
CurrentModule = PowerSystemsInvestmentsPortfolios
```

# Add a Transmission Technology

PSIP provides three transmission technology types:

  - [`AggregateTransportTechnology`](@ref) — a transfer corridor between two zones
    (`Area` or `LoadZone`) in a zonal model.
  - [`NodalACTransportTechnology`](@ref) — an AC line between two buses, with the electrical
    parameters needed for power-flow constraints.
  - [`NodalHVDCTransportTechnology`](@ref) — an HVDC link between two buses.

The endpoints are topology components that must already be in the portfolio (see
[Define Regions and Topology](@ref)).

## When to use each

| Type                           | Endpoints                     | Electrical parameters          | Typical use                  |
|:------------------------------ |:----------------------------- |:------------------------------ |:---------------------------- |
| `AggregateTransportTechnology` | `start_region` / `end_region` | Line loss fraction             | Zonal capacity expansion     |
| `NodalACTransportTechnology`   | `start_node` / `end_node`     | Resistance, reactance, voltage | Nodal / DC power flow models |
| `NodalHVDCTransportTechnology` | `start_node` / `end_node`     | Loss curve                     | Nodal models with HVDC       |

## Zonal example

```julia
using PowerSystemsInvestmentsPortfolios
import PowerSystems as PSY
using PowerSystems: LinearCurve

portfolio = Portfolio()

west = Area(; name="West", input_basis=u"NU")
east = Area(; name="East", input_basis=u"NU")
add_topology!(portfolio, west)
add_topology!(portfolio, east)

fin = TechnologyFinancialData(;
    capital_recovery_period=40,
    technology_base_year=2030,
    debt_fraction=0.6,
    debt_rate=0.05,
    return_on_equity=0.10,
    tax_rate=0.21,
)

corridor = AggregateTransportTechnology{PSY.ACBranch}(;
    name="west_east",
    available=true,
    power_systems_type="ACBranch",
    start_region=west,
    end_region=east,
    financial_data=fin,
    capital_costs=CapitalCost(; capital_cost=LinearCurve(500.0)),   # USD/MW
    capacity_limits=(min=0.0, max=1000.0),                          # MW
    line_loss=0.01,
)

add_technology!(portfolio, corridor)
```

## Nodal AC example

For nodal models, connect two buses and give the line's electrical parameters in natural
units. Setting `unit_size` lets the model build the line in discrete units.

```julia
lz =
    LoadZone(; name="LZ", peak_active_power=0.0, peak_reactive_power=0.0, input_basis=u"NU")
add_topology!(portfolio, lz)

bus(number, name, type) = ACBus(;
    number=number,
    name=name,
    available=true,
    bustype=type,
    angle=0.0,
    magnitude=1.0,
    voltage_limits=(min=0.95, max=1.05),
    base_voltage=345.0,
    area=west,
    load_zone=lz,
    input_basis=u"NU",
)
bus_a = bus(1, "bus_a", ACBusTypes.REF)
bus_b = bus(2, "bus_b", ACBusTypes.PQ)
add_topology!(portfolio, bus_a)
add_topology!(portfolio, bus_b)

ac_line = NodalACTransportTechnology{PSY.Line}(;
    name="a_b",
    available=true,
    power_systems_type="Line",
    start_node=bus_a,
    end_node=bus_b,
    financial_data=fin,
    capital_costs=CapitalCost(; capital_cost=LinearCurve(600.0)),   # USD/MW
    capacity_limits=(min=0.0, max=500.0),                           # MW
    unit_size=250.0,                                                # MW per line
    reactance=10.0,                                                 # Ω
    resistance=1.0,                                                 # Ω
    voltage=345.0,                                                  # kV
)

add_technology!(portfolio, ac_line)
```

## Nodal HVDC example

The HVDC loss model is a `LinearCurve` (a proportional loss rate and a constant loss, as
fractions of installed capacity) or a `PiecewiseIncrementalCurve`.

```julia
hvdc = NodalHVDCTransportTechnology{PSY.TwoTerminalLCCLine}(;
    name="hvdc_ab",
    available=true,
    power_systems_type="TwoTerminalLCCLine",
    start_node=bus_a,
    end_node=bus_b,
    financial_data=fin,
    capacity_limits=(min=0.0, max=2000.0),
    line_loss=LinearCurve(0.02, 0.0),
)

add_technology!(portfolio, hvdc)
```

## Key fields

| Field                         | Type                      | Description                                                   |
|:----------------------------- |:------------------------- |:------------------------------------------------------------- |
| `start_region` / `end_region` | `PSY.AggregationTopology` | Endpoints of an aggregate corridor                            |
| `start_node` / `end_node`     | `PSY.Bus`                 | Endpoints of a nodal line                                     |
| `capacity_limits`             | `MinMax`                  | Minimum and maximum transfer capacity in MW                   |
| `unit_size`                   | `Float64`                 | Capacity of each line for discrete investment, MW (default 1) |
| `capital_costs`               | [`CapitalCost`](@ref)     | Cost of new capacity (USD/MW) and interconnection cost        |
| `line_loss`                   | `Float64` or curve        | Loss fraction (aggregate) or loss curve (HVDC)                |
| `resistance`, `reactance`     | `Float64`                 | Series impedance of an AC line in Ω                           |
| `voltage`                     | `Float64`                 | Voltage rating of an AC line in kV                            |

## See also

  - [`AggregateTransportTechnology`](@ref)
  - [`NodalACTransportTechnology`](@ref)
  - [`NodalHVDCTransportTechnology`](@ref)
  - [Regions and Topology](@ref)
