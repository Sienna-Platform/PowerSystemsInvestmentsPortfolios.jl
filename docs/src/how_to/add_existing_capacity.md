```@meta
CurrentModule = PowerSystemsInvestmentsPortfolios
```

# Link Existing, Retiring, and Retrofit Capacity

A technology describes *new* capacity. Existing capacity lives in the base system, and the
link between the two is made with supplemental attributes attached to the technology:

| Attribute                     | Purpose                                                              |
|:----------------------------- |:-------------------------------------------------------------------- |
| [`ExistingDevices`](@ref)     | The base system components whose capacity counts for this technology |
| [`RetirementPotential`](@ref) | Existing units that may be retired, with retirement years and costs  |
| [`RetrofitPotential`](@ref)   | Existing units that may be retrofitted, with the fraction and cost   |

Attach each one with `add_supplemental_attribute!`. The names listed in an attribute must
match the `name` of components in the base system.

## Existing capacity

```julia
using PowerSystemsInvestmentsPortfolios
using PowerSystems: LinearCurve

existing = ExistingDevices(; existing_devices=["gas_1", "gas_2"])
add_supplemental_attribute!(portfolio, ccgt, existing)

is_new(ccgt)                              # false
get_existing_capacity_mw(portfolio, ccgt) # sum of the ratings of gas_1 and gas_2, in MW
```

For a [`StorageTechnology`](@ref), [`get_existing_capacity_mwh`](@ref) returns the existing
energy capacity as well.

## Retirement

```julia
retirement = RetirementPotential(;
    eligible_generators=["gas_1"],
    planned_retirement_year=Dict("gas_1" => 2035),   # optional forced retirements
    build_year=Dict("gas_1" => 1995),                # optional
    retirement_cost=LinearCurve(10_000.0),           # USD/MW
)
add_supplemental_attribute!(portfolio, ccgt, retirement)
```

## Retrofit

```julia
retrofit = RetrofitPotential(;
    eligible_generators=["gas_2"],
    retrofit_fraction=0.5,                     # fraction of existing capacity
    retrofit_cost=LinearCurve(200_000.0),      # USD/MW
)
add_supplemental_attribute!(portfolio, ccgt, retrofit)
```

## Read them back

```julia
get_supplemental_attributes(ExistingDevices, ccgt)
get_supplemental_attributes(RetirementPotential, portfolio)
```

!!! note
    
    Supplemental attributes cannot be added to a masked technology — the supply or storage
    part of a [`ColocatedSupplyStorageTechnology`](@ref). Attach them before adding the
    co-located technology.

## See also

  - [Existing, Retirement, and Retrofit Data](@ref)
  - [`get_existing_capacity_mw`](@ref)
