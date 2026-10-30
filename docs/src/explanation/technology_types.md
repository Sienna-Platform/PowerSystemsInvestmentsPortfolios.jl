```@meta
CurrentModule = PowerSystemsInvestmentsPortfolios
```

# Technology Types

## The `Technology` Abstract Type

All technology types in PSIP extend the abstract type `Technology`, which itself extends `IS.InfrastructureSystemsComponent`. This means every technology is a first-class InfrastructureSystems component: it lives inside the portfolio's `data` field, can hold supplemental attributes, and can carry attached time series.

Every concrete technology type shares a common set of fields:

| Field                | Type                                      | Purpose                                                                                    |
|:-------------------- |:----------------------------------------- |:------------------------------------------------------------------------------------------ |
| `name`               | `String`                                  | Unique identifier for this technology within the portfolio                                 |
| `available`          | `Bool`                                    | Whether this technology is active in the model; set to `false` to exclude without deleting |
| `power_systems_type` | `String`                                  | PSY type name stored as a string; used for JSON serialization and PSI lookup               |
| `financial_data`     | `Union{Nothing, TechnologyFinancialData}` | Technology-level economic parameters; overrides portfolio defaults when set                |
| `region`             | `Vector{<:RegionTopology}`                | The regions where this technology operates                                                 |

## Type Hierarchy

```
Technology (abstract) <: IS.InfrastructureSystemsComponent
├── ResourceTechnology (abstract)
│   ├── SupplyTechnology{T <: PSY.Generator}
│   ├── StorageTechnology{T <: PSY.Storage}
│   └── ColocatedSupplyStorageTechnology{T <: PSY.Generator}
├── TransmissionTechnology (abstract)
│   ├── AggregateTransportTechnology{T <: PSY.Device}
│   ├── NodalACTransportTechnology{T <: PSY.Device}
│   └── NodalHVDCTransportTechnology{T <: PSY.Device}
└── DemandTechnology (abstract)
    ├── ProjectedDemand{T <: PSY.StaticInjection}
    └── DemandSideTechnology{T <: PSY.StaticInjection}
```

All concrete types except the supplemental attributes described below are added to a portfolio with `add_technology!`.

## The `{T}` Type Parameter

Every concrete technology type is parameterized by a PSY component type. For example:

  - [`SupplyTechnology`](@ref)`{T}` where `T <: PSY.Generator`
  - [`StorageTechnology`](@ref)`{T}` where `T <: PSY.Storage`
  - [`AggregateTransportTechnology`](@ref)`{T}` where `T <: PSY.Device`

This parameterization serves two purposes. At runtime, PSI uses the `{T}` parameter to look up operating costs, capacity limits, and constraints from the base system using the PSY type dispatch system. At serialization time, the concrete `T` cannot be stored directly in JSON, so the `power_systems_type` field records the type name as a string to reconstruct the parameterization on deserialization.

Common values of `T` for each technology branch:

| `T`                          | Typical technology           |
|:---------------------------- |:---------------------------- |
| `PSY.ThermalStandard`        | Gas CCGT, coal, nuclear      |
| `PSY.RenewableDispatch`      | Wind, solar PV               |
| `PSY.HydroDispatch`          | Run-of-river hydro           |
| `PSY.EnergyReservoirStorage` | Battery, pumped hydro        |
| `PSY.ACBranch`               | AC transmission line (zonal) |

## ResourceTechnology, TransmissionTechnology, and DemandTechnology

The three abstract branches partition the technology space by role in the model.

**`ResourceTechnology`** covers generation and storage candidates — technologies that inject power into or absorb power from a region. [`SupplyTechnology`](@ref) models dispatchable and variable generators. [`StorageTechnology`](@ref) models energy storage. [`ColocatedSupplyStorageTechnology`](@ref) models a generator and storage device that share a grid interconnection point and are optimized jointly.

**`TransmissionTechnology`** covers buildable connections between regions. [`AggregateTransportTechnology`](@ref) models a zonal transport constraint (a transfer capacity between two zones). [`NodalACTransportTechnology`](@ref) and [`NodalHVDCTransportTechnology`](@ref) model individual AC and HVDC lines in nodal formulations.

**`DemandTechnology`** covers demand-side modeling. [`ProjectedDemand`](@ref) represents an exogenous load that must be served, including any flexibility it has: voluntary curtailment and time shifting. [`DemandSideTechnology`](@ref) represents end-use technologies that can be built, such as hydrogen electrolyzers, whose consumption is a decision valued by what they produce.

## Supplemental Attributes for Existing Capacity and Retirement

Several types that describe existing capacity or retirement and retrofit potential are **not subtypes of `Technology`**. They are `IS.SupplementalAttribute` instances that attach to a technology object:

| Type                           | Purpose                                                         |
|:------------------------------ |:--------------------------------------------------------------- |
| [`ExistingDevices`](@ref)      | Records existing devices associated with a technology candidate |
| `RetirementPotential`          | Marks a technology as having retirable existing capacity        |
| `AggregateRetirementPotential` | Aggregated retirement potential across a region                 |
| `RetrofitPotential`            | Links a source technology's retrofittable units to a retrofit option; attached to both |
| `AggregateRetrofitPotential`   | Aggregated retrofit potential across a region                   |

These are attached via `add_supplemental_attribute!`, not `add_technology!`:

```julia
existing = ExistingDevices(; existing_devices=["gas_unit_1", "gas_unit_2"])
add_supplemental_attribute!(portfolio, wind_tech, existing)
```

!!! note
    
    Because these are supplemental attributes rather than technologies, they do not appear when iterating over `get_technologies(portfolio)`. Retrieve them with `IS.get_supplemental_attributes(ExistingDevices, portfolio, wind_tech)` or the equivalent PSIP accessor.

```@docs
ExistingDevices
```

## See Also

  - [`SupplyTechnology`](@ref)
  - [`StorageTechnology`](@ref)
  - [`ColocatedSupplyStorageTechnology`](@ref)
  - [`AggregateTransportTechnology`](@ref)
  - [`NodalACTransportTechnology`](@ref)
  - [`ProjectedDemand`](@ref)
  - [`ExistingDevices`](@ref)
