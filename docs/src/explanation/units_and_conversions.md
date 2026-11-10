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
                       get_x(component, u"kW")          set_x!(component, val * u"kW")
     stored value  ───────────────────────────▶  kW        kW  ───────────────────────────▶  stored value
     (natural unit)          convert out                            convert in            (natural unit)
```

Storing in one consistent unit system keeps the optimization model, serialization,
and internal math unambiguous, while the conversion layer keeps the user API
flexible.

### Natural units by physical quantity

| Physical quantity   | Natural unit (stored) | Example fields                                                             |
|:------------------- |:--------------------- |:-------------------------------------------------------------------------- |
| Power               | `u"MW"`               | `unit_size`, `capacity_limits`, `peak_demand_mw`, `min_capacity_mw`        |
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

Curve-valued fields are a cost in USD as a function of a quantity. Their accessors take the
unit of that quantity and convert the curve's x-axis (a curve stored in USD/MWh and read in
`u"kWh"` is in USD/kWh); the cost axis stays in USD. Incremental and average rate curves
hold their data in USD per x, so it scales accordingly. A tiered `curtailment_cost` (an
incremental curve whose breakpoints are fractions of demand) only converts its prices. The
natural units of each curve are:

| Physical quantity | Natural unit | Example fields                     |
|:----------------- |:------------ |:---------------------------------- |
| Power cost        | USD/MW       | `retirement_cost`, `retrofit_cost` |
| Energy cost       | USD/MWh      | `curtailment_cost`, `shift_cost`   |
| Product price     | USD/t        | `price_per_unit`                   |

Capital costs follow the same rules on the fields of [`CapitalCost`](@ref) and
[`StorageCapitalCost`](@ref) (a technology's `capital_costs` returns the struct): the
capital cost curves (USD/MW; USD/MWh for storage energy) convert their x-axis, and
`interconnection_cost` is a USD/MW rate.

Operating costs (`operation_costs`, `operation_costs_inverter`) are different: their
`CostCurve`s and `FuelCurve`s carry their own units, as in PowerSystems. Each records the
basis of its power axis, which must be natural units (a portfolio has no base power, so a
per-unit curve is an error), and a `FuelCurve` records the fuel it is in (`fuel_units`, such
as MMBtu or GJ). Their accessors take natural units, which return the cost as stored, or a
fuel unit, which converts the fuel of any fuel curve; the power and currency axes are not
converted.

## The units-aware accessor pattern

For every field `x` that carries a unit, the struct generator emits three accessors:

| Accessor                          | Returns                                                              |
|:--------------------------------- |:-------------------------------------------------------------------- |
| `get_x(component, units)`         | A **bare number** (or `NamedTuple`/curve) in `units`                 |
| `get_x_unitful(component, units)` | The same value as a `Unitful.Quantity` (unit attached; not exported) |
| `set_x!(component, value)`        | Stores a units-tagged `value` (e.g. `250.0u"MW"`) in natural units   |

As in PowerSystems, getters always take a `units` argument (calling one without it is an
error that says so) and setters take a units-tagged value (a bare number is an error). Pass
`u"NU"` to read a value in the unit it is stored in. Curve-valued fields are set
in natural units, without a tag. `get_x` strips the unit so downstream numeric code is
unaffected; `get_x_unitful` keeps the `Unitful.Quantity` when you want to carry the unit
along or convert further.

```julia
get_unit_size(supply, u"MW")          # 100.0            :: Float64
get_unit_size(supply, u"kW")          # 100000.0         :: Float64
get_unit_size(supply, u"NU")             # 100.0            :: Float64
PSIP.get_unit_size_unitful(supply, u"MW")  # 100.0 MW    :: Unitful.Quantity

set_unit_size!(supply, 250_000.0u"kW")     # stores 250.0 MW
get_unit_size(supply, u"MW")               # 250.0
```

!!! note
    
    Reading a field with plain property access (`supply.unit_size`) always returns
    the raw value in its **natural unit** — no conversion is applied. Prefer the
    `get_x(component, u"NU")` accessor, which does the same without reaching into the struct.

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
`:mt_per_mwh`) maps to a **`UnitCategory`** — a small singleton type that names a
physical quantity. The exported physical categories are `POWER`, `ENERGY`,
`VOLTAGE`, `IMPEDANCE`, `OPS_TIME`, and `INV_TIME` (see the
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
      + compound fields (`MinMax`, `UpDown`, and per-topology `Dict`s of them) convert
        each component;
      + value curves rescale their x-axis (`scale_axes`), and operating costs return as
        stored or with their fuel converted (`cost_in_units`).
    
    Setters take units-tagged values, which `set_value` converts to natural units.

!!! note
    
    `get_value`, `set_value`, `convert_units`, and `_natural_unit_conversions` are
    **internal** functions. Application code should use the per-field
    `get_x` / `set_x!` accessors; the internals are documented here to explain the
    machinery and to guide contributors extending it.

## See also

  - [How to work with units](@ref)
  - [`natural_unit`](@ref)
