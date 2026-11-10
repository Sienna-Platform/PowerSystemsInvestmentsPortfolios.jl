```@meta
CurrentModule = PowerSystemsInvestmentsPortfolios
```

# Demand Technologies

## `ProjectedDemand{T}`

A [`ProjectedDemand{T}`](@ref) represents an exogenous load in a region that must be
served: its profile and peak are data, and the model only decides how it is served. It is a
subtype of `DemandTechnology`, not a policy requirement, and is added with `add_technology!`.

**Type parameter:** `T <: PSY.StaticInjection`, typically `PSY.PowerLoad`.

**Key fields:** `region` (`Vector{PSY.Topology}`), `growth_rate`, `conformity`
(`PSY.LoadConformity`), `max_demand_curtailment`, `curtailment_cost`,
`value_of_lost_load` (USD/MWh), `flexible_fraction`, `max_demand_delay` and
`max_demand_advance` (minutes), `shift_efficiency`, `shift_cost`; for new demands,
`peak_demand_mw` and `construction_year`

**Peak demand and time series:** a demand's `"ops_demand"` time series is normalized to
its peak demand, so it is at most 1 and carries no growth. A demand with an
`ExistingDevices` supplemental attribute takes its peak from those loads in the base system:
the maximum of their summed `"max_active_power"` profiles, each scaled by the load's maximum
active power (see `get_peak_demand_mw`). Its `"ops_demand"` should be normalized by that
same peak. A demand without `ExistingDevices` is new: its peak is `peak_demand_mw`, starting
in `construction_year`. Conforming demands grow by `growth_rate`; non-conforming demands do
not.

**Unserved demand:** up to `max_demand_curtailment` of the demand can be curtailed
voluntarily at `curtailment_cost`, either a single price (`LinearCurve`) or tiers whose x
coordinates are fractions of demand (`PiecewiseIncrementalCurve`). Any other unserved demand
is shed involuntarily at `value_of_lost_load`.

**Time shifting:** up to `flexible_fraction` of the demand can be served up to
`max_demand_delay` minutes later or `max_demand_advance` minutes earlier, keeping
`shift_efficiency` of the energy shifted, at `shift_cost`.

```@docs
ProjectedDemand
```

## `DemandSideTechnology{T}`

A [`DemandSideTechnology{T}`](@ref) represents an end-use technology that consumes
electricity and can be built, such as a hydrogen electrolyzer, direct air capture or an
industrial heat pump. Its capacity is an investment decision and its consumption an
operating decision, valued at `price_per_unit` per unit of product, with
`technology_efficiency` MWh of electricity per unit.

**Type parameter:** `T <: PSY.StaticInjection`.

**Key fields:** `capacity_limits`, `unit_size`, `capital_costs`, `operation_costs`
(`PSY.LoadCost`), `min_power`, `ramp_limits` (MW/min), `technology_efficiency`,
`price_per_unit`, `lifetime`, `financial_data`

```@docs
DemandSideTechnology
```
