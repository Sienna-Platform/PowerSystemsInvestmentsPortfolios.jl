```@meta
CurrentModule = PowerSystemsInvestmentsPortfolios
```

# Add a Storage Technology

[`StorageTechnology{T}`](@ref) represents a candidate storage technology — battery, pumped
hydro, or other storage — whose charge power, discharge power, and energy capacity can be
built independently.

## Minimal working example

The example below adds a lithium-ion battery that may be built with 1 to 8 hours of
storage duration.

```julia
using PowerSystemsInvestmentsPortfolios
import PowerSystems as PSY
using PowerSystems: LinearCurve, CostCurve, StorageCost

portfolio = Portfolio()

west = Area(; name="West", input_basis=u"NU")
add_topology!(portfolio, west)

fin = TechnologyFinancialData(;
    capital_recovery_period=15,
    technology_base_year=2030,
    debt_fraction=0.4,
    debt_rate=0.05,
    return_on_equity=0.12,
    tax_rate=0.21,
)

battery = StorageTechnology{PSY.EnergyReservoirStorage}(;
    name="battery_west",
    available=true,
    region=[west],
    power_systems_type="EnergyReservoirStorage",
    financial_data=fin,
    prime_mover_type=PrimeMovers.BT,
    storage_tech=StorageTech.LIB,
    capital_costs=StorageCapitalCost(;
        discharge_capital_cost=LinearCurve(300_000.0),   # USD/MW
        energy_capital_cost=LinearCurve(250_000.0),      # USD/MWh
    ),
    operation_costs=StorageCost(;
        charge_variable_cost=CostCurve(LinearCurve(0.0)),
        discharge_variable_cost=CostCurve(LinearCurve(0.0)),
        fixed=0.0,
    ),
    capacity_limits_discharge=(min=0.0, max=500.0),   # MW
    capacity_limits_energy=(min=0.0, max=2000.0),     # MWh
    duration_limits=(min=60.0, max=480.0),            # minutes
    efficiency=(in=0.92, out=0.92),
    lifetime=15,
)

add_technology!(portfolio, battery)
```

## Capital costs for power and energy

A [`StorageCapitalCost`](@ref) holds one cost curve for each capacity that can be built,
plus an interconnection cost:

  - **`energy_capital_cost`** (USD/MWh) — cost of adding energy capacity.
  - **`discharge_capital_cost`** (USD/MW) — cost of adding discharge power capacity.
  - **`charge_capital_cost`** (USD/MW) — cost of adding charge power capacity, for
    technologies where it is sized separately (e.g. asymmetric pumped hydro).
  - **`interconnection_cost`** (USD/MW) — last-mile interconnection cost.

Every curve defaults to `LinearCurve(0.0)`. For a battery whose charge and discharge
hardware are the same, set only the energy and discharge curves.

## Key fields

| Field                       | Type                         | Description                                                   |
|:--------------------------- |:---------------------------- |:------------------------------------------------------------- |
| `capital_costs`             | [`StorageCapitalCost`](@ref) | Charge, discharge, energy, and interconnection costs          |
| `operation_costs`           | `PSY.StorageCost`            | Charge/discharge variable costs and fixed O&M                 |
| `capacity_limits_energy`    | `MinMax` or `Dict`           | Minimum and maximum energy capacity in MWh                    |
| `capacity_limits_discharge` | `MinMax` or `Dict`           | Minimum and maximum discharge capacity in MW                  |
| `capacity_limits_charge`    | `MinMax` or `Dict`           | Minimum and maximum charge capacity in MW                     |
| `duration_limits`           | `MinMax`                     | Allowed ratio of energy to discharge capacity, in minutes     |
| `efficiency`                | `InOut`                      | Charge (`in`) and discharge (`out`) efficiency, fractions     |
| `losses`                    | `Float64`                    | Self-discharge, fraction of stored energy per hour            |
| `unit_size_energy`          | `Float64`                    | Size of each energy unit for discrete investment, MWh         |
| `unit_size_discharge`       | `Float64`                    | Size of each discharge unit for discrete investment, MW       |
| `unit_size_charge`          | `Union{Nothing, Float64}`    | Size of each charge unit; `nothing` when not sized separately |
| `storage_tech`              | `StorageTech`                | Storage technology (e.g. `StorageTech.LIB`)                   |

See [`StorageTechnology`](@ref) for the complete list of fields and their defaults.

## See also

  - [Add a Co-located Supply and Storage Technology](@ref)
  - [`SupplyTechnology`](@ref)
  - [`add_technology!`](@ref)
