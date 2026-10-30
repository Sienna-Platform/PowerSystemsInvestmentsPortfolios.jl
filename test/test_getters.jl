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
    demand_r = get_technology(ProjectedDemand{PowerLoad}, p_5bus, "demand_b")
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
    demand = get_technology(ProjectedDemand{PowerLoad}, p_5bus, "demand_b")

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

    # sum of the existing units' maximum active power (their MVA ratings sum to 791.25)
    @test get_existing_capacity_mw(p_5bus, thermal) == 730.0
    # new technology → 0
    @test get_existing_capacity_mw(p_5bus, renewable) == 0.0
    @test get_existing_capacity_mw(p_5bus, storage) == 0.0

    # A demand side technology takes the maximum active power of its existing loads
    demand_side = get_technology(DemandSideTechnology{PowerLoad}, p_5bus, "test_demand")
    @test get_existing_capacity_mw(p_5bus, demand_side) == 0.0
    load = first(get_components(PowerLoad, get_base_system(p_5bus)))
    PSIP.add_supplemental_attribute!(
        p_5bus,
        demand_side,
        ExistingDevices(; id=60, existing_devices=[PSY.get_name(load)]),
    )
    expected = with_units_base(get_base_system(p_5bus), "NATURAL_UNITS") do
        get_max_active_power(load)
    end
    @test get_existing_capacity_mw(p_5bus, demand_side) == expected
end

@testset "Retrofit getters" begin
    p_5bus = build_portfolio()
    source = get_technology(SupplyTechnology{ThermalStandard}, p_5bus, "cheap_thermal")
    retrofit = only(PSIP.get_supplemental_attributes(RetrofitPotential, source))

    # The attribute is shared by the source and its retrofit option
    @test Set(PSIP.get_name.(get_associated_technologies(p_5bus, retrofit))) ==
          Set(["cheap_thermal", "expensive_thermal"])
    @test get_retrofit_efficiency(retrofit) == 0.9
    # The eligible units are the source's existing units
    @test get_retrofit_capacity_mw(p_5bus, source, retrofit) == 730.0
    PSIP.set_eligible_generators!(retrofit, ["missing_unit"])
    @test_throws r"missing_unit" get_retrofit_capacity_mw(p_5bus, source, retrofit)
end

@testset "get_existing_capacity_mwh" begin
    p_5bus = build_portfolio()
    storage = get_technology(StorageTechnology, p_5bus, "test_storage")
    # new storage → 0
    @test get_existing_capacity_mwh(p_5bus, storage) == 0.0
end

@testset "get_peak_demand_mw" begin
    p_5bus = build_portfolio()
    demand_b = get_technology(ProjectedDemand{PowerLoad}, p_5bus, "demand_b")

    # No ExistingDevices: the demand's own peak demand
    @test get_peak_demand_mw(p_5bus, demand_b) == 120.0
end

# Portfolio whose base system has one load per (name, max active power, time series), and a
# demand mapped to the given load names.
function peak_demand_portfolio(loads, existing_names)
    sys = PSY.System(100.0)
    set_units_base_system!(sys, "NATURAL_UNITS")
    bus = ACBus(nothing)
    set_bustype!(bus, ACBusTypes.REF)
    add_component!(sys, bus)
    for (name, max_power, time_series) in loads
        load = PowerLoad(nothing)
        PSY.set_name!(load, name)
        PSY.set_bus!(load, bus)
        add_component!(sys, load)
        PSY.set_max_active_power!(load, max_power)
        isnothing(time_series) || PSY.add_time_series!(sys, load, time_series)
    end
    port = Portfolio(sys; financial_data=PortfolioFinancialData(2025, 0.07, 0.05, 0.03))
    zone = Zone(; name="zone", id=1)
    add_region!(port, zone)
    demand = ProjectedDemand{PowerLoad}(;
        name="demand",
        id=1,
        power_systems_type="PowerLoad",
        region=[zone],
    )
    add_technology!(port, demand)
    PSIP.add_supplemental_attribute!(
        port,
        demand,
        ExistingDevices(; id=61, existing_devices=existing_names),
    )
    return port, demand
end

@testset "get_peak_demand_mw of existing loads" begin
    stamps =
        collect(DateTime("2025-01-01T00:00:00"):Hour(1):DateTime("2025-01-01T02:00:00"))
    profile(values) = SingleTimeSeries(
        "max_active_power",
        TimeArray(stamps, values);
        scaling_factor_multiplier=PSY.get_max_active_power,
    )
    offset_loads = [
        ("load1", 100.0, profile([1.0, 0.5, 0.2])),
        ("load2", 50.0, profile([0.2, 1.0, 0.4])),
    ]

    # Coincident peak (110 MW in the first hour), below the sum of the maxima (150 MW)
    port, demand = peak_demand_portfolio(offset_loads, ["load1", "load2"])
    @test get_peak_demand_mw(port, demand) ≈ 110.0

    # A load without a profile counts at its maximum in every time step
    port, demand = peak_demand_portfolio(
        [offset_loads..., ("load3", 30.0, nothing)],
        ["load1", "load2", "load3"],
    )
    @test (@test_logs (:warn, r"load3") get_peak_demand_mw(port, demand)) ≈ 140.0

    # Profiles must share their time stamps
    shifted =
        SingleTimeSeries("max_active_power", TimeArray(stamps .+ Hour(1), [1.0, 0.5, 0.2]))
    port, demand = peak_demand_portfolio(
        [offset_loads[1], ("load2", 50.0, shifted)],
        ["load1", "load2"],
    )
    @test_throws ErrorException get_peak_demand_mw(port, demand)

    # Every name must be a load of the base system
    port, demand = peak_demand_portfolio(offset_loads, ["load1", "missing_load"])
    @test_throws r"missing_load" get_peak_demand_mw(port, demand)

    # Forecast windows that do not overlap are joined into one profile
    t0 = DateTime("2025-01-01T00:00:00")
    forecast(windows) = Deterministic("max_active_power", windows, Hour(1))
    port, demand = peak_demand_portfolio(
        [
            ("load1", 100.0, forecast(Dict(t0 => [1.0, 0.5], t0 + Hour(2) => [0.2, 0.3]))),
            ("load2", 50.0, forecast(Dict(t0 => [0.2, 1.0], t0 + Hour(2) => [0.4, 1.0]))),
        ],
        ["load1", "load2"],
    )
    @test get_peak_demand_mw(port, demand) ≈ 110.0

    # Overlapping windows are an error
    port, demand = peak_demand_portfolio(
        [("load1", 100.0, forecast(Dict(t0 => [1.0, 0.5], t0 + Hour(1) => [0.2, 0.3])))],
        ["load1"],
    )
    @test_throws r"overlapping" get_peak_demand_mw(port, demand)
end

@testset "get_heat_rate / get_fuel_cost / get_variable_cost" begin
    p_5bus = build_portfolio()
    # cheap_thermal uses a FuelCurve — heat_rate and fuel_cost are defined
    thermal = get_technology(SupplyTechnology{ThermalStandard}, p_5bus, "cheap_thermal")
    @test PSIP.get_heat_rate(thermal) isa Float64
    @test PSIP.get_heat_rate(thermal) > 0
    @test PSIP.get_fuel_cost(thermal) isa Float64
    @test PSIP.get_fuel_cost(thermal) == 1.12

    # both FuelCurve and CostCurve technologies expose get_variable_cost
    expensive =
        get_technology(SupplyTechnology{ThermalStandard}, p_5bus, "expensive_thermal")
    @test PSIP.get_variable_cost(expensive) isa Float64
    @test PSIP.get_variable_cost(thermal) isa Float64
end

@testset "get_variable_cost_charge / get_variable_cost_discharge" begin
    p_5bus = build_portfolio()
    storage = get_technology(StorageTechnology, p_5bus, "test_storage")
    @test get_variable_cost_charge(storage) isa Float64
    @test get_variable_cost_discharge(storage) isa Float64
    # storage in 5bus fixture has zero variable costs
    @test get_variable_cost_charge(storage) == 0.0
    @test get_variable_cost_discharge(storage) == 0.0
end

@testset "get_fixed_cost / get_fixed_cost_charge / get_fixed_cost_discharge" begin
    p_5bus = build_portfolio()
    thermal = get_technology(SupplyTechnology{ThermalStandard}, p_5bus, "cheap_thermal")
    wind = get_technology(SupplyTechnology{RenewableDispatch}, p_5bus, "wind")
    storage = get_technology(StorageTechnology, p_5bus, "test_storage")

    @test get_fixed_cost(thermal) isa Float64
    @test get_fixed_cost(wind) isa Float64
    @test get_fixed_cost(storage) isa Float64

    @test get_fixed_cost_charge(storage) isa Float64
    @test get_fixed_cost_discharge(storage) isa Float64
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
    demand_b = get_technology(ProjectedDemand{PowerLoad}, p_5bus, "demand_b")
    # demand_b is new, with a peak demand of 120 MW and no growth
    result = PSIP.scale_conforming_load(demand_b, p_5bus, 2026)
    @test result == 120.0
end

@testset "get_base_year_for_load" begin
    p_5bus = build_portfolio()
    demand_b = get_technology(ProjectedDemand{PowerLoad}, p_5bus, "demand_b")
    @test PSIP.get_base_year_for_load(demand_b, p_5bus) == get_base_year(p_5bus)
    @test PSIP.get_base_year_for_load(demand_b, p_5bus) == 2025
end
