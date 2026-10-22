```@meta
CurrentModule = PowerSystemsInvestmentsPortfolios
```

# Add a Supply Technology

[`SupplyTechnology{T}`](@ref) represents a candidate generation technology — thermal,
renewable, or hydro — that can be built in a capacity expansion model.

## Common PSY type mappings

| Type parameter `T`      | Represents                                        |
|:----------------------- |:------------------------------------------------- |
| `PSY.ThermalStandard`   | Gas, coal, nuclear, or other dispatchable thermal |
| `PSY.RenewableDispatch` | Wind, solar, or other variable renewables         |
| `PSY.HydroDispatch`     | Conventional hydro dispatch                       |

## Minimal working example

The example below adds a wind supply technology to a portfolio. The region must be added to
the portfolio before the technology (see [Define Regions and Topology](@ref)).

```julia
using PowerSystemsInvestmentsPortfolios
import PowerSystems as PSY
using PowerSystems: LinearCurve, CostCurve, RenewableGenerationCost

portfolio = Portfolio()

west = Area(; name="West", input_basis=u"NU")
add_topology!(portfolio, west)

fin = TechnologyFinancialData(;
    capital_recovery_period=20,
    technology_base_year=2030,
    debt_fraction=0.4,
    debt_rate=0.05,
    return_on_equity=0.12,
    tax_rate=0.21,
)

wind = SupplyTechnology{PSY.RenewableDispatch}(;
    name="wind_west",
    available=true,
    region=[west],
    power_systems_type="RenewableDispatch",
    financial_data=fin,
    prime_mover_type=PrimeMovers.WT,
    capital_costs=CapitalCost(; capital_cost=LinearCurve(1_200_000.0)),   # USD/MW
    operation_costs=RenewableGenerationCost(CostCurve(LinearCurve(0.0))),
    capacity_limits=(min=0.0, max=500.0),                                  # MW
)

add_technology!(portfolio, wind)
```

## Thermal generator example

Thermal technologies use a `ThermalGenerationCost`. A `FuelCurve` gives the heat rate
(MMBtu/MWh) and fuel price (USD/MMBtu).

```julia
using PowerSystems: FuelCurve, ThermalGenerationCost

ccgt = SupplyTechnology{PSY.ThermalStandard}(;
    name="ccgt_west",
    available=true,
    region=[west],
    power_systems_type="ThermalStandard",
    financial_data=fin,
    prime_mover_type=PrimeMovers.CC,
    fuel=[ThermalFuels.NATURAL_GAS],
    capital_costs=CapitalCost(;
        capital_cost=LinearCurve(900_000.0),    # USD/MW
        interconnection_cost=50_000.0,          # USD/MW
    ),
    operation_costs=ThermalGenerationCost(;
        variable_operation_cost=FuelCurve(LinearCurve(6.5), 3.5),
        fixed=12_000.0,
        start_up=0.0,
        shut_down=0.0,
    ),
    capacity_limits=(min=0.0, max=1000.0),      # MW
    unit_size=250.0,                            # MW, for discrete investment
    ramp_limits=(up=0.5, down=0.5),
    time_limits=(up=240.0, down=240.0),         # minutes
    outage_factor=(planned=0.05, forced=0.03),
    lifetime=30,                                # years
)

add_technology!(portfolio, ccgt)
```

## Locate a technology in several regions

A supply technology can be located in more than one region. Its `capacity_limits` can then
be given per region as a `Dict`:

```julia
east = Area(; name="East", input_basis=u"NU")
add_topology!(portfolio, east)

solar = SupplyTechnology{PSY.RenewableDispatch}(;
    name="solar_multi",
    available=true,
    region=[west, east],
    power_systems_type="RenewableDispatch",
    financial_data=fin,
    prime_mover_type=PrimeMovers.PVe,
    operation_costs=RenewableGenerationCost(CostCurve(LinearCurve(0.0))),
    capacity_limits=Dict{PSY.Topology, MinMax}(
        west => (min=0.0, max=300.0),
        east => (min=0.0, max=200.0),
    ),
)

add_technology!(portfolio, solar)
```

## Key fields

| Field             | Type                                     | Description                                                       |
|:----------------- |:---------------------------------------- |:----------------------------------------------------------------- |
| `region`          | `Vector{PSY.Topology}`                   | Regions where the technology can be built; at least one           |
| `capital_costs`   | [`CapitalCost`](@ref)                    | Overnight capital cost curve and interconnection cost (USD/MW)    |
| `operation_costs` | `PSY.OperationalCost`                    | Fixed and variable O&M costs (default: `ThermalGenerationCost`)   |
| `capacity_limits` | `MinMax` or `Dict{PSY.Topology, MinMax}` | Minimum and maximum installed capacity in MW                      |
| `unit_size`       | `Float64`                                | Size of each unit for discrete investment, MW                     |
| `outage_factor`   | `(planned, forced)` `NamedTuple`         | Planned and forced outage factors, fractions of availability      |
| `ramp_limits`     | `UpDown`                                 | Maximum decrease and increase in output between operation periods |
| `time_limits`     | `UpDown`                                 | Minimum up and down times, minutes                                |
| `lifetime`        | `Int`                                    | Years a technology can be active once installed (default: `100`)  |
| `financial_data`  | [`TechnologyFinancialData`](@ref)        | Financing parameters used to annualize capital costs (required)   |
| `requirements`    | `Vector{Requirement}`                    | Policy requirements the technology contributes to                 |

See [`SupplyTechnology`](@ref) for the complete list of fields and their defaults.

## See also

  - [Link Existing, Retiring, and Retrofit Capacity](@ref)
  - [`StorageTechnology`](@ref)
  - [`TechnologyFinancialData`](@ref)
  - [`add_technology!`](@ref)
