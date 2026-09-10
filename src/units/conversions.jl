#=
Unit conversion system for power systems components.

Core abstraction: a UnitCategory defines a physical quantity (power, impedance, etc.)
with a natural unit and a way to compute the per-unit base value for any component.

Portfolios does not support System-base of Device-base units, so this system only supports 
conversion between natural units and user-specified display units.
=#

# ============================================================
# Unit categories
# ============================================================

"""
    FuelCurveUnits

A `NamedTuple` type `(energy_unit, fuel_unit, currency_unit)` of `Unitful.Units`
used to describe the units of a `FuelCurve`. Its natural units are
`(energy_unit=u"MW"*u"hr", fuel_unit=MMBtu, currency_unit=USD)`.
"""
const FuelCurveUnits = NamedTuple{
    (:energy_unit, :fuel_unit, :currency_unit),
    T,
} where {T <: Tuple{<:Unitful.Units, <:Unitful.Units, <:Unitful.Units}}

"""
    ConversionUnits

A `NamedTuple` type `(x_unit, y_unit)` of `Unitful.Units` used to describe the
two axes of a cost curve or value curve — `x_unit` for the independent variable
(e.g. power or energy) and `y_unit` for the dependent variable (e.g. cost).
"""
const ConversionUnits =
    NamedTuple{(:x_unit, :y_unit), T} where {T <: Tuple{<:Unitful.Units, <:Unitful.Units}}

const _UNIT_AWARE = Union{Technology, Requirement, SupplementalAttribute}
const _UNIT_OPTIONS = Union{Unitful.Units, ConversionUnits, FuelCurveUnits, IS.NaturalUnit}

# Can import relevant units from PSY 
abstract type UnitCategory end

struct PowerCategory <: UnitCategory end
struct ImpedanceCategory <: UnitCategory end
struct AdmittanceCategory <: UnitCategory end
struct VoltageCategory <: UnitCategory end
struct CurrentCategory <: UnitCategory end
struct CostCategory <: UnitCategory end
struct FuelCategory <: UnitCategory end
struct FuelConsumptionEnergyCategory <: UnitCategory end
struct FuelConsumptionPowerCategory <: UnitCategory end
struct EmissionsMassCategory <: UnitCategory end
struct EmissionsCostCategory <: UnitCategory end
struct EmissionsFuelCategory <: UnitCategory end
struct EmissionsEnergyCategory <: UnitCategory end
struct FuelCurveCategory <: UnitCategory end
struct PowerCostCategory <: UnitCategory end
struct EnergyCostCategory <: UnitCategory end
struct EnergyCostScalarCategory <: UnitCategory end
struct FuelCostCategory <: UnitCategory end
struct OPSTimeCategory <: UnitCategory end
struct INVTimeCategory <: UnitCategory end
struct MinuteTimeCategory <: UnitCategory end
struct EnergyCategory <: UnitCategory end
struct RampingCategory <: UnitCategory end

const POWER = PowerCategory()
const IMPEDANCE = ImpedanceCategory()
const ADMITTANCE = AdmittanceCategory()
const VOLTAGE = VoltageCategory()
const CURRENT = CurrentCategory()
const OPS_TIME = OPSTimeCategory()
const INV_TIME = INVTimeCategory()
const MINUTE_TIME = MinuteTimeCategory()
const ENERGY = EnergyCategory()
const COST = CostCategory()
const FUEL = FuelCategory()
const FUEL_CONSUMPTION_ENERGY = FuelConsumptionEnergyCategory()
const FUEL_CONSUMPTION_POWER = FuelConsumptionPowerCategory()
const EMISSIONS_MASS = EmissionsMassCategory()
const EMISSIONS_COST = EmissionsCostCategory()
const EMISSIONS_FUEL = EmissionsFuelCategory()
const EMISSIONS_ENERGY = EmissionsEnergyCategory()
const FUEL_CURVE = FuelCurveCategory()
const POWER_COST = PowerCostCategory()
const ENERGY_COST = EnergyCostCategory()
const ENERGY_COST_SCALAR = EnergyCostScalarCategory()
const FUEL_COST = FuelCostCategory()
const RAMPING = RampingCategory()

"""
    natural_unit(category) → Unitful.Units

The natural (physical) unit for this category.
"""
natural_unit(::PowerCategory) = u"MW"
natural_unit(::ImpedanceCategory) = u"Ω"
natural_unit(::AdmittanceCategory) = u"S"
natural_unit(::VoltageCategory) = u"kV"
natural_unit(::CurrentCategory) = u"kA"
natural_unit(::OPSTimeCategory) = u"hr"
natural_unit(::INVTimeCategory) = u"yr"
natural_unit(::MinuteTimeCategory) = u"minute"
natural_unit(::EnergyCategory) = natural_unit(POWER) * natural_unit(OPS_TIME)
natural_unit(::RampingCategory) = u"MW/minute"

natural_unit(::CostCategory) = USD
natural_unit(::PowerCostCategory) = (x_unit=u"MW", y_unit=USD)
natural_unit(::EnergyCostCategory) = (x_unit=u"MW" * u"hr", y_unit=USD)
natural_unit(::EnergyCostScalarCategory) = USD / (u"MW" * u"hr")

natural_unit(::FuelCategory) = MMBtu
natural_unit(::FuelConsumptionEnergyCategory) = (x_unit=u"MW" * u"hr", y_unit=MMBtu)
natural_unit(::FuelConsumptionPowerCategory) = MMBtu / u"MW"
natural_unit(::EmissionsMassCategory) = Mt
natural_unit(::EmissionsCostCategory) = USD / tonne
natural_unit(::EmissionsFuelCategory) = tonne / MMBtu
natural_unit(::EmissionsEnergyCategory) = Mt / (u"MW" * u"hr")
natural_unit(::FuelCostCategory) = (x_unit=MMBtu, y_unit=USD)
natural_unit(::FuelCurveCategory) =
    (energy_unit=u"MW" * u"hr", fuel_unit=MMBtu, currency_unit=USD)

# --- Return value with its default natural units ---
function convert_units(c, val::Number, from::UnitCategory, to::IS.NaturalUnit)
    return val * natural_unit(from)
end

# --- Convert from natural units to a target Unitful unit ---
function convert_units(c, val::Number, from::UnitCategory, to::Unitful.Units)
    units = natural_unit(from)
    val = val * units
    return uconvert(to, val)
end

function convert_units(c, val::Number, from::Unitful.Units, to::Unitful.Units)
    val = val * from
    return uconvert(to, val)
end

# --- Convert from a Unitful quantity to default natural units ---
function convert_units(c, val::Quantity, from::UnitCategory, to::UnitCategory)
    return uconvert(natural_unit(to), val)
end

#######################################################
# Units-aware get_value / set_value
#
# Fields are stored internally in a pre-defined set of natural units (NU). The 4-arg `get_value`
# converts from the default units to a requested target unit.
#######################################################

val_to_symbol(::Val{T}) where {T} = T
val_to_string(v::Val) = String(val_to_symbol(v))

# `InfrastructureSystems.NU` (natural units) passed as a `from`/`to` argument is treated
# as equivalent to the field's assumed internal (natural) units, i.e. no conversion.
_resolve_nu(u, natural_unit) = u isa IS.NaturalUnit ? natural_unit : u

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
    value = Base.getproperty(t, val_to_symbol(field))
    base_unit = natural_unit(_unit_category(from))
    return _natural_unit_conversions(t, value, base_unit, _resolve_nu(to, base_unit))
end

# Operation costs requires special handling for SupplyTechnologies, since it can be a 
# FuelCurve or CostCurve, and the units are different for each.
function get_value(
    t::SupplyTechnology,
    field::Val{:operation_costs},
    from::Val,
    to::_UNIT_OPTIONS,
)
    value = Base.getproperty(t, val_to_symbol(field))
    variable = get_variable_operation_cost(value)
    if isa(variable, FuelCurve)
        from = Val(:fuel_curve)
    end
    base_unit = natural_unit(_unit_category(from))
    return _natural_unit_conversions(t, value, base_unit, _resolve_nu(to, base_unit))
end

"""
    set_value(t::Technology, field::Val, val, conversion_unit::Val) -> value

Set `t`'s field value, converting from `val`'s units to our default natural units.
Returns the value in natural units.
"""

# ---- From Unitful.Quantity (natural units): inverse conversion ----
function set_value(
    t::T,
    field::U,
    value,
    from::_UNIT_OPTIONS,
    to::Val,
) where {T <: _UNIT_AWARE, U}
    base_unit = natural_unit(_unit_category(to))
    return IS._strip_units(
        _natural_unit_conversions(t, value, _resolve_nu(from, base_unit), base_unit),
    )
end

# Operation costs requires special handling for SupplyTechnologies, since it can be a 
# FuelCurve or CostCurve, and the units are different for each.
function set_value(
    t::T,
    field::Val{:operation_costs},
    value,
    from::_UNIT_OPTIONS,
    to::Val,
) where {T <: SupplyTechnology}
    if isa(get_variable_operation_cost(value), FuelCurve)
        to = Val(:fuel_curve)
    end
    base_unit = natural_unit(_unit_category(to))
    return IS._strip_units(
        _natural_unit_conversions(t, value, _resolve_nu(from, base_unit), base_unit),
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

_natural_unit_conversions(base, v::PSY.StartUpShutDown, from, to) = (
    startup=_natural_unit_conversions(base, v.startup, from, to),
    shutdown=_natural_unit_conversions(base, v.shutdown, from, to),
)

_natural_unit_conversions(base, v::PSY.StartUpStages, from, to) = (
    hot=IS._strip_units(_natural_unit_conversions(base, v.hot, from, to)),
    warm=IS._strip_units(_natural_unit_conversions(base, v.warm, from, to)),
    cold=IS._strip_units(_natural_unit_conversions(base, v.cold, from, to)),
)

_natural_unit_conversions(base, v::PSY.STORAGE_OPERATION_MODES, from, to) = (
    charge=IS._strip_units(_natural_unit_conversions(base, v.charge, from, to)),
    discharge=IS._strip_units(_natural_unit_conversions(base, v.discharge, from, to)),
)

# ---- Dict-valued fields (e.g. per-fuel rates keyed by an enum) ----
_natural_unit_conversions(base, v::Dict, cu, u) =
    Dict(k => _natural_unit_conversions(base, val, cu, u) for (k, val) in v)

# `_strip_units` has no generic Dict method (IS's fallback is the identity); a
# Dict-valued convertible field needs each value stripped individually.
IS._strip_units(d::Dict) = Dict(k => IS._strip_units(v) for (k, v) in d)

# _set_value(t::Technology, val::Quantity, cu::Val)

# Physical category implied by a field's conversion unit.
_unit_category(::Val{:mw}) = POWER
_unit_category(::Val{:mwh}) = ENERGY
_unit_category(::Val{:ohm}) = IMPEDANCE
_unit_category(::Val{:kv}) = VOLTAGE
_unit_category(::Val{:hr}) = OPS_TIME
_unit_category(::Val{:min}) = MINUTE_TIME
_unit_category(::Val{:yr}) = INV_TIME
_unit_category(::Val{:usd_per_mw}) = POWER_COST
_unit_category(::Val{:usd_per_mwh}) = ENERGY_COST
_unit_category(::Val{:usd_per_mwh_scalar}) = ENERGY_COST_SCALAR
_unit_category(::Val{:usd_per_mmbtu}) = FUEL_COST
_unit_category(::Val{:usd}) = COST
_unit_category(::Val{:mmbtu}) = FUEL
_unit_category(::Val{:mmbtu_per_mwh}) = FUEL_CONSUMPTION_ENERGY
_unit_category(::Val{:mmbtu_per_mw}) = FUEL_CONSUMPTION_POWER
_unit_category(::Val{:fuel_curve}) = FUEL_CURVE
_unit_category(::Val{:mt}) = EMISSIONS_MASS
_unit_category(::Val{:usd_per_t}) = EMISSIONS_COST
_unit_category(::Val{:t_per_mmbtu}) = EMISSIONS_FUEL
_unit_category(::Val{:mt_per_mwh}) = EMISSIONS_ENERGY
_unit_category(::Val{:mw_per_min}) = RAMPING
