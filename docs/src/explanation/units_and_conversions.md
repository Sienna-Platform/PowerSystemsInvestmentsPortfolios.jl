```@meta
CurrentModule = PowerSystemsInvestmentsPortfolios
```

# Units and Unit Conversions

PSIP stores every physical quantity internally in a fixed set of **natural units**
(for example MW for power, USD for cost, `tonne` for emissions). At the same time,
the units-aware accessors let you *read* and *write* any of these fields in whatever
unit is convenient — kW, kV, USD/kW, USD/tonne, and so on — while the stored value
always stays in natural units.

This page explains the model behind that system. For task-oriented recipes see
[How to work with units](@ref).

## The core idea: store in natural units, display in any unit

Each unit-aware field has a single, canonical **natural unit** in which its value is
physically stored on the struct. Nothing about the stored data changes when you ask
for a different unit — the conversion happens on the way *out* (getters) and on the
way *in* (setters):

```
                       get_x(component, u"kW")          set_x!(component, val, u"kW")
     stored value  ───────────────────────────▶  kW        kW  ───────────────────────────▶  stored value
     (natural unit)          convert out                            convert in            (natural unit)
```

Storing in one consistent unit system keeps the optimization model, serialization,
and internal math unambiguous, while the conversion layer keeps the user API
flexible.

### Natural units by physical quantity

| Physical quantity   | Natural unit (stored) | Example fields                                                             |
|:------------------- |:--------------------- |:-------------------------------------------------------------------------- |
| Power               | `u"MW"`               | `unit_size`, `capacity_limits`, `new_demand_mw`, `min_capacity_mw`         |
| Energy              | `u"MW*hr"`            | `unit_size_energy`, `capacity_limits_energy`                               |
| Voltage             | `u"kV"`               | `voltage`                                                                  |
| Impedance           | `u"Ω"`                | `resistance`, `reactance`                                                  |
| Duration (minutes)  | `u"minute"`           | `time_limits`, `duration_limits`, `max_demand_delay`, `max_demand_advance` |
| Investment time     | `u"yr"`               | `lifetime`                                                                 |
| Ramp rate           | `u"MW/minute"`        | `ramp_limits`                                                              |
| Startup fuel        | `MMBtu / u"MW"`       | `start_fuel_mmbtu_per_mw`                                                  |
| Emissions (mass)    | `Mt`                  | `max_mtons`                                                                |
| Emissions / energy  | `Mt / u"MW*hr"`       | `max_tons_mwh`                                                             |
| Emissions cost      | `USD / tonne`         | `tax_dollars_per_ton`, `price_per_unit`                                    |
| Energy cost (value) | `USD / u"MW*hr"`      | `value_of_lost_load`                                                       |

Fractions (efficiencies, outage factors, reserve margins) and financial rates have no unit
and are plain fields.

### Natural units for cost curves

Cost fields carry a value along *two* axes (an independent `x` and a dependent `y`), so their
units are expressed as a `NamedTuple` rather than a single unit. The corresponding
[`ConversionUnits`](@ref) natural units are:

| Physical quantity | Natural unit                       | Example fields                                                                             |
|:----------------- |:---------------------------------- |:------------------------------------------------------------------------------------------ |
| Power cost        | `(x_unit=u"MW", y_unit=USD)`       | `retirement_cost`, `retrofit_cost`                                                         |
| Energy cost       | `(x_unit=u"MW"*u"hr", y_unit=USD)` | `operation_costs`, `operation_costs_inverter`, `unserved_demand_curve`, `curtailment_cost` |

Capital costs are not unit-aware fields: [`CapitalCost`](@ref) and
[`StorageCapitalCost`](@ref) hold curves that are always in USD/MW (USD/MWh for storage
energy).

Fuel-consumption curves (`FuelCurve`) span three axes and use the
[`FuelCurveUnits`](@ref) form `(energy_unit=…, fuel_unit=…, currency_unit=…)`, whose
natural units are `(energy_unit=u"MW"*u"hr", fuel_unit=MMBtu, currency_unit=USD)`. An
`operation_costs` field whose variable cost is a `FuelCurve` takes this form instead of
`(x_unit, y_unit)`.

## The units-aware accessor pattern

For every field `x` that carries a unit, the struct generator emits three accessors:

| Accessor                          | Returns                                                                  |
|:--------------------------------- |:------------------------------------------------------------------------ |
| `get_x(component, units)`         | A **bare number** (or `NamedTuple`/curve) in `units`                     |
| `get_x_unitful(component, units)` | The same value as a `Unitful.Quantity` (unit attached; not exported)     |
| `set_x!(component, value, units)` | Stores `value` — interpreted as being in `units` — back in natural units |

The `units` argument is always required. Pass `NU` (natural units) to read or write a value
in the unit it is stored in. `get_x` strips the unit so downstream numeric code is
unaffected; `get_x_unitful` keeps the `Unitful.Quantity` when you want to carry the unit
along or convert further.

```julia
get_unit_size(supply, u"MW")          # 100.0            :: Float64
get_unit_size(supply, u"kW")          # 100000.0         :: Float64
get_unit_size(supply, NU)             # 100.0            :: Float64
PSIP.get_unit_size_unitful(supply, u"MW")  # 100.0 MW    :: Unitful.Quantity

set_unit_size!(supply, 250_000.0, u"kW")   # interprets 250000 kW, stores 250.0 MW
get_unit_size(supply, u"MW")               # 250.0
```

!!! note
    
    Reading a field with plain property access (`supply.unit_size`) always returns
    the raw value in its **natural unit** — no conversion is applied. Prefer the
    `get_x(component, NU)` accessor, which does the same without reaching into the struct.

## Specifying units

Units come from [Unitful.jl](https://github.com/PainterQubits/Unitful.jl). There are
three ways to name them:

  - **Built-in Unitful units** via the `@u_str` string macro: `u"MW"`, `u"kW"`,
    `u"kV"`, `u"Ω"`, `u"hr"`, `u"minute"`, `u"yr"`.
  - **PSIP custom units**, exported as plain constants: `USD`, `MMBtu`, `tonne`, and `Mt`.
    Reference these by the constant, e.g. `USD`, not through `u"USD"`.
  - **Composite / rate units** built with `*`, `/`, and `^`:
    `u"MW" / u"minute"`, `USD / tonne`, `MMBtu / u"MW"`.
  - **`NU`** — the field's natural unit, whatever it is.

For cost-curve fields, pass the `NamedTuple` forms described above, e.g.
`(x_unit=u"kW", y_unit=USD)`.

!!! warning "Do not wrap PSIP custom units in `u"…"`"
`USD`, `MMBtu`, `tonne`, and `Mt` are defined by PSIP and only registered with
Unitful at load time (`__init__`). The `u"…"` string macro resolves unit names
at *macro-expansion* time and cannot see them, so `u"tonne/MMBtu"` fails to
precompile. Always build composite units from the exported constants instead:
`tonne / MMBtu`, `USD / tonne`, `MMBtu / u"MW"`.

## Custom units

PSIP adds four units that Unitful does not ship with, defined in `units/types.jl`:

| Unit    | Dimension | Definition                                      |
|:------- |:--------- |:----------------------------------------------- |
| `USD`   | Money     | reference unit for the custom `Money` dimension |
| `MMBtu` | Energy    | `1e6 * u"btu"`                                  |
| `tonne` | Mass      | `1e3 * u"kg"`                                   |
| `Mt`    | Mass      | `1e6 * tonne`                                   |

Because these are defined in a package (not in Unitful itself), they are registered
with Unitful inside the module's `__init__` so that quantities constructed from them
promote and convert correctly.

## Unit categories and `natural_unit`

Internally, each unit token used by a field (for example `:mw`, `:usd_per_mwh`,
`:t_per_mmbtu`) maps to a **`UnitCategory`** — a small singleton type that names a
physical quantity. The exported physical categories are `POWER`, `ENERGY`,
`VOLTAGE`, `IMPEDANCE`, `ADMITTANCE`, `CURRENT`, `OPS_TIME`, and `INV_TIME` (see the
[Public API Reference](@ref) for their docstrings). Duration fields in minutes use the
internal `MINUTE_TIME` category.

Cost, fuel, ramping, and emissions categories exist as well but are internal.
Each category answers a single query — its natural unit — through
[`natural_unit`](@ref):

```julia
natural_unit(POWER)     # u"MW"
natural_unit(ENERGY)    # u"MW" * u"hr"
natural_unit(VOLTAGE)   # u"kV"
```

## How conversions flow through the layers

When you call an accessor, the request passes through three layers:

 1. **Generated accessor** (`get_x` / `set_x!`) — knows the field's unit *token* and
    whether to strip units.

 2. **`get_value` / `set_value`** — look up the field's category with
    `_unit_category`, resolve its `natural_unit`, and hand off the actual conversion.
 3. **`_natural_unit_conversions`** — the recursive engine that converts the value.
    It dispatches on the value type:
    
      + scalars go straight to `convert_units` (a thin wrapper over `Unitful.uconvert`);
      + compound fields (`MinMax`, `UpDown`, `InOut`, start-up stages) convert each
        component;
      + `FunctionData`, `ValueCurve`, `CostCurve`, `FuelCurve`, and `OperationalCost`
        structures convert each of their coefficients along the correct axis, so a
        whole cost curve can be re-expressed in new units in one call.

This means a single getter call can convert an entire nested cost structure — for
example turning a `ThermalGenerationCost` from USD/MWh into USD/kWh — while
preserving its shape.

!!! note
    
    `get_value`, `set_value`, `convert_units`, and `_natural_unit_conversions` are
    **internal** functions. Application code should use the per-field
    `get_x` / `set_x!` accessors; the internals are documented here to explain the
    machinery and to guide contributors extending it.

## See also

  - [How to work with units](@ref)
  - [`natural_unit`](@ref)
  - [`ConversionUnits`](@ref)
  - [`FuelCurveUnits`](@ref)
