# Quick Start Guide

```@meta
CurrentModule = PowerSystemsInvestmentsPortfolios
```

## Where to Start

| I want to...                                          | Go to...                                                                       |
|:----------------------------------------------------- |:------------------------------------------------------------------------------ |
| Build my first `Portfolio` and add technologies       | [Tutorials](@ref "Create and Explore a Portfolio")                             |
| Understand how PSIP models capacity expansion data    | [Explanation — The Portfolio](@ref "The Portfolio")                            |
| Add a specific technology type                        | [How to... → Add a Supply Technology](@ref "Add a Supply Technology")          |
| Look up a specific type or function                   | [Public API Reference](@ref "Public API Reference")                            |
| See how PSIP connects to `PowerSystemsInvestments.jl` | [PSI documentation](https://github.com/NREL-Sienna/PowerSystemsInvestments.jl) |

## Key Types at a Glance

| Category                | Types                                                                                                                                                                                                                 |
|:----------------------- |:--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Container               | [`Portfolio`](@ref)                                                                                                                                                                                                   |
| Regions                 | [`Zone`](@ref), [`Node`](@ref)                                                                                                                                                                                        |
| Supply technologies     | [`SupplyTechnology`](@ref)                                                                                                                                                                                            |
| Storage technologies    | [`StorageTechnology`](@ref)                                                                                                                                                                                           |
| Co-located technologies | [`ColocatedSupplyStorageTechnology`](@ref)                                                                                                                                                                            |
| Transmission            | [`AggregateTransportTechnology`](@ref), [`NodalACTransportTechnology`](@ref)                                                                                                                                          |
| Demand                  | [`ProjectedDemand`](@ref)                                                                                                                                                                                             |
| Policy requirements     | [`CarbonCaps`](@ref), [`CarbonTax`](@ref), [`CapacityReserveMargin`](@ref), [`EnergyShareRequirements`](@ref), [`MinimumCapacityRequirements`](@ref), [`MaximumCapacityRequirements`](@ref), [`HourlyMatching`](@ref) |
| Financial data          | [`PortfolioFinancialData`](@ref), [`TechnologyFinancialData`](@ref)                                                                                                                                                   |

## Related Packages

| Package                                                                                   | Role                                                                         |
|:----------------------------------------------------------------------------------------- |:---------------------------------------------------------------------------- |
| [`InfrastructureSystems.jl`](https://github.com/NREL-Sienna/InfrastructureSystems.jl)     | Component framework and time series infrastructure shared across Sienna      |
| [`PowerSystems.jl`](https://sienna-platform.github.io/PowerSystems.jl/stable/)            | Grid snapshot data model for production cost modeling                        |
| [`PowerSystemsInvestments.jl`](https://github.com/NREL-Sienna/PowerSystemsInvestments.jl) | Capacity expansion optimization engine that consumes a `Portfolio`           |
| [`SiennaGridDB.jl`](https://github.com/NREL-Sienna/SiennaGridDB.jl)                       | Database-backed grid data source; can populate both `System` and `Portfolio` |

## Basic Usage

```julia
using PowerSystemsInvestmentsPortfolios
import PowerSystems as PSY

# Create a portfolio with financial parameters
portfolio = Portfolio(PSY.LoadZone, base_sys, 2030, 0.07, 0.025, 0.05)

# Add a planning zone
zone = Zone(; name="West", id=1)
add_region!(portfolio, zone)

# Add a supply technology
fin = TechnologyFinancialData(;
    capital_recovery_period=30,
    technology_base_year=2030,
    debt_fraction=0.5,
    debt_rate=0.07,
    return_on_equity=0.10,
    tax_rate=0.257,
)

wind = SupplyTechnology{PSY.RenewableDispatch}(;
    name="wind_west",
    id=1,
    available=true,
    power_systems_type="RenewableDispatch",
    financial_data=fin,
    region=[zone],
    capital_costs=LinearCurve(1300.0),
    capacity_limits=(min=0.0, max=5000.0),
)

add_technology!(portfolio, wind)
```

For a full walkthrough, see the [Tutorials](@ref "Create and Explore a Portfolio").
