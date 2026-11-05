```@meta
CurrentModule = PowerSystemsInvestmentsPortfolios
```

# Financial Data

## Financial Data Lives on Each Technology

Every technology carries a [`TechnologyFinancialData`](@ref).
It holds the parameters that annualize the technology's overnight capital cost and the rates that convert its costs to a net present value.
A portfolio holds no financial data of its own: portfolio-wide rates are modeling assumptions, not data.
A study with one common rate repeats it on every technology.

The base year that all costs are discounted to belongs to the investment model.
PSI reads it from its `DiscountedCashFlow` capital model.

### `TechnologyFinancialData` Fields

| Field                     | Type      | Description                                                                                              |
|:------------------------- |:--------- |:-------------------------------------------------------------------------------------------------------- |
| `capital_recovery_period` | `Int64`   | Years over which capital cost is recovered                                                               |
| `technology_base_year`    | `Int64`   | Year in which the overnight capital cost is quoted; used for inflation adjustment to the model base year |
| `debt_fraction`           | `Float64` | Share of capital financed by debt (0–1)                                                                  |
| `debt_rate`               | `Float64` | Nominal annual interest rate on the debt portion                                                         |
| `return_on_equity`        | `Float64` | Required annual return on the equity portion                                                             |
| `tax_rate`                | `Float64` | Combined marginal state and federal tax rate                                                             |
| `discount_rate`           | `Float64` | Rate that discounts future costs to the model base year (fraction per year)                              |
| `inflation_rate`          | `Float64` | Rate that escalates costs from `technology_base_year` to the model base year (fraction per year)         |
| `interest_rate`           | `Float64` | Nominal interest rate for financing (fraction per year)                                                  |

## Capital Recovery Factor

The capital recovery factor (CRF) converts an overnight capital cost (USD/MW at construction) into an annualized payment (USD/MW/year). PSI computes the CRF from `TechnologyFinancialData` using a standard formula that accounts for the after-tax weighted average cost of capital (WACC).

The key quantities are:

  - After-tax debt cost: `debt_rate × (1 - tax_rate)`
  - After-tax equity cost: `return_on_equity × (1 - tax_rate)`
  - WACC: `debt_fraction × debt_rate × (1 - tax_rate) + (1 - debt_fraction) × return_on_equity`
  - CRF: `WACC × (1 + WACC)^N / ((1 + WACC)^N - 1)`, where `N = capital_recovery_period`

The CRF represents the fraction of the overnight cost that must be recovered each year to pay back debt and equity investors over the recovery period. Multiplying the overnight capital cost by the CRF gives the annual capital payment that enters the objective function.

!!! note
    
    The exact formula used by PSI may differ in detail. These parameters are passed through to PSI unchanged; refer to the PSI documentation for the precise CRF calculation.

## How PSI Uses These Values

PSI reads financial data from each technology when it builds the model:

  - Each technology's `discount_rate` discounts its costs to the model base year, which PSI
    takes from its `DiscountedCashFlow` capital model.
  - Each technology's `inflation_rate` converts its costs from `technology_base_year` dollars
    to model base year dollars.
  - The remaining fields annualize the technology's capital cost.

## Capital Costs

The overnight cost of building a technology is stored on the technology itself, separately
from its financing:

| Type                         | Used by                                   | Fields                                                                                                            |
|:---------------------------- |:----------------------------------------- |:----------------------------------------------------------------------------------------------------------------- |
| [`CapitalCost`](@ref)        | Supply, transmission, co-located inverter | `capital_cost` (USD/MW curve), `interconnection_cost` (USD/MW)                                                    |
| [`StorageCapitalCost`](@ref) | Storage                                   | `charge_capital_cost`, `discharge_capital_cost` (USD/MW), `energy_capital_cost` (USD/MWh), `interconnection_cost` |

The cost curves are `PSY.ValueCurve`s, usually a `LinearCurve`. An `"inv_capex"` time series
of multipliers can make the cost change across investment periods.

## `technology_base_year` and Cost Inflation

Capital costs for different technologies may be quoted in different vintage years — for example, wind costs from a 2020 study and solar costs from a 2025 study. Mixing these directly would produce inconsistent cost comparisons.

PSI uses the difference between `technology_base_year` and the model base year, together with the technology's `inflation_rate`, to escalate or deflate each technology's quoted overnight cost to a consistent present-value basis before computing the annualized cost.

For example: a wind technology with `technology_base_year = 2020` and `inflation_rate = 0.025`, in a model with base year 2030, would have its overnight capital cost scaled by `(1.025)^10` before the CRF is applied. A technology whose `technology_base_year` is later than the model base year would be deflated by the same mechanism.

This adjustment ensures that all technology candidates are evaluated on a consistent cost basis regardless of when their cost estimates were produced.

## See Also

  - [`TechnologyFinancialData`](@ref)
  - [`CapitalCost`](@ref)
  - [`StorageCapitalCost`](@ref)
  - [Configure Financial Data](@ref)
