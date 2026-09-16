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

"""`initial_input`/`input_at_zero` are optional-by-omission on the wire (not nullable) —
`nothing` fails schema validation on encode, so a missing PSY-side value emits `IC.ABSENT`."""
_optional_to_wire(::Nothing) = IC.ABSENT
_optional_to_wire(v) = v

# ── value curves: FunctionData leaves + InputOutputCurve/IncrementalCurve/AverageRateCurve ──
#
# `convert_value_curve` accepts either the wrapped `PC.ValueCurve`/`PC.*FunctionData` oneOf or
# a bare concrete PC curve/function-data struct — both resolve to the same IS type, so one
# family suffices. The `_to_openapi` direction is asymmetric: some PSY fields need the wrapped
# `PC.ValueCurve` oneOf (`PSY.ValueCurve`-typed fields, `CostCurve.value_curve`) and others need
# the bare concrete curve (`vom_cost`, `startup_fuel_offtake`), so the bare recursion lives in
# the private `_value_curve_body_to_openapi` family and `convert_value_curve_to_openapi` wraps it.
_power_units_to_string(::NaturalUnit, ::ProductionVariableCostCurve) =
    IC.UnitSystem("NATURAL_UNITS")
_power_units_to_string(
    ::ComponentBaseUnit,
    ::ProductionVariableCostCurve,
) = IC.UnitSystem("COMPONENT_BASE")

"""`CostCurve.power_units`/`FuelCurve.power_units` carry no system-base member — a curve whose
per-unit data is on the system base is expected to record that base in the owning component's
`base_power` and ride as `COMPONENT_BASE`. This converter is handed the curve alone (see the
`convert_cost_to_openapi(get_operation_cost(gen))` call sites), so it can neither check that the
component's `base_power` really is the system base nor rescale the curve's x-coordinates by
`system_base / component_base` if it is not. Relabelling would silently corrupt magnitudes, so fail
loudly instead (psy6 rule)."""
function _power_units_to_string(::SystemBaseUnit, cost::ProductionVariableCostCurve)
    error(
        "cannot export $(typeof(cost)) with power_units = SystemBaseUnit(): the OpenAPI " *
        "power_units enum accepts only COMPONENT_BASE and NATURAL_UNITS, and this converter " *
        "has no access to the owning component's base_power to rescale the curve. Rebuild " *
        "the curve on the component's own base (ComponentBaseUnit) or in natural units first.",
    )
end

# ── FunctionData ────────────────────────────────────────────────────────────────

function convert_cost_to_openapi(fd::LinearFunctionData)
    return IC.LinearFunctionData(;
        proportional_term = get_proportional_term(fd),
        constant_term = get_constant_term(fd),
    )
end

function convert_cost_to_openapi(fd::QuadraticFunctionData)
    return IC.QuadraticFunctionData(;
        quadratic_term = get_quadratic_term(fd),
        proportional_term = get_proportional_term(fd),
        constant_term = get_constant_term(fd),
    )
end

function convert_cost_to_openapi(fd::PiecewiseLinearData)
    return IC.PiecewiseLinearData(;
        points = [IC.XYCoords(; x = p.x, y = p.y) for p in get_points(fd)],
    )
end

function convert_cost_to_openapi(fd::PiecewiseStepData)
    return IC.PiecewiseStepData(; x_coords = get_x_coords(fd), y_coords = get_y_coords(fd))
end

# ── ValueCurve ──────────────────────────────────────────────────────────────────
# Returns the bare PO curve struct (not the `PC.ValueCurve` oneOf wrapper) — callers wrap it
# where the field's spec type is the wrapper (`CostCurve.value_curve`) and use it bare where
# the spec type is the concrete curve directly (`vom_cost`, `TwoTerminalLoss`).

function convert_cost_to_openapi(curve::InputOutputCurve)
    return PC.InputOutputCurve(;
        function_data = PC.InputOutputCurveFunctionData(
            convert_cost_to_openapi(get_function_data(curve)),
        ),
        input_at_zero = _optional_to_wire(get_input_at_zero(curve)),
    )
end

function convert_cost_to_openapi(curve::IncrementalCurve)
    return PC.IncrementalCurve(;
        function_data = PC.IncrementalCurveFunctionData(
            convert_cost_to_openapi(get_function_data(curve)),
        ),
        initial_input = _optional_to_wire(get_initial_input(curve)),
        input_at_zero = _optional_to_wire(get_input_at_zero(curve)),
    )
end

function convert_cost_to_openapi(curve::AverageRateCurve)
    return PC.AverageRateCurve(;
        function_data = PC.AverageRateCurveFunctionData(
            convert_cost_to_openapi(get_function_data(curve)),
        ),
        initial_input = _optional_to_wire(get_initial_input(curve)),
        input_at_zero = _optional_to_wire(get_input_at_zero(curve)),
    )
end

# ── vom_cost: always a LINEAR InputOutputCurve, or `nothing` for the zero sentinel ─────

"""`LinearCurve(0.0)` is the sentinel `_vom_cost` maps `nothing` to on import;
reverse it back to `nothing` rather than emitting a spurious zero-cost curve."""
function _vom_cost_to_openapi(curve::InputOutputCurve)
    # if curve == LinearCurve(0.0)
    #     return nothing
    # end
    return convert_cost_to_openapi(curve)
end

# ── Time-series FunctionData/ValueCurve — export reads association ids straight off the
# PSY key, needs no store ──────────────────────────────────────────────────────

_ts_function_data_wire_type(::Type{LinearFunctionData}) = IC.TimeSeriesLinearFunctionData
_ts_function_data_wire_type(::Type{QuadraticFunctionData}) =
    IC.TimeSeriesQuadraticFunctionData
_ts_function_data_wire_type(::Type{PiecewiseLinearData}) = IC.TimeSeriesPiecewiseLinearData
_ts_function_data_wire_type(::Type{PiecewiseStepData}) = IC.TimeSeriesPiecewiseStepData

function convert_cost_to_openapi(fd::IS.TimeSeriesFunctionData{T}) where {T}
    WireType = _ts_function_data_wire_type(T)
    return WireType(;
        association_id = _key_association_id(IS.get_time_series_key(fd)),
    )
end

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
const _EMITTED_ASSOCIATION_IDS_KEY = :psy_openapi_export_emitted_association_ids

function _record_emitted_association_id(id::Int)
    ids = get(task_local_storage(), _EMITTED_ASSOCIATION_IDS_KEY, nothing)
    isnothing(ids) || push!(ids, id)
    return id
end

"""`nothing` stays `nothing`; a present key emits its `association_id`."""
_key_association_id(::Nothing) = nothing
_key_association_id(key::IS.TimeSeriesKey) =
    _record_emitted_association_id(IS.get_association_id(key))

"""Wire representation of [`CurveStyles`](@ref): a plain integer (0/1) - see
`cost_conversion.jl`'s `_curve_style_from_wire` for the import-direction counterpart."""
_curve_style_to_wire(style::CurveStyles) = style.value
"""Wire representation of [`CurveMultiStep`](@ref): a plain integer (0/1), mirroring
`_curve_style_to_wire`."""
_curve_multistep_to_wire(flag::CurveMultiStep) = flag.value

function convert_cost_to_openapi(curve::TimeSeriesInputOutputCurve)
    return PC.TimeSeriesInputOutputCurve(;
        function_data = IC.FunctionData(convert_cost_to_openapi(get_function_data(curve))),
        input_at_zero = get_input_at_zero(curve),
    )
end

function convert_cost_to_openapi(curve::TimeSeriesIncrementalCurve)
    return PC.TimeSeriesIncrementalCurve(;
        function_data = IC.FunctionData(convert_cost_to_openapi(get_function_data(curve))),
        initial_input_association_id = _key_association_id(get_initial_input(curve)),
        input_at_zero_association_id = _key_association_id(get_input_at_zero(curve)),
    )
end

function convert_cost_to_openapi(curve::TimeSeriesAverageRateCurve)
    return PC.TimeSeriesAverageRateCurve(;
        function_data = IC.FunctionData(convert_cost_to_openapi(get_function_data(curve))),
        initial_input_association_id = _key_association_id(get_initial_input(curve)),
        input_at_zero_association_id = _key_association_id(get_input_at_zero(curve)),
    )
end

# ── fuel_cost: PSY splits it into `fuel_cost`/`fuel_cost_time_series` — exactly one set ──

_fuel_cost_time_series_id(fuel_cost) = _key_association_id(fuel_cost)

# ── ProductionVariableCostCurve: CostCurve / FuelCurve ─────────────────────────

function convert_cost_to_openapi(cost::CostCurve)
    return PC.CostCurve(;
        power_units = _power_units_to_string(get_power_units(cost), cost),
        value_curve = PC.ValueCurve(convert_cost_to_openapi(get_value_curve(cost))),
        vom_cost = convert_cost_to_openapi(get_vom_cost(cost)),
    )
end

function convert_cost_to_openapi(cost::FuelCurve)
    return PC.FuelCurve(;
        power_units = _power_units_to_string(get_power_units(cost), cost),
        value_curve = PC.ValueCurve(convert_cost_to_openapi(get_value_curve(cost))),
        fuel_cost = get_fuel_cost(cost),
        fuel_cost_time_series = _fuel_cost_time_series_id(
            IS.get_fuel_cost_time_series(cost),
        ),
        vom_cost = convert_cost_to_openapi(get_vom_cost(cost)),
    )
end

"""`zero(CostCurve)` is the sentinel `_optional_cost_curve` maps `nothing` to on import;
reverse it back to `nothing` (curtailment_cost, storage charge/discharge_variable_cost)."""
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
        PC.StartUpStages(;
            startup_stages_type = "STAGES",
            hot = x.hot,
            warm = x.warm,
            cold = x.cold,
        ),
    )
end

_storage_start_up_to_openapi(x::Real) = PC.StorageCostStartUp(Float64(x))
function _storage_start_up_to_openapi(x::NamedTuple)
    return PC.StorageCostStartUp(
        PC.ChargeDischarge(; charge = x.charge, discharge = x.discharge),
    )
end

# ── Operation-cost containers ─────────────────────────────────────────────────

function convert_cost_to_openapi(cost::ThermalGenerationCost)
    return PC.ThermalGenerationCost(;
        cost_type = "THERMAL",
        fixed = get_fixed(cost),
        shut_down = get_shut_down(cost),
        start_up = _thermal_start_up_to_openapi(get_start_up(cost)),
        variable_operation_cost = PC.ProductionVariableCostCurve(
            convert_cost_to_openapi(get_variable_operation_cost(cost)),
        ),
    )
end

function convert_cost_to_openapi(cost::RenewableGenerationCost)
    return PC.RenewableGenerationCost(;
        cost_type = "RENEWABLE",
        variable_operation_cost = convert_cost_to_openapi(
            get_variable_operation_cost(cost),
        ),
        curtailment_cost = _optional_cost_curve_to_openapi(get_curtailment_cost(cost)),
        fixed = get_fixed(cost),
    )
end

function convert_cost_to_openapi(cost::HydroGenerationCost)
    return PC.HydroGenerationCost(;
        cost_type = "HYDRO_GEN",
        fixed = get_fixed(cost),
        variable_operation_cost = PC.ProductionVariableCostCurve(
            convert_cost_to_openapi(get_variable_operation_cost(cost)),
        ),
    )
end

function convert_cost_to_openapi(cost::LoadCost)
    return PC.LoadCost(;
        cost_type = "LOAD",
        variable_operation_cost = convert_cost_to_openapi(
            get_variable_operation_cost(cost),
        ),
        fixed = get_fixed(cost),
    )
end

function convert_cost_to_openapi(cost::HydroReservoirCost)
    return PC.HydroReservoirCost(;
        cost_type = "HYDRO_RES",
        level_shortage_cost = get_level_shortage_cost(cost),
        level_surplus_cost = get_level_surplus_cost(cost),
        spillage_cost = get_spillage_cost(cost),
    )
end

function convert_cost_to_openapi(cost::StorageCost)
    return PC.StorageCost(;
        cost_type = "STORAGE",
        charge_variable_cost = _optional_cost_curve_to_openapi(
            get_charge_variable_cost(cost),
        ),
        discharge_variable_cost = _optional_cost_curve_to_openapi(
            get_discharge_variable_cost(cost),
        ),
        fixed = get_fixed(cost),
        shut_down = get_shut_down(cost),
        start_up = _storage_start_up_to_openapi(get_start_up(cost)),
        energy_shortage_cost = get_energy_shortage_cost(cost),
        energy_surplus_cost = get_energy_surplus_cost(cost),
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
    # TODO: Remove id field from this struct
    return PI.PortfolioFinancialData(;
        id=1e6,
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
        capital_cost=PC.ValueCurve(convert_cost_to_openapi(get_capital_cost(cc))),
        interconnection_cost=get_interconnection_cost(cc),
    )
end
function convert_nested_data_to_openapi(sc::StorageCapitalCost)
    return PC.StorageCapitalCost(;
        charge_capital_cost=PC.ValueCurve(convert_cost_to_openapi(get_charge_capital_cost(sc))),
        discharge_capital_cost=PC.ValueCurve(
            convert_cost_to_openapi(get_discharge_capital_cost(sc)),
        ),
        energy_capital_cost=PC.ValueCurve(convert_cost_to_openapi(get_energy_capital_cost(sc))),
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
