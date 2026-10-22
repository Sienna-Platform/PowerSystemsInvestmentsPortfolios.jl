```@meta
CurrentModule = PowerSystemsInvestmentsPortfolios
```

# Policy Requirements

Requirements represent policies added to a portfolio with [`add_requirement!`](@ref). A
technology contributes to a requirement when the requirement is in the technology's
`requirements` field. Each type has its own page in this section with its full field list.

| Type                                  | Policy                                                                              |
|:------------------------------------- |:----------------------------------------------------------------------------------- |
| [`CarbonCaps`](@ref)                  | Limit on CO₂ emissions: absolute (`max_mtons`, Mt) or rate (`max_tons_mwh`, Mt/MWh) |
| [`CarbonTax`](@ref)                   | Cost on CO₂ emissions (`tax_dollars_per_ton`, USD/tCO₂)                             |
| [`CapacityReserveMargin`](@ref)       | Capacity above peak demand by `capacity_reserve_fraction`                           |
| [`EnergyShareRequirements`](@ref)     | `generation_fraction_requirement` of annual demand met by contributing technologies |
| [`HourlyMatching`](@ref)              | Contributing supply matches contributing demand in every hour                       |
| [`MinimumCapacityRequirements`](@ref) | Floor on capacity of contributing technologies (`min_capacity_mw`)                  |
| [`MaximumCapacityRequirements`](@ref) | Ceiling on capacity of contributing technologies (`max_capacity_mw`)                |

Every requirement except `HourlyMatching` has a `target_year` in which it applies.

See [Requirements](@ref) for how requirements work and
[Add Policy Requirements](@ref) for examples.
