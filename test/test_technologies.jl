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

    area_a = PSY.Area(; input_basis=u"CU", name="area_a", base_power=100.0)
    area_b = PSY.Area(; input_basis=u"CU", name="area_b", base_power=100.0)
    lz_a = PSY.LoadZone(;
        input_basis=u"CU",
        name="lz_a",
        peak_active_power=0.0,
        peak_reactive_power=0.0,
        base_power=100.0,
    )
    lz_b = PSY.LoadZone(;
        input_basis=u"CU",
        name="lz_b",
        peak_active_power=0.0,
        peak_reactive_power=0.0,
        base_power=100.0,
    )
    bus_a = PSY.ACBus(;
        input_basis=u"CU",
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
        input_basis=u"CU",
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
        financial_data=tech_financial_data,
        power_systems_type="ThermalStandard",
        operation_costs=ThermalGenerationCost(nothing),
        available=true,
        region=[area_a],
    )
    supply_req = Requirement[req_a, req_b]
    supply_capital = PSIP.CapitalCost(LinearCurve(22.0), 0.0)
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
    supply_regions = PSY.Topology[bus_a, area_b]

    # SupplyTechnology: all fields
    PSIP.set_requirements!(supply, supply_req)
    PSIP.set_outage_factor!(supply, (planned=0.93, forced=0.0))
    PSIP.set_prime_mover_type!(supply, PrimeMovers.OT)
    PSIP.set_capital_costs!(supply, supply_capital)
    PSIP.set_lifetime!(supply, 35u"yr")
    PSIP.set_name!(supply, "supply_updated")
    PSIP.set_available!(supply, false)
    PSIP.set_cofire_start_limits!(supply, supply_cofire_start)
    PSIP.set_financial_data!(supply, tech_financial_data)
    PSIP.set_start_fuel_mmbtu_per_mw!(supply, 1.7 * PSIP.MMBtu / u"MW")
    PSIP.set_operation_costs!(supply, thermal_cost)
    PSIP.set_fuel!(supply, [ThermalFuels.COAL, ThermalFuels.OTHER])
    PSIP.set_power_systems_type!(supply, "ThermalStandardUpdated")
    PSIP.set_cofire_level_limits!(supply, supply_cofire_level)
    PSIP.set_internal!(supply, supply_internal)
    PSIP.set_id!(supply, 110)
    PSIP.set_ext!(supply, supply_ext)
    PSIP.set_region!(supply, supply_regions)
    PSIP.set_min_generation_fraction!(supply, 0.15)
    PSIP.set_time_limits!(supply, (up=4.0u"minute", down=2.0u"minute"))
    PSIP.set_unit_size!(supply, 12.0u"MW")
    PSIP.set_ramp_limits!(supply, (up=0.3u"MW/minute", down=0.25u"MW/minute"))
    PSIP.set_capacity_limits!(supply, (min=5.0u"MW", max=600.0u"MW"))

    @test PSIP.get_requirements(supply) === supply_req
    @test PSIP.get_outage_factor(supply) == (planned=0.93, forced=0.0)
    @test PSIP.get_prime_mover_type(supply) == PrimeMovers.OT
    @test PSIP.get_capital_costs(supply) === supply_capital
    @test PSIP.get_lifetime(supply, u"NU") == 35
    @test PSIP.get_name(supply) == "supply_updated"
    @test PSIP.get_id(supply) == 110
    @test !PSIP.get_available(supply)
    @test PSIP.get_cofire_start_limits(supply) === supply_cofire_start
    @test PSIP.get_financial_data(supply) === tech_financial_data
    @test PSIP.get_start_fuel_mmbtu_per_mw(supply, u"NU") == 1.7
    @test IS.compare_values(PSIP.get_operation_costs(supply, u"NU"), thermal_cost)
    @test PSIP.get_fuel(supply) == [ThermalFuels.COAL, ThermalFuels.OTHER]
    @test PSIP.get_power_systems_type(supply) == "ThermalStandardUpdated"
    @test PSIP.get_cofire_level_limits(supply) === supply_cofire_level
    @test PSIP.get_internal(supply) === supply_internal
    @test PSIP.get_ext(supply) === supply_ext
    @test PSIP.get_region(supply) === supply_regions
    @test PSIP.get_min_generation_fraction(supply) == 0.15
    @test PSIP.get_time_limits(supply, u"NU") == (up=4.0, down=2.0)
    @test PSIP.get_unit_size(supply, u"NU") == 12.0
    @test PSIP.get_ramp_limits(supply, u"NU") == (up=0.3, down=0.25)
    @test PSIP.get_capacity_limits(supply, u"NU") == (min=5.0, max=600.0)

    storage = StorageTechnology{PSY.EnergyReservoirStorage}(
        name="storage",
        storage_tech=StorageTech.LIB,
        financial_data=tech_financial_data,
        operation_costs=StorageCost(nothing),
        power_systems_type="EnergyReservoirStorage",
        available=true,
        region=[area_a],
    )
    PSIP.set_capacity_limits_energy!(storage, (min=10.0u"MWh", max=1000.0u"MWh"))
    PSIP.set_capital_costs!(
        storage,
        PSIP.StorageCapitalCost(LinearCurve(1.0), LinearCurve(2.0), LinearCurve(3.0), 4.0),
    )
    @test PSIP.get_capacity_limits_energy(storage, u"NU") == (min=10.0, max=1000.0)
    @test PSIP.get_charge_capital_cost(PSIP.get_capital_costs(storage), u"NU") ==
          LinearCurve(1.0)

    demand_req = ProjectedDemand{PSY.PowerLoad}(
        name="demand_req",
        power_systems_type="PowerLoad",
        available=true,
        region=[area_a],
    )
    PSIP.set_peak_demand_mw!(demand_req, 25.0u"MW")
    PSIP.set_max_demand_delay!(demand_req, 120.0u"minute")
    PSIP.set_flexible_fraction!(demand_req, 0.3)
    PSIP.set_shift_efficiency!(demand_req, 0.92)
    PSIP.set_construction_year!(demand_req, 2035)
    @test PSIP.get_peak_demand_mw(demand_req, u"NU") == 25.0
    @test PSIP.get_max_demand_delay(demand_req, u"NU") == 120.0
    @test PSIP.get_flexible_fraction(demand_req) == 0.3
    @test PSIP.get_shift_efficiency(demand_req) == 0.92
    @test PSIP.get_construction_year(demand_req) == 2035

    demand_side = DemandSideTechnology{PSY.PowerLoad}(
        name="demand_side",
        power_systems_type="PowerLoad",
        available=true,
        region=[area_a],
        financial_data=tech_financial_data,
    )
    demand_side_operation = PSY.LoadCost(CostCurve(LinearCurve(2.0)), 15.0)
    PSIP.set_capacity_limits!(demand_side, (min=0.0u"MW", max=200.0u"MW"))
    PSIP.set_operation_costs!(demand_side, demand_side_operation)
    PSIP.set_capital_costs!(demand_side, PSIP.CapitalCost(LinearCurve(900.0), 0.0))
    PSIP.set_technology_efficiency!(demand_side, 50.0)
    @test PSIP.get_capacity_limits(demand_side, u"NU") == (min=0.0, max=200.0)
    @test PSIP.get_fixed(PSIP.get_operation_costs(demand_side, u"NU")) == 15.0
    @test PSIP.get_capital_cost(PSIP.get_capital_costs(demand_side), u"NU") ==
          LinearCurve(900.0)
    @test PSIP.get_technology_efficiency(demand_side) == 50.0

    agg = AggregateTransportTechnology{PSY.ACBranch}(
        name="agg",
        start_region=area_a,
        end_region=area_b,
        financial_data=tech_financial_data,
        power_systems_type="ACBranch",
        available=true,
    )
    PSIP.set_end_region!(agg, area_a)
    PSIP.set_capital_costs!(agg, PSIP.CapitalCost(LinearCurve(700.0), 0.0))
    @test PSIP.get_end_region(agg) === area_a
    @test PSIP.get_capital_cost(PSIP.get_capital_costs(agg), u"NU") == LinearCurve(700.0)

    ac = NodalACTransportTechnology{PSY.ACBranch}(
        name="ac",
        start_node=bus_a,
        end_node=bus_b,
        financial_data=tech_financial_data,
        power_systems_type="ACBranch",
        available=true,
    )
    PSIP.set_end_node!(ac, bus_a)
    @test PSIP.get_end_node(ac) === bus_a

    hvdc = NodalHVDCTransportTechnology{PSY.ACBranch}(
        name="hvdc",
        start_node=bus_a,
        end_node=bus_b,
        financial_data=tech_financial_data,
        power_systems_type="ACBranch",
        available=true,
    )
    PSIP.set_line_loss!(hvdc, LinearCurve(0.06))
    @test PSIP.get_line_loss(hvdc) == LinearCurve(0.06)

    colocated = ColocatedSupplyStorageTechnology{PSY.RenewableDispatch}(
        name="colocated",
        financial_data=tech_financial_data,
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
    PSIP.set_inverter_capacity_limits!(colocated, (min=10.0u"MW", max=900.0u"MW"))
    @test PSIP.get_inverter_capacity_limits(colocated, u"NU") == (min=10.0, max=900.0)
    @test PSIP.get_capital_cost(PSIP.get_capital_costs_inverter(colocated), u"NU") ==
          LinearCurve(70.0)
end
