"""
    mutable struct TechnologyFinancialData <: FinancialData
        capital_recovery_period::Int64
        technology_base_year::Int64
        debt_fraction::Float64
        debt_rate::Float64
        return_on_equity::Float64
        tax_rate::Float64
        discount_rate::Float64
        inflation_rate::Float64
        interest_rate::Float64
    end

# Arguments

  - `capital_recovery_period::Int64`: Capital recovery period (in years) used for determining overnight capital costs from annualized investment costs
  - `technology_base_year::Int64`: Year for which all dollar values for this technology are reported. Will be converted to dollars in the model base year.
  - `debt_fraction::Float64`: Fraction of capital financed with debt
  - `debt_rate::Float64`: Nominal debt rate for a technology
  - `return_on_equity::Float64`: Fraction of capital financed with debt
  - `tax_rate::Float64`: Combined assumed marginal state and federal tax rate
  - `discount_rate::Float64`: Discount rate used to convert future costs to a net present value in the model base year
  - `inflation_rate::Float64`: Inflation rate used to convert costs from `technology_base_year` to the model base year
  - `interest_rate::Float64`: Interest rate for financing calculations
"""
mutable struct TechnologyFinancialData <: FinancialData
    "Capital recovery period (in years) used for determining overnight capital costs from annualized investment costs"
    capital_recovery_period::Int64
    "Year for which all dollar values for this technology are reported. Will be converted to dollars in the model base year."
    technology_base_year::Int64
    "Fraction of capital financed with debt"
    debt_fraction::Float64
    "Nominal debt rate for a technology"
    debt_rate::Float64
    "Assumed rate of return on the share of assets financed with equity"
    return_on_equity::Float64
    "Combined assumed marginal state and federal tax rate"
    tax_rate::Float64
    "Discount rate used to convert future costs to a net present value in the model base year"
    discount_rate::Float64
    "Inflation rate used to convert costs from `technology_base_year` to the model base year"
    inflation_rate::Float64
    "Interest rate for financing calculations"
    interest_rate::Float64
end

function TechnologyFinancialData(;
    capital_recovery_period,
    technology_base_year,
    debt_fraction,
    debt_rate,
    return_on_equity,
    tax_rate,
    discount_rate,
    inflation_rate,
    interest_rate,
)
    TechnologyFinancialData(
        capital_recovery_period,
        technology_base_year,
        debt_fraction,
        debt_rate,
        return_on_equity,
        tax_rate,
        discount_rate,
        inflation_rate,
        interest_rate,
    )
end

"""
Get [`TechnologyFinancialData`](@ref) `capital_recovery_period`.
"""
get_capital_recovery_period(value::TechnologyFinancialData) = value.capital_recovery_period
"""
Get [`TechnologyFinancialData`](@ref) `technology_base_year`.
"""
get_technology_base_year(value::TechnologyFinancialData) = value.technology_base_year
"""
Get [`TechnologyFinancialData`](@ref) `debt_fraction`.
"""
get_debt_fraction(value::TechnologyFinancialData) = value.debt_fraction
"""
Get [`TechnologyFinancialData`](@ref) `debt_rate`.
"""
get_debt_rate(value::TechnologyFinancialData) = value.debt_rate
"""
Get [`TechnologyFinancialData`](@ref) `return_on_equity`.
"""
get_return_on_equity(value::TechnologyFinancialData) = value.return_on_equity
"""
Get [`TechnologyFinancialData`](@ref) `tax_rate`.
"""
get_tax_rate(value::TechnologyFinancialData) = value.tax_rate
"""
Get [`TechnologyFinancialData`](@ref) `discount_rate`.
"""
get_discount_rate(value::TechnologyFinancialData) = value.discount_rate
"""
Get [`TechnologyFinancialData`](@ref) `inflation_rate`.
"""
get_inflation_rate(value::TechnologyFinancialData) = value.inflation_rate
"""
Get [`TechnologyFinancialData`](@ref) `interest_rate`.
"""
get_interest_rate(value::TechnologyFinancialData) = value.interest_rate

"""
Set [`TechnologyFinancialData`](@ref) `capital_recovery_period`.
"""
set_capital_recovery_period!(value::TechnologyFinancialData, val) =
    value.capital_recovery_period = val
"""
Set [`TechnologyFinancialData`](@ref) `technology_base_year`.
"""
set_technology_base_year!(value::TechnologyFinancialData, val) =
    value.technology_base_year = val
"""
Set [`TechnologyFinancialData`](@ref) `debt_fraction`.
"""
set_debt_fraction!(value::TechnologyFinancialData, val) = value.debt_fraction = val
"""
Set [`TechnologyFinancialData`](@ref) `debt_rate`.
"""
set_debt_rate!(value::TechnologyFinancialData, val) = value.debt_rate = val
"""
Set [`TechnologyFinancialData`](@ref) `return_on_equity`.
"""
set_return_on_equity!(value::TechnologyFinancialData, val) = value.return_on_equity = val
"""
Set [`TechnologyFinancialData`](@ref) `tax_rate`.
"""
set_tax_rate!(value::TechnologyFinancialData, val) = value.tax_rate = val
"""
Set [`TechnologyFinancialData`](@ref) `discount_rate`.
"""
set_discount_rate!(value::TechnologyFinancialData, val) = value.discount_rate = val
"""
Set [`TechnologyFinancialData`](@ref) `inflation_rate`.
"""
set_inflation_rate!(value::TechnologyFinancialData, val) = value.inflation_rate = val
"""
Set [`TechnologyFinancialData`](@ref) `interest_rate`.
"""
set_interest_rate!(value::TechnologyFinancialData, val) = value.interest_rate = val
