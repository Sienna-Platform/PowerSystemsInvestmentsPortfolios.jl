```@meta
CurrentModule = PowerSystemsInvestmentsPortfolios
```

# Migrate to the PowerSystems 6 data model

This version of PSIP is built on PowerSystems 6 and InfrastructureSystems 4. This page lists
the changes needed to update code written for the previous version.

## Regions are PowerSystems topology

`RegionTopology`, `Zone`, and `Node` are removed. Technologies are located with
PowerSystems topology components, which are stored in the portfolio's base system.

```julia
# Before
zone = Zone(; name="West", id=1)
add_region!(portfolio, zone)

# After
zone = Area(; name="West", input_basis=u"NU")   # or LoadZone; ACBus for nodal models
add_topology!(portfolio, zone)
```

  - `region` fields are `Vector{PSY.Topology}`.
  - `AggregateTransportTechnology` endpoints are `PSY.AggregationTopology`;
    `NodalACTransportTechnology` and `NodalHVDCTransportTechnology` endpoints are `PSY.Bus`.
  - Topology must be added before a technology that references it.
  - `add_region!`, `get_regions`, and `get_region` remain as aliases.

See [Define Regions and Topology](@ref).

## The `id` field is removed

Technologies, requirements, and supplemental attributes no longer take an `id` keyword.
Remove it from constructor calls.

## Capital costs are `CapitalCost` structs

`capital_costs` is no longer a `ValueCurve`, and the separate storage cost fields are merged:

```julia
# Before
capital_costs = LinearCurve(1200.0)

# After
capital_costs = CapitalCost(; capital_cost=LinearCurve(1200.0), interconnection_cost=0.0)
```

| Before (storage)                                                          | After                                                                                                                        |
|:------------------------------------------------------------------------- |:---------------------------------------------------------------------------------------------------------------------------- |
| `capital_costs_charge`, `capital_costs_discharge`, `capital_costs_energy` | `capital_costs=StorageCapitalCost(; charge_capital_cost, discharge_capital_cost, energy_capital_cost, interconnection_cost)` |

The co-located inverter cost, `capital_costs_inverter`, is also a `CapitalCost`.

## Changed field types and units

| Field                                                         | Change                                                         |
|:------------------------------------------------------------- |:-------------------------------------------------------------- |
| `SupplyTechnology.outage_factor`                              | Now `(planned=..., forced=...)`, not a single number           |
| `SupplyTechnology.time_limits`                                | Minutes, not hours                                             |
| `StorageTechnology.duration_limits`                           | Minutes, not hours                                             |
| `DemandSideTechnology.max_demand_delay`, `max_demand_advance` | Minutes                                                        |
| `CarbonCaps.max_tons_mwh`                                     | Mt/MWh, not tCO₂/MWh                                           |
| `capacity_limits` (supply, storage)                           | May also be a `Dict{PSY.Topology, MinMax}` for several regions |
| `RetirementPotential`                                         | New required field `retirement_cost` (USD/MW)                  |
| `RetrofitPotential`                                           | New fields `retrofit_fraction` and `retrofit_cost` (USD/MW)    |

`AggregateRetirementPotential` and `AggregateRetrofitPotential` are removed.

Unit-aware getters require a units argument: use `get_capacity_limits(tech, NU)` for the
natural-unit value.

## Time series features

Operational time series are tagged with a `features` dictionary, both when adding and when
reading them:

```julia
# Before
add_time_series!(portfolio, tech, ts; year="2024", rep_day=1)

# After
add_time_series!(portfolio, tech, ts; features=Dict("year" => "2024", "rep_day" => 1))
get_time_series_array(
    SingleTimeSeries,
    tech,
    "ops_variable_cap_factor";
    features=Dict("year" => "2024", "rep_day" => 1),
)
```

## Serialization

`to_json` and `Portfolio(path)` are replaced by [`to_file`](@ref) and [`from_file`](@ref),
which write an OpenAPI document instead of the InfrastructureSystems JSON format. Files
written by the previous version cannot be read; rebuild the portfolio and save it again.

```julia
# Before
to_json(portfolio, "data/my_portfolio")
portfolio = Portfolio("data/my_portfolio.json")

# After
PSIP.to_file(portfolio, "data/my_portfolio.json")
portfolio = PSIP.from_file("data/my_portfolio.json")
```

See [Save and Load a Portfolio](@ref).

## Co-located technologies own their parts

Adding a [`ColocatedSupplyStorageTechnology`](@ref) now masks its supply and storage
technologies: they no longer appear in [`get_technologies`](@ref). Use
[`get_subcomponents`](@ref) or [`get_masked_technologies`](@ref) to reach them. See
[Add a Co-located Supply and Storage Technology](@ref).
