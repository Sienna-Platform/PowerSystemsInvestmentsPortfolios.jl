"""
$(TYPEDEF)
$(TYPEDFIELDS)

    StorageCapitalCost(charge_capital_cost, discharge_capital_cost, energy_capital_cost, interconnection)
    StorageCapitalCost(; charge_capital_cost, discharge_capital_cost, energy_capital_cost, interconnection_cost)

An investment cost for candidate storage technologies which includes 
overnight capital costs and last-mile interconnection costs.
"""

@kwdef mutable struct StorageCapitalCost <: InvestmentCost
    charge_capital_cost::ValueCurve
    discharge_capital_cost::ValueCurve
    energy_capital_cost::ValueCurve
    interconnection_cost::Float64
end

# Constructor for demo purposes; non-functional.
function StorageCapitalCost(::Nothing)
    return StorageCapitalCost(LinearCurve(0.0), LinearCurve(0.0), LinearCurve(0.0), 0.0)
end

"""
Return the `charge_capital_cost` field of [`StorageCapitalCost`](@ref).
"""
get_charge_capital_cost(value::StorageCapitalCost) = value.charge_capital_cost

"""
Return the `discharge_capital_cost` field of [`StorageCapitalCost`](@ref).
"""
get_discharge_capital_cost(value::StorageCapitalCost) = value.discharge_capital_cost

"""
Return the `energy_capital_cost` field of [`StorageCapitalCost`](@ref).
"""
get_energy_capital_cost(value::StorageCapitalCost) = value.energy_capital_cost

"""
Return the `interconnection_cost` field of [`StorageCapitalCost`](@ref).
"""
get_interconnection_cost(value::StorageCapitalCost) = value.interconnection_cost

"""
Set the `charge_capital_cost` field of [`StorageCapitalCost`](@ref).
"""
set_charge_capital_cost!(value::StorageCapitalCost, val) = value.charge_capital_cost = val
"""
Set the `discharge_capital_cost` field of [`StorageCapitalCost`](@ref).
"""
set_discharge_capital_cost!(value::StorageCapitalCost, val) =
    value.discharge_capital_cost = val
"""
Set the `energy_capital_cost` field of [`StorageCapitalCost`](@ref).
"""
set_energy_capital_cost!(value::StorageCapitalCost, val) = value.energy_capital_cost = val
"""
Set the `interconnection_cost` field of [`StorageCapitalCost`](@ref).
"""
set_interconnection_cost!(value::StorageCapitalCost, val) = value.interconnection_cost = val
