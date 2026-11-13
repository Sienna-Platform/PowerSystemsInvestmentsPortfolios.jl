#######################################################
# Unit conversions of curve-valued fields. A value curve is a cost (USD) as a function of a
# quantity (energy, capacity, product), so converting one only changes its x-axis:
# `curtailment_cost` stored in USD/MWh and read in `u"kWh"` is in USD/kWh. The y-axis stays
# in USD. Operating costs (cost and fuel curves and their containers) carry their own units
# and are handled at the end.
#######################################################

# ---- Scaling a curve's axes ----
# `kx` and `ky` are the new units per old unit on each axis (x' = kx x, y' = ky y).

scale_axes(fd::LinearFunctionData, kx, ky) =
    LinearFunctionData(get_proportional_term(fd) * ky / kx, get_constant_term(fd) * ky)

scale_axes(fd::QuadraticFunctionData, kx, ky) = QuadraticFunctionData(
    get_quadratic_term(fd) * ky / kx^2,
    get_proportional_term(fd) * ky / kx,
    get_constant_term(fd) * ky,
)

scale_axes(fd::PiecewiseLinearData, kx, ky) =
    PiecewiseLinearData([(x * kx, y * ky) for (x, y) in get_points(fd)])

scale_axes(fd::PiecewiseStepData, kx, ky) =
    PiecewiseStepData(get_x_coords(fd) .* kx, get_y_coords(fd) .* ky)

_scale(::Nothing, ::Any) = nothing
_scale(value::Real, k) = value * k

scale_axes(curve::InputOutputCurve, kx, ky) = InputOutputCurve(
    scale_axes(get_function_data(curve), kx, ky),
    _scale(get_input_at_zero(curve), ky),
)

# The function data of incremental and average rate curves is in y per x
scale_axes(curve::IncrementalCurve, kx, ky) = IncrementalCurve(
    scale_axes(get_function_data(curve), kx, ky / kx),
    _scale(get_initial_input(curve), ky),
    _scale(get_input_at_zero(curve), ky),
)

scale_axes(curve::AverageRateCurve, kx, ky) = AverageRateCurve(
    scale_axes(get_function_data(curve), kx, ky / kx),
    _scale(get_initial_input(curve), ky),
    _scale(get_input_at_zero(curve), ky),
)

# ---- Value-curve fields ----
# A field's natural unit is its rate (e.g. USD/MWh), so its x-axis is in USD per that rate.

_x_scale(rate::Unitful.Units, units::Unitful.Units) =
    Unitful.ustrip(Unitful.uconvert(units, 1.0 * (USD / rate)))

function curve_in_units(curve::IS.ValueCurve, rate, units)
    _is_natural(units) && return curve
    return scale_axes(curve, _x_scale(rate, units), 1.0)
end

# The tiers of a curtailment cost given as an incremental curve are fractions of demand, so a
# unit conversion only changes their prices (USD per energy), not their breakpoints
function curtailment_tiers_in_units(curve::IS.IncrementalCurve, rate, units)
    _is_natural(units) && return curve
    return _scale_tier_prices(curve, 1.0 / _x_scale(rate, units))
end

_scale_tier_prices(curve::IS.IncrementalCurve, k) = IncrementalCurve(
    scale_axes(get_function_data(curve), 1.0, k),
    get_initial_input(curve),
    get_input_at_zero(curve),
)

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
Return an operating cost in `units`: natural units return it as stored. FuelCurves accept 
a fuel unit (e.g. `MMBtu`) to convert the fuel values.
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

function set_cost(t, field, cost::UnitsCarryingCost)
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
    # Fuel scales with the fuel unit; the power and energy axes do not change
    ky = Unitful.ustrip(Unitful.uconvert(units, 1.0 * from))
    return FuelCurve(;
        value_curve=scale_axes(get_value_curve(curve), 1.0, ky),
        fuel_units=units,
        fuel_cost=IS.get_fuel_cost(curve) / ky,
        startup_fuel_offtake=scale_axes(IS.get_startup_fuel_offtake(curve), 1.0, ky),
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
