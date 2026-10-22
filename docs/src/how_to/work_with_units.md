```@meta
CurrentModule = PowerSystemsInvestmentsPortfolios
```

# How to work with units

PSIP stores every physical field in a fixed **natural unit** but lets you read and write it
in any compatible unit. This page collects the common recipes. For the concepts behind them,
see [Units and Unit Conversions](@ref).

Every unit-aware field `x` provides:

  - `get_x(component, units)` — the value as a bare number in `units`
  - `set_x!(component, value, units)` — store `value`, interpreting it as `units`
  - `PSIP.get_x_unitful(component, units)` — the value as a `Unitful.Quantity` (not exported)

The `units` argument is required. Pass `NU` to get the value in its natural unit.

## Read a scalar field in a chosen unit

```julia
using PowerSystemsInvestmentsPortfolios
import PowerSystemsInvestmentsPortfolios as PSIP
import PowerSystems as PSY

fin = TechnologyFinancialData(;
    capital_recovery_period=30,
    technology_base_year=2030,
    debt_fraction=0.5,
    debt_rate=0.06,
    return_on_equity=0.12,
    tax_rate=0.21,
)

supply = SupplyTechnology{PSY.ThermalStandard}(;
    name="ccgt",
    available=true,
    power_systems_type="ThermalStandard",
    financial_data=fin,
    unit_size=100.0,                        # stored in MW
    capacity_limits=(min=0.0, max=500.0),   # stored in MW
    time_limits=(up=240.0, down=240.0),     # stored in minutes
)

get_unit_size(supply, NU)       # 100.0 (MW)
get_unit_size(supply, u"kW")    # 100000.0
```

## Keep the unit attached

```julia
q = PSIP.get_unit_size_unitful(supply, u"MW")   # 100.0 MW
uconvert(u"kW", q)                               # 100000.0 kW
ustrip(q)                                        # 100.0
```

## Write a field in a convenient unit

The setter interprets the value you pass as being in the given unit and stores it in the
field's natural unit:

```julia
set_unit_size!(supply, 250_000.0, u"kW")   # stores 250.0 MW
get_unit_size(supply, u"MW")               # 250.0
```

## Compound fields (`MinMax`, `UpDown`)

`MinMax` and `UpDown` fields convert each component; pass and receive a `NamedTuple`:

```julia
get_capacity_limits(supply, u"GW")                    # (min = 0.0, max = 0.5)
set_capacity_limits!(supply, (min=0.0, max=0.8), u"GW")
get_capacity_limits(supply, u"MW")                    # (min = 0.0, max = 800.0)

get_time_limits(supply, NU)          # (up = 240.0, down = 240.0), minutes
get_time_limits(supply, u"hr")       # (up = 4.0, down = 4.0)
```

## Cost-curve fields

Operating-cost fields span two axes, so their units are given as a [`ConversionUnits`](@ref)
`NamedTuple`. The conversion applies to the whole cost structure:

```julia
get_operation_costs(supply, (x_unit=u"MW" * u"hr", y_unit=USD))   # USD/MWh
get_operation_costs(supply, (x_unit=u"kW" * u"hr", y_unit=USD))   # USD/kWh
```

A cost built on a `FuelCurve` spans three axes and takes [`FuelCurveUnits`](@ref):

```julia
get_operation_costs(supply, (energy_unit=u"kW" * u"hr", fuel_unit=MMBtu, currency_unit=USD))
```

Capital costs are a [`CapitalCost`](@ref) or [`StorageCapitalCost`](@ref) whose curves are
always in USD/MW (or USD/MWh for storage energy); they have no units argument.

## Rate units

```julia
get_ramp_limits(supply, u"MW/minute")
get_start_fuel_mmbtu_per_mw(supply, MMBtu / u"MW")
```

## Emissions units

Emissions fields on policy requirements use the PSIP units `Mt` and `tonne`. Build composite
units from the exported constants (`USD`, `MMBtu`, `tonne`, `Mt`) — never from a `u"…"`
string:

```julia
cap = CarbonCaps(; name="cap", available=true, max_mtons=50.0)
get_max_mtons(cap, Mt)                      # 50.0
get_max_mtons(cap, tonne)                   # 5.0e7

tax = CarbonTax(; name="tax", available=true, tax_dollars_per_ton=50.0)
get_tax_dollars_per_ton(tax, USD / tonne)   # 50.0
get_tax_dollars_per_ton(tax, USD / u"kg")   # 0.05
```

!!! warning
    
    Do not write PSIP units with the string macro (`u"tonne/MMBtu"`); `USD`, `MMBtu`,
    `tonne`, and `Mt` are defined by PSIP and are invisible to `u"…"` at macro-expansion
    time. Compose them with operators instead: `tonne / MMBtu`, `USD / tonne`.

## Query a category's natural unit

```julia
natural_unit(POWER)      # MW
natural_unit(ENERGY)     # MW hr
natural_unit(OPS_TIME)   # hr
```

## See also

  - [Units and Unit Conversions](@ref)
  - [`natural_unit`](@ref)
  - [`ConversionUnits`](@ref)
  - [`FuelCurveUnits`](@ref)
