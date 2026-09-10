@testset "Technology and region getters/setters" begin
    thermal_cost = ThermalGenerationCost(
        variable_operation_cost=CostCurve(LinearCurve(0.0)),
        fixed=0.0,
        start_up=0.0,
        shut_down=0.0,
    )
    storage_cost = StorageCost(
        charge_variable_cost=CostCurve(LinearCurve(0.0)),
        discharge_variable_cost=CostCurve(LinearCurve(0.0)),
        fixed=0.0,
    )
    renewable_cost = RenewableGenerationCost(
        variable_operation_cost=CostCurve(LinearCurve(0.0)),
        curtailment_cost=CostCurve(LinearCurve(0.0)),
        fixed=0.0,
    )
    inverter_cost = CostCurve(LinearCurve(0.0))
    tech_financial_data = TechnologyFinancialData(
        capital_recovery_period=20,
        technology_base_year=2020,
        debt_fraction=0.5,
        debt_rate=0.05,
        return_on_equity=0.08,
        tax_rate=0.21,
    )

    zone_a = Zone(name="zone_a")
    zone_b = Zone(name="zone_b")
    node_a = Node(name="node_a")
    node_b = Node(name="node_b")

    req_a = CarbonTax(name="req_a", available=true)
    req_b = CarbonCaps(name="req_b", available=true)

    # Zone: name, internal, id, ext
    zone_internal = IS.InfrastructureSystemsInternal()
    zone_ext = Dict("zone" => "meta")
    PSIP.set_name!(zone_a, "zone_a_updated")
    PSIP.set_internal!(zone_a, zone_internal)
    PSIP.set_id!(zone_a, 101)
    PSIP.set_ext!(zone_a, zone_ext)
    @test PSIP.get_name(zone_a) == "zone_a_updated"
    @test PSIP.get_internal(zone_a) === zone_internal
    @test PSIP.get_id(zone_a) == 101
    @test PSIP.get_ext(zone_a) === zone_ext

    # Node: name, bus_type, internal, id, ext
    node_internal = IS.InfrastructureSystemsInternal()
    node_ext = Dict("node" => "meta")
    PSIP.set_name!(node_a, "node_a_updated")
    PSIP.set_bus_type!(node_a, ACBusTypes.REF)
    PSIP.set_internal!(node_a, node_internal)
    PSIP.set_id!(node_a, 111)
    PSIP.set_ext!(node_a, node_ext)
    @test PSIP.get_name(node_a) == "node_a_updated"
    @test PSIP.get_bus_type(node_a) == ACBusTypes.REF
    @test PSIP.get_internal(node_a) === node_internal
    @test PSIP.get_id(node_a) == 111
    @test PSIP.get_ext(node_a) === node_ext

    supply = SupplyTechnology{PSY.ThermalStandard}(
        name="supply",
        financial_data=tech_financial_data,
        power_systems_type="ThermalStandard",
        operation_costs=thermal_cost,
        available=true,
        region=[zone_a],
    )
    supply_req = Requirement[req_a, req_b]
    supply_capital = LinearCurve(22.0)
    supply_co2 = Dict(ThermalFuels.COAL => 0.9, ThermalFuels.OTHER => 0.4)
    supply_cofire_start = Dict(
        ThermalFuels.COAL => (min=0.2, max=0.6),
        ThermalFuels.OTHER => (min=0.1, max=0.5),
    )
    supply_cofire_level = Dict(
        ThermalFuels.COAL => (min=0.3, max=0.7),
        ThermalFuels.OTHER => (min=0.2, max=0.6),
    )
    supply_internal = IS.InfrastructureSystemsInternal()
    supply_ext = Dict("supply" => "meta")
    supply_regions = RegionTopology[node_a, zone_b]

    # SupplyTechnology: all fields
    PSIP.set_requirements!(supply, supply_req)
    PSIP.set_outage_factor!(supply, 0.93)
    PSIP.set_prime_mover_type!(supply, PrimeMovers.OT)
    PSIP.set_capital_costs!(supply, supply_capital, IS.NU)
    PSIP.set_lifetime!(supply, 35, IS.NU)
    PSIP.set_name!(supply, "supply_updated")
    PSIP.set_available!(supply, false)
    PSIP.set_co2!(supply, supply_co2, tonne / MMBtu)
    PSIP.set_cofire_start_limits!(supply, supply_cofire_start)
    PSIP.set_financial_data!(supply, tech_financial_data)
    PSIP.set_start_fuel_mmbtu_per_mw!(supply, 1.7, IS.NU)
    PSIP.set_operation_costs!(supply, thermal_cost, IS.NU)
    PSIP.set_fuel!(supply, ThermalFuels[ThermalFuels.COAL, ThermalFuels.OTHER])
    PSIP.set_power_systems_type!(supply, "ThermalStandardUpdated")
    PSIP.set_cofire_level_limits!(supply, supply_cofire_level)
    PSIP.set_internal!(supply, supply_internal)
    PSIP.set_id!(supply, 110)
    PSIP.set_ext!(supply, supply_ext)
    PSIP.set_region!(supply, supply_regions)
    PSIP.set_min_generation_fraction!(supply, 0.15)
    PSIP.set_time_limits!(supply, (up=4.0, down=2.0), IS.NU)
    PSIP.set_unit_size!(supply, 12.0, IS.NU)
    PSIP.set_ramp_limits!(supply, (up=0.3, down=0.25), IS.NU)
    PSIP.set_capacity_limits!(supply, (min=5.0, max=600.0), IS.NU)

    @test PSIP.get_requirements(supply) === supply_req
    @test PSIP.get_outage_factor(supply) == 0.93
    @test PSIP.get_prime_mover_type(supply) == PrimeMovers.OT
    @test PSIP.get_capital_costs(supply, IS.NU) === supply_capital
    @test PSIP.get_lifetime(supply, IS.NU) == 35
    @test PSIP.get_name(supply) == "supply_updated"
    @test PSIP.get_id(supply) == 110
    @test !PSIP.get_available(supply)
    @test PSIP.get_co2(supply, tonne / MMBtu) == supply_co2
    @test PSIP.get_cofire_start_limits(supply) === supply_cofire_start
    @test PSIP.get_financial_data(supply) === tech_financial_data
    @test PSIP.get_start_fuel_mmbtu_per_mw(supply, IS.NU) == 1.7
    @test IS.compare_values(PSIP.get_operation_costs(supply, IS.NU), thermal_cost)
    @test PSIP.get_fuel(supply) == ThermalFuels[ThermalFuels.COAL, ThermalFuels.OTHER]
    @test PSIP.get_power_systems_type(supply) == "ThermalStandardUpdated"
    @test PSIP.get_cofire_level_limits(supply) === supply_cofire_level
    @test PSIP.get_internal(supply) === supply_internal
    @test PSIP.get_ext(supply) === supply_ext
    @test PSIP.get_region(supply) === supply_regions
    @test PSIP.get_min_generation_fraction(supply) == 0.15
    @test PSIP.get_time_limits(supply, IS.NU) == (up=4.0, down=2.0)
    @test PSIP.get_unit_size(supply, IS.NU) == 12.0
    @test PSIP.get_ramp_limits(supply, IS.NU) == (up=0.3, down=0.25)
    @test PSIP.get_capacity_limits(supply, IS.NU) == (min=5.0, max=600.0)

    storage = StorageTechnology{PSY.EnergyReservoirStorage}(
        name="storage",
        storage_tech=StorageTech.LIB,
        financial_data=tech_financial_data,
        operation_costs=storage_cost,
        power_systems_type="EnergyReservoirStorage",
        available=true,
        region=[zone_a],
    )
    storage_req = Requirement[req_a]
    storage_charge_curve = LinearCurve(15.0)
    storage_discharge_curve = LinearCurve(18.0)
    storage_energy_curve = LinearCurve(11.0)
    storage_internal = IS.InfrastructureSystemsInternal()
    storage_ext = Dict("storage" => "meta")
    storage_regions = RegionTopology[zone_b]

    # StorageTechnology: all fields, including optionals
    PSIP.set_requirements!(storage, storage_req)
    PSIP.set_prime_mover_type!(storage, PrimeMovers.BT)
    PSIP.set_lifetime!(storage, 28, IS.NU)
    PSIP.set_name!(storage, "storage_updated")
    PSIP.set_available!(storage, false)
    PSIP.set_min_discharge_fraction!(storage, 0.12)
    PSIP.set_capacity_limits_charge!(storage, (min=3.0, max=400.0), IS.NU)
    PSIP.set_storage_tech!(storage, StorageTech.LIB)
    PSIP.set_duration_limits!(storage, (min=2.0, max=12.0), IS.NU)
    PSIP.set_losses!(storage, 0.02)
    PSIP.set_capital_costs_energy!(storage, storage_energy_curve, IS.NU)
    PSIP.set_financial_data!(storage, tech_financial_data)
    PSIP.set_operation_costs!(storage, storage_cost, IS.NU)
    PSIP.set_power_systems_type!(storage, "EnergyReservoirStorageUpdated")
    PSIP.set_internal!(storage, storage_internal)
    PSIP.set_id!(storage, 120)
    PSIP.set_ext!(storage, storage_ext)
    PSIP.set_region!(storage, storage_regions)
    PSIP.set_capacity_limits_energy!(storage, (min=10.0, max=1000.0), IS.NU)
    PSIP.set_unit_size_energy!(storage, 20.0, IS.NU)
    PSIP.set_unit_size_charge!(storage, 7.5, IS.NU)
    PSIP.set_efficiency!(storage, (in=0.94, out=0.91))
    PSIP.set_unit_size_discharge!(storage, 8.5, IS.NU)
    PSIP.set_capacity_limits_discharge!(storage, (min=6.0, max=500.0), IS.NU)
    PSIP.set_capital_costs_charge!(storage, storage_charge_curve, IS.NU)
    PSIP.set_capital_costs_discharge!(storage, storage_discharge_curve, IS.NU)

    @test PSIP.get_requirements(storage) === storage_req
    @test PSIP.get_prime_mover_type(storage) == PrimeMovers.BT
    @test PSIP.get_lifetime(storage, IS.NU) == 28
    @test PSIP.get_name(storage) == "storage_updated"
    @test PSIP.get_id(storage) == 120
    @test !PSIP.get_available(storage)
    @test PSIP.get_min_discharge_fraction(storage) == 0.12
    @test PSIP.get_capacity_limits_charge(storage, IS.NU) == (min=3.0, max=400.0)
    @test PSIP.get_storage_tech(storage) == StorageTech.LIB
    @test PSIP.get_duration_limits(storage, IS.NU) == (min=2.0, max=12.0)
    @test PSIP.get_losses(storage) == 0.02
    @test PSIP.get_capital_costs_energy(storage, IS.NU) === storage_energy_curve
    @test PSIP.get_financial_data(storage) === tech_financial_data
    @test IS.compare_values(PSIP.get_operation_costs(storage, IS.NU), storage_cost)
    @test PSIP.get_power_systems_type(storage) == "EnergyReservoirStorageUpdated"
    @test PSIP.get_internal(storage) === storage_internal
    @test PSIP.get_ext(storage) === storage_ext
    @test PSIP.get_region(storage) === storage_regions
    @test PSIP.get_capacity_limits_energy(storage, IS.NU) == (min=10.0, max=1000.0)
    @test PSIP.get_unit_size_energy(storage, IS.NU) == 20.0
    @test PSIP.get_unit_size_charge(storage, IS.NU) == 7.5
    @test PSIP.get_efficiency(storage) == (in=0.94, out=0.91)
    @test PSIP.get_unit_size_discharge(storage, IS.NU) == 8.5
    @test PSIP.get_capacity_limits_discharge(storage, IS.NU) == (min=6.0, max=500.0)
    @test PSIP.get_capital_costs_charge(storage, IS.NU) === storage_charge_curve
    @test PSIP.get_capital_costs_discharge(storage, IS.NU) === storage_discharge_curve

    # Also test optional fields can be set back to nothing.
    PSIP.set_capacity_limits_charge!(storage, nothing, IS.NU)
    PSIP.set_unit_size_charge!(storage, nothing, IS.NU)
    PSIP.set_capital_costs_charge!(storage, nothing, IS.NU)
    @test isnothing(PSIP.get_capacity_limits_charge(storage, IS.NU))
    @test isnothing(PSIP.get_unit_size_charge(storage, IS.NU))
    @test isnothing(PSIP.get_capital_costs_charge(storage, IS.NU))

    demand_requirement = DemandRequirement{PSY.PowerLoad}(
        name="demand_requirement",
        power_systems_type="PowerLoad",
        value_of_lost_load=1000.0,
        available=true,
        region=[zone_a],
    )
    demand_req_requirements = Requirement[req_b]
    demand_req_curve = LinearCurve(65.0)
    demand_req_internal = IS.InfrastructureSystemsInternal()
    demand_req_ext = Dict("demand_requirement" => "meta")
    demand_req_regions = RegionTopology[node_b]

    # DemandRequirement: all fields
    PSIP.set_requirements!(demand_requirement, demand_req_requirements)
    PSIP.set_name!(demand_requirement, "demand_requirement_updated")
    PSIP.set_available!(demand_requirement, false)
    PSIP.set_conformity!(demand_requirement, PSY.LoadConformity.NON_CONFORMING)
    PSIP.set_growth_rate!(demand_requirement, 0.03)
    PSIP.set_power_systems_type!(demand_requirement, "PowerLoadUpdated")
    PSIP.set_value_of_lost_load!(demand_requirement, 1200.0, IS.NU)
    PSIP.set_internal!(demand_requirement, demand_req_internal)
    PSIP.set_id!(demand_requirement, 130)
    PSIP.set_ext!(demand_requirement, demand_req_ext)
    PSIP.set_region!(demand_requirement, demand_req_regions)
    PSIP.set_unserved_demand_curve!(demand_requirement, demand_req_curve, IS.NU)
    PSIP.set_new_construction_year!(demand_requirement, 2035)
    PSIP.set_new_demand_mw!(demand_requirement, 25.0, IS.NU)

    @test PSIP.get_requirements(demand_requirement) === demand_req_requirements
    @test PSIP.get_name(demand_requirement) == "demand_requirement_updated"
    @test PSIP.get_id(demand_requirement) == 130
    @test !PSIP.get_available(demand_requirement)
    @test PSIP.get_conformity(demand_requirement) == PSY.LoadConformity.NON_CONFORMING
    @test PSIP.get_growth_rate(demand_requirement) == 0.03
    @test PSIP.get_power_systems_type(demand_requirement) == "PowerLoadUpdated"
    @test PSIP.get_value_of_lost_load(demand_requirement, IS.NU) == 1200.0
    @test PSIP.get_internal(demand_requirement) === demand_req_internal
    @test PSIP.get_ext(demand_requirement) === demand_req_ext
    @test PSIP.get_region(demand_requirement) === demand_req_regions
    @test PSIP.get_unserved_demand_curve(demand_requirement, IS.NU) === demand_req_curve
    @test PSIP.get_new_construction_year(demand_requirement) == 2035
    @test PSIP.get_new_demand_mw(demand_requirement, IS.NU) == 25.0

    demand_side = DemandSideTechnology{PSY.PowerLoad}(
        name="demand_side",
        power_systems_type="PowerLoad",
        available=true,
        region=[zone_a],
    )
    demand_side_requirements = Requirement[req_a, req_b]
    demand_side_price = LinearCurve(120.0)
    demand_side_shift_cost = LinearCurve(4.5)
    demand_side_curtailment = LinearCurve(350.0)
    demand_side_internal = IS.InfrastructureSystemsInternal()
    demand_side_ext = Dict("demand_side" => "meta")
    demand_side_regions = RegionTopology[node_a, zone_b]

    # DemandSideTechnology: all fields
    PSIP.set_requirements!(demand_side, demand_side_requirements)
    PSIP.set_price_per_unit!(demand_side, demand_side_price, IS.NU)
    PSIP.set_name!(demand_side, "demand_side_updated")
    PSIP.set_available!(demand_side, false)
    PSIP.set_shift_variable_cost!(demand_side, demand_side_shift_cost, IS.NU)
    PSIP.set_curtailment_cost!(demand_side, demand_side_curtailment, IS.NU)
    PSIP.set_technology_efficiency!(demand_side, 0.75)
    PSIP.set_max_demand_advance!(demand_side, 6.0, IS.NU)
    PSIP.set_demand_energy_efficiency!(demand_side, 0.92)
    PSIP.set_max_demand_curtailment!(demand_side, 0.2)
    PSIP.set_max_demand_delay!(demand_side, 8.0, IS.NU)
    PSIP.set_power_systems_type!(demand_side, "PowerLoadUpdated")
    PSIP.set_internal!(demand_side, demand_side_internal)
    PSIP.set_id!(demand_side, 140)
    PSIP.set_ext!(demand_side, demand_side_ext)
    PSIP.set_region!(demand_side, demand_side_regions)
    PSIP.set_min_power!(demand_side, 0.1)
    PSIP.set_peak_demand_mw!(demand_side, 50.0, IS.NU)

    @test PSIP.get_requirements(demand_side) === demand_side_requirements
    @test PSIP.get_price_per_unit(demand_side, IS.NU) === demand_side_price
    @test PSIP.get_name(demand_side) == "demand_side_updated"
    @test PSIP.get_id(demand_side) == 140
    @test !PSIP.get_available(demand_side)
    @test PSIP.get_shift_variable_cost(demand_side, IS.NU) === demand_side_shift_cost
    @test PSIP.get_curtailment_cost(demand_side, IS.NU) === demand_side_curtailment
    @test PSIP.get_technology_efficiency(demand_side) == 0.75
    @test PSIP.get_max_demand_advance(demand_side, IS.NU) == 6.0
    @test PSIP.get_demand_energy_efficiency(demand_side) == 0.92
    @test PSIP.get_max_demand_curtailment(demand_side) == 0.2
    @test PSIP.get_max_demand_delay(demand_side, IS.NU) == 8.0
    @test PSIP.get_power_systems_type(demand_side) == "PowerLoadUpdated"
    @test PSIP.get_internal(demand_side) === demand_side_internal
    @test PSIP.get_ext(demand_side) === demand_side_ext
    @test PSIP.get_region(demand_side) === demand_side_regions
    @test PSIP.get_min_power(demand_side) == 0.1
    @test PSIP.get_peak_demand_mw(demand_side, IS.NU) == 50.0

    aggregate_transport = AggregateTransportTechnology{PSY.ACBranch}(
        name="aggregate_transport",
        start_region=zone_a,
        end_region=zone_b,
        financial_data=tech_financial_data,
        power_systems_type="ACBranch",
        available=true,
    )
    aggregate_requirements = Requirement[req_a]
    aggregate_capital = LinearCurve(700.0)
    aggregate_internal = IS.InfrastructureSystemsInternal()
    aggregate_ext = Dict("aggregate_transport" => "meta")

    # AggregateTransportTechnology: all fields
    PSIP.set_requirements!(aggregate_transport, aggregate_requirements)
    PSIP.set_start_region!(aggregate_transport, zone_b)
    PSIP.set_capital_costs!(aggregate_transport, aggregate_capital, IS.NU)
    PSIP.set_name!(aggregate_transport, "aggregate_transport_updated")
    PSIP.set_end_region!(aggregate_transport, node_a)
    PSIP.set_financial_data!(aggregate_transport, tech_financial_data)
    PSIP.set_power_systems_type!(aggregate_transport, "ACBranchUpdated")
    PSIP.set_internal!(aggregate_transport, aggregate_internal)
    PSIP.set_id!(aggregate_transport, 150)
    PSIP.set_ext!(aggregate_transport, aggregate_ext)
    PSIP.set_unit_size!(aggregate_transport, 3.0, IS.NU)
    PSIP.set_available!(aggregate_transport, false)
    PSIP.set_line_loss!(aggregate_transport, 0.03)
    PSIP.set_capacity_limits!(aggregate_transport, (min=50.0, max=1500.0), IS.NU)

    @test PSIP.get_requirements(aggregate_transport) === aggregate_requirements
    @test PSIP.get_start_region(aggregate_transport) === zone_b
    @test PSIP.get_capital_costs(aggregate_transport, IS.NU) === aggregate_capital
    @test PSIP.get_name(aggregate_transport) == "aggregate_transport_updated"
    @test PSIP.get_id(aggregate_transport) == 150
    @test PSIP.get_end_region(aggregate_transport) === node_a
    @test PSIP.get_financial_data(aggregate_transport) === tech_financial_data
    @test PSIP.get_power_systems_type(aggregate_transport) == "ACBranchUpdated"
    @test PSIP.get_internal(aggregate_transport) === aggregate_internal
    @test PSIP.get_ext(aggregate_transport) === aggregate_ext
    @test PSIP.get_unit_size(aggregate_transport, IS.NU) == 3.0
    @test !PSIP.get_available(aggregate_transport)
    @test PSIP.get_line_loss(aggregate_transport) == 0.03
    @test PSIP.get_capacity_limits(aggregate_transport, IS.NU) == (min=50.0, max=1500.0)

    nodal_ac_transport = NodalACTransportTechnology{PSY.ACBranch}(
        name="nodal_ac_transport",
        start_node=node_a,
        end_node=node_b,
        financial_data=tech_financial_data,
        power_systems_type="ACBranch",
        available=true,
    )
    nodal_ac_requirements = Requirement[req_b]
    nodal_ac_capital = LinearCurve(900.0)
    nodal_ac_internal = IS.InfrastructureSystemsInternal()
    nodal_ac_ext = Dict("nodal_ac_transport" => "meta")

    # NodalACTransportTechnology: all fields
    PSIP.set_requirements!(nodal_ac_transport, nodal_ac_requirements)
    PSIP.set_capital_costs!(nodal_ac_transport, nodal_ac_capital, IS.NU)
    PSIP.set_name!(nodal_ac_transport, "nodal_ac_transport_updated")
    PSIP.set_end_node!(nodal_ac_transport, node_a)
    PSIP.set_financial_data!(nodal_ac_transport, tech_financial_data)
    PSIP.set_start_node!(nodal_ac_transport, node_b)
    PSIP.set_power_systems_type!(nodal_ac_transport, "ACBranchUpdated")
    PSIP.set_internal!(nodal_ac_transport, nodal_ac_internal)
    PSIP.set_id!(nodal_ac_transport, 160)
    PSIP.set_ext!(nodal_ac_transport, nodal_ac_ext)
    PSIP.set_available!(nodal_ac_transport, false)
    PSIP.set_reactance!(nodal_ac_transport, 2.5, IS.NU)
    PSIP.set_resistance!(nodal_ac_transport, 1.4, IS.NU)
    PSIP.set_voltage!(nodal_ac_transport, 345.0, IS.NU)
    PSIP.set_unit_size!(nodal_ac_transport, 4.0, IS.NU)
    PSIP.set_capacity_limits!(nodal_ac_transport, (min=10.0, max=800.0), IS.NU)

    @test PSIP.get_requirements(nodal_ac_transport) === nodal_ac_requirements
    @test PSIP.get_capital_costs(nodal_ac_transport, IS.NU) === nodal_ac_capital
    @test PSIP.get_name(nodal_ac_transport) == "nodal_ac_transport_updated"
    @test PSIP.get_end_node(nodal_ac_transport) === node_a
    @test PSIP.get_id(nodal_ac_transport) == 160
    @test PSIP.get_financial_data(nodal_ac_transport) === tech_financial_data
    @test PSIP.get_start_node(nodal_ac_transport) === node_b
    @test PSIP.get_power_systems_type(nodal_ac_transport) == "ACBranchUpdated"
    @test PSIP.get_internal(nodal_ac_transport) === nodal_ac_internal
    @test PSIP.get_ext(nodal_ac_transport) === nodal_ac_ext
    @test !PSIP.get_available(nodal_ac_transport)
    @test PSIP.get_reactance(nodal_ac_transport, IS.NU) == 2.5
    @test PSIP.get_resistance(nodal_ac_transport, IS.NU) == 1.4
    @test PSIP.get_voltage(nodal_ac_transport, IS.NU) == 345.0
    @test PSIP.get_unit_size(nodal_ac_transport, IS.NU) == 4.0
    @test PSIP.get_capacity_limits(nodal_ac_transport, IS.NU) == (min=10.0, max=800.0)

    nodal_hvdc_transport = NodalHVDCTransportTechnology{PSY.ACBranch}(
        name="nodal_hvdc_transport",
        start_node=node_a,
        end_node=node_b,
        financial_data=tech_financial_data,
        power_systems_type="ACBranch",
        available=true,
    )
    nodal_hvdc_requirements = Requirement[req_a, req_b]
    nodal_hvdc_capital = LinearCurve(1200.0)
    nodal_hvdc_internal = IS.InfrastructureSystemsInternal()
    nodal_hvdc_ext = Dict("nodal_hvdc_transport" => "meta")
    nodal_hvdc_line_loss = LinearCurve(0.06)

    # NodalHVDCTransportTechnology: all fields
    PSIP.set_requirements!(nodal_hvdc_transport, nodal_hvdc_requirements)
    PSIP.set_capital_costs!(nodal_hvdc_transport, nodal_hvdc_capital, IS.NU)
    PSIP.set_name!(nodal_hvdc_transport, "nodal_hvdc_transport_updated")
    PSIP.set_end_node!(nodal_hvdc_transport, zone_b)
    PSIP.set_financial_data!(nodal_hvdc_transport, tech_financial_data)
    PSIP.set_start_node!(nodal_hvdc_transport, node_b)
    PSIP.set_power_systems_type!(nodal_hvdc_transport, "HVDCUpdated")
    PSIP.set_internal!(nodal_hvdc_transport, nodal_hvdc_internal)
    PSIP.set_id!(nodal_hvdc_transport, 170)
    PSIP.set_ext!(nodal_hvdc_transport, nodal_hvdc_ext)
    PSIP.set_available!(nodal_hvdc_transport, false)
    PSIP.set_unit_size!(nodal_hvdc_transport, 5.0, IS.NU)
    PSIP.set_line_loss!(nodal_hvdc_transport, nodal_hvdc_line_loss)
    PSIP.set_capacity_limits!(nodal_hvdc_transport, (min=30.0, max=1800.0), IS.NU)

    @test PSIP.get_requirements(nodal_hvdc_transport) === nodal_hvdc_requirements
    @test PSIP.get_capital_costs(nodal_hvdc_transport, IS.NU) === nodal_hvdc_capital
    @test PSIP.get_name(nodal_hvdc_transport) == "nodal_hvdc_transport_updated"
    @test PSIP.get_end_node(nodal_hvdc_transport) === zone_b
    @test PSIP.get_id(nodal_hvdc_transport) == 170
    @test PSIP.get_financial_data(nodal_hvdc_transport) === tech_financial_data
    @test PSIP.get_start_node(nodal_hvdc_transport) === node_b
    @test PSIP.get_power_systems_type(nodal_hvdc_transport) == "HVDCUpdated"
    @test PSIP.get_internal(nodal_hvdc_transport) === nodal_hvdc_internal
    @test PSIP.get_ext(nodal_hvdc_transport) === nodal_hvdc_ext
    @test !PSIP.get_available(nodal_hvdc_transport)
    @test PSIP.get_unit_size(nodal_hvdc_transport, IS.NU) == 5.0
    @test PSIP.get_line_loss(nodal_hvdc_transport) === nodal_hvdc_line_loss
    @test PSIP.get_capacity_limits(nodal_hvdc_transport, IS.NU) == (min=30.0, max=1800.0)

    colocated_supply_storage = ColocatedSupplyStorageTechnology{PSY.RenewableDispatch}(
        name="colocated_supply_storage",
        financial_data=tech_financial_data,
        power_systems_type="RenewableDispatch",
        operation_costs_power=storage_cost,
        operation_costs_energy=storage_cost,
        operation_costs_inverter=inverter_cost,
        operation_costs_solar=renewable_cost,
        operation_costs_wind=renewable_cost,
        inverter_efficiency=0.96,
        inverter_supply_ratio=1.0,
        capital_costs_inverter=LinearCurve(0.0),
        available=true,
        region=[zone_a],
    )
    colocated_power_cost = StorageCost(
        charge_variable_cost=CostCurve(LinearCurve(1.0)),
        discharge_variable_cost=CostCurve(LinearCurve(2.0)),
        fixed=3.0,
    )
    colocated_energy_cost = StorageCost(
        charge_variable_cost=CostCurve(LinearCurve(1.5)),
        discharge_variable_cost=CostCurve(LinearCurve(2.5)),
        fixed=3.5,
    )
    colocated_inverter_cost = CostCurve(LinearCurve(0.8))
    colocated_solar_cost = RenewableGenerationCost(
        variable_operation_cost=CostCurve(LinearCurve(4.0)),
        curtailment_cost=CostCurve(LinearCurve(0.1)),
        fixed=1.0,
    )
    colocated_wind_cost = RenewableGenerationCost(
        variable_operation_cost=CostCurve(LinearCurve(3.0)),
        curtailment_cost=CostCurve(LinearCurve(0.2)),
        fixed=1.2,
    )
    colocated_capital_power = LinearCurve(200.0)
    colocated_capital_energy = LinearCurve(90.0)
    colocated_capital_wind = LinearCurve(150.0)
    colocated_capital_solar = LinearCurve(130.0)
    colocated_capital_inverter = LinearCurve(70.0)
    colocated_internal = IS.InfrastructureSystemsInternal()
    colocated_ext = Dict("colocated" => "meta")
    colocated_regions = RegionTopology[node_a]

    # ColocatedSupplyStorageTechnology: all fields
    PSIP.set_operation_costs_power!(colocated_supply_storage, colocated_power_cost, IS.NU)
    PSIP.set_lifetime_storage!(colocated_supply_storage, 26, IS.NU)
    PSIP.set_operation_costs_solar!(colocated_supply_storage, colocated_solar_cost, IS.NU)
    PSIP.set_capacity_limits_wind!(colocated_supply_storage, (min=10.0, max=900.0), IS.NU)
    PSIP.set_name!(colocated_supply_storage, "colocated_supply_storage_updated")
    PSIP.set_capital_costs_power!(colocated_supply_storage, colocated_capital_power, IS.NU)
    PSIP.set_capacity_power_limits!(colocated_supply_storage, (min=5.0, max=600.0), IS.NU)
    PSIP.set_lifetime_wind!(colocated_supply_storage, 30, IS.NU)
    PSIP.set_capacity_energy_limits!(
        colocated_supply_storage,
        (min=20.0, max=1200.0),
        IS.NU,
    )
    PSIP.set_duration_limits!(colocated_supply_storage, (min=2.0, max=10.0), IS.NU)
    PSIP.set_min_inverter_capacity!(colocated_supply_storage, 15.0, IS.NU)
    PSIP.set_operation_costs_energy!(colocated_supply_storage, colocated_energy_cost, IS.NU)
    PSIP.set_capital_costs_energy!(
        colocated_supply_storage,
        colocated_capital_energy,
        IS.NU,
    )
    PSIP.set_operation_costs_inverter!(
        colocated_supply_storage,
        colocated_inverter_cost,
        IS.NU,
    )
    PSIP.set_financial_data!(colocated_supply_storage, tech_financial_data)
    PSIP.set_available!(colocated_supply_storage, false)
    PSIP.set_inverter_efficiency!(colocated_supply_storage, 0.97)
    PSIP.set_power_systems_type!(colocated_supply_storage, "RenewableDispatchUpdated")
    PSIP.set_capacity_limits_solar!(colocated_supply_storage, (min=12.0, max=950.0), IS.NU)
    PSIP.set_internal!(colocated_supply_storage, colocated_internal)
    PSIP.set_id!(colocated_supply_storage, 180)
    PSIP.set_operation_costs_wind!(colocated_supply_storage, colocated_wind_cost, IS.NU)
    PSIP.set_efficiency_storage!(colocated_supply_storage, (in=0.95, out=0.9))
    PSIP.set_ext!(colocated_supply_storage, colocated_ext)
    PSIP.set_region!(colocated_supply_storage, colocated_regions)
    PSIP.set_losses_storage!(colocated_supply_storage, 0.015)
    PSIP.set_inverter_supply_ratio!(colocated_supply_storage, 1.1)
    PSIP.set_capital_costs_wind!(colocated_supply_storage, colocated_capital_wind, IS.NU)
    PSIP.set_lifetime_solar!(colocated_supply_storage, 29, IS.NU)
    PSIP.set_capital_costs_inverter!(
        colocated_supply_storage,
        colocated_capital_inverter,
        IS.NU,
    )
    PSIP.set_max_inverter_capacity!(colocated_supply_storage, 450.0, IS.NU)
    PSIP.set_capital_costs_solar!(colocated_supply_storage, colocated_capital_solar, IS.NU)

    @test IS.compare_values(
        PSIP.get_operation_costs_power(colocated_supply_storage, IS.NU),
        colocated_power_cost,
    )
    @test PSIP.get_lifetime_storage(colocated_supply_storage, IS.NU) == 26
    @test IS.compare_values(
        PSIP.get_operation_costs_solar(colocated_supply_storage, IS.NU),
        colocated_solar_cost,
    )
    @test PSIP.get_capacity_limits_wind(colocated_supply_storage, IS.NU) ==
          (min=10.0, max=900.0)
    @test PSIP.get_name(colocated_supply_storage) == "colocated_supply_storage_updated"
    @test PSIP.get_capital_costs_power(colocated_supply_storage, IS.NU) ===
          colocated_capital_power
    @test PSIP.get_capacity_power_limits(colocated_supply_storage, IS.NU) ==
          (min=5.0, max=600.0)
    @test PSIP.get_lifetime_wind(colocated_supply_storage, IS.NU) == 30
    @test PSIP.get_capacity_energy_limits(colocated_supply_storage, IS.NU) ==
          (min=20.0, max=1200.0)
    @test PSIP.get_duration_limits(colocated_supply_storage, IS.NU) == (min=2.0, max=10.0)
    @test PSIP.get_min_inverter_capacity(colocated_supply_storage, IS.NU) == 15.0
    @test PSIP.get_id(colocated_supply_storage) == 180
    @test IS.compare_values(
        PSIP.get_operation_costs_energy(colocated_supply_storage, IS.NU),
        colocated_energy_cost,
    )
    @test PSIP.get_capital_costs_energy(colocated_supply_storage, IS.NU) ===
          colocated_capital_energy
    @test IS.compare_values(
        PSIP.get_operation_costs_inverter(colocated_supply_storage, IS.NU),
        colocated_inverter_cost,
    )
    @test PSIP.get_financial_data(colocated_supply_storage) === tech_financial_data
    @test !PSIP.get_available(colocated_supply_storage)
    @test PSIP.get_inverter_efficiency(colocated_supply_storage) == 0.97
    @test PSIP.get_power_systems_type(colocated_supply_storage) ==
          "RenewableDispatchUpdated"
    @test PSIP.get_capacity_limits_solar(colocated_supply_storage, IS.NU) ==
          (min=12.0, max=950.0)
    @test PSIP.get_internal(colocated_supply_storage) === colocated_internal
    @test IS.compare_values(
        PSIP.get_operation_costs_wind(colocated_supply_storage, IS.NU),
        colocated_wind_cost,
    )
    @test PSIP.get_efficiency_storage(colocated_supply_storage) == (in=0.95, out=0.9)
    @test PSIP.get_ext(colocated_supply_storage) === colocated_ext
    @test PSIP.get_region(colocated_supply_storage) === colocated_regions
    @test PSIP.get_losses_storage(colocated_supply_storage) == 0.015
    @test PSIP.get_inverter_supply_ratio(colocated_supply_storage) == 1.1
    @test PSIP.get_capital_costs_wind(colocated_supply_storage, IS.NU) ===
          colocated_capital_wind
    @test PSIP.get_lifetime_solar(colocated_supply_storage, IS.NU) == 29
    @test PSIP.get_capital_costs_inverter(colocated_supply_storage, IS.NU) ===
          colocated_capital_inverter
    @test PSIP.get_max_inverter_capacity(colocated_supply_storage, IS.NU) == 450.0
    @test PSIP.get_capital_costs_solar(colocated_supply_storage, IS.NU) ===
          colocated_capital_solar
end
