"""
    CapitalCost(capital_cost, interconnection_cost)
    CapitalCost(; capital_cost, interconnection_cost)

An investment cost for candidate generation and transmission technologies which includes
overnight capital costs and last-mile interconnection costs.
"""
mutable struct CapitalCost <: InvestmentCost
    capital_cost::ValueCurve
    interconnection_cost::Float64
end

function CapitalCost(; capital_cost=LinearCurve(0.0), interconnection_cost=0.0)
    return CapitalCost(capital_cost, interconnection_cost)
end

# Sentinel constructor used as the descriptor default (`CapitalCost(nothing)`).
CapitalCost(::Nothing) = CapitalCost(LinearCurve(0.0), 0.0)

"""
Get [`CapitalCost`](@ref) `capital_cost` (USD/MW), its x-axis in `units`: `u"NU"` for natural units, or e.g. `u"kW"` for USD/kW.
"""
get_capital_cost(value::CapitalCost, units) =
    IS._strip_units(get_value(value, Val(:capital_cost), Val(:usd_per_mw), units))
get_capital_cost(value::CapitalCost) =
    _units_arg_required(get_capital_cost, Val(:usd_per_mw))
IS.display_units_arg(::typeof(get_capital_cost), ::Type{CapitalCost}) = u"NU"
"""
Set [`CapitalCost`](@ref) `capital_cost` (USD/MW), a curve in natural units.
"""
set_capital_cost!(value::CapitalCost, val) =
    value.capital_cost = set_value(value, Val(:capital_cost), val, Val(:usd_per_mw))
"""
Get [`CapitalCost`](@ref) `interconnection_cost` (USD/MW) in `units`: `u"NU"` for natural units, or e.g. `USD / u"kW"`.
"""
get_interconnection_cost(value::CapitalCost, units) =
    IS._strip_units(get_value(value, Val(:interconnection_cost), Val(:usd_per_mw), units))
get_interconnection_cost(value::CapitalCost) =
    _units_arg_required(get_interconnection_cost, Val(:usd_per_mw))
IS.display_units_arg(::typeof(get_interconnection_cost), ::Type{CapitalCost}) = u"NU"
"""
Set [`CapitalCost`](@ref) `interconnection_cost` (USD/MW) from a units-tagged value (e.g. `50.0USD / u"kW"`).
"""
set_interconnection_cost!(value::CapitalCost, val) =
    value.interconnection_cost =
        set_value(value, Val(:interconnection_cost), val, Val(:usd_per_mw))
