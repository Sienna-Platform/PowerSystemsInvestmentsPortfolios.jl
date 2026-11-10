#=
Unit conversion system for portfolio components.

Core abstraction: a UnitCategory names a physical quantity (power, voltage, a cost rate, ...)
and its natural unit, the unit a field is stored in. A portfolio has no base power, so values
convert only between natural units and other units of the same quantity.
=#

# ============================================================
# Unit categories
# ============================================================

const _UNIT_AWARE = Union{Technology, Requirement, SupplementalAttribute, InvestmentCost}
const _UNIT_OPTIONS = Unitful.Units
# Operating costs, whose cost and fuel curves carry their own units
const UnitsCarryingCost = Union{PSY.OperationalCost, IS.ProductionVariableCostCurve}

abstract type UnitCategory end

struct PowerCategory <: UnitCategory end
struct ImpedanceCategory <: UnitCategory end
struct VoltageCategory <: UnitCategory end
struct FuelConsumptionPowerCategory <: UnitCategory end
struct EmissionsMassCategory <: UnitCategory end
struct EmissionsCostCategory <: UnitCategory end
struct EmissionsEnergyCategory <: UnitCategory end
struct PowerCostCategory <: UnitCategory end
struct EnergyCostCategory <: UnitCategory end
struct OPSTimeCategory <: UnitCategory end
struct INVTimeCategory <: UnitCategory end
struct MinuteTimeCategory <: UnitCategory end
struct EnergyCategory <: UnitCategory end
struct RampingCategory <: UnitCategory end

const POWER = PowerCategory()
const IMPEDANCE = ImpedanceCategory()
const VOLTAGE = VoltageCategory()
const OPS_TIME = OPSTimeCategory()
const INV_TIME = INVTimeCategory()
const MINUTE_TIME = MinuteTimeCategory()
const ENERGY = EnergyCategory()
const FUEL_CONSUMPTION_POWER = FuelConsumptionPowerCategory()
const EMISSIONS_MASS = EmissionsMassCategory()
const EMISSIONS_COST = EmissionsCostCategory()
const EMISSIONS_ENERGY = EmissionsEnergyCategory()
const POWER_COST = PowerCostCategory()
const ENERGY_COST = EnergyCostCategory()
const RAMPING = RampingCategory()

"""
    natural_unit(category) → Unitful.Units

The natural (physical) unit for this category.
"""
natural_unit(::PowerCategory) = u"MW"
natural_unit(::ImpedanceCategory) = u"Ω"
natural_unit(::VoltageCategory) = u"kV"
natural_unit(::OPSTimeCategory) = u"hr"
natural_unit(::INVTimeCategory) = u"yr"
natural_unit(::MinuteTimeCategory) = u"minute"
natural_unit(::EnergyCategory) = natural_unit(POWER) * natural_unit(OPS_TIME)
natural_unit(::RampingCategory) = u"MW/minute"

natural_unit(::PowerCostCategory) = USD / u"MW"
natural_unit(::EnergyCostCategory) = USD / (u"MW" * u"hr")

natural_unit(::FuelConsumptionPowerCategory) = MMBtu / u"MW"
natural_unit(::EmissionsMassCategory) = Mt
natural_unit(::EmissionsCostCategory) = USD / tonne
natural_unit(::EmissionsEnergyCategory) = Mt / (u"MW" * u"hr")

# --- Convert a value from one unit to another ---
convert_units(c, val::Number, from::Unitful.Units, to::Unitful.Units) =
    uconvert(to, val * from)

#######################################################
# Units-aware get_value / set_value
#
# Fields are stored internally in a pre-defined set of natural units (u"NU"). The 4-arg `get_value`
# converts from the default units to a requested target unit.
#######################################################

val_to_symbol(::Val{T}) where {T} = T
val_to_string(v::Val) = String(val_to_symbol(v))

# Natural units, `u"NU"` as in PowerSystems, passed as a `from`/`to` argument are the field's
# internal (natural) units, i.e. no conversion.
_is_natural(u) = u == u"NU"
_resolve_nu(u, natural_unit) = _is_natural(u) ? natural_unit : u

"""
    get_value(t::Technology, field::Val, conversion_unit::Val, units) -> value

Get `t`'s field value, converting from our default natural units to `units`.
Returns a `Unitful.Quantity`. Public getters can wrap this in `_strip_units`
for the bare-number form, with `_unitful` companions returning the wrapped value.
"""
function get_value(
    t::T,
    field::Val{U},
    from::Val,
    to::_UNIT_OPTIONS,
) where {T <: _UNIT_AWARE, U}
    return _get_value(t, field, Base.getproperty(t, U), from, to)
end

function _get_value(t, field, value, from::Val, to)
    base_unit = natural_unit(_unit_category(from))
    return _natural_unit_conversions(t, value, base_unit, _resolve_nu(to, base_unit))
end

_get_value(t, field, value::UnitsCarryingCost, ::Val, to) =
    cost_in_units(t, field, value, to)
_get_value(t, field, value::IS.ValueCurve, from::Val, to) =
    curve_in_units(value, natural_unit(_unit_category(from)), to)
_get_value(t, ::Val{:curtailment_cost}, value::IS.IncrementalCurve, from::Val, to) =
    curtailment_tiers_in_units(value, natural_unit(_unit_category(from)), to)

"""
    set_value(t::Technology, field::Val, val, conversion_unit::Val) -> value

Return `val`, a units-tagged value (e.g. `100.0u"MW"`, or a `NamedTuple` or `Dict` of
them), in the field's natural units, as PowerSystems setters take it. A curve is given in
natural units.
"""
set_value(t::_UNIT_AWARE, field::Val, value, to::Val) =
    _from_tagged(field, value, natural_unit(_unit_category(to)))
set_value(t::_UNIT_AWARE, field::Val, value::UnitsCarryingCost, ::Val) =
    set_cost(t, field, value)
set_value(t::_UNIT_AWARE, field::Val, value::IS.ValueCurve, ::Val) = value

_from_tagged(field, value::Unitful.Quantity, units) =
    Unitful.ustrip(Unitful.uconvert(units, value))
_from_tagged(field, ::Nothing, units) = nothing
_from_tagged(field, value::NamedTuple, units) =
    map(v -> _from_tagged(field, v, units), value)
_from_tagged(field, value::AbstractDict, units) =
    Dict{keytype(value), MinMax}(k => _from_tagged(field, v, units) for (k, v) in value)
_from_tagged(field, value::Real, units) = throw(
    ArgumentError(
        "set_$(val_to_string(field))! requires a units-tagged value, e.g. " *
        "`$(value) * $(units)` for natural units.",
    ),
)

"""
Throw the error for a units-aware getter called without a units argument.
"""
function _units_arg_required(getter, conversion_unit::Val)
    name = nameof(getter)
    throw(
        ArgumentError(
            "`$name` requires a units argument: `$name(component, u\"NU\")` for natural " *
            "units ($(natural_unit(_unit_category(conversion_unit)))), or another unit " *
            "such as `u\"kW\"`.",
        ),
    )
end

_natural_unit_conversions(base, value::Number, from, to) =
    convert_units(base, value, from, to)

# ---- Nothing passthrough ----
_natural_unit_conversions(base, ::Nothing, ::Any, ::Any) = nothing

# ---- Compound field types ----
_natural_unit_conversions(base, v::MinMax, from, to) = (
    min=_natural_unit_conversions(base, v.min, from, to),
    max=_natural_unit_conversions(base, v.max, from, to),
)

_natural_unit_conversions(base, v::UpDown, from, to) = (
    up=_natural_unit_conversions(base, v.up, from, to),
    down=_natural_unit_conversions(base, v.down, from, to),
)

# ---- Dict-valued fields (e.g. capacity limits keyed by topology) ----
_natural_unit_conversions(base, v::Dict, cu, u) =
    Dict(k => _natural_unit_conversions(base, val, cu, u) for (k, val) in v)

# `_strip_units` has no generic Dict method (IS's fallback is the identity); a
# Dict-valued convertible field needs each value stripped individually.
IS._strip_units(d::Dict) = Dict(k => IS._strip_units(v) for (k, v) in d)

# Physical category implied by a field's conversion unit.
_unit_category(::Val{:mw}) = POWER
_unit_category(::Val{:mwh}) = ENERGY
_unit_category(::Val{:ohm}) = IMPEDANCE
_unit_category(::Val{:kv}) = VOLTAGE
_unit_category(::Val{:min}) = MINUTE_TIME
_unit_category(::Val{:yr}) = INV_TIME
_unit_category(::Val{:usd_per_mw}) = POWER_COST
_unit_category(::Val{:usd_per_mwh}) = ENERGY_COST
_unit_category(::Val{:usd_per_mwh_scalar}) = ENERGY_COST
_unit_category(::Val{:mmbtu_per_mw}) = FUEL_CONSUMPTION_POWER
_unit_category(::Val{:mt}) = EMISSIONS_MASS
_unit_category(::Val{:usd_per_t}) = EMISSIONS_COST
_unit_category(::Val{:mt_per_mwh}) = EMISSIONS_ENERGY
_unit_category(::Val{:mw_per_min}) = RAMPING
