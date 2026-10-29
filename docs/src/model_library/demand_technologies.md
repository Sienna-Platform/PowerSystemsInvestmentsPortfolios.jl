```@meta
CurrentModule = PowerSystemsInvestmentsPortfolios
```

# Demand Technologies

## `DemandRequirement{T}`

A [`DemandRequirement{T}`](@ref) represents a load that must be served in a region. Despite its name, `DemandRequirement` is a subtype of `DemandTechnology` and is added to the portfolio with `add_technology!`.

**Type parameter:** `T <: PSY.StaticInjection`, typically `PSY.PowerLoad`.

**Key fields:** `name`, `id`, `available`, `region` (`Vector{RegionTopology}`), `power_systems_type`

!!! note
    
    `DemandRequirement` encodes a demand that the optimizer must satisfy — it is the demand side of the supply-demand balance constraint, not a policy requirement. See [`Requirement`](@ref) for policy constraints.

**Peak demand and time series:** a demand's `"ops_demand"` time series is normalized to its peak demand, so it is at most 1 and carries no growth. A demand with an `ExistingDevices` supplemental attribute takes its peak from those loads in the base system: the maximum of their summed `"max_active_power"` profiles, each scaled by the load's maximum active power (see `get_peak_demand_mw`). Its `"ops_demand"` should be normalized by that same peak. A demand without `ExistingDevices` is new: its peak is `peak_demand_mw`, starting in `construction_year`. Conforming demands grow by `growth_rate`; non-conforming demands do not.

```@docs
DemandRequirement
```

## `DemandSideTechnology{T}`

A [`DemandSideTechnology{T}`](@ref) represents a demand flexibility resource — a load that can shift, curtail, or respond to price signals as part of the investment plan.

**Type parameter:** `T <: PSY.StaticInjection`.

```@docs
DemandSideTechnology
```
