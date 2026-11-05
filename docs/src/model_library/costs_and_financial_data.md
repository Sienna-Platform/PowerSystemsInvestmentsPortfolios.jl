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

[`TechnologyFinancialData`](@ref) describes how a technology is financed and the rates that
convert its costs to a net present value. See [Financial Data](@ref).

```@docs
TechnologyFinancialData
```
