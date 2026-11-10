#######################################################
# Unit-aware methods for FunctionData and ValueCurves, converted from units `from` to
# units `to`, e.g. a cost (USD) as a function of capacity (MW). Operating costs (cost and
# fuel curves and their containers) carry their own units and are handled at the end.
#######################################################

# A `Val(:conversion_unit)` symbol maps to exactly one category (one Julia
# method per `Val` type), but some fields share a physical unit with a
# scalar field while being ValueCurve-typed (e.g. DemandSideTechnology's
# price_per_unit is USD/t, the same unit as CarbonTax's scalar
# tax_dollars_per_ton). Rather than mint a second `:usd_per_t`-shaped symbol
# purely to satisfy the curve machinery's (x_unit, y_unit) pair shape, bridge
# a bare currency-per-x rate into that pair: y_unit is always USD for these
# cost categories, so x_unit = USD / rate is recovered exactly, dimensionally.
function _natural_unit_conversions(
    base,
    v::PSY.ValueCurve,
    from::Unitful.Units,
    to::Unitful.Units,
)
    return _natural_unit_conversions(
        base,
        v,
        (x_unit=USD / from, y_unit=USD),
        (x_unit=USD / to, y_unit=USD),
    )
end

# ----Function Data----
function _natural_unit_conversions(
    base,
    v::LinearFunctionData,
    from::ConversionUnits,
    to::ConversionUnits,
)
    from_proportional = from.y_unit / from.x_unit
    from_constant = from.y_unit

    to_proportional = to.y_unit / to.x_unit
    to_constant = to.y_unit
    return LinearFunctionData(
        IS._strip_units(
            _natural_unit_conversions(
                base,
                v.proportional_term,
                from_proportional,
                to_proportional,
            ),
        ),
        IS._strip_units(
            _natural_unit_conversions(base, v.constant_term, from_constant, to_constant),
        ),
    )
end

function _natural_unit_conversions(
    base,
    v::QuadraticFunctionData,
    from::ConversionUnits,
    to::ConversionUnits,
)
    from_quadratic = from.y_unit / (from.x_unit^2)
    from_proportional = from.y_unit / from.x_unit
    from_constant = from.y_unit

    to_quadratic = to.y_unit / (to.x_unit^2)
    to_proportional = to.y_unit / to.x_unit
    to_constant = to.y_unit
    return QuadraticFunctionData(
        IS._strip_units(
            _natural_unit_conversions(base, v.quadratic_term, from_quadratic, to_quadratic),
        ),
        IS._strip_units(
            _natural_unit_conversions(
                base,
                v.proportional_term,
                from_proportional,
                to_proportional,
            ),
        ),
        IS._strip_units(
            _natural_unit_conversions(base, v.constant_term, from_constant, to_constant),
        ),
    )
end

function _natural_unit_conversions(
    base,
    v::PiecewiseLinearData,
    from::ConversionUnits,
    to::ConversionUnits,
)
    data = get_points(v)
    return PiecewiseLinearData([
        (
            IS._strip_units(_natural_unit_conversions(base, x, from.x_unit, to.x_unit)),
            IS._strip_units(_natural_unit_conversions(base, y, from.y_unit, to.y_unit)),
        ) for (x, y) in data
    ])
end

function _natural_unit_conversions(
    base,
    v::PiecewiseStepData,
    from::ConversionUnits,
    to::ConversionUnits,
)
    return PiecewiseStepData(
        [
            IS._strip_units(_natural_unit_conversions(base, x, from.x_unit, to.x_unit)) for
            x in v.x_coords
        ],
        [
            IS._strip_units(
                _natural_unit_conversions(
                    base,
                    y,
                    from.y_unit / from.x_unit,
                    to.y_unit / to.x_unit,
                ),
            ) for y in v.y_coords
        ],
    )
end

# ---- ValueCurves ----
function _natural_unit_conversions(
    base,
    v::InputOutputCurve,
    from::ConversionUnits,
    to::ConversionUnits,
)
    return InputOutputCurve(
        _natural_unit_conversions(base, v.function_data, from, to),
        isa(v.input_at_zero, Float64) ?
        IS._strip_units(
            _natural_unit_conversions(base, v.input_at_zero, from.y_unit, to.y_unit),
        ) : v.input_at_zero,
    )
end

function _natural_unit_conversions(
    base,
    v::IncrementalCurve,
    from::ConversionUnits,
    to::ConversionUnits,
)
    return IncrementalCurve(
        _natural_unit_conversions(base, v.function_data, from, to),
        IS._strip_units(
            _natural_unit_conversions(base, v.initial_input, from.y_unit, to.y_unit),
        ),
        IS._strip_units(
            _natural_unit_conversions(base, v.input_at_zero, from.y_unit, to.y_unit),
        ),
    )
end

function _natural_unit_conversions(
    base,
    v::AverageRateCurve,
    from::ConversionUnits,
    to::ConversionUnits,
)
    return AverageRateCurve(
        _natural_unit_conversions(base, v.function_data, from, to),
        IS._strip_units(
            _natural_unit_conversions(base, v.initial_input, from.y_unit, to.y_unit),
        ),
        IS._strip_units(
            _natural_unit_conversions(base, v.input_at_zero, from.y_unit, to.y_unit),
        ),
    )
end

# ---- Operating costs ----
# Cost and fuel curves carry their own units (a power basis, and a FuelCurve's fuel unit),
# so they are not rescaled like plain value curves. A portfolio has no base power, so every
# curve must be in natural units; the only conversion is of the fuel of a FuelCurve.

_fields(cost) = (getfield(cost, f) for f in fieldnames(typeof(cost)))

cost_curves(curve::IS.ProductionVariableCostCurve) = [curve]
cost_curves(cost::PSY.OperationalCost) =
    [x for x in _fields(cost) if x isa IS.ProductionVariableCostCurve]

has_natural_power_units(cost) =
    all(c -> IS.get_power_units(c) isa IS.NaturalUnit, cost_curves(cost))

function check_natural_power_units(t, field, cost)
    has_natural_power_units(cost) && return
    throw(
        IS.InvalidValue(
            "$(val_to_string(field)) of $(summary(t)) has a curve in per-unit power; a " *
            "portfolio has no base power, so cost curves must be in natural units.",
        ),
    )
end

const _FUEL_DIMENSIONS =
    (Unitful.dimension(u"J"), Unitful.dimension(u"m^3"), Unitful.dimension(u"kg"))

"""
Return an operating cost in `units`: natural units return it as stored, and a fuel unit
(e.g. `MMBtu`) converts the fuel of its fuel curves. Cost curves have no fuel to convert.
"""
function cost_in_units(t, field, cost::UnitsCarryingCost, units)
    check_natural_power_units(t, field, cost)
    _is_natural(units) && return cost
    if !(units isa Unitful.Units && Unitful.dimension(units) in _FUEL_DIMENSIONS)
        throw(
            ArgumentError(
                "$(val_to_string(field)) takes natural units (`u\"NU\"`) or a fuel unit " *
                "for its fuel curves (e.g. `MMBtu`); got $units.",
            ),
        )
    end
    return convert_fuel_units(cost, units)
end

function set_cost(t, field, cost::UnitsCarryingCost, units)
    if !_is_natural(units)
        throw(
            ArgumentError(
                "$(val_to_string(field)) is set in natural units (`u\"NU\"`); its curves " *
                "carry their own units. Got $units.",
            ),
        )
    end
    check_natural_power_units(t, field, cost)
    return cost
end

convert_fuel_units(curve::IS.CostCurve, ::Unitful.Units) = curve

function convert_fuel_units(curve::IS.FuelCurve, units::Unitful.Units)
    from = IS.get_fuel_units(curve)
    from == units && return curve
    if !isnothing(IS.get_fuel_cost_time_series(curve))
        throw(
            ArgumentError(
                "The fuel of a FuelCurve priced by a time series cannot be converted.",
            ),
        )
    end
    # Fuel per hour scales with the fuel unit; the energy axis does not change
    energy = u"MW" * u"hr"
    from_fuel = (x_unit=energy, y_unit=from)
    to_fuel = (x_unit=energy, y_unit=units)
    return FuelCurve(;
        value_curve=_natural_unit_conversions(
            nothing,
            get_value_curve(curve),
            from_fuel,
            to_fuel,
        ),
        fuel_units=units,
        fuel_cost=IS._strip_units(
            _natural_unit_conversions(
                nothing,
                IS.get_fuel_cost(curve),
                USD / from,
                USD / units,
            ),
        ),
        startup_fuel_offtake=_natural_unit_conversions(
            nothing,
            IS.get_startup_fuel_offtake(curve),
            (x_unit=u"MW", y_unit=from),
            (x_unit=u"MW", y_unit=units),
        ),
        vom_cost=IS.get_vom_cost(curve),
    )
end

function convert_fuel_units(cost::PSY.OperationalCost, units::Unitful.Units)
    needs_conversion(x) = x isa IS.FuelCurve && IS.get_fuel_units(x) != units
    any(needs_conversion, _fields(cost)) || return cost
    return typeof(cost)(
        (x isa IS.FuelCurve ? convert_fuel_units(x, units) : x for x in _fields(cost))...,
    )
end
