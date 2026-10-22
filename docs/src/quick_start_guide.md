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

| Category                 | Types                                                                                                                                                                                                                 |
|:------------------------ |:--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Container                | [`Portfolio`](@ref)                                                                                                                                                                                                   |
| Topology                 | `Area`, `LoadZone`, `ACBus` from `PowerSystems.jl` (see [Regions and Topology](@ref))                                                                                                                                 |
| Supply technologies      | [`SupplyTechnology`](@ref)                                                                                                                                                                                            |
| Storage technologies     | [`StorageTechnology`](@ref)                                                                                                                                                                                           |
| Co-located technologies  | [`ColocatedSupplyStorageTechnology`](@ref)                                                                                                                                                                            |
| Transmission             | [`AggregateTransportTechnology`](@ref), [`NodalACTransportTechnology`](@ref), [`NodalHVDCTransportTechnology`](@ref)                                                                                                  |
| Demand                   | [`DemandRequirement`](@ref), [`DemandSideTechnology`](@ref)                                                                                                                                                           |
| Policy requirements      | [`CarbonCaps`](@ref), [`CarbonTax`](@ref), [`CapacityReserveMargin`](@ref), [`EnergyShareRequirements`](@ref), [`MinimumCapacityRequirements`](@ref), [`MaximumCapacityRequirements`](@ref), [`HourlyMatching`](@ref) |
| Existing capacity        | [`ExistingDevices`](@ref), [`RetirementPotential`](@ref), [`RetrofitPotential`](@ref)                                                                                                                                 |
| Costs and financial data | [`CapitalCost`](@ref), [`StorageCapitalCost`](@ref), [`PortfolioFinancialData`](@ref), [`TechnologyFinancialData`](@ref)                                                                                              |

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
import PowerSystemsInvestmentsPortfolios as PSIP
import PowerSystems as PSY
using PowerSystems: LinearCurve, CostCurve, RenewableGenerationCost

# Create a portfolio from an existing system, with financial parameters
portfolio =
    Portfolio(base_sys; financial_data=PortfolioFinancialData(2030, 0.07, 0.025, 0.05))

# Add a planning zone to the portfolio's topology
west = Area(; name="West", input_basis=u"NU")
add_topology!(portfolio, west)

# Add a supply technology located in that zone
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
    available=true,
    power_systems_type="RenewableDispatch",
    financial_data=fin,
    region=[west],
    capital_costs=CapitalCost(; capital_cost=LinearCurve(1_300_000.0)),   # USD/MW
    operation_costs=RenewableGenerationCost(CostCurve(LinearCurve(0.0))),
    capacity_limits=(min=0.0, max=5000.0),                                 # MW
)
add_technology!(portfolio, wind)

# Add a policy and link the technology to it
rps = EnergyShareRequirements(;
    name="rps",
    available=true,
    generation_fraction_requirement=0.5,
)
add_requirement!(portfolio, rps)
set_requirements!(wind, [rps])

# Save it
PSIP.to_file(portfolio, "my_portfolio.json")
```

For a full walkthrough, see the [Tutorials](@ref "Create and Explore a Portfolio").
