```@meta
CurrentModule = PowerSystemsInvestmentsPortfolios
```

# Add a Demand Technology

PSIP has two demand technology types, both added with [`add_technology!`](@ref):

  - [`DemandRequirement{T}`](@ref) — load that must be served in a region. Despite its name
    it is a `DemandTechnology`, not a policy `Requirement`.
  - [`DemandSideTechnology{T}`](@ref) — flexible demand that can be curtailed or shifted in
    time.

The examples below assume a portfolio with an `Area` named `west` already added (see
[Define Regions and Topology](@ref)).

## Load from the base system

To represent load that already exists in the base system, create a `DemandRequirement`,
attach its load profile as the `"ops_peak_load"` time series (see
[Working With Time Series](@ref)), and point it at the existing loads with an
[`ExistingDevices`](@ref) attribute:

```julia
using PowerSystemsInvestmentsPortfolios
import PowerSystems as PSY

load = DemandRequirement{PSY.PowerLoad}(;
    name="load_west",
    available=true,
    power_systems_type="PowerLoad",
    region=[west],
    value_of_lost_load=10_000.0,   # USD/MWh
    growth_rate=0.01,              # annual load growth
)

add_technology!(portfolio, load)
add_supplemental_attribute!(portfolio, load, ExistingDevices(; existing_devices=["load_1"]))
```

## New load

A load that does not exist yet — a new data center, for example — sets its peak demand and
the year it is built:

```julia
datacenter = DemandRequirement{PSY.PowerLoad}(;
    name="datacenter",
    available=true,
    power_systems_type="PowerLoad",
    region=[west],
    new_demand_mw=300.0,
    new_construction_year=2030,
    conformity=PSY.LoadConformity.NON_CONFORMING,
)

add_technology!(portfolio, datacenter)
```

## Flexible demand

```julia
using PowerSystems: LinearCurve

ev_flex = DemandSideTechnology{PSY.PowerLoad}(;
    name="ev_flex",
    available=true,
    power_systems_type="PowerLoad",
    region=[west],
    peak_demand_mw=100.0,
    max_demand_curtailment=0.1,             # fraction of demand
    curtailment_cost=LinearCurve(500.0),    # USD/MWh
    max_demand_delay=240.0,                 # minutes
    max_demand_advance=120.0,               # minutes
)

add_technology!(portfolio, ev_flex)
```

## See also

  - [`DemandRequirement`](@ref)
  - [`DemandSideTechnology`](@ref)
  - [Technology Types](@ref)
