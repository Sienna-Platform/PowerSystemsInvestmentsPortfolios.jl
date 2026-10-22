```@meta
CurrentModule = PowerSystemsInvestmentsPortfolios
```

# Demand Technologies

## `DemandRequirement{T}`

A [`DemandRequirement{T}`](@ref) represents load that must be served in a region. Despite
its name, it is a subtype of `DemandTechnology` and is added with `add_technology!`.

**Type parameter:** `T <: PSY.StaticInjection`, typically `PSY.PowerLoad`.

**Key fields:** `region` (`Vector{PSY.Topology}`), `value_of_lost_load` (USD/MWh),
`unserved_demand_curve`, `growth_rate`; for new loads, `new_demand_mw`,
`new_construction_year`, and `conformity` (`PSY.LoadConformity`)

!!! note
    
    `DemandRequirement` is the demand side of the supply-demand balance, not a policy
    requirement. See [`Requirement`](@ref) for policies.

```@docs
DemandRequirement
```

## `DemandSideTechnology{T}`

A [`DemandSideTechnology{T}`](@ref) represents flexible demand that can be curtailed or
shifted in time.

**Type parameter:** `T <: PSY.StaticInjection`.

**Key fields:** `peak_demand_mw`, `min_power`, `max_demand_curtailment`,
`curtailment_cost`, `max_demand_delay` and `max_demand_advance` (minutes),
`demand_energy_efficiency`, `shift_variable_cost`, `technology_efficiency`,
`price_per_unit`

```@docs
DemandSideTechnology
```
