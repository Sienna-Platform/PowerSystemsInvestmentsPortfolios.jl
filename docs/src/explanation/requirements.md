```@meta
CurrentModule = PowerSystemsInvestmentsPortfolios
```

# Requirements

## What Requirements Model

Requirements represent policy constraints that the optimizer must satisfy when making investment decisions. They do not generate or consume power — they bound the solution space. Examples: a state renewable portfolio standard mandating 50% clean energy, a reliability requirement ensuring 15% reserve margin above peak demand, or a carbon budget limiting total CO₂ emissions.

Conceptually, each requirement adds one or more constraints to the optimization problem. The optimizer must find an investment plan that satisfies all requirements simultaneously.

## The `Requirement` Abstract Type

`Requirement <: IS.InfrastructureSystemsComponent` is the abstract base for all policy constraints. Requirements are distinct from technologies:

|                            | `Technology` subtypes | `Requirement` subtypes |
|:-------------------------- |:--------------------- |:---------------------- |
| Added via                  | `add_technology!`     | `add_requirement!`     |
| Role                       | Investment candidate  | Policy constraint      |
| Parameterized by PSY type? | Yes (`{T}`)           | No                     |

!!! note
    
    Requirements must be added to a portfolio with `add_requirement!`, not `add_technology!`. Passing a requirement to `add_technology!` will throw a method error.

## Requirement Types

### CarbonCaps

[`CarbonCaps`](@ref) enforces a CO₂ emissions limit. It operates in two modes:

  - `max_tons_mwh` caps the emission *intensity* of the system (tCO₂/MWh of total generation).
  - `max_mtons` caps the *absolute* annual volume of CO₂ emissions (million tCO₂/year).

Use `CarbonCaps` to model carbon budget constraints, clean electricity standards that limit emissions per unit of output, or absolute tonnage limits set by regulation.

### CarbonTax

[`CarbonTax`](@ref) adds a cost signal (USD/tCO₂) on CO₂ emissions rather than imposing a hard cap. Technologies with higher emission rates face a higher effective marginal cost, nudging the optimizer toward cleaner alternatives without prohibiting any specific technology.

A carbon tax affects the objective function directly: the expected emissions of each technology candidate are multiplied by the tax rate and added to that technology's operating cost. This makes carbon-intensive resources more expensive at the margin, shifting the cost-optimal solution toward lower-emission alternatives.

### CapacityReserveMargin

[`CapacityReserveMargin`](@ref) requires total installed capacity to exceed peak demand by a given fraction (`capacity_reserve_fraction`). A value of `0.15` means total capacity must be at least 15% above the peak demand level. This requirement models resource adequacy standards that ensure a buffer of generation capacity exists beyond the expected maximum demand.

### EnergyShareRequirements

[`EnergyShareRequirements`](@ref) enforces that a minimum fraction of total annual energy is served by eligible resources (`generation_fraction_requirement`). A value of `0.50` means 50% of annual demand must come from the resource set listed in `eligible_resources`. This requirement models renewable portfolio standards (RPS) and clean energy standards that specify an annual energy-based target.

Unlike `HourlyMatching`, this requirement evaluates compliance on an annual-average basis: a wind or solar resource that produces energy in any hour contributes to the annual total.

### HourlyMatching

[`HourlyMatching`](@ref) enforces hour-by-hour clean energy matching (24/7 carbon-free energy, CFE). Eligible resources (`eligible_resources`) must cover eligible demand (`eligible_demand`) in every hour of the year, not just on an annual average.

This is a strictly stronger constraint than `EnergyShareRequirements`. A portfolio that satisfies hourly matching automatically satisfies any annual energy share target at the same percentage, but the converse is not true. `HourlyMatching` models 24/7 clean energy procurement commitments and hourly carbon-free energy (CFE) standards.

### MinimumCapacityRequirements

[`MinimumCapacityRequirements`](@ref) sets a floor on total installed capacity for a set of eligible resources (`min_capacity_mw`). The optimizer must build at least that many MW of the listed resource types. Use this requirement to mandate a minimum amount of a specific technology — for example, an offshore wind target or a storage mandate specified in MW.

### MaximumCapacityRequirements

[`MaximumCapacityRequirements`](@ref) sets a ceiling on total installed capacity for a set of eligible resources (`max_capacity_mw`). The optimizer may not build more than that many MW of the listed resource types. Use this requirement to limit overbuild of a specific technology — for example, a siting constraint that caps onshore wind in a particular region.

## `eligible_regions` and `eligible_resources` Fields

Several requirement types accept `eligible_regions` and `eligible_resources` vectors to scope their effect spatially and by technology type.

  - `eligible_regions::Vector{RegionTopology}` — when set, the requirement applies only within those planning zones or nodes. An empty vector means the requirement applies globally across all regions.
  - `eligible_resources::Vector{ResourceTechnology}` — the set of technology candidates that count toward satisfying (or are counted against) the requirement. For `EnergyShareRequirements`, only generation from listed technologies counts toward the annual fraction. For `MinimumCapacityRequirements` and `MaximumCapacityRequirements`, only the listed technologies contribute to the capacity total being bounded.

Both fields allow one requirement object to target a specific subset of the modeled system without creating separate requirement objects for each region or resource class.

## See Also

  - [`Requirement`](@ref)
  - [`CarbonCaps`](@ref)
  - [`CarbonTax`](@ref)
  - [`CapacityReserveMargin`](@ref)
  - [`EnergyShareRequirements`](@ref)
  - [`HourlyMatching`](@ref)
  - [`MinimumCapacityRequirements`](@ref)
  - [`MaximumCapacityRequirements`](@ref)
  - [`add_requirement!`](@ref)
