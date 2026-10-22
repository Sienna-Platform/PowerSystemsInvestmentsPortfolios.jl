```@meta
CurrentModule = PowerSystemsInvestmentsPortfolios
```

# Transport Technologies

PSIP provides three transmission technology types. Their endpoints are PowerSystems
topology components stored in the portfolio's base system.

## `AggregateTransportTechnology{T}`

A buildable transfer corridor between two zones. Use it for zonal capacity expansion.

**Type parameter:** `T <: PSY.Device`, typically `PSY.ACBranch`.

**Key fields:** `start_region`, `end_region` (`PSY.AggregationTopology`), `capacity_limits`
(`MinMax` in MW), `unit_size` (MW), `capital_costs` ([`CapitalCost`](@ref)), `line_loss`
(fraction)

```@docs
AggregateTransportTechnology
```

## `NodalACTransportTechnology{T}`

A buildable AC line between two buses, with the electrical parameters needed for power-flow
constraints.

**Type parameter:** `T <: PSY.Device`, typically `PSY.Line` or `PSY.ACBranch`.

**Key fields:** `start_node`, `end_node` (`PSY.Bus`), `capacity_limits` (`MinMax` in MW),
`unit_size` (MW per line), `capital_costs` ([`CapitalCost`](@ref)), `reactance` and
`resistance` (Ω), `voltage` (kV)

```@docs
NodalACTransportTechnology
```

## `NodalHVDCTransportTechnology{T}`

A buildable HVDC link between two buses.

**Type parameter:** `T <: PSY.Device`, e.g. `PSY.TwoTerminalLCCLine`.

**Key fields:** `start_node`, `end_node` (`PSY.Bus`), `capacity_limits`, `unit_size`,
`capital_costs`, `line_loss` (`LinearCurve` or `PiecewiseIncrementalCurve`, as fractions of
installed capacity)

```@docs
NodalHVDCTransportTechnology
```
