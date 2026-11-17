```@meta
CurrentModule = PowerSystemsInvestmentsPortfolios
```

# Configure Financial Data

Every technology carries its own financial data in a [`TechnologyFinancialData`](@ref).
It describes how the technology's overnight capital cost is financed and annualized, and the rates used to convert its costs to a net present value.
A portfolio holds no financial data of its own.
The base year that every cost is discounted to is a setting of the investment model, not of the portfolio.

## Technology financial data

All nine fields are required:

```julia
fin = TechnologyFinancialData(;
    capital_recovery_period=30,   # years
    technology_base_year=2030,    # year the technology's costs are quoted in
    debt_fraction=0.5,            # 50% debt financing
    debt_rate=0.07,               # nominal interest rate on debt
    return_on_equity=0.10,        # required return on equity
    tax_rate=0.257,               # combined state and federal tax rate
    discount_rate=0.07,           # discounts future costs to the model base year
    inflation_rate=0.025,         # escalates costs from technology_base_year
    interest_rate=0.05,           # nominal interest rate for financing
)
```

Pass it as the `financial_data` keyword of every supply, storage, co-located, and transmission technology; it is a required field for those types.

```julia
wind = SupplyTechnology{PSY.RenewableDispatch}(;
    name="wind_z1",
    available=true,
    power_systems_type="RenewableDispatch",
    financial_data=fin,
    # ... other fields
)
```

### Common rates across technologies

A study with one discount, inflation, and interest rate repeats them on every technology.
Build one `TechnologyFinancialData` per technology rather than sharing one instance: the struct is mutable, so a shared instance changes every technology at once.

```julia
rates = (discount_rate=0.07, inflation_rate=0.025, interest_rate=0.05)
fin_for(base_year) = TechnologyFinancialData(;
    capital_recovery_period=30,
    technology_base_year=base_year,
    debt_fraction=0.5,
    debt_rate=0.07,
    return_on_equity=0.10,
    tax_rate=0.257,
    rates...,
)
```

### Update after construction

```julia
fin = get_financial_data(wind)
set_discount_rate!(fin, 0.05)
set_inflation_rate!(fin, 0.02)
set_interest_rate!(fin, 0.04)
```

## Capital costs

The overnight capital cost of a technology is a [`CapitalCost`](@ref) (or a [`StorageCapitalCost`](@ref) for storage), quoted in `technology_base_year` dollars:

```julia
using PowerSystems: LinearCurve

capital_costs = CapitalCost(;
    capital_cost=LinearCurve(1_200_000.0),   # USD/MW
    interconnection_cost=40_000.0,           # USD/MW
)
```

To make the capital cost change across investment periods, attach an `"inv_capex"` time series of multipliers (see [Working With Time Series](@ref)).

## See also

  - [Financial Data](@ref)
  - [`TechnologyFinancialData`](@ref)
  - [`CapitalCost`](@ref)
