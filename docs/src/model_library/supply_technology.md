```@meta
CurrentModule = PowerSystemsInvestmentsPortfolios
```

# Supply Technology

A [`SupplyTechnology{T}`](@ref) represents a candidate generation technology. Each instance
describes one buildable option: where it can be built, what it costs, and how it operates.

## Type parameter

`T` must be a subtype of `PSY.Generator`. Common choices:

| `T`                     | Typical technology                  |
|:----------------------- |:----------------------------------- |
| `PSY.ThermalStandard`   | Gas, coal, nuclear                  |
| `PSY.RenewableDispatch` | Variable renewable (wind, solar PV) |
| `PSY.HydroDispatch`     | Hydropower                          |

## Key field groups

**Identity and location:** `name`, `available`, `power_systems_type`, `region`
(`Vector{PSY.Topology}`)

**Capacity:** `capacity_limits` (`MinMax` in MW, or a `Dict{PSY.Topology, MinMax}` for a
technology in several regions), `unit_size` (MW per unit for discrete investment)

**Economics:** `capital_costs` ([`CapitalCost`](@ref)), `operation_costs`
(`PSY.OperationalCost`), `financial_data` ([`TechnologyFinancialData`](@ref))

**Fuel and prime mover:** `prime_mover_type` (`PrimeMovers`), `fuel` (`Vector{ThermalFuels}`),
`start_fuel_mmbtu_per_mw`, `cofire_level_limits`, `cofire_start_limits`

**Operation:** `ramp_limits` (`UpDown`), `time_limits` (`UpDown`, minutes),
`min_generation_fraction`, `outage_factor` (`(planned, forced)`), `lifetime` (years)

**Policy:** `requirements` (`Vector{Requirement}`)

```@docs
SupplyTechnology
```

## `ColocatedSupplyStorageTechnology`

A [`ColocatedSupplyStorageTechnology`](@ref) represents a supply and a storage technology
that share one inverter and grid connection (e.g., solar PV plus a battery). It owns the two
technologies it references, which are masked in the portfolio; see
[Add a Co-located Supply and Storage Technology](@ref).

```@docs
ColocatedSupplyStorageTechnology
```
