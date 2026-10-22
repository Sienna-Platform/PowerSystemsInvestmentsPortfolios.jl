```@meta
CurrentModule = PowerSystemsInvestmentsPortfolios
```

# Add Policy Requirements

Requirements represent policies that constrain investment decisions. Adding one takes two
steps:

 1. Add the requirement to the portfolio with [`add_requirement!`](@ref).
 2. List it in the `requirements` field of every technology that contributes to it, either
    at construction (`requirements=[...]`) or with `set_requirements!`.

The examples below assume a portfolio containing the `wind`, `ccgt`, and `datacenter`
technologies from the other how-to pages.

## Add a [`CarbonCaps`](@ref) constraint

`CarbonCaps` limits CO₂ emissions in the target year. Use `max_mtons` for an absolute limit
(million tonnes) or `max_tons_mwh` for an emission rate limit (Mt/MWh).

```julia
using PowerSystemsInvestmentsPortfolios

cap = CarbonCaps(; name="carbon_cap_2035", available=true, target_year=2035, max_mtons=50.0)
add_requirement!(portfolio, cap)
```

## Add a [`CarbonTax`](@ref)

`CarbonTax` adds a price on CO₂ emissions rather than a hard cap.

```julia
tax = CarbonTax(;
    name="carbon_tax_2040",
    available=true,
    target_year=2040,
    tax_dollars_per_ton=75.0,   # USD/tCO2
)
add_requirement!(portfolio, tax)
```

## Add a [`CapacityReserveMargin`](@ref)

`CapacityReserveMargin` requires installed capacity to exceed peak demand by a fraction.

```julia
crm = CapacityReserveMargin(;
    name="reserve_margin",
    available=true,
    target_year=2030,
    capacity_reserve_fraction=0.15,   # 15% above peak demand
)
add_requirement!(portfolio, crm)
```

## Add an [`EnergyShareRequirements`](@ref)

`EnergyShareRequirements` requires a fraction of annual demand to be met by the contributing
technologies.

```julia
rps = EnergyShareRequirements(;
    name="50pct_rps",
    available=true,
    target_year=2030,
    generation_fraction_requirement=0.50,
)
add_requirement!(portfolio, rps)
```

## Add an [`HourlyMatching`](@ref) constraint

`HourlyMatching` requires generation from contributing supply technologies to match demand
from contributing demand technologies in every hour.

```julia
cfe = HourlyMatching(; name="247_cfe", available=true)
add_requirement!(portfolio, cfe)
```

## Add capacity limits

[`MinimumCapacityRequirements`](@ref) and [`MaximumCapacityRequirements`](@ref) set a floor
or a ceiling on the total capacity of the contributing technologies.

```julia
min_wind = MinimumCapacityRequirements(;
    name="min_wind",
    available=true,
    target_year=2035,
    min_capacity_mw=200.0,
)
max_gas = MaximumCapacityRequirements(;
    name="max_gas",
    available=true,
    target_year=2050,
    max_capacity_mw=800.0,
)
add_requirement!(portfolio, min_wind)
add_requirement!(portfolio, max_gas)
```

## Link technologies to requirements

A technology contributes to every requirement in its `requirements` field. For a capacity
requirement, those are the technologies whose capacity is counted; for an energy share, the
technologies whose generation is counted; for hourly matching, both the supply and the
demand technologies that are matched.

```julia
set_requirements!(wind, [crm, rps, cfe, min_wind])
set_requirements!(ccgt, [cap, tax, crm, max_gas])
set_requirements!(datacenter, [cfe])
```

## Query requirements

```julia
get_requirements(CapacityReserveMargin, portfolio)       # all requirements of a type
get_requirement(EnergyShareRequirements, portfolio, "50pct_rps")
get_contributing_technologies(portfolio, cfe)            # [wind, datacenter]
has_requirement(wind, rps)                               # true
has_requirement(wind, CarbonTax)                         # false
```

## See also

  - [Requirements](@ref)
  - [`Requirement`](@ref)
  - [`get_contributing_technologies`](@ref)
