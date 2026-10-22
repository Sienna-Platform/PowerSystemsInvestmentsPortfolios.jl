```@meta
CurrentModule = PowerSystemsInvestmentsPortfolios
```

# Technology Types

## The `Technology` Abstract Type

All technology types in PSIP extend the abstract type `Technology`, which itself extends
`IS.InfrastructureSystemsComponent`. Every technology is a first-class InfrastructureSystems
component: it lives inside the portfolio, can hold supplemental attributes, and can carry
time series.

Most technologies share these fields:

| Field                | Type                              | Purpose                                                                       |
|:-------------------- |:--------------------------------- |:----------------------------------------------------------------------------- |
| `name`               | `String`                          | Identifier, unique within the technology's concrete type                      |
| `available`          | `Bool`                            | Whether the technology is considered; `false` excludes it without deleting it |
| `power_systems_type` | `String`                          | Name of the PSY type the technology maps to, kept for serialization           |
| `region`             | `Vector{PSY.Topology}`            | Where the technology can be built (transmission uses endpoints instead)       |
| `financial_data`     | [`TechnologyFinancialData`](@ref) | Financing parameters (supply, storage, co-located, and transmission)          |
| `requirements`       | `Vector{Requirement}`             | Policy requirements the technology contributes to                             |
| `ext`                | `Dict`                            | Extra user data                                                               |

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
    ├── DemandRequirement{T <: PSY.StaticInjection}
    └── DemandSideTechnology{T <: PSY.StaticInjection}
```

All of these are added to a portfolio with `add_technology!`.

## The `{T}` Type Parameter

Every concrete technology type is parameterized by a PSY component type, for example
`SupplyTechnology{PSY.RenewableDispatch}`. `PowerSystemsInvestments.jl` dispatches on `T` to
choose formulations and to find existing units of the same type in the base system. Because
a type cannot be written to a file directly, `power_systems_type` records its name so the
parameter can be restored when the portfolio is read.

| `T`                          | Typical technology    |
|:---------------------------- |:--------------------- |
| `PSY.ThermalStandard`        | Gas, coal, nuclear    |
| `PSY.RenewableDispatch`      | Wind, solar PV        |
| `PSY.HydroDispatch`          | Run-of-river hydro    |
| `PSY.EnergyReservoirStorage` | Battery, pumped hydro |
| `PSY.ACBranch`, `PSY.Line`   | AC transmission       |
| `PSY.PowerLoad`              | Demand                |

## ResourceTechnology, TransmissionTechnology, and DemandTechnology

The three abstract branches partition technologies by their role in the model.

**`ResourceTechnology`** covers generation and storage. [`SupplyTechnology`](@ref) models
dispatchable and variable generators, [`StorageTechnology`](@ref) models energy storage, and
[`ColocatedSupplyStorageTechnology`](@ref) models a generator and a storage device that share
one inverter and grid connection.

**`TransmissionTechnology`** covers buildable connections.
[`AggregateTransportTechnology`](@ref) is a transfer corridor between two zones;
[`NodalACTransportTechnology`](@ref) and [`NodalHVDCTransportTechnology`](@ref) are AC and
HVDC lines between two buses.

**`DemandTechnology`** covers demand. [`DemandRequirement`](@ref) is load that must be
served; [`DemandSideTechnology`](@ref) is flexible demand that can be curtailed or shifted.

## `DemandRequirement`

!!! note
    
    [`DemandRequirement`](@ref)`{T}` is a subtype of `DemandTechnology`, **not** a
    `Requirement`. It is added with `add_technology!`. Its name reflects that it *requires*
    generation to serve it: it is the demand side of the supply-demand balance.

## Co-located Technologies and Masking

A [`ColocatedSupplyStorageTechnology`](@ref) owns the supply and storage technologies it
references. When it is added to a portfolio those parts become **masked**: they stay in the
portfolio and reachable through [`get_subcomponents`](@ref) and
[`get_masked_technologies`](@ref), but [`get_technologies`](@ref) leaves them out. This is
the same rule PowerSystems applies to the subcomponents of a `HybridSystem`, and it keeps a
model from building the project twice.

## Supplemental Attributes for Existing Capacity

Data about existing units is attached to a technology as `IS.SupplementalAttribute`s rather
than stored as technologies:

| Type                          | Purpose                                                         |
|:----------------------------- |:--------------------------------------------------------------- |
| [`ExistingDevices`](@ref)     | Base system components whose capacity counts for the technology |
| [`RetirementPotential`](@ref) | Existing units that may be retired, and the cost of retiring    |
| [`RetrofitPotential`](@ref)   | Existing units that may be retrofitted, and the cost            |

A technology without an `ExistingDevices` attribute is new ([`is_new`](@ref) returns `true`)
and has no existing capacity. See
[Link Existing, Retiring, and Retrofit Capacity](@ref).

## See Also

  - [`SupplyTechnology`](@ref)
  - [`StorageTechnology`](@ref)
  - [`ColocatedSupplyStorageTechnology`](@ref)
  - [`AggregateTransportTechnology`](@ref)
  - [`NodalACTransportTechnology`](@ref)
  - [`DemandRequirement`](@ref)
