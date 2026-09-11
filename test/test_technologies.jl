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

    area_a = PSY.Area(; name="area_a", base_power=100.0)
    area_b = PSY.Area(; name="area_b", base_power=100.0)
    lz_a = PSY.LoadZone(;
        name="lz_a",
        peak_active_power=0.0,
        peak_reactive_power=0.0,
        base_power=100.0,
    )
    lz_b = PSY.LoadZone(;
        name="lz_b",
        peak_active_power=0.0,
        peak_reactive_power=0.0,
        base_power=100.0,
    )
    bus_a = PSY.ACBus(;
        number=915,
        name="bus_a",
        available=true,
        bustype=PSY.ACBusTypes.PQ,
        angle=0.0,
        magnitude=1.0,
        voltage_limits=(min=0.9, max=1.1),
        base_voltage=138.0,
        area=area_a,
        load_zone=lz_a,
    )
    bus_b = PSY.ACBus(;
        number=916,
        name="bus_b",
        available=true,
        bustype=PSY.ACBusTypes.PQ,
        angle=0.0,
        magnitude=1.0,
        voltage_limits=(min=0.9, max=1.1),
        base_voltage=138.0,
        area=area_b,
        load_zone=lz_b,
    )

    req_a = CarbonTax(name="req_a", available=true)
    req_b = CarbonCaps(name="req_b", available=true)

    supply = SupplyTechnology{PSY.ThermalStandard}(
        name="supply",
        financial_data=fd,
        power_systems_type="ThermalStandard",
        operation_costs=ThermalGenerationCost(nothing),
        available=true,
        region=[area_a],
    )
    PSIP.set_requirements!(supply, Requirement[req_a, req_b])
    PSIP.set_outage_factor!(supply, (planned=0.1, forced=0.02))
    PSIP.set_capital_costs!(supply, PSIP.CapitalCost(LinearCurve(22.0), 3.0))
    PSIP.set_region!(supply, PSY.Topology[bus_a, area_b])
    @test PSIP.get_outage_factor(supply) == (planned=0.1, forced=0.02)
    @test PSIP.get_capital_cost(PSIP.get_capital_costs(supply)) == LinearCurve(22.0)
    @test PSIP.get_interconnection_cost(PSIP.get_capital_costs(supply)) == 3.0
    @test PSIP.get_region(supply) == PSY.Topology[bus_a, area_b]

    storage = StorageTechnology{PSY.EnergyReservoirStorage}(
        name="storage",
        storage_tech=StorageTech.LIB,
        financial_data=fd,
        operation_costs=StorageCost(nothing),
        power_systems_type="EnergyReservoirStorage",
        available=true,
        region=[area_a],
    )
    PSIP.set_capacity_limits_energy!(storage, (min=10.0, max=1000.0), IS.NU)
    PSIP.set_capital_costs!(
        storage,
        PSIP.StorageCapitalCost(LinearCurve(1.0), LinearCurve(2.0), LinearCurve(3.0), 4.0),
    )
    @test PSIP.get_capacity_limits_energy(storage, IS.NU) == (min=10.0, max=1000.0)
    @test PSIP.get_charge_capital_cost(PSIP.get_capital_costs(storage)) == LinearCurve(1.0)

    demand_req = DemandRequirement{PSY.PowerLoad}(
        name="demand_req",
        power_systems_type="PowerLoad",
        value_of_lost_load=1000.0,
        available=true,
        region=[area_a],
    )
    PSIP.set_new_demand_mw!(demand_req, 25.0, IS.NU)
    @test PSIP.get_new_demand_mw(demand_req, IS.NU) == 25.0

    demand_side = DemandSideTechnology{PSY.PowerLoad}(
        name="demand_side",
        power_systems_type="PowerLoad",
        available=true,
        region=[area_a],
    )
    PSIP.set_peak_demand_mw!(demand_side, 50.0, IS.NU)
    @test PSIP.get_peak_demand_mw(demand_side, IS.NU) == 50.0

    agg = AggregateTransportTechnology{PSY.ACBranch}(
        name="agg",
        start_region=area_a,
        end_region=area_b,
        financial_data=fd,
        power_systems_type="ACBranch",
        available=true,
    )
    PSIP.set_end_region!(agg, area_a)
    PSIP.set_capital_costs!(agg, PSIP.CapitalCost(LinearCurve(700.0), 0.0))
    @test PSIP.get_end_region(agg) === area_a
    @test PSIP.get_capital_cost(PSIP.get_capital_costs(agg)) == LinearCurve(700.0)

    ac = NodalACTransportTechnology{PSY.ACBranch}(
        name="ac",
        start_node=bus_a,
        end_node=bus_b,
        financial_data=fd,
        power_systems_type="ACBranch",
        available=true,
    )
    PSIP.set_end_node!(ac, bus_a)
    @test PSIP.get_end_node(ac) === bus_a

    hvdc = NodalHVDCTransportTechnology{PSY.ACBranch}(
        name="hvdc",
        start_node=bus_a,
        end_node=bus_b,
        financial_data=fd,
        power_systems_type="ACBranch",
        available=true,
    )
    PSIP.set_line_loss!(hvdc, LinearCurve(0.06))
    @test PSIP.get_line_loss(hvdc) == LinearCurve(0.06)

    colocated = ColocatedSupplyStorageTechnology{PSY.RenewableDispatch}(
        name="colocated",
        financial_data=fd,
        power_systems_type="RenewableDispatch",
        operation_costs_inverter=CostCurve(LinearCurve(0.8)),
        inverter_efficiency=0.96,
        inverter_supply_ratio=1.0,
        capital_costs_inverter=PSIP.CapitalCost(LinearCurve(70.0), 0.0),
        available=true,
        region=[area_a],
        supply_technology=supply,
        storage_technology=storage,
    )
    PSIP.set_inverter_capacity_limits!(colocated, (min=10.0, max=900.0), IS.NU)
    @test PSIP.get_inverter_capacity_limits(colocated, IS.NU) == (min=10.0, max=900.0)
    @test PSIP.get_capital_cost(PSIP.get_capital_costs_inverter(colocated)) ==
          LinearCurve(70.0)
end
