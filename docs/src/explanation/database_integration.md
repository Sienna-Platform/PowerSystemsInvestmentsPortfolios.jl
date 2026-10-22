```@meta
CurrentModule = PowerSystemsInvestmentsPortfolios
```

# Database Integration

## What problem it solves

Constructing a [`Portfolio`](@ref) manually field-by-field is verbose for large, real-world systems with hundreds of technologies, many zones, time series data for every technology, and complex financial parameters. A database back-end (SiennaGridDB) stores technology inputs in a structured relational schema that is maintained separately from any specific model run. The PSIP database parser reads that schema and automatically translates it into typed PSIP structs, ready to pass to the optimizer.

The parser handles: topology creation, technology construction (supply, storage, transmission), demand requirements, existing units in the base system, time series loading, and technology financial data — everything that would otherwise require hundreds of individual [`add_technology!`](@ref) and [`add_topology!`](@ref) calls.

!!! warning "Not yet updated for PowerSystems 6"
    
    Parts of the parser still construct the removed `Zone` and `Node` region types, so
    `database_to_portfolio` does not run on this version. The mapping below describes the
    intended behavior once the parser is updated.

## Conceptual mapping

The database parser maps SiennaGridDB relational tables to PSIP types:

| Database concept                | PSIP type                                                                                               |
|:------------------------------- |:------------------------------------------------------------------------------------------------------- |
| `planning_regions` table rows   | `PSY.Area` in the base system                                                                           |
| `balancing_topologies` rows     | `PSY.ACBus` in the base system                                                                          |
| `supply_technologies` rows      | [`SupplyTechnology`](@ref)                                                                              |
| `generation_units` rows         | [`ExistingDevices`](@ref) supplemental attribute                                                        |
| `storage_units` rows            | [`StorageTechnology`](@ref)                                                                             |
| `transport_technologies` rows   | [`AggregateTransportTechnology`](@ref), or [`NodalACTransportTechnology`](@ref) for a nodal aggregation |
| `loads` rows                    | [`DemandRequirement`](@ref)                                                                             |
| `time_series_associations` rows | InfrastructureSystems time series attachments                                                           |

## How to invoke it

The public entry point is `PowerSystemsInvestmentsPortfolios.DBParser.database_to_portfolio`.
`db_parser.jl` is a submodule (`DBParser`), staged for later extraction into its own package,
so it is reached through its qualified path rather than an exported name. Portfolio-level
financial data is not stored in the database and must be provided as arguments:

```julia
using PowerSystemsInvestmentsPortfolios
import PowerSystemsInvestmentsPortfolios as PSIP
import PowerSystems as PSY

portfolio = PSIP.DBParser.database_to_portfolio(
    "path/to/sienna_grid.db",   # path to the SiennaGridDB SQLite file
    0.07,                        # discount_rate
    0.025,                       # inflation_rate
    0.05,                        # interest_rate
    2030;                        # base_year
    aggregation=PSY.ACBus,     # optional: spatial resolution (default PSY.Area)
    system=base_sys,           # optional: PSY.System with existing grid data
)
```

!!! warning
    
    The `database_to_portfolio` interface reflects the current SiennaGridDB schema. As SiennaGridDB evolves, field mappings and query names may change. For the current interface, consult the `db_parser.jl` source and the SiennaGridDB documentation.

## Status and future direction

The database parser is the primary integration point between SiennaGridDB and PSIP. It is designed to give the Sienna stack a structured, database-backed path for ingesting large-scale real-world datasets without manual data entry.

Note that the parser's SQL queries are tightly coupled to the current SiennaGridDB schema. Users who maintain their own database schemas should consult `db_parser.jl` directly to understand the expected table and column names.

## See also

  - [Regions and Topology](@ref)
  - [`SupplyTechnology`](@ref)
  - [`StorageTechnology`](@ref)
  - [`AggregateTransportTechnology`](@ref)
  - [`DemandRequirement`](@ref)
  - [`add_technology!`](@ref)
  - [`add_topology!`](@ref)
  - [`add_requirement!`](@ref)
