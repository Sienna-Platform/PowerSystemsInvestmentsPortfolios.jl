#######################################################
# Unit-aware methods for converting units for FunctionData, ValueCurves, 
# ProductionVariableCostCurve, and OperationalCosts.
# Convert the data from units `from` to units `to`.
# Current design is intended to support the following function types:
# - Cost (USD) as a function of power output and/or installed capacity (MW)
# - Fuel consumption (MMBtu) as a function of energy production (MWh)
# - Fuel cost (USD) as a function of fuel consumption (MMBtu)
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

# ---- CostCurve ----
function _natural_unit_conversions(
    base,
    v::CostCurve,
    from::ConversionUnits,
    to::ConversionUnits,
)
    return CostCurve(
        _natural_unit_conversions(base, v.value_curve, from, to),
        _natural_unit_conversions(base, v.vom_cost, from, to),
    )
end

# ---- FuelCurve ----
function _natural_unit_conversions(
    base,
    v::FuelCurve,
    from::FuelCurveUnits,
    to::FuelCurveUnits,
)
    # Construct conversion units for fields of FuelCurve
    from_fuel_consumption = (x_unit=from.energy_unit, y_unit=from.fuel_unit)
    from_vom_cost = (x_unit=from.energy_unit, y_unit=from.currency_unit)
    from_fuel_cost = from.currency_unit / from.fuel_unit

    to_fuel_consumption = (x_unit=to.energy_unit, y_unit=to.fuel_unit)
    to_vom_cost = (x_unit=to.energy_unit, y_unit=to.currency_unit)
    to_fuel_cost = to.currency_unit / to.fuel_unit

    return FuelCurve(
        _natural_unit_conversions(
            base,
            v.value_curve,
            from_fuel_consumption,
            to_fuel_consumption,
        ),
        isa(v.fuel_cost, Float64) ?
        IS._strip_units(
            _natural_unit_conversions(base, v.fuel_cost, from_fuel_cost, to_fuel_cost),
        ) : v.fuel_cost,
        _natural_unit_conversions(
            base,
            v.startup_fuel_offtake,
            from_fuel_consumption,
            to_fuel_consumption,
        ),
        _natural_unit_conversions(base, v.vom_cost, from_vom_cost, to_vom_cost),
    )
end

# ---- OperationalCost Structs ----
function _natural_unit_conversions(
    base,
    v::ThermalGenerationCost,
    from::FuelCurveUnits,
    to::FuelCurveUnits,
)
    if isa(get_variable_operation_cost(v), CostCurve)
        @error "Variable Cost is a CostCurve. Use ConversionUnits for conversion."
    end
    start_up = _natural_unit_conversions(
        base,
        get_start_up(v),
        from.currency_unit / from.energy_unit,
        to.currency_unit / to.energy_unit,
    )
    return ThermalGenerationCost(
        _natural_unit_conversions(base, v.variable_operation_cost, from, to),
        IS._strip_units(
            _natural_unit_conversions(
                base,
                v.fixed,
                from.currency_unit / from.energy_unit,
                to.currency_unit / to.energy_unit,
            ),
        ),
        isa(start_up, PSY.StartUpStages) ? start_up : IS._strip_units(start_up),
        IS._strip_units(
            _natural_unit_conversions(
                base,
                get_shut_down(v),
                from.currency_unit / from.energy_unit,
                to.currency_unit / to.energy_unit,
            ),
        ),
    )
end

function _natural_unit_conversions(
    base,
    v::ThermalGenerationCost,
    from::ConversionUnits,
    to::ConversionUnits,
)
    if isa(get_variable_operation_cost(v), FuelCurve)
        @error "Variable Cost is a FuelCurve. Use FuelCurveUnits for conversion."
    end

    start_up = _natural_unit_conversions(
        base,
        get_start_up(v),
        from.y_unit / from.x_unit,
        to.y_unit / to.x_unit,
    )
    return ThermalGenerationCost(
        _natural_unit_conversions(base, v.variable_operation_cost, from, to),
        IS._strip_units(
            _natural_unit_conversions(
                base,
                v.fixed,
                from.y_unit / from.x_unit,
                to.y_unit / to.x_unit,
            ),
        ),
        isa(start_up, PSY.StartUpStages) ? start_up : IS._strip_units(start_up),
        IS._strip_units(
            _natural_unit_conversions(
                base,
                PSY.get_shut_down(v),
                from.y_unit / from.x_unit,
                to.y_unit / to.x_unit,
            ),
        ),
    )
end

function _natural_unit_conversions(
    base,
    v::HydroGenerationCost,
    from::ConversionUnits,
    to::ConversionUnits,
)
    return HydroGenerationCost(
        _natural_unit_conversions(base, v.variable_operation_cost, from, to),
        IS._strip_units(
            _natural_unit_conversions(
                base,
                v.fixed,
                from.y_unit / from.x_unit,
                to.y_unit / to.x_unit,
            ),
        ),
    )
end

function _natural_unit_conversions(
    base,
    v::StorageCost,
    from::ConversionUnits,
    to::ConversionUnits,
)
    start_up = IS._strip_units(
        _natural_unit_conversions(
            base,
            get_start_up(v),
            from.y_unit / from.x_unit,
            to.y_unit / to.x_unit,
        ),
    )
    return StorageCost(
        _natural_unit_conversions(base, v.charge_variable_cost, from, to),
        _natural_unit_conversions(base, v.discharge_variable_cost, from, to),
        IS._strip_units(
            _natural_unit_conversions(
                base,
                v.fixed,
                from.y_unit / from.x_unit,
                to.y_unit / to.x_unit,
            ),
        ),
        isa(start_up, PSY.STORAGE_OPERATION_MODES) ? start_up : IS._strip_units(start_up),
        IS._strip_units(
            _natural_unit_conversions(
                base,
                get_shut_down(v),
                from.y_unit / from.x_unit,
                to.y_unit / to.x_unit,
            ),
        ),
        IS._strip_units(
            _natural_unit_conversions(
                base,
                get_energy_shortage_cost(v),
                from.y_unit / from.x_unit,
                to.y_unit / to.x_unit,
            ),
        ),
        IS._strip_units(
            _natural_unit_conversions(
                base,
                get_energy_surplus_cost(v),
                from.y_unit / from.x_unit,
                to.y_unit / to.x_unit,
            ),
        ),
    )
end

function _natural_unit_conversions(
    base,
    v::RenewableGenerationCost,
    from::ConversionUnits,
    to::ConversionUnits,
)
    return RenewableGenerationCost(
        _natural_unit_conversions(base, v.variable_operation_cost, from, to),
        _natural_unit_conversions(base, v.curtailment_cost, from, to),
        IS._strip_units(
            _natural_unit_conversions(
                base,
                v.fixed,
                from.y_unit / from.x_unit,
                to.y_unit / to.x_unit,
            ),
        ),
    )
end
