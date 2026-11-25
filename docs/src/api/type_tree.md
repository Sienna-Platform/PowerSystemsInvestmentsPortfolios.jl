```@meta
CurrentModule = PowerSystemsInvestmentsPortfolios
```

# Type Tree

Full type hierarchies for the main PSIP abstract types.

## Technology hierarchy

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

## Requirement hierarchy

```
Requirement (abstract) <: PSY.Service
├── CarbonCaps
├── CarbonTax
├── CapacityReserveMargin
├── EnergyShareRequirements
├── HourlyMatching
├── MinimumCapacityRequirements
└── MaximumCapacityRequirements
```

## RegionTopology hierarchy

```
RegionTopology (abstract) <: IS.InfrastructureSystemsComponent
├── Zone
└── Node
```

## Supplemental attributes

The following types are `IS.SupplementalAttribute` instances attached to technologies, not subtypes of `Technology`:

```
IS.SupplementalAttribute
├── ExistingDevices
├── RetirementPotential
├── AggregateRetirementPotential
├── RetrofitPotential
└── AggregateRetrofitPotential
```
