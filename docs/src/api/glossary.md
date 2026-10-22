```@meta
CurrentModule = PowerSystemsInvestmentsPortfolios
```

# Glossary

Key terms specific to `PowerSystemsInvestmentsPortfolios.jl` and capacity expansion modeling.

| Term                              | Definition                                                                                                                                                               |
|:--------------------------------- |:------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **Portfolio**                     | The central PSIP data container; the capacity-expansion analogue of a `PSY.System`. Holds technology candidates, regions, requirements, time series, and financial data. |
| **Technology**                    | A candidate investment option parameterized by a PSY component type (e.g., `SupplyTechnology{PSY.RenewableDispatch}`). Added via `add_technology!`.                      |
| **Requirement**                   | A policy constraint (carbon cap, reserve margin, energy mandate) that bounds the optimizer's solution. Added via `add_requirement!`.                                     |
| **Topology**                      | The `PowerSystems.jl` components that locate technologies: `Area` or `LoadZone` (zonal) and `ACBus` (nodal). Stored in the base system.                                  |
| **Investment period**             | A multi-year planning window over which capital decisions are made (e.g., 2025–2029).                                                                                    |
| **Representative period**         | A short time window (day or week) that statistically approximates a full operational year. Identified by `"year"` and `"rep_day"` time series features.                  |
| **Capital Recovery Factor (CRF)** | Converts overnight capital cost (USD/MW) to annualised payment (USD/MW/year). Computed from `TechnologyFinancialData`.                                                   |
| **Overnight capital cost**        | The total cost to build a technology, as if it were constructed instantaneously, before financing.                                                                       |
| **Capacity reserve margin**       | Required surplus of installed capacity above peak demand, expressed as a fraction (e.g., `0.15` = 15%).                                                                  |
| **Energy share requirement**      | A mandate that a specified fraction of total annual energy be served by eligible (typically renewable) resources.                                                        |
| **Hourly matching**               | A stricter clean energy standard requiring eligible resources to cover eligible demand in every hour, not just on an annual average.                                     |
| **ExistingDevices**               | A supplemental attribute (`IS.SupplementalAttribute`) marking that a technology candidate has associated existing installed capacity.                                    |
| **`power_systems_type`**          | A string field on every technology recording the PSY type name (e.g., `"RenewableDispatch"`); used to restore the type parameter when a portfolio is read from a file.   |
| **Contributing technology**       | A technology that lists a requirement in its `requirements` field; see [`get_contributing_technologies`](@ref).                                                          |
| **Masked technology**             | A supply or storage technology owned by a co-located technology; kept in the portfolio but left out of `get_technologies`.                                               |
| **Natural units**                 | The units portfolio data is stored in: MW, MWh, USD, minutes, years. No per-unit base is used.                                                                           |
| **base_system**                   | A `PSY.System` held by the portfolio; holds the topology and the existing units that technologies refer to.                                                              |
