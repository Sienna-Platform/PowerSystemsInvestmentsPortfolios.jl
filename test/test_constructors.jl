@testset "Technology Constructors" begin
    tech_financial_data = TechnologyFinancialData(
        capital_recovery_period=20,
        technology_base_year=2020,
        debt_fraction=0.5,
        debt_rate=0.05,
        return_on_equity=0.08,
        tax_rate=0.21,
    )

    zone_a = Zone(name="zone_a", id=1)
    zone_b = Zone(name="zone_b", id=2)
    node_a = Node(name="node_a", id=1)
    node_b = Node(name="node_b", id=2)

    @test zone_a isa Zone
    @test zone_a isa RegionTopology
    @test node_a isa Node
    @test node_a isa RegionTopology

    carbon_caps = CarbonCaps(name="carbon_cap", id=1, available=true)
    capacity_reserve = CapacityReserveMargin(name="reserve_margin", id=2, available=true)
    carbon_tax = CarbonTax(name="carbon_tax", id=3, available=true)
    hourly_matching = HourlyMatching(name="hourly_matching", id=4, available=true)
    energy_share = EnergyShareRequirements(name="energy_share", id=5, available=true)
    minimum_capacity =
        MinimumCapacityRequirements(name="minimum_capacity", id=6, available=true)
    maximum_capacity =
        MaximumCapacityRequirements(name="maximum_capacity", id=7, available=true)

    @test carbon_caps isa CarbonCaps
    @test capacity_reserve isa CapacityReserveMargin
    @test carbon_tax isa CarbonTax
    @test hourly_matching isa HourlyMatching
    @test energy_share isa EnergyShareRequirements
    @test minimum_capacity isa MinimumCapacityRequirements
    @test maximum_capacity isa MaximumCapacityRequirements
    @test carbon_caps isa Requirement

    supply = SupplyTechnology{PSY.ThermalStandard}(
        name="supply",
        id=10,
        financial_data=tech_financial_data,
        power_systems_type="ThermalStandard",
        available=true,
        region=[zone_a],
    )
    storage = StorageTechnology{PSY.EnergyReservoirStorage}(
        name="storage",
        id=11,
        storage_tech=StorageTech.LIB,
        financial_data=tech_financial_data,
        power_systems_type="EnergyReservoirStorage",
        available=true,
        region=[zone_a],
    )
    demand_requirement = DemandRequirement{PSY.PowerLoad}(
        name="demand_requirement",
        id=12,
        power_systems_type="PowerLoad",
        value_of_lost_load=1000.0,
        available=true,
        region=[zone_a],
    )
    demand_side = DemandSideTechnology{PSY.PowerLoad}(
        name="demand_side",
        id=13,
        power_systems_type="PowerLoad",
        available=true,
        region=[zone_a],
    )
    aggregate_transport = AggregateTransportTechnology{PSY.ACBranch}(
        name="aggregate_transport",
        id=14,
        start_region=zone_a,
        end_region=zone_b,
        financial_data=tech_financial_data,
        power_systems_type="ACBranch",
        available=true,
    )
    nodal_ac_transport = NodalACTransportTechnology{PSY.ACBranch}(
        name="nodal_ac_transport",
        id=15,
        start_node=node_a,
        end_node=node_b,
        financial_data=tech_financial_data,
        power_systems_type="ACBranch",
        available=true,
    )
    nodal_hvdc_transport = NodalHVDCTransportTechnology{PSY.ACBranch}(
        name="nodal_hvdc_transport",
        id=16,
        start_node=node_a,
        end_node=node_b,
        financial_data=tech_financial_data,
        power_systems_type="ACBranch",
        available=true,
    )
    colocated_supply_storage = ColocatedSupplyStorageTechnology{PSY.RenewableDispatch}(
        name="colocated_supply_storage",
        id=17,
        operation_costs_inverter=StorageCost(),
        financial_data=tech_financial_data,
        inverter_efficiency=0.96,
        power_systems_type="RenewableDispatch",
        inverter_supply_ratio=1.0,
        capital_costs_inverter=CapitalCost(LinearCurve(0.0), 0.0),
        available=true,
        region=[zone_a],
    )

    @test supply isa SupplyTechnology{PSY.ThermalStandard}
    @test supply isa ResourceTechnology
    @test storage isa StorageTechnology{PSY.EnergyReservoirStorage}
    @test storage isa ResourceTechnology
    @test demand_requirement isa DemandRequirement{PSY.PowerLoad}
    @test demand_requirement isa DemandTechnology
    @test demand_side isa DemandSideTechnology{PSY.PowerLoad}
    @test demand_side isa DemandTechnology
    @test aggregate_transport isa AggregateTransportTechnology{PSY.ACBranch}
    @test aggregate_transport isa TransmissionTechnology
    @test nodal_ac_transport isa NodalACTransportTechnology{PSY.ACBranch}
    @test nodal_ac_transport isa TransmissionTechnology
    @test nodal_hvdc_transport isa NodalHVDCTransportTechnology{PSY.ACBranch}
    @test nodal_hvdc_transport isa TransmissionTechnology
    @test colocated_supply_storage isa
          ColocatedSupplyStorageTechnology{PSY.RenewableDispatch}
    @test colocated_supply_storage isa ResourceTechnology

    retirement_potential = RetirementPotential(id=20)
    aggregate_retirement_potential = AggregateRetirementPotential(id=21)
    retrofit_potential = RetrofitPotential(id=22)
    aggregate_retrofit_potential = AggregateRetrofitPotential(id=23)
    existing_devices = ExistingDevices(id=24)
    topology_mapping = TopologyMapping(id=25)

    @test retirement_potential isa RetirementPotential
    @test retirement_potential isa IS.SupplementalAttribute
    @test aggregate_retirement_potential isa AggregateRetirementPotential
    @test aggregate_retirement_potential isa IS.SupplementalAttribute
    @test retrofit_potential isa RetrofitPotential
    @test retrofit_potential isa IS.SupplementalAttribute
    @test aggregate_retrofit_potential isa AggregateRetrofitPotential
    @test aggregate_retrofit_potential isa IS.SupplementalAttribute
    @test existing_devices isa ExistingDevices
    @test existing_devices isa IS.SupplementalAttribute
    @test topology_mapping isa TopologyMapping
    @test topology_mapping isa IS.SupplementalAttribute
end
