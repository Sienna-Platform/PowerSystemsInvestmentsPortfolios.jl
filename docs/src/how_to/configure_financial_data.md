```@meta
CurrentModule = PowerSystemsInvestmentsPortfolios
```

# Configure Financial Data

PSIP has two levels of financial data. Portfolio-level parameters set the economic context
for the whole study (base year, discount rate, inflation rate, interest rate).
Technology-level parameters describe how each technology's overnight capital cost is
financed and annualized.

## Portfolio-level financial data

[`PortfolioFinancialData`](@ref) holds four parameters that apply to every technology.

| Field            | Description                                            | Typical value |
|:---------------- |:------------------------------------------------------ |:------------- |
| `base_year`      | Year all costs are converted to                        | `2030`        |
| `discount_rate`  | Rate used to discount future costs (fraction per year) | `0.07`        |
| `inflation_rate` | General inflation rate (fraction per year)             | `0.025`       |
| `interest_rate`  | Nominal interest rate used for financing calculations  | `0.05`        |

### Specify at construction

Pass the four values positionally after the aggregation type and base system:

```julia
using PowerSystemsInvestmentsPortfolios
import PowerSystems as PSY

portfolio = Portfolio(
    PSY.Area,       # aggregation type
    base_system,    # PSY.System
    2030,           # base_year
    0.07,           # discount_rate
    0.025,          # inflation_rate
    0.05,           # interest_rate
)
```

or pass a [`PortfolioFinancialData`](@ref) as a keyword:

```julia
portfolio =
    Portfolio(base_system; financial_data=PortfolioFinancialData(2030, 0.07, 0.025, 0.05))
```

### Update after construction

```julia
set_base_year!(portfolio, 2035)
set_discount_rate!(portfolio, 0.05)
set_inflation_rate!(portfolio, 0.02)
set_interest_rate!(portfolio, 0.04)

get_financial_data(portfolio)   # PortfolioFinancialData, or nothing if never set
```

!!! note
    
    The individual setters change an existing `PortfolioFinancialData`. A portfolio built
    without financial data has `nothing` there; give it one with the constructor first.

## Technology-level financial data

[`TechnologyFinancialData`](@ref) describes how a technology is financed. All six fields are
required:

```julia
fin = TechnologyFinancialData(;
    capital_recovery_period=30,   # years
    technology_base_year=2030,    # year the technology's costs are quoted in
    debt_fraction=0.5,            # 50% debt financing
    debt_rate=0.07,               # nominal interest rate on debt
    return_on_equity=0.10,        # required return on equity
    tax_rate=0.257,               # combined state and federal tax rate
)
```

Pass it as the `financial_data` keyword of every supply, storage, co-located, and
transmission technology; it is a required field for those types.

```julia
wind = SupplyTechnology{PSY.RenewableDispatch}(;
    name="wind_z1",
    available=true,
    power_systems_type="RenewableDispatch",
    financial_data=fin,
    # ... other fields
)
```

## Capital costs

The overnight capital cost of a technology is a [`CapitalCost`](@ref) (or a
[`StorageCapitalCost`](@ref) for storage), quoted in `technology_base_year` dollars:

```julia
using PowerSystems: LinearCurve

capital_costs = CapitalCost(;
    capital_cost=LinearCurve(1_200_000.0),   # USD/MW
    interconnection_cost=40_000.0,           # USD/MW
)
```

To make the capital cost change across investment periods, attach an `"inv_capex"` time
series of multipliers (see [Working With Time Series](@ref)).

## See also

  - [Financial Data](@ref)
  - [`PortfolioFinancialData`](@ref)
  - [`TechnologyFinancialData`](@ref)
  - [`CapitalCost`](@ref)
