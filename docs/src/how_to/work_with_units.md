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

get_unit_size(supply, u"NU")       # 100.0 (MW)
get_unit_size(supply, u"kW")    # 100000.0
```

## Keep the unit attached

```julia
q = PSIP.get_unit_size_unitful(supply, u"MW")   # 100.0 MW
uconvert(u"kW", q)                               # 100000.0 kW
ustrip(q)                                        # 100.0
```

## Write a field in a convenient unit

As in PowerSystems, the setter takes a units-tagged value and stores it in the field's
natural unit; a bare number is an error:

```julia
set_unit_size!(supply, 250_000.0u"kW")     # stores 250.0 MW
get_unit_size(supply, u"MW")               # 250.0
```

## Compound fields (`MinMax`, `UpDown`)

`MinMax` and `UpDown` fields convert each component; pass and receive a `NamedTuple`:

```julia
get_capacity_limits(supply, u"GW")                    # (min = 0.0, max = 0.5)
set_capacity_limits!(supply, (min=0.0u"GW", max=0.8u"GW"))
get_capacity_limits(supply, u"MW")                    # (min = 0.0, max = 800.0)

get_time_limits(supply, u"NU")          # (up = 240.0, down = 240.0), minutes
get_time_limits(supply, u"hr")       # (up = 4.0, down = 4.0)
```

## Cost-curve fields

Operating costs carry their own units: their cost and fuel curves record them, as in
PowerSystems, and must be in natural units. Read them in natural units to get the cost as
stored, or with a fuel unit to convert the fuel of a `FuelCurve`:

```julia
get_operation_costs(supply, u"NU")       # as stored, e.g. a FuelCurve in GJ
get_operation_costs(supply, MMBtu)    # the FuelCurve's heat rate and fuel price in MMBtu
```

Other curve-valued fields (`curtailment_cost`, `shift_cost`, `price_per_unit`,
`retirement_cost`, `retrofit_cost`) are a cost in USD as a function of a quantity. Pass the
unit of that quantity to convert the curve's x-axis; the cost stays in USD:

```julia
get_curtailment_cost(demand, u"NU")        # USD/MWh, as stored
get_curtailment_cost(demand, u"kWh")    # USD/kWh
get_retrofit_cost(retrofit, u"kW")      # USD/kW
set_price_per_unit!(electrolyzer, LinearCurve(3000.0))   # curves are set in natural units (USD/t)
```

A tiered `curtailment_cost` (a `PiecewiseIncrementalCurve`) is the exception: its breakpoints
are fractions of demand, so only its prices convert.

`u"NU"` means natural units, as in PowerSystems. PSIP defines `u"Wh"` with SI
prefixes (`u"kWh"`, `u"MWh"`, ...), since Unitful spells energy `u"kW*hr"`.

Capital costs are a [`CapitalCost`](@ref) or [`StorageCapitalCost`](@ref); their fields take
units like any other curve or scalar:

```julia
costs = get_capital_costs(supply)
get_capital_cost(costs, u"kW")                 # USD/kW
get_interconnection_cost(costs, USD / u"kW")   # a rate, like other scalar fields
set_interconnection_cost!(costs, 50.0USD / u"kW")

storage_costs = get_capital_costs(storage)
get_energy_capital_cost(storage_costs, u"kWh") # USD/kWh
```

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
