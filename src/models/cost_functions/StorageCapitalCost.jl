"""
    StorageCapitalCost(charge_capital_cost, discharge_capital_cost, energy_capital_cost, interconnection_cost)
    StorageCapitalCost(; charge_capital_cost, discharge_capital_cost, energy_capital_cost, interconnection_cost)

An investment cost for candidate storage technologies which includes overnight capital
costs (for charge, discharge, and energy capacity) and last-mile interconnection costs.
"""
mutable struct StorageCapitalCost <: InvestmentCost
    charge_capital_cost::ValueCurve
    discharge_capital_cost::ValueCurve
    energy_capital_cost::ValueCurve
    interconnection_cost::Float64
end

function StorageCapitalCost(;
    charge_capital_cost=LinearCurve(0.0),
    discharge_capital_cost=LinearCurve(0.0),
    energy_capital_cost=LinearCurve(0.0),
    interconnection_cost=0.0,
)
    return StorageCapitalCost(
        charge_capital_cost,
        discharge_capital_cost,
        energy_capital_cost,
        interconnection_cost,
    )
end

# Sentinel constructor used as the descriptor default (`StorageCapitalCost(nothing)`).
StorageCapitalCost(::Nothing) =
    StorageCapitalCost(LinearCurve(0.0), LinearCurve(0.0), LinearCurve(0.0), 0.0)

"""
Get [`StorageCapitalCost`](@ref) `charge_capital_cost` (USD/MW), its x-axis in `units`: `u"NU"` for natural units, or e.g. `u"kW"` for USD/kW.
"""
get_charge_capital_cost(value::StorageCapitalCost, units) =
    IS._strip_units(get_value(value, Val(:charge_capital_cost), Val(:usd_per_mw), units))
get_charge_capital_cost(value::StorageCapitalCost) =
    _units_arg_required(get_charge_capital_cost, Val(:usd_per_mw))
IS.display_units_arg(::typeof(get_charge_capital_cost), ::Type{StorageCapitalCost}) = u"NU"
"""
Set [`StorageCapitalCost`](@ref) `charge_capital_cost` (USD/MW), a curve in natural units.
"""
set_charge_capital_cost!(value::StorageCapitalCost, val) =
    value.charge_capital_cost =
        set_value(value, Val(:charge_capital_cost), val, Val(:usd_per_mw))
"""
Get [`StorageCapitalCost`](@ref) `discharge_capital_cost` (USD/MW), its x-axis in `units`: `u"NU"` for natural units, or e.g. `u"kW"` for USD/kW.
"""
get_discharge_capital_cost(value::StorageCapitalCost, units) =
    IS._strip_units(get_value(value, Val(:discharge_capital_cost), Val(:usd_per_mw), units))
get_discharge_capital_cost(value::StorageCapitalCost) =
    _units_arg_required(get_discharge_capital_cost, Val(:usd_per_mw))
IS.display_units_arg(::typeof(get_discharge_capital_cost), ::Type{StorageCapitalCost}) =
    u"NU"
"""
Set [`StorageCapitalCost`](@ref) `discharge_capital_cost` (USD/MW), a curve in natural units.
"""
set_discharge_capital_cost!(value::StorageCapitalCost, val) =
    value.discharge_capital_cost =
        set_value(value, Val(:discharge_capital_cost), val, Val(:usd_per_mw))
"""
Get [`StorageCapitalCost`](@ref) `energy_capital_cost` (USD/MWh), its x-axis in `units`: `u"NU"` for natural units, or e.g. `u"kW"` for USD/kW.
"""
get_energy_capital_cost(value::StorageCapitalCost, units) =
    IS._strip_units(get_value(value, Val(:energy_capital_cost), Val(:usd_per_mwh), units))
get_energy_capital_cost(value::StorageCapitalCost) =
    _units_arg_required(get_energy_capital_cost, Val(:usd_per_mwh))
IS.display_units_arg(::typeof(get_energy_capital_cost), ::Type{StorageCapitalCost}) = u"NU"
"""
Set [`StorageCapitalCost`](@ref) `energy_capital_cost` (USD/MWh), a curve in natural units.
"""
set_energy_capital_cost!(value::StorageCapitalCost, val) =
    value.energy_capital_cost =
        set_value(value, Val(:energy_capital_cost), val, Val(:usd_per_mwh))
"""
Get [`StorageCapitalCost`](@ref) `interconnection_cost` (USD/MW) in `units`: `u"NU"` for natural units, or e.g. `USD / u"kW"`.
"""
get_interconnection_cost(value::StorageCapitalCost, units) =
    IS._strip_units(get_value(value, Val(:interconnection_cost), Val(:usd_per_mw), units))
get_interconnection_cost(value::StorageCapitalCost) =
    _units_arg_required(get_interconnection_cost, Val(:usd_per_mw))
IS.display_units_arg(::typeof(get_interconnection_cost), ::Type{StorageCapitalCost}) = u"NU"
"""
Set [`StorageCapitalCost`](@ref) `interconnection_cost` (USD/MW) from a units-tagged value (e.g. `50.0USD / u"kW"`).
"""
set_interconnection_cost!(value::StorageCapitalCost, val) =
    value.interconnection_cost =
        set_value(value, Val(:interconnection_cost), val, Val(:usd_per_mw))
