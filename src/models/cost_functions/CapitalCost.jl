"""
    CapitalCost(capital_cost, interconnection_cost)
    CapitalCost(; capital_cost, interconnection_cost)

An investment cost for candidate generation and transmission technologies which includes
overnight capital costs and last-mile interconnection costs.
"""
@kwdef mutable struct CapitalCost <: InvestmentCost
    capital_cost::ValueCurve
    interconnection_cost::Float64
end

# Sentinel constructor used as the descriptor default (`CapitalCost(nothing)`).
CapitalCost(::Nothing) = CapitalCost(LinearCurve(0.0), 0.0)

"""
Return the `capital_cost` field of [`CapitalCost`](@ref).
"""
get_capital_cost(value::CapitalCost) = value.capital_cost
"""
Return the `interconnection_cost` field of [`CapitalCost`](@ref).
"""
get_interconnection_cost(value::CapitalCost) = value.interconnection_cost

"""
Set the `capital_cost` field of [`CapitalCost`](@ref).
"""
set_capital_cost!(value::CapitalCost, val) = value.capital_cost = val
"""
Set the `interconnection_cost` field of [`CapitalCost`](@ref).
"""
set_interconnection_cost!(value::CapitalCost, val) = value.interconnection_cost = val
