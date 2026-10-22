```@meta
CurrentModule = PowerSystemsInvestmentsPortfolios
```

# The Portfolio

## What is a Portfolio?

A [`Portfolio`](@ref) is the central data container in `PowerSystemsInvestmentsPortfolios.jl`
(PSIP). It plays the same role for capacity expansion modeling that `PSY.System` plays for
production cost modeling: everything lives in it, and the optimizer reads from it.

Where a `PSY.System` describes the grid as it exists at a point in time, a `Portfolio`
describes the *space of possibilities* for future investment. It holds:

  - **Technology candidates** — generation, storage, transmission, and demand options
  - **Requirements** — policies that must be satisfied (e.g., reserve margins, renewable
    portfolio standards)
  - **Supplemental attributes** — links from technologies to existing, retiring, and
    retrofittable units
  - **Time series** — capacity factors, load shapes, and cost trajectories
  - **Financial data** — base year, discount, inflation, and interest rates
  - **A base system** — the existing grid and its topology

The optimizer, `PowerSystemsInvestments.jl` (PSI), decides which technologies to build or
retire over the investment horizon.

## Portfolio vs. System

|                  | `PSY.System`                     | `PSIP.Portfolio`                             |
|:---------------- |:-------------------------------- |:-------------------------------------------- |
| Primary question | What exists now?                 | What can be built, when, where?              |
| Central concept  | Component (bus, generator, line) | Technology candidate                         |
| Spatial unit     | Bus (`ACBus`)                    | PSY topology: `Area`, `LoadZone`, or `ACBus` |
| Time dimension   | Single operating snapshot        | Multi-period investment horizon              |
| Units            | Per-unit or natural              | Natural units (MW, MWh, USD)                 |

A `Portfolio` always wraps a `PSY.System` (the `base_system` field). The system describes the
existing grid; the portfolio describes how that grid might change.

## Fields of a Portfolio

| Field                   | Type                                                | Purpose                                                                     |
|:----------------------- |:--------------------------------------------------- |:--------------------------------------------------------------------------- |
| `aggregation`           | `Type{<:Union{PSY.ACBus, PSY.AggregationTopology}}` | Spatial resolution of the study; `PSY.Area` by default                      |
| `data`                  | `IS.SystemData`                                     | Stores technologies, requirements, supplemental attributes, and time series |
| `base_system`           | `PSY.System`                                        | The existing grid and its topology                                          |
| `investment_schedule`   | `Union{Nothing, InvestmentScheduleResults}`         | `nothing` until investment decisions are stored                             |
| `time_series_directory` | `Union{Nothing, String}`                            | Optional directory for time series storage                                  |
| `financial_data`        | `Union{Nothing, PortfolioFinancialData}`            | Portfolio-wide economic parameters; see [`PortfolioFinancialData`](@ref)    |
| `metadata`              | `PortfolioMetadata`                                 | Name, description, and data source                                          |
| `internal`              | `IS.InfrastructureSystemsInternal`                  | InfrastructureSystems bookkeeping                                           |

Read and change these through accessors — [`get_base_system`](@ref),
[`get_financial_data`](@ref), [`set_name!`](@ref), and so on — rather than through the
fields.

## The `base_system` Relationship

Every `Portfolio` holds a `PSY.System`. The base system serves two purposes:

 1. **Topology** — areas, load zones, buses, and arcs are stored in the base system.
    Technologies reference these components directly, and [`add_topology!`](@ref) adds new
    ones there. See [Regions and Topology](@ref).
 2. **Existing units** — an [`ExistingDevices`](@ref) attribute names base system components
    whose capacity belongs to a technology, so PSI can count existing capacity and retirements.

`Portfolio()` without a system creates an empty `PSY.System(100.0)` as the base system. This
is enough for small examples; studies of a real grid pass its `PSY.System`.

## Natural Units

All portfolio data is in **natural units**: MW, MWh, USD, minutes, years. There is no
per-unit base for technology data. Each unit-bearing field can still be read and written in
other units; see [Units and Unit Conversions](@ref).

## Constructors

```julia
Portfolio()                                           # empty, default base system
Portfolio(sys)                                        # with a base system
Portfolio(sys; financial_data=PortfolioFinancialData(2030, 0.07, 0.025, 0.05))
Portfolio(2030, 0.07, 0.025, 0.05)                    # financial data, default base system
Portfolio(PSY.LoadZone, sys, 2030, 0.07, 0.025, 0.05) # aggregation, base system, financial data
```

The keywords `name`, `description`, and `data_source` set the metadata.

## See Also

  - [`Portfolio`](@ref)
  - [`PortfolioFinancialData`](@ref)
  - [Regions and Topology](@ref)
  - [Save and Load a Portfolio](@ref)
