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
    ├── DemandRequirement{T <: PSY.StaticInjection}
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

## Topology

PSIP uses the `PowerSystems.jl` topology types; it defines none of its own.

```
PSY.Topology
├── PSY.AggregationTopology
│   ├── PSY.Area
│   └── PSY.LoadZone
├── PSY.Bus
│   ├── PSY.ACBus
│   └── PSY.DCBus
└── PSY.Arc
```

## Supplemental attributes

The following types are `IS.SupplementalAttribute`s attached to technologies, not subtypes of
`Technology`:

```
IS.SupplementalAttribute
├── ExistingDevices
├── RetirementPotential
└── RetrofitPotential
```

## Costs and financial data

```
IS.DeviceParameter
├── InvestmentCost
│   ├── CapitalCost
│   └── StorageCapitalCost
└── FinancialData
    └── TechnologyFinancialData

IS.InfrastructureSystemsType
├── PortfolioFinancialData
└── InvestmentScheduleResults
```
