# OpenAPI export (`*_to_openapi`) converters: reverse direction of
# `src/openapi/cost_conversion.jl`, mirroring PowerSystems.jl structure.

# Every association id the document emits passes through here.
#
# A cost may reference a series owned by a different component, and that owner may
# be one the document cannot describe -- a dynamic component today, since none has
# a converter yet. `_export_all_time_series` then skips the series' association row
# and the document ships a cost pointing at a series it never declares. Importing
# that against another sidecar resolves the bare id against whatever holds it
# there, silently binding the cost to the wrong series.
#
# Recording each id as it is emitted lets `_check_costs_reference_declared_series!`
# catch that before the document exists, and it stays correct for cost shapes added
# later: a new emit point routes through here or it does not emit an id at all.
const _EMITTED_ASSOCIATION_IDS_KEY = :psip_openapi_export_emitted_association_ids

function _record_emitted_association_id(id::Int)
    ids = get(task_local_storage(), _EMITTED_ASSOCIATION_IDS_KEY, nothing)
    isnothing(ids) || push!(ids, id)
    return id
end

# ── compound PO constructors, called by generated to_openapi ──────────────────

_minmax_po(v) = PC.MinMax(; min=v.min, max=v.max)
_minmax_po_optional(::Nothing) = nothing
_minmax_po_optional(v) = _minmax_po(v)

_updown_po(v) = PC.UpDown(; up=v.up, down=v.down)
_updown_po_optional(::Nothing) = nothing
_updown_po_optional(v) = _updown_po(v)

_inout_po(v) = PC.InOut(; in=v.in, out=v.out)
_inout_po_optional(::Nothing) = nothing
_inout_po_optional(v) = _inout_po(v)
_outagefactors_po(v) = PC.OutageFactors(; planned=v.planned, forced=v.forced)
_outagefactors_po_optional(::Nothing) = nothing
_outagefactors_po_optional(v) = _outagefactors_po(v)
# ── value curves: FunctionData leaves + InputOutputCurve/IncrementalCurve/AverageRateCurve ──
#
# `convert_value_curve` accepts either the wrapped `PC.ValueCurve`/`PC.*FunctionData` oneOf or
# a bare concrete PC curve/function-data struct — both resolve to the same IS type, so one
# family suffices. The `_to_openapi` direction is asymmetric: some PSY fields need the wrapped
# `PC.ValueCurve` oneOf (`PSY.ValueCurve`-typed fields, `CostCurve.value_curve`) and others need
# the bare concrete curve (`vom_cost`, `startup_fuel_offtake`), so the bare recursion lives in
# the private `_value_curve_body_to_openapi` family and `convert_value_curve_to_openapi` wraps it.
function _value_curve_body_to_openapi(fd::LinearFunctionData)
    return PC.LinearFunctionData(;
        proportional_term=get_proportional_term(fd),
        constant_term=get_constant_term(fd),
    )
end

function _value_curve_body_to_openapi(fd::QuadraticFunctionData)
    return PC.QuadraticFunctionData(;
        quadratic_term=get_quadratic_term(fd),
        proportional_term=get_proportional_term(fd),
        constant_term=get_constant_term(fd),
    )
end

function _value_curve_body_to_openapi(fd::PiecewiseLinearData)
    return PC.PiecewiseLinearData(;
        points=[PC.XYCoords(; x=p.x, y=p.y) for p in get_points(fd)],
    )
end

function _value_curve_body_to_openapi(fd::PiecewiseStepData)
    return PC.PiecewiseStepData(; x_coords=get_x_coords(fd), y_coords=get_y_coords(fd))
end

function _value_curve_body_to_openapi(curve::InputOutputCurve)
    return PC.InputOutputCurve(;
        function_data=PC.InputOutputCurveFunctionData(
            _value_curve_body_to_openapi(get_function_data(curve)),
        ),
        input_at_zero=get_input_at_zero(curve),
    )
end

function _value_curve_body_to_openapi(curve::IncrementalCurve)
    return PC.IncrementalCurve(;
        function_data=PC.IncrementalCurveFunctionData(
            _value_curve_body_to_openapi(get_function_data(curve)),
        ),
        initial_input=get_initial_input(curve),
        input_at_zero=get_input_at_zero(curve),
    )
end

function _value_curve_body_to_openapi(curve::AverageRateCurve)
    return PC.AverageRateCurve(;
        function_data=PC.IncrementalCurveFunctionData(
            _value_curve_body_to_openapi(get_function_data(curve)),
        ),
        initial_input=get_initial_input(curve),
        input_at_zero=get_input_at_zero(curve),
    )
end

function _value_curve_body_to_openapi(x)
    return error(
        "convert_value_curve_to_openapi: no OpenAPI value-curve converter for " *
        "$(nameof(typeof(x))) — every value curve in the document must be converted, " *
        "not skipped",
    )
end

convert_value_curve_to_openapi(curve::ValueCurve) =
    PC.ValueCurve(_value_curve_body_to_openapi(curve))

_value_curve_po_optional(::Nothing) = nothing
_value_curve_po_optional(curve) = convert_value_curve_to_openapi(curve)
"""
`LinearCurve(0.0)` is the sentinel `_vom_cost`/`_startup_fuel_offtake` map `nothing` to on
import; reverse it back to `nothing` rather than emitting a spurious zero-cost curve.
"""
function _linear_curve_or_nothing(curve::InputOutputCurve)
    if curve == LinearCurve(0.0)
        return nothing
    end
    return _value_curve_body_to_openapi(curve)
end
_vom_cost_to_openapi(curve) = _linear_curve_or_nothing(curve)
_startup_fuel_offtake_to_openapi(curve) = _linear_curve_or_nothing(curve)
# ── fuel_cost: a bare number, or (unimplemented) a time-series reference ──────

_fuel_cost_to_openapi(v::Real) = Float64(v)
_power_units_to_string(::NaturalUnit, ::ProductionVariableCostCurve) = "NATURAL_UNITS"
_power_units_to_string(::DeviceBaseUnit, ::ProductionVariableCostCurve) = "DEVICE_BASE"

"""
`CostCurve.power_units`/`FuelCurve.power_units` carry no system-base member — a curve whose
per-unit data is on the system base is expected to record that base in the owning component's
`base_power` and ride as `DEVICE_BASE`. This converter is handed the curve alone, so it can
neither check that the component's `base_power` really is the system base nor rescale the
curve's x-coordinates by `system_base / device_base` if it is not. Relabelling would silently
corrupt magnitudes, so fail loudly instead (psy6 rule).
"""
function _power_units_to_string(::SystemBaseUnit, cost::ProductionVariableCostCurve)
    error(
        "cannot export $(typeof(cost)) with power_units = SystemBaseUnit(): the OpenAPI " *
        "power_units enum accepts only DEVICE_BASE and NATURAL_UNITS, and this converter " *
        "has no access to the owning component's base_power to rescale the curve. Rebuild " *
        "the curve on the component's own base (DeviceBaseUnit) or in natural units first.",
    )
end

function convert_cost_to_openapi(cost::CostCurve)
    return PC.CostCurve(;
        power_units=_power_units_to_string(get_power_units(cost), cost),
        value_curve=convert_value_curve_to_openapi(get_value_curve(cost)),
        vom_cost=_vom_cost_to_openapi(get_vom_cost(cost)),
    )
end

function convert_cost_to_openapi(cost::FuelCurve)
    return PC.FuelCurve(;
        power_units=_power_units_to_string(get_power_units(cost), cost),
        value_curve=convert_value_curve_to_openapi(get_value_curve(cost)),
        fuel_cost=_fuel_cost_to_openapi(IS.get_fuel_cost(cost)),
        startup_fuel_offtake=_startup_fuel_offtake_to_openapi(
            PSY.get_startup_fuel_offtake(cost),
        ),
        vom_cost=_vom_cost_to_openapi(get_vom_cost(cost)),
    )
end

"""
`zero(CostCurve)` is the sentinel `_optional_cost_curve` maps `nothing` to on import;
reverse it back to `nothing` (curtailment_cost, storage charge/discharge_variable_cost).
"""
function _optional_cost_curve_to_openapi(cost::CostCurve)
    if cost == zero(CostCurve)
        return nothing
    end
    return convert_cost_to_openapi(cost)
end
# ── start_up: a bare number, or a multi-stage / charge-discharge breakdown ────

_thermal_start_up_to_openapi(x::Real) = PC.ThermalGenerationCostStartUp(Float64(x))
function _thermal_start_up_to_openapi(x::NamedTuple)
    return PC.ThermalGenerationCostStartUp(
        PC.StartUpStages(; hot=x.hot, warm=x.warm, cold=x.cold),
    )
end

_storage_start_up_to_openapi(x::Real) = PC.StorageCostStartUp(Float64(x))
function _storage_start_up_to_openapi(x::NamedTuple)
    return PC.StorageCostStartUp(
        PC.StorageCostStartUpOneOf(; charge=x.charge, discharge=x.discharge),
    )
end
# ── Operation-cost containers ──────────────────────────────────────────────

function convert_cost_to_openapi(cost::ThermalGenerationCost)
    return PC.ThermalGenerationCost(;
        fixed=get_fixed(cost),
        shut_down=get_shut_down(cost),
        start_up=_thermal_start_up_to_openapi(get_start_up(cost)),
        variable_operation_cost=PC.ProductionVariableCostCurve(
            convert_cost_to_openapi(get_variable_operation_cost(cost)),
        ),
    )
end

function convert_cost_to_openapi(cost::RenewableGenerationCost)
    return PC.RenewableGenerationCost(;
        variable_operation_cost=convert_cost_to_openapi(get_variable_operation_cost(cost)),
        # `get_curtailment_cost` is shadowed in this module by `DemandSideTechnology`'s
        # generated 2-arg getter of the same name, so PSY's 1-arg getter must be qualified.
        curtailment_cost=_optional_cost_curve_to_openapi(PSY.get_curtailment_cost(cost)),
        fixed=get_fixed(cost),
    )
end

function convert_cost_to_openapi(cost::HydroGenerationCost)
    return PC.HydroGenerationCost(;
        fixed=get_fixed(cost),
        variable_operation_cost=PC.ProductionVariableCostCurve(
            convert_cost_to_openapi(get_variable_operation_cost(cost)),
        ),
    )
end

function convert_cost_to_openapi(cost::StorageCost)
    return PC.StorageCost(;
        charge_variable_cost=_optional_cost_curve_to_openapi(
            get_charge_variable_cost(cost),
        ),
        discharge_variable_cost=_optional_cost_curve_to_openapi(
            get_discharge_variable_cost(cost),
        ),
        fixed=get_fixed(cost),
        shut_down=get_shut_down(cost),
        start_up=_storage_start_up_to_openapi(get_start_up(cost)),
        energy_shortage_cost=get_energy_shortage_cost(cost),
        energy_surplus_cost=get_energy_surplus_cost(cost),
    )
end

function convert_cost_to_openapi(cost)
    return error(
        "convert_cost_to_openapi: no OpenAPI operational-cost converter for " *
        "$(nameof(typeof(cost))) — every cost in the document must be converted, not skipped",
    )
end
# ── financial data ───────────────────────────────────────────────────────────

function convert_nested_data_to_openapi(fd::TechnologyFinancialData)
    return PI.TechnologyFinancialData(;
        capital_recovery_period=get_capital_recovery_period(fd),
        technology_base_year=get_technology_base_year(fd),
        debt_fraction=get_debt_fraction(fd),
        debt_rate=get_debt_rate(fd),
        return_on_equity=get_return_on_equity(fd),
        tax_rate=get_tax_rate(fd),
    )
end

function convert_nested_data_to_openapi(fd::PortfolioFinancialData)
    return PI.PortfolioFinancialData(;
        base_year=fd.base_year,
        discount_rate=fd.discount_rate,
        inflation_rate=fd.inflation_rate,
        interest_rate=fd.interest_rate,
    )
end

convert_nested_data_to_openapi(::Nothing) = nothing

function convert_nested_data_to_openapi(fd)
    return error(
        "convert_nested_data_to_openapi: no OpenAPI financial-data converter for " *
        "$(nameof(typeof(fd))) — every financial data record must be converted, not skipped",
    )
end
# ── investment costs: CapitalCost / StorageCapitalCost ────────────────────────
#
# Nested cost structs that embed `ValueCurve`s, so unlike `TechnologyFinancialData`
# (scalar fields only) they recurse through `convert_value_curve`. `interconnection_cost`
# is schema-optional (defaults to 0.0), so an omitted PO value imports as 0.0.

function convert_nested_data_to_openapi(cc::CapitalCost)
    return PC.CapitalCost(;
        capital_cost=convert_value_curve_to_openapi(get_capital_cost(cc)),
        interconnection_cost=get_interconnection_cost(cc),
    )
end
function convert_nested_data_to_openapi(sc::StorageCapitalCost)
    return PC.StorageCapitalCost(;
        charge_capital_cost=convert_value_curve_to_openapi(get_charge_capital_cost(sc)),
        discharge_capital_cost=convert_value_curve_to_openapi(
            get_discharge_capital_cost(sc),
        ),
        energy_capital_cost=convert_value_curve_to_openapi(get_energy_capital_cost(sc)),
        interconnection_cost=get_interconnection_cost(sc),
    )
end
# ── capacity bounds: a MinMax, or a per-topology map of MinMax ────────────────
#
# The platform model wraps the value in a field-specific AnyOf struct whose `.value` is
# either a `PC.MinMax` or a `Dict{String, PC.MinMax}`. In the map case the string keys are
# base-system topology ids, so they resolve to the `PSY.Topology` component through `refs`
# (seeded from the base system). A nullable bound omitted on the wire imports as the default.

_capacity_bound_po_value(v::NamedTuple, ::OpenAPIRefs) = PC.MinMax(; min=v.min, max=v.max)
_capacity_bound_po_value(d::AbstractDict, refs::OpenAPIRefs) =
    Dict(string(component_id(refs, k)) => PC.MinMax(; min=v.min, max=v.max) for (k, v) in d)
