```@meta
CurrentModule = PowerSystemsInvestmentsPortfolios
```

# Storage Technology

A [`StorageTechnology{T}`](@ref) represents a candidate storage technology whose charge
power, discharge power, and energy capacity are sized independently.

## Type parameter

`T` must be a subtype of `PSY.Storage`. The most common choice:

| `T`                          | Typical technology                        |
|:---------------------------- |:----------------------------------------- |
| `PSY.EnergyReservoirStorage` | Battery (lithium-ion, flow), pumped hydro |

## Key field groups

**Capacity:** `capacity_limits_energy` (MWh), `capacity_limits_discharge` (MW),
`capacity_limits_charge` (MW) — each a `MinMax` or a `Dict{PSY.Topology, MinMax}`

**Duration:** `duration_limits` (`MinMax` in minutes — ratio of energy to discharge capacity)

**Efficiency:** `efficiency` (`InOut` — charge and discharge efficiency), `losses`
(self-discharge, fraction of stored energy per hour), `min_discharge_fraction`

**Economics:** `capital_costs` ([`StorageCapitalCost`](@ref)), `operation_costs`
(`PSY.StorageCost`), `financial_data` ([`TechnologyFinancialData`](@ref))

**Build increments:** `unit_size_energy` (MWh), `unit_size_discharge` (MW),
`unit_size_charge` (MW, or `nothing`)

**Other:** `storage_tech` (`StorageTech`), `prime_mover_type`, `lifetime` (years),
`requirements`

```@docs
StorageTechnology
```
