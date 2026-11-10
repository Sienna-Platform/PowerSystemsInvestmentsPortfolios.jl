```@meta
CurrentModule = PowerSystemsInvestmentsPortfolios
```

# Add a Demand Technology

PSIP has two demand technology types, both added with [`add_technology!`](@ref):

  - [`ProjectedDemand{T}`](@ref) — load that must be served in a region, with optional
    voluntary curtailment and time shifting. It is a `DemandTechnology`, not a policy
    `Requirement`.
  - [`DemandSideTechnology{T}`](@ref) — an end-use technology that can be built, such as a
    hydrogen electrolyzer, whose consumption is valued by what it produces.

The examples below assume a portfolio with an `Area` named `west` already added (see
[Define Regions and Topology](@ref)).

## Load from the base system

To represent load that already exists in the base system, create a `ProjectedDemand`,
attach its load profile as the `"ops_peak_load"` time series (see
[Working With Time Series](@ref)), and point it at the existing loads with an
[`ExistingDevices`](@ref) attribute:

```julia
using PowerSystemsInvestmentsPortfolios
import PowerSystems as PSY

load = ProjectedDemand{PSY.PowerLoad}(;
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
datacenter = ProjectedDemand{PSY.PowerLoad}(;
    name="datacenter",
    available=true,
    power_systems_type="PowerLoad",
    region=[west],
    peak_demand_mw=300.0,
    construction_year=2030,
    conformity=PSY.LoadConformity.NON_CONFORMING,
)

add_technology!(portfolio, datacenter)
```

## Flexible demand

Curtailment and time shifting are part of a `ProjectedDemand`:

```julia
using PowerSystems: LinearCurve

ev_flex = ProjectedDemand{PSY.PowerLoad}(;
    name="ev_flex",
    available=true,
    power_systems_type="PowerLoad",
    region=[west],
    peak_demand_mw=100.0,
    construction_year=2030,
    conformity=PSY.LoadConformity.CONFORMING,
    max_demand_curtailment=0.1,             # fraction of demand
    curtailment_cost=LinearCurve(500.0),    # USD/MWh
    flexible_fraction=0.3,                  # fraction of demand that can be shifted
    max_demand_delay=240.0,                 # minutes
    max_demand_advance=120.0,               # minutes
)

add_technology!(portfolio, ev_flex)
```

## End-use technology

```julia
electrolyzer = DemandSideTechnology{PSY.PowerLoad}(;
    name="electrolyzer",
    available=true,
    power_systems_type="PowerLoad",
    region=[west],
    capital_costs=CapitalCost(LinearCurve(1_000_000.0), 0.0),   # USD/MW
    technology_efficiency=50.0,             # MWh per tonne of hydrogen
    price_per_unit=LinearCurve(3_000.0),    # USD per tonne of hydrogen
    financial_data=tech_financials,
)

add_technology!(portfolio, electrolyzer)
```

## See also

  - [`ProjectedDemand`](@ref)
  - [`DemandSideTechnology`](@ref)
  - [Technology Types](@ref)
