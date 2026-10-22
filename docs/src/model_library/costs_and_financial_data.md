```@meta
CurrentModule = PowerSystemsInvestmentsPortfolios
```

# Capital Costs and Financial Data

## Capital costs

[`CapitalCost`](@ref) is the investment cost of supply and transmission technologies and of
a co-located inverter. [`StorageCapitalCost`](@ref) is the investment cost of storage, with
separate curves for charge, discharge, and energy capacity.

```@docs
CapitalCost
StorageCapitalCost
```

## Financial data

[`TechnologyFinancialData`](@ref) describes how a technology is financed. The portfolio-wide
parameters are in [`PortfolioFinancialData`](@ref). See [Financial Data](@ref).

```@docs
TechnologyFinancialData
```
