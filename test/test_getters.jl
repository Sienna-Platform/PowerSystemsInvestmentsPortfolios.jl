@testset "get_max / get_min on MinMax" begin
    x = (min=3.0, max=7.5)
    @test PSIP.get_max(x) == 7.5
    @test PSIP.get_min(x) == 3.0
end

@testset "get_in / get_out on InOut" begin
    x = (in=0.9, out=0.85)
    @test PSIP.get_in(x) == 0.9
    @test PSIP.get_out(x) == 0.85
end

@testset "get_parameter_type" begin
    p_5bus = build_portfolio()
    thermal = get_technology(SupplyTechnology{ThermalStandard}, p_5bus, "cheap_thermal")
    storage = get_technology(StorageTechnology, p_5bus, "test_storage")
    agg_line = get_technology(AggregateTransportTechnology{ACBranch}, p_5bus, "test_branch")
    ac_line = get_technology(NodalACTransportTechnology{ACBranch}, p_5bus, "test")
    demand_r = get_technology(DemandRequirement{PowerLoad}, p_5bus, "demand_b")
    demand_s = get_technology(DemandSideTechnology{PowerLoad}, p_5bus, "test_demand")

    @test PSIP.get_parameter_type(thermal) == PSY.ThermalStandard
    @test PSIP.get_parameter_type(typeof(thermal)) == PSY.ThermalStandard
    @test PSIP.get_parameter_type(storage) == PSY.EnergyReservoirStorage
    @test PSIP.get_parameter_type(typeof(storage)) == PSY.EnergyReservoirStorage
    @test PSIP.get_parameter_type(agg_line) == PSY.ACBranch
    @test PSIP.get_parameter_type(typeof(agg_line)) == PSY.ACBranch
    @test PSIP.get_parameter_type(ac_line) == PSY.ACBranch
    @test PSIP.get_parameter_type(typeof(ac_line)) == PSY.ACBranch
    @test PSIP.get_parameter_type(demand_r) == PSY.PowerLoad
    @test PSIP.get_parameter_type(typeof(demand_r)) == PSY.PowerLoad
    @test PSIP.get_parameter_type(demand_s) == PSY.PowerLoad
    @test PSIP.get_parameter_type(typeof(demand_s)) == PSY.PowerLoad
end

@testset "is_new" begin
    p_5bus = build_portfolio()
    thermal = get_technology(SupplyTechnology{ThermalStandard}, p_5bus, "cheap_thermal")
    expensive =
        get_technology(SupplyTechnology{ThermalStandard}, p_5bus, "expensive_thermal")
    renewable = get_technology(SupplyTechnology{RenewableDispatch}, p_5bus, "wind")
    storage = get_technology(StorageTechnology, p_5bus, "test_storage")
    demand = get_technology(DemandRequirement{PowerLoad}, p_5bus, "demand_b")

    # existing devices are attached to thermal and expensive_thermal
    @test !is_new(thermal)
    @test !is_new(expensive)
    # no ExistingDevices attached to these
    @test is_new(renewable)
    @test is_new(storage)
    @test is_new(demand)
end

@testset "get_existing_capacity_mw" begin
    p_5bus = build_portfolio()
    thermal = get_technology(SupplyTechnology{ThermalStandard}, p_5bus, "cheap_thermal")
    renewable = get_technology(SupplyTechnology{RenewableDispatch}, p_5bus, "wind")
    storage = get_technology(StorageTechnology, p_5bus, "test_storage")

    @test get_existing_capacity_mw(p_5bus, thermal) == 791.25
    # new technology → 0
    @test get_existing_capacity_mw(p_5bus, renewable) == 0.0
    @test get_existing_capacity_mw(p_5bus, storage) == 0.0
end

@testset "get_existing_capacity_mwh" begin
    p_5bus = build_portfolio()
    storage = get_technology(StorageTechnology, p_5bus, "test_storage")
    # new storage → 0
    @test get_existing_capacity_mwh(p_5bus, storage) == 0.0
end

@testset "get_peak_demand_mw" begin
    p_5bus = build_portfolio()
    demand_b = get_technology(DemandRequirement{PowerLoad}, p_5bus, "demand_b")
    demand_s = get_technology(DemandSideTechnology{PowerLoad}, p_5bus, "test_demand")

    # demand_b has no ExistingDevices → warns and returns 0.0
    @test get_peak_demand_mw(p_5bus, demand_b) == 0.0
    @test get_peak_demand_mw(p_5bus, demand_s) == 0.0
end

@testset "get_heat_rate / get_fuel_cost / get_variable_cost" begin
    p_5bus = build_portfolio()
    # cheap_thermal uses a FuelCurve — heat_rate and fuel_cost are defined
    fc_units = (energy_unit=u"MW" * u"hr", fuel_unit=MMBtu, currency_unit=USD)
    cost_units = (x_unit=u"MW" * u"hr", y_unit=USD)
    thermal = get_technology(SupplyTechnology{ThermalStandard}, p_5bus, "cheap_thermal")
    @test PSIP.get_heat_rate(thermal, fc_units) isa Float64
    @test PSIP.get_heat_rate(thermal, fc_units) > 0
    @test PSIP.get_fuel_cost(thermal, fc_units) isa Float64
    @test PSIP.get_fuel_cost(thermal, fc_units) == 1.12

    # both FuelCurve and CostCurve technologies expose get_variable_cost
    expensive =
        get_technology(SupplyTechnology{ThermalStandard}, p_5bus, "expensive_thermal")
    @test PSIP.get_variable_cost(expensive, cost_units) isa Float64
    @test PSIP.get_variable_cost(thermal, fc_units) isa Float64
end

@testset "get_variable_cost_charge / get_variable_cost_discharge" begin
    p_5bus = build_portfolio()

    cost_units = (x_unit=u"MW" * u"hr", y_unit=USD)
    storage = get_technology(StorageTechnology, p_5bus, "test_storage")
    @test get_variable_cost_charge(storage, cost_units) isa Float64
    @test get_variable_cost_discharge(storage, cost_units) isa Float64
    # storage in 5bus fixture has zero variable costs
    @test get_variable_cost_charge(storage, cost_units) == 0.0
    @test get_variable_cost_discharge(storage, cost_units) == 0.0
end

@testset "get_fixed_cost / get_fixed_cost_charge / get_fixed_cost_discharge" begin
    p_5bus = build_portfolio()

    fc_units = (energy_unit=u"MW" * u"hr", fuel_unit=MMBtu, currency_unit=USD)
    cost_units = (x_unit=u"MW" * u"hr", y_unit=USD)
    thermal = get_technology(SupplyTechnology{ThermalStandard}, p_5bus, "cheap_thermal")
    wind = get_technology(SupplyTechnology{RenewableDispatch}, p_5bus, "wind")
    storage = get_technology(StorageTechnology, p_5bus, "test_storage")

    @test get_fixed_cost(thermal, fc_units) isa Float64
    @test get_fixed_cost(wind, cost_units) isa Float64
    @test get_fixed_cost(storage, cost_units) isa Float64

    @test get_fixed_cost_charge(storage, cost_units) isa Float64
    @test get_fixed_cost_discharge(storage, cost_units) isa Float64
end

@testset "get_wacc" begin
    # Standard case: WACC = D*Rd*(1-Tc) + E*Re
    fd = TechnologyFinancialData(
        capital_recovery_period=30,
        technology_base_year=2025,
        debt_fraction=0.5,
        debt_rate=0.07,
        return_on_equity=0.1,
        tax_rate=0.257,
    )
    expected = 0.5 * 0.07 * (1.0 - 0.257) + 0.5 * 0.1
    @test get_wacc(fd) ≈ expected

    # Also matches the value from the 5bus fixture
    p_5bus = build_portfolio()
    thermal = get_technology(SupplyTechnology{ThermalStandard}, p_5bus, "cheap_thermal")
    @test get_wacc(PSIP.get_financial_data(thermal)) ≈ expected

    # All-equity (debt_fraction = 0): WACC = Re
    fd_equity = TechnologyFinancialData(
        capital_recovery_period=20,
        technology_base_year=2020,
        debt_fraction=0.0,
        debt_rate=0.05,
        return_on_equity=0.12,
        tax_rate=0.21,
    )
    @test get_wacc(fd_equity) ≈ 0.12

    # All-debt (debt_fraction = 1): WACC = Rd*(1-Tc)
    fd_debt = TechnologyFinancialData(
        capital_recovery_period=20,
        technology_base_year=2020,
        debt_fraction=1.0,
        debt_rate=0.06,
        return_on_equity=0.1,
        tax_rate=0.25,
    )
    @test get_wacc(fd_debt) ≈ 0.06 * (1.0 - 0.25)

    # Debt fraction out of [0,1] should throw
    fd_invalid = TechnologyFinancialData(
        capital_recovery_period=20,
        technology_base_year=2020,
        debt_fraction=1.5,
        debt_rate=0.05,
        return_on_equity=0.1,
        tax_rate=0.21,
    )
    @test_throws ErrorException get_wacc(fd_invalid)
end

@testset "scale_conforming_load" begin
    p_5bus = build_portfolio()
    demand_b = get_technology(DemandRequirement{PowerLoad}, p_5bus, "demand_b")
    # demand_b has no ExistingDevices → peak demand is 0, growth_rate is 0 (default)
    # scale_conforming_load returns peak_demand * (1+growth_rate)^(year-base_year)
    result = PSIP.scale_conforming_load(demand_b, p_5bus, 2026)
    @test result isa Float64
    @test result == 0.0   # no ExistingDevices → peak demand is 0
end

@testset "get_base_year_for_load" begin
    p_5bus = build_portfolio()
    demand_b = get_technology(DemandRequirement{PowerLoad}, p_5bus, "demand_b")
    @test PSIP.get_base_year_for_load(demand_b, p_5bus) == get_base_year(p_5bus)
    @test PSIP.get_base_year_for_load(demand_b, p_5bus) == 2025
end

@testset "getters edge cases (ExistingDevices branches)" begin
    p_5bus = build_portfolio()
    sys = get_base_system(p_5bus)
    load_names = [PSY.get_name(l) for l in get_components(PowerLoad, sys)]
    @test !isempty(load_names)

    # --- ColocatedSupplyStorageTechnology short-circuits with a warning -> 0.0 ---
    tech_fd = TechnologyFinancialData(;
        capital_recovery_period=30,
        technology_base_year=2025,
        debt_fraction=0.5,
        debt_rate=0.07,
        return_on_equity=0.1,
        tax_rate=0.257,
    )
    sc = StorageCost(
        charge_variable_cost=CostCurve(LinearCurve(0.0)),
        discharge_variable_cost=CostCurve(LinearCurve(0.0)),
        fixed=0.0,
    )
    rc = RenewableGenerationCost(
        variable_operation_cost=CostCurve(LinearCurve(0.0)),
        curtailment_cost=CostCurve(LinearCurve(0.0)),
        fixed=0.0,
    )
    colocated = ColocatedSupplyStorageTechnology{PSY.RenewableDispatch}(;
        name="colo_edge",
        financial_data=tech_fd,
        power_systems_type="RenewableDispatch",
        operation_costs_power=sc,
        operation_costs_energy=sc,
        operation_costs_inverter=CostCurve(LinearCurve(0.0)),
        operation_costs_solar=rc,
        operation_costs_wind=rc,
        inverter_efficiency=0.96,
        inverter_supply_ratio=1.0,
        capital_costs_inverter=LinearCurve(0.0),
        available=true,
        region=[get_region(Zone, p_5bus, "Zone_1")],
    )
    @test get_existing_capacity_mw(p_5bus, colocated) == 0.0

    # --- get_existing_capacity_mw: multiple ExistingDevices attributes -> 0.0 ---
    thermal = get_technology(SupplyTechnology{ThermalStandard}, p_5bus, "cheap_thermal")
    PSIP.add_supplemental_attribute!(
        p_5bus,
        thermal,
        ExistingDevices(existing_devices=["extra"]),
    )
    @test get_existing_capacity_mw(p_5bus, thermal) == 0.0   # >1 attr

    # --- get_existing_capacity_mw: empty ExistingDevices name list -> 0.0 ---
    wind = get_technology(SupplyTechnology{RenewableDispatch}, p_5bus, "wind")
    PSIP.add_supplemental_attribute!(
        p_5bus,
        wind,
        ExistingDevices(existing_devices=String[]),
    )
    @test get_existing_capacity_mw(p_5bus, wind) == 0.0

    # --- get_existing_capacity_mwh: multiple attributes -> 0.0 ---
    storage = get_technology(StorageTechnology, p_5bus, "test_storage")
    PSIP.add_supplemental_attribute!(
        p_5bus,
        storage,
        ExistingDevices(existing_devices=["a"]),
    )
    PSIP.add_supplemental_attribute!(
        p_5bus,
        storage,
        ExistingDevices(existing_devices=["b"]),
    )
    @test get_existing_capacity_mwh(p_5bus, storage) == 0.0

    # --- get_peak_demand_mw: non-new demand with real loads attached -> > 0 ---
    demand_b = get_technology(DemandRequirement{PowerLoad}, p_5bus, "demand_b")
    PSIP.add_supplemental_attribute!(
        p_5bus,
        demand_b,
        ExistingDevices(existing_devices=load_names),
    )
    peak = get_peak_demand_mw(p_5bus, demand_b)
    @test peak isa Float64
    @test peak > 0.0
    # scale_conforming_load on a non-new, conforming demand exercises the else branch
    scaled = PSIP.scale_conforming_load(demand_b, p_5bus, 2030)
    @test scaled isa Float64
    @test scaled ≈ peak   # growth_rate defaults to 0

    # --- get_peak_demand_mw: multiple ExistingDevices attributes -> 0.0 ---
    demand_c = get_technology(DemandRequirement{PowerLoad}, p_5bus, "demand_c")
    PSIP.add_supplemental_attribute!(
        p_5bus,
        demand_c,
        ExistingDevices(existing_devices=["x"]),
    )
    PSIP.add_supplemental_attribute!(
        p_5bus,
        demand_c,
        ExistingDevices(existing_devices=["y"]),
    )
    @test get_peak_demand_mw(p_5bus, demand_c) == 0.0

    # --- get_peak_demand_mw: empty names + NON_CONFORMING scale branch ---
    demand_d = get_technology(DemandRequirement{PowerLoad}, p_5bus, "demand_d")
    PSIP.add_supplemental_attribute!(
        p_5bus,
        demand_d,
        ExistingDevices(existing_devices=String[]),
    )
    @test get_peak_demand_mw(p_5bus, demand_d) == 0.0
    PSIP.set_conformity!(demand_d, PSY.LoadConformity.NON_CONFORMING)
    @test PSIP.scale_conforming_load(demand_d, p_5bus, 2030) == 0.0  # non-conforming path
end
