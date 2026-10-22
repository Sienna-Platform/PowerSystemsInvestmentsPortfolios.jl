```@meta
CurrentModule = PowerSystemsInvestmentsPortfolios
```

# Add a Co-located Supply and Storage Technology

[`ColocatedSupplyStorageTechnology{T}`](@ref) represents a generator and a storage device
that share one inverter and grid connection — for example solar PV plus a battery. It
references a [`SupplyTechnology`](@ref) and a [`StorageTechnology`](@ref) and adds the
shared inverter's limits and costs.

## Example

Build the supply and storage technologies first, then the co-located technology that owns
them. The two parts do not need to be added to the portfolio separately.

```julia
using PowerSystemsInvestmentsPortfolios
import PowerSystems as PSY
using PowerSystems: LinearCurve, CostCurve, RenewableGenerationCost, StorageCost

portfolio = Portfolio()
east = Area(; name="East", input_basis=u"NU")
add_topology!(portfolio, east)

fin = TechnologyFinancialData(;
    capital_recovery_period=20,
    technology_base_year=2030,
    debt_fraction=0.4,
    debt_rate=0.05,
    return_on_equity=0.12,
    tax_rate=0.21,
)

pv = SupplyTechnology{PSY.RenewableDispatch}(;
    name="hybrid_pv",
    available=true,
    region=[east],
    power_systems_type="RenewableDispatch",
    financial_data=fin,
    prime_mover_type=PrimeMovers.PVe,
    capital_costs=CapitalCost(; capital_cost=LinearCurve(1_000_000.0)),
    operation_costs=RenewableGenerationCost(CostCurve(LinearCurve(0.0))),
)

battery = StorageTechnology{PSY.EnergyReservoirStorage}(;
    name="hybrid_battery",
    available=true,
    region=[east],
    power_systems_type="EnergyReservoirStorage",
    financial_data=fin,
    storage_tech=StorageTech.LIB,
    operation_costs=StorageCost(;
        charge_variable_cost=CostCurve(LinearCurve(0.0)),
        discharge_variable_cost=CostCurve(LinearCurve(0.0)),
        fixed=0.0,
    ),
)

hybrid = ColocatedSupplyStorageTechnology{PSY.RenewableDispatch}(;
    name="pv_plus_storage",
    power_systems_type="RenewableDispatch",
    region=[east],
    financial_data=fin,
    supply_technology=pv,
    storage_technology=battery,
    inverter_capacity_limits=(min=0.0, max=400.0),                       # MW
    capital_costs_inverter=CapitalCost(; capital_cost=LinearCurve(70_000.0)),
    operation_costs_inverter=CostCurve(LinearCurve(0.0)),
    inverter_efficiency=0.96,
    inverter_supply_ratio=1.3,
)

add_technology!(portfolio, hybrid)
```

## How the parts are stored

The supply and storage parts are added to the portfolio as **masked** technologies, as the
subcomponents of a PowerSystems `HybridSystem` are. They stay reachable from the co-located
technology but are left out of [`get_technologies`](@ref), so a model built from the
portfolio sees the co-located project once rather than its parts as well.

```julia
get_subcomponents(hybrid)                               # (pv, battery)
is_masked(pv, portfolio)                                # true
collect(get_technologies(SupplyTechnology, portfolio))  # does not include pv
collect(get_masked_technologies(SupplyTechnology, portfolio))  # [pv]
```

  - A supply or storage technology can belong to only one co-located technology.
  - Removing the co-located technology with [`remove_technology!`](@ref) removes its parts.
  - Supplemental attributes cannot be added to a masked technology, so attach them to the
    parts **before** adding the co-located technology.

## See also

  - [`ColocatedSupplyStorageTechnology`](@ref)
  - [Add a Supply Technology](@ref)
  - [Add a Storage Technology](@ref)
