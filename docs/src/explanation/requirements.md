```@meta
CurrentModule = PowerSystemsInvestmentsPortfolios
```

# Requirements

## What Requirements Model

Requirements represent policies that the optimizer must satisfy when making investment
decisions. They do not generate or consume power — they bound the solution space. Examples:
a renewable portfolio standard requiring 50% clean energy, a 15% reserve margin above peak
demand, or a limit on total CO₂ emissions.

Each requirement adds one or more constraints (or, for a tax, cost terms) to the
optimization problem.

## The `Requirement` Abstract Type

`Requirement <: PSY.Service` is the abstract type of all policies. Like a PowerSystems
service, a requirement is a separate component that devices — here, technologies —
contribute to.

|                            | `Technology` subtypes | `Requirement` subtypes |
|:-------------------------- |:--------------------- |:---------------------- |
| Added via                  | `add_technology!`     | `add_requirement!`     |
| Role                       | Investment candidate  | Policy constraint      |
| Parameterized by PSY type? | Yes (`{T}`)           | No                     |

## Contributing Technologies

A requirement does not list the technologies it applies to. Instead, every technology has a
`requirements` field, and a technology contributes to each requirement in it. This mirrors how
PowerSystems devices list the services they provide.

```julia
add_requirement!(portfolio, rps)
set_requirements!(wind, [rps])
set_requirements!(solar, [rps])

get_contributing_technologies(portfolio, rps)   # [wind, solar]
```

What "contributing" means depends on the requirement: the technologies whose capacity is
counted toward a capacity requirement, whose generation is counted toward an energy share,
or whose emissions are capped or taxed.

## Requirement Types

### CarbonCaps

[`CarbonCaps`](@ref) limits CO₂ emissions in its `target_year`, either as an absolute
amount (`max_mtons`, million tonnes) or as an emission rate (`max_tons_mwh`, Mt/MWh).

### CarbonTax

[`CarbonTax`](@ref) adds a cost (USD/tCO₂) on emissions instead of a hard cap. Technologies
with higher emission rates face a higher effective marginal cost, shifting the cost-optimal
plan toward lower-emission alternatives without prohibiting any of them.

### CapacityReserveMargin

[`CapacityReserveMargin`](@ref) requires installed capacity to exceed peak demand by
`capacity_reserve_fraction`. A value of `0.15` requires capacity at least 15% above peak
demand.

### EnergyShareRequirements

[`EnergyShareRequirements`](@ref) requires that at least `generation_fraction_requirement`
of annual demand is met by contributing technologies. It models renewable portfolio
standards and clean energy standards with annual energy targets.

### HourlyMatching

[`HourlyMatching`](@ref) requires generation from contributing supply technologies to
match demand from contributing demand technologies in every hour, not only on an annual
average. It models 24/7 carbon-free energy commitments and is stricter than an annual energy
share at the same level.

### MinimumCapacityRequirements and MaximumCapacityRequirements

[`MinimumCapacityRequirements`](@ref) sets a floor (`min_capacity_mw`) and
[`MaximumCapacityRequirements`](@ref) a ceiling (`max_capacity_mw`) on the total capacity of
the contributing technologies in the target year — for example an offshore wind target or a
siting limit.

## DemandRequirement — the Boundary Case

[`DemandRequirement`](@ref) is a subtype of `DemandTechnology`, **not** `Requirement`. It
represents load that must be served and is added with `add_technology!`. See
[Technology Types](@ref).

## See Also

  - [Add Policy Requirements](@ref)
  - [`Requirement`](@ref)
  - [`add_requirement!`](@ref)
  - [`get_contributing_technologies`](@ref)
