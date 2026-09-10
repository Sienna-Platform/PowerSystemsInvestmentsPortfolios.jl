# Hand-written (not generated) OpenAPI value converters, mirroring PowerSystems.jl's
# src/openapi/cost_conversion.jl and export_cost_conversion.jl. Called by the generated
# `from_openapi`/`to_openapi` methods (Task 4) for the field types codegen cannot express
# inline: value curves, operational costs, financial data, and the compound
# MinMax/UpDown/InOut PO constructors.
#
# PSIP carries no per-unit basis of its own (see Design decision 1 in the plan header), so
# unlike PSY's converters these take no `Val{:DEVICE_BASE}`/`Val{:NATURAL_UNITS}` argument.
# The one place a unit marker still appears is `CostCurve`/`FuelCurve`'s own `power_units`
# type parameter (`NaturalUnit`/`DeviceBaseUnit`/`SystemBaseUnit`) — that is intrinsic to
# those PSY types themselves, not a PSIP concept, so it is handled exactly as PSY handles it.
#
# PO fields are accessed with dot notation throughout (`po.value_curve`, `po.function_data`),
# matching the OpenAPI model convention — PO structs are `OpenAPI.jl`-generated kwarg structs,
# not PSIP component types, so the "getters, not dot access" rule does not apply to them.
#
# Two independent recursive families exist, `convert_value_curve`/`convert_value_curve_to_openapi`
# and `convert_cost`/`convert_cost_to_openapi`, rather than PSY's single `convert_cost` name
# spanning both — PSIP's generator classifies fields into `PSY.ValueCurve` and
# `PSY.OperationalCost` categories separately (`SiennaInvestSchema.json`), so the generated
# code needs one converter entry point per category. `convert_cost` still delegates to
# `convert_value_curve` for the `ValueCurve` fields nested inside a cost (`CostCurve.value_curve`,
# `vom_cost`, ...), so there is exactly one implementation of the curve/function-data recursion.
# ── compound extraction, called by generated from_openapi ────────────────────
#
# The generated OpenAPI models declare every `$ref`ed field as bare `Any`, so reading
# `po.capacity_limits.min` inline is a dynamic `getproperty` chain that no annotation on
# `po` can recover — the type is absent from the model's struct definition, not merely
# unstated. Dispatching on the concrete `PC` struct once, here at the boundary, makes every
# member access after it a concrete field load.
#
# One name per alias rather than the `_optional` pair the export side needs: absence is
# dispatch on `::Nothing`, which also absorbs the `if isnothing(...)` guard the generator
# used to wrap around every nullable compound.

_minmax_from_po(x::PC.MinMax) = (min=x.min, max=x.max)
_minmax_from_po(::Nothing) = nothing

_updown_from_po(x::PC.UpDown) = (up=x.up, down=x.down)
_updown_from_po(::Nothing) = nothing

_inout_from_po(x::PC.InOut) = (in=x.in, out=x.out)
_inout_from_po(::Nothing) = nothing

_outagefactors_from_po(x::PC.OutageFactors) = (planned=x.planned, forced=x.forced)
_outagefactors_from_po(::Nothing) = nothing

const _IMPORT_STORE = Base.ScopedValues.ScopedValue{IS.Store}()

"""No sidecar was adopted, so there is nothing to bind; a document that then names a
time-series-backed cost fails in `_current_import_store`."""
_with_import_store(f, ::Nothing) = f()

"""Bind `store` for the duration of `f()`. `ScopedValue`-based, so a nested import and a
task spawned inside one both see the innermost binding."""
_with_import_store(f, store::IS.Store) =
    Base.ScopedValues.with(f, _IMPORT_STORE => store)

function _current_import_store()
    store = Base.ScopedValues.get(_IMPORT_STORE)
    isnothing(store) && error(
        "convert_cost: the document names a time-series-backed cost, but no time series " *
        "store is bound — either this ran outside an active from_openapi(System, doc) " *
        "import, or no time_series_storage_path sidecar was adopted for it",
    )
    return something(store)
end

# ── value curves: FunctionData leaves + InputOutputCurve/IncrementalCurve/AverageRateCurve ──
#
# `convert_value_curve` accepts either the wrapped `PC.ValueCurve`/`PC.*FunctionData` oneOf or
# a bare concrete PC curve/function-data struct — both resolve to the same IS type, so one
# family suffices. The `_to_openapi` direction is asymmetric: some PSY fields need the wrapped
# `PC.ValueCurve` oneOf (`PSY.ValueCurve`-typed fields, `CostCurve.value_curve`) and others need
# the bare concrete curve (`vom_cost`, `startup_fuel_offtake`), so the bare recursion lives in
# the private `_value_curve_body_to_openapi` family and `convert_value_curve_to_openapi` wraps it.

convert_value_curve(fd::PC.LinearFunctionData) =
    LinearFunctionData(fd.proportional_term, fd.constant_term)
convert_value_curve(fd::PC.QuadraticFunctionData) =
    QuadraticFunctionData(fd.quadratic_term, fd.proportional_term, fd.constant_term)
# `PiecewiseLinearData.points` is generated as a bare `Vector` (the element type is dropped
# from `Vector{XYCoords}`); converting once restores inference for the per-point loop.
function convert_value_curve(fd::PC.PiecewiseLinearData)
    points = convert(Vector{PC.XYCoords}, fd.points)
    return PiecewiseLinearData([(x=p.x, y=p.y) for p in points])
end
convert_value_curve(fd::PC.PiecewiseStepData) = PiecewiseStepData(fd.x_coords, fd.y_coords)

# oneOf FunctionData wrappers: unwrap to the concrete variant above.
convert_value_curve(w::PC.InputOutputCurveFunctionData) = convert_value_curve(w.value)
convert_value_curve(w::PC.IncrementalCurveFunctionData) = convert_value_curve(w.value)

convert_value_curve(vc::PC.InputOutputCurve) =
    InputOutputCurve(convert_value_curve(vc.function_data), vc.input_at_zero)
convert_value_curve(vc::PC.IncrementalCurve) = IncrementalCurve(
    convert_value_curve(vc.function_data),
    vc.initial_input,
    vc.input_at_zero,
)
convert_value_curve(vc::PC.AverageRateCurve) = AverageRateCurve(
    convert_value_curve(vc.function_data),
    vc.initial_input,
    vc.input_at_zero,
)

# oneOf ValueCurve wrapper: unwrap to the concrete variant above.
convert_value_curve(w::PC.ValueCurve) = convert_value_curve(w.value)

function convert_value_curve(x)
    return error(
        "convert_value_curve: no OpenAPI value-curve converter for $(nameof(typeof(x))) — " *
        "every value curve in the document must be converted, not skipped",
    )
end
_value_curve_optional(::Nothing) = nothing
_value_curve_optional(po) = convert_value_curve(po)
# ── operational costs ────────────────────────────────────────────────────────
#
# `ThermalGenerationCost`, `StorageCost`, `RenewableGenerationCost`, `HydroGenerationCost`,
# and the `CostCurve`/`FuelCurve` (`ProductionVariableCostCurve`) pair nested inside them are
# covered. `SupplyTechnology.operation_costs` is typed as the abstract `PSY.OperationalCost`
# (not narrowed to these four), but on import it arrives wrapped in `PC.GenericOperationCost`,
# whose oneOf discriminator (`cost_type`) only resolves `HYDRO_GEN`/`RENEWABLE`/`THERMAL` —
# `LoadCost` and `HydroReservoirCost` are real PSY cost types with real PC wire structs, but
# their discriminators (`LOAD`/`HYDRO_RES`) aren't in that oneOf, so `OpenAPI.from_json` can
# never produce them for this field; converters for them would be unreachable dead code until
# `GenericOperationCost` is regenerated upstream in PowerOpenAPIModels/SiennaSchemas to add
# those branches. `MarketBidCost`/`ImportExportCost` have no PSY OpenAPI converters yet either.
# The reserve ORDC `variable` special-casing is PSY-only and does not apply here.
# `convert_cost`'s terminal fallback errors loudly on anything else rather than guessing.

"""
Required-field guard: dispatches on `Nothing` vs. anything else, per style (no
`isnothing(x) && ...` guards) — a required PO field read as `nothing` is malformed input.
"""
_require(::Nothing, context::AbstractString) =
    error("convert_cost: $context is required and missing")
_require(x, ::AbstractString) = x

_power_units_marker(::Nothing) = error("convert_cost: power_units is required and missing")
function _power_units_marker(s::AbstractString)
    s == "NATURAL_UNITS" && return NaturalUnit()
    s == "DEVICE_BASE" && return DeviceBaseUnit()
    return error(
        "convert_cost: unmapped power_units \"$s\" — expected one of " *
        "NATURAL_UNITS, DEVICE_BASE",
    )
end

# ── vom_cost / startup_fuel_offtake: always a LINEAR InputOutputCurve ──────────

_as_linear_curve(curve::LinearCurve, ::AbstractString) = curve
_as_linear_curve(curve, context::AbstractString) = error(
    "convert_cost: $context must be a LINEAR InputOutputCurve, got " *
    "InputOutputCurve{$(typeof(get_function_data(curve)))}",
)

_vom_cost(::Nothing) = LinearCurve(0.0)
_vom_cost(io::PC.InputOutputCurve) = _linear_curve_no_input_at_zero(io, "vom_cost")

_startup_fuel_offtake(::Nothing) = LinearCurve(0.0)
_startup_fuel_offtake(io::PC.InputOutputCurve) =
    _linear_curve_no_input_at_zero(io, "startup_fuel_offtake")

"""
`vom_cost` / `startup_fuel_offtake` are canonically linear curves with no `input_at_zero`
(that is how PSY constructs them, and the export side cannot preserve it). The generated
`CostCurve`/`FuelCurve` OpenAPI models fill an omitted `vom_cost` with a default whose
`input_at_zero` is `0.0` — a spec-default artifact — so rebuild the canonical linear curve
(`input_at_zero = nothing`) rather than round-trip that zero.
"""
function _linear_curve_no_input_at_zero(io::PC.InputOutputCurve, context::AbstractString)
    curve = _as_linear_curve(convert_value_curve(io), context)
    return InputOutputCurve(get_function_data(curve))
end
# ── fuel_cost: a bare number, or (unimplemented) a time-series reference ──────

convert_cost(v::Real) = Float64(v)
convert_cost(v::AbstractString) = error(
    "convert_cost: a String variant (\"$v\") — a time-series reference — is not implemented",
)
# ── ProductionVariableCostCurve: CostCurve / FuelCurve ─────────────────────────

function convert_cost(c::PC.CostCurve)
    return CostCurve(;
        value_curve=convert_value_curve(_require(c.value_curve, "CostCurve.value_curve")),
        power_units=_power_units_marker(c.power_units),
        vom_cost=_vom_cost(c.vom_cost),
    )
end

function convert_cost(f::PC.FuelCurve)
    return FuelCurve(;
        value_curve=convert_value_curve(_require(f.value_curve, "FuelCurve.value_curve")),
        power_units=_power_units_marker(f.power_units),
        fuel_cost=convert_cost(_require(f.fuel_cost, "FuelCurve.fuel_cost")),
        startup_fuel_offtake=_startup_fuel_offtake(f.startup_fuel_offtake),
        vom_cost=_vom_cost(f.vom_cost),
    )
end

# oneOf ProductionVariableCostCurve wrapper: unwrap to the concrete variant above.
convert_cost(w::PC.ProductionVariableCostCurve) = convert_cost(w.value)

_optional_cost_curve(::Nothing) = zero(CostCurve)
_optional_cost_curve(c::PC.CostCurve) = convert_cost(c)
# ── start_up: a bare number, or a multi-stage / charge-discharge breakdown ────

convert_cost(s::PC.StartUpStages) = (hot=s.hot, warm=s.warm, cold=s.cold)
convert_cost(w::PC.ThermalGenerationCostStartUp) = convert_cost(w.value)

convert_cost(s::PC.StorageCostStartUpOneOf) = (charge=s.charge, discharge=s.discharge)
convert_cost(w::PC.StorageCostStartUp) = convert_cost(w.value)
# ── Operation-cost containers ──────────────────────────────────────────────

function convert_cost(po::PC.ThermalGenerationCost)
    return ThermalGenerationCost(;
        variable_operation_cost=convert_cost(
            _require(
                po.variable_operation_cost,
                "ThermalGenerationCost.variable_operation_cost",
            ),
        ),
        fixed=po.fixed,
        start_up=convert_cost(_require(po.start_up, "ThermalGenerationCost.start_up")),
        shut_down=po.shut_down,
    )
end

function convert_cost(po::PC.RenewableGenerationCost)
    return RenewableGenerationCost(;
        variable_operation_cost=convert_cost(
            _require(
                po.variable_operation_cost,
                "RenewableGenerationCost.variable_operation_cost",
            ),
        ),
        curtailment_cost=_optional_cost_curve(po.curtailment_cost),
        fixed=po.fixed,
    )
end

function convert_cost(po::PC.HydroGenerationCost)
    return HydroGenerationCost(;
        variable_operation_cost=convert_cost(
            _require(
                po.variable_operation_cost,
                "HydroGenerationCost.variable_operation_cost",
            ),
        ),
        fixed=po.fixed,
    )
end

function convert_cost(po::PC.StorageCost)
    return StorageCost(;
        charge_variable_cost=_optional_cost_curve(po.charge_variable_cost),
        discharge_variable_cost=_optional_cost_curve(po.discharge_variable_cost),
        fixed=po.fixed,
        start_up=convert_cost(_require(po.start_up, "StorageCost.start_up")),
        shut_down=po.shut_down,
        energy_shortage_cost=po.energy_shortage_cost,
        energy_surplus_cost=po.energy_surplus_cost,
    )
end

# oneOf GenericOperationCost wrapper: what `OpenAPI.from_json` produces for any
# `operation_costs` field, discriminated on `cost_type`. Unwrap to the concrete variant.
convert_cost(w::PC.GenericOperationCost) = convert_cost(w.value)

function convert_cost(po)
    return error(
        "convert_cost: no OpenAPI operational-cost converter for $(nameof(typeof(po))) — " *
        "every cost in the document must be converted, not skipped",
    )
end
# ── financial data ───────────────────────────────────────────────────────────

function convert_nested_data(po::PI.TechnologyFinancialData)
    return TechnologyFinancialData(;
        capital_recovery_period=po.capital_recovery_period,
        technology_base_year=po.technology_base_year,
        debt_fraction=po.debt_fraction,
        debt_rate=po.debt_rate,
        return_on_equity=po.return_on_equity,
        tax_rate=po.tax_rate,
    )
end

function convert_nested_data(po::PI.PortfolioFinancialData)
    return PortfolioFinancialData(
        po.base_year,
        po.discount_rate,
        po.inflation_rate,
        po.interest_rate,
    )
end

function convert_nested_data(po)
    return error(
        "convert_nested_data: no OpenAPI financial-data converter for " *
        "$(nameof(typeof(po))) — every financial data record must be converted, not skipped",
    )
end
# ── investment costs: CapitalCost / StorageCapitalCost ────────────────────────
#
# Nested cost structs that embed `ValueCurve`s, so unlike `TechnologyFinancialData`
# (scalar fields only) they recurse through `convert_value_curve`. `interconnection_cost`
# is schema-optional (defaults to 0.0), so an omitted PO value imports as 0.0.

function convert_nested_data(po::PC.CapitalCost)
    return CapitalCost(;
        capital_cost=convert_value_curve(
            _require(po.capital_cost, "CapitalCost.capital_cost"),
        ),
        interconnection_cost=something(po.interconnection_cost, 0.0),
    )
end
function convert_nested_data(po::PC.StorageCapitalCost)
    return StorageCapitalCost(;
        charge_capital_cost=convert_value_curve(
            _require(po.charge_capital_cost, "StorageCapitalCost.charge_capital_cost"),
        ),
        discharge_capital_cost=convert_value_curve(
            _require(
                po.discharge_capital_cost,
                "StorageCapitalCost.discharge_capital_cost",
            ),
        ),
        energy_capital_cost=convert_value_curve(
            _require(po.energy_capital_cost, "StorageCapitalCost.energy_capital_cost"),
        ),
        interconnection_cost=something(po.interconnection_cost, 0.0),
    )
end
# ── capacity bounds: a MinMax, or a per-topology map of MinMax ────────────────
#
# The platform model wraps the value in a field-specific AnyOf struct whose `.value` is
# either a `PC.MinMax` or a `Dict{String, PC.MinMax}`. In the map case the string keys are
# base-system topology ids, so they resolve to the `PSY.Topology` component through `refs`
# (seeded from the base system). A nullable bound omitted on the wire imports as the default.

_capacity_bound_from_po(::Nothing, ::OpenAPIRefs) = (min=0.0, max=1e8)
_capacity_bound_from_po(po, refs::OpenAPIRefs) = _capacity_bound_value(po.value, refs)

# One `(min, max)` pair, from either the typed wire struct or the `Dict{String,Any}` that
# `OpenAPI.from_json` leaves an AnyOf value as.
_minmax_nt(v::PC.MinMax) = (min=Float64(v.min), max=Float64(v.max))
_minmax_nt(v::AbstractDict) = (min=Float64(v["min"]), max=Float64(v["max"]))

_capacity_bound_value(x::PC.MinMax, ::OpenAPIRefs) = _minmax_nt(x)
# A plain MinMax deserializes to a dict keyed `"min"`/`"max"`; a per-topology map is keyed by
# base-system topology ids (integer strings). Distinguish the two by their keys.
function _capacity_bound_value(d::AbstractDict, refs::OpenAPIRefs)
    (haskey(d, "min") && haskey(d, "max")) && return _minmax_nt(d)
    return Dict{PSY.Topology, MinMax}(
        resolve_ref(refs, parse(Int, string(k)), PSY.Topology) => _minmax_nt(v) for (k, v) in d
    )
end
