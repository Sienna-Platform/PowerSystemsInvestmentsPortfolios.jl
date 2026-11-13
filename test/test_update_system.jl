update_financials() = TechnologyFinancialData(;
    capital_recovery_period=20,
    technology_base_year=2024,
    debt_fraction=0.5,
    debt_rate=0.05,
    return_on_equity=0.1,
    tax_rate=0.2,
)

update_thermal(name, node; kwargs...) = SupplyTechnology{PSY.ThermalStandard}(;
    name=name,
    power_systems_type="ThermalStandard",
    region=PSY.Topology[node],
    operation_costs=ThermalGenerationCost(;
        variable_operation_cost=CostCurve(LinearCurve(20.0)),
        fixed=0.0,
        start_up=0.0,
        shut_down=0.0,
    ),
    financial_data=update_financials(),
    kwargs...,
)

update_profile(name, start, values) = SingleTimeSeries(;
    name=name,
    data=TimeArray(collect(range(start; step=Hour(1), length=length(values))), values),
)

# A nodal portfolio on the 5-bus system with one technology per kind of update
function update_portfolio()
    sys = build_system(PSITestSystems, "c_sys5_re"; skip_serialization=true)
    port = Portfolio(PSY.ACBus, sys, 2024, 0.07, 0.025, 0.05)
    node(name) = PSY.get_component(PSY.ACBus, sys, name)
    attach!(technology, attribute) =
        PSIP.add_supplemental_attribute!(port, technology, attribute)

    # Existing coal: Park City (170 MW, oldest), Solitude (520 MW), Alta (40 MW, no build year)
    coal = update_thermal("coal", node("nodeA"))
    add_technology!(port, coal)
    attach!(coal, ExistingDevices(; existing_devices=["Solitude", "Park City", "Alta"]))
    attach!(
        coal,
        RetirementPotential(;
            eligible_generators=["Solitude", "Park City", "Alta"],
            build_year=Dict("Solitude" => 1990, "Park City" => 1980),
            retirement_cost=LinearCurve(0.0),
        ),
    )

    # Brighton (600 MW) and Sundance (200 MW) can be retrofitted into new coal with CCS
    gas = update_thermal("gas", node("nodeA"))
    ccs = update_thermal("coal_ccs", node("nodeA"))
    add_technology!(port, gas)
    add_technology!(port, ccs)
    attach!(gas, ExistingDevices(; existing_devices=["Brighton", "Sundance"]))
    retrofit = RetrofitPotential(;
        eligible_generators=["Brighton", "Sundance"],
        retrofit_efficiency=0.9,
        retrofit_cost=LinearCurve(0.0),
    )
    attach!(gas, retrofit)
    attach!(ccs, retrofit)

    add_technology!(
        port,
        update_thermal(
            "new_gas",
            node("nodeB");
            min_generation_fraction=0.4,
            ramp_limits=(up=0.5, down=0.5),
            time_limits=(up=120.0, down=60.0),
        ),
    )

    renewable(name, n) = SupplyTechnology{PSY.RenewableDispatch}(;
        name=name,
        power_systems_type="RenewableDispatch",
        region=PSY.Topology[node(n)],
        operation_costs=RenewableGenerationCost(CostCurve(LinearCurve(0.0))),
        financial_data=update_financials(),
    )
    wind = renewable("wind", "nodeE")
    add_technology!(port, wind)
    attach!(wind, ExistingDevices(; existing_devices=["WindBusA", "WindBusB"]))
    new_wind = renewable("new_wind", "nodeC")
    add_technology!(port, new_wind)
    # The chronological profile (no features) next to a representative day (with features)
    PSIP.add_time_series!(
        port,
        new_wind,
        update_profile("max_active_power", DateTime(2024, 2, 28), fill(0.4, 72)),
    )
    PSIP.add_time_series!(
        port,
        new_wind,
        update_profile("max_active_power", DateTime(2024, 1, 1), fill(0.9, 24));
        features=Dict("year" => "2024", "rep_day" => 1),
    )

    add_technology!(
        port,
        StorageTechnology{PSY.EnergyReservoirStorage}(;
            name="battery",
            region=PSY.Topology[node("nodeD")],
            available=true,
            power_systems_type="EnergyReservoirStorage",
            prime_mover_type=PrimeMovers.BT,
            efficiency=(in=0.9, out=0.95),
            operation_costs=StorageCost(;
                charge_variable_cost=CostCurve(LinearCurve(0.0)),
                discharge_variable_cost=CostCurve(LinearCurve(0.0)),
                fixed=0.0,
            ),
            financial_data=update_financials(),
        ),
    )

    line(name, from, to) = NodalACTransportTechnology{PSY.Line}(;
        name=name,
        available=true,
        power_systems_type="Line",
        start_node=node(from),
        end_node=node(to),
        reactance=5.0,
        resistance=0.5,
        financial_data=update_financials(),
    )
    add_technology!(port, line("new_line", "nodeB", "nodeD"))
    add_technology!(port, line("unit_line", "nodeA", "nodeB"))
    existing_line = line("line_1", "nodeA", "nodeB")
    add_technology!(port, existing_line)
    attach!(existing_line, ExistingDevices(; existing_devices=["1"]))

    load2 = ProjectedDemand{PSY.PowerLoad}(;
        name="load2",
        power_systems_type="PowerLoad",
        region=PSY.Topology[node("nodeB")],
    )
    add_technology!(port, load2)
    attach!(load2, ExistingDevices(; existing_devices=["Bus2"]))
    data_center = ProjectedDemand{PSY.PowerLoad}(;
        name="data_center",
        power_systems_type="PowerLoad",
        region=PSY.Topology[node("nodeC")],
        peak_demand_mw=50.0,
        construction_year=2030,
    )
    add_technology!(port, data_center)
    PSIP.add_time_series!(
        port,
        data_center,
        update_profile("demand", DateTime(2024, 2, 28), fill(0.8, 72)),
    )

    # A chronological series on an existing device, to be restamped
    PSY.add_time_series!(
        sys,
        PSY.get_component(PSY.ThermalStandard, sys, "Alta"),
        update_profile("availability", DateTime(2024, 2, 28), collect(1.0:72.0)),
    )
    return port
end

function update_schedule()
    schedule = InvestmentScheduleResults()
    for decision in (
        Retirement(; technology="coal", capacity=Dict(2030 => 600.0)),
        CapacityBuild(; technology="coal", capacity=Dict("nodeA" => Dict(2035 => 130.0))),
        Retrofit(;
            source="gas",
            option="coal_ccs",
            converted=Dict(2030 => 700.0),
            retrofitted=Dict(2030 => 630.0),
        ),
        CapacityBuild(;
            technology="new_gas",
            capacity=Dict("nodeB" => Dict(2030 => 300.0)),
            units=Dict("nodeB" => Dict(2030 => 2)),
        ),
        CapacityBuild(; technology="wind", capacity=Dict("nodeE" => Dict(2030 => 120.0))),
        CapacityBuild(;
            technology="new_wind",
            capacity=Dict("nodeC" => Dict(2030 => 80.0)),
        ),
        StorageBuild(;
            technology="battery",
            region="nodeD",
            power=Dict(2030 => 50.0),
            energy=Dict(2030 => 200.0),
        ),
        LineBuild(;
            technology="new_line",
            start_region="nodeB",
            end_region="nodeD",
            capacity=Dict(2030 => 300.0),
        ),
        LineBuild(;
            technology="unit_line",
            start_region="nodeA",
            end_region="nodeB",
            capacity=Dict(2030 => 200.0),
            units=Dict(2030 => 2),
        ),
        LineBuild(;
            technology="line_1",
            start_region="nodeA",
            end_region="nodeB",
            capacity=Dict(2030 => 100.0),
        ),
        DemandProjection(;
            technology="load2",
            region="nodeB",
            peak=Dict(2024 => 300.0, 2030 => 600.0),
        ),
        DemandProjection(;
            technology="data_center",
            region="nodeC",
            peak=Dict(2024 => 0.0, 2030 => 50.0),
        ),
    )
        add_decision!(schedule, decision)
    end
    return schedule
end

update_capacity(sys, T, name) = PSIP._existing_capacity_mw(PSY.get_component(T, sys, name))

@testset "Operational system from an investment schedule" begin
    port = update_portfolio()
    schedule = update_schedule()
    base = get_base_system(port)
    base_peak = PSIP.get_peak_demand_mw(
        port,
        PSIP.get_technology(ProjectedDemand{PSY.PowerLoad}, port, "load2"),
    )

    sys =
        @test_logs (:warn, r"Removed \d+ forecasts") match_mode = :any build_operational_system(
            port,
            schedule,
            2030,
        )
    @test sys !== base
    # The base system is untouched
    @test update_capacity(base, PSY.ThermalStandard, "Solitude") ≈ 520.0
    @test PSY.get_available(PSY.get_component(PSY.ThermalStandard, base, "Park City"))
    @test isnothing(PSY.get_component(PSY.ThermalStandard, base, "new_gas_1"))

    # Retirement, oldest first: Park City (1980) out, Solitude (1990) scaled from 520 to 90
    park_city = PSY.get_component(PSY.ThermalStandard, sys, "Park City")
    @test !PSY.get_available(park_city)
    solitude = PSY.get_component(PSY.ThermalStandard, sys, "Solitude")
    @test PSY.get_available(solitude)
    @test update_capacity(sys, PSY.ThermalStandard, "Solitude") ≈ 90.0
    # Every size-dependent field scales
    @test PSY.get_rating(solitude, u"MW") ≈
          PSY.get_rating(PSY.get_component(PSY.ThermalStandard, base, "Solitude"), u"MW") *
          90 / 520
    @test update_capacity(sys, PSY.ThermalStandard, "Alta") ≈ 40.0

    # Retrofit: Brighton (600) converted, Sundance half (200 to 100); options at their buses
    @test !PSY.get_available(PSY.get_component(PSY.ThermalStandard, sys, "Brighton"))
    @test update_capacity(sys, PSY.ThermalStandard, "Sundance") ≈ 100.0
    @test update_capacity(sys, PSY.ThermalStandard, "coal_ccs_Brighton") ≈ 540.0
    @test update_capacity(sys, PSY.ThermalStandard, "coal_ccs_Sundance") ≈ 90.0
    @test PSY.get_bus(PSY.get_component(PSY.ThermalStandard, sys, "coal_ccs_Brighton")) ===
          PSY.get_bus(PSY.get_component(PSY.ThermalStandard, sys, "Brighton"))

    # New thermal: two units, with the technology's operating data
    for k in 1:2
        unit = PSY.get_component(PSY.ThermalStandard, sys, "new_gas_$k")
        @test PSY.get_max_active_power(unit, u"MW") ≈ 150.0
        @test PSY.get_active_power_limits(unit, u"MW").min ≈ 60.0
        @test PSY.get_name(PSY.get_bus(unit)) == "nodeB"
        @test PSY.get_time_limits(unit) == (up=2.0, down=1.0)
    end

    # Existing wind scaled from 240 to 360 MW
    @test update_capacity(sys, PSY.RenewableDispatch, "WindBusA") ≈ 180.0
    @test update_capacity(sys, PSY.RenewableDispatch, "WindBusB") ≈ 180.0
    @test update_capacity(sys, PSY.RenewableDispatch, "WindBusC") ≈ 120.0

    # New wind takes the chronological profile, restamped to 2030 (no February 29)
    new_wind = PSY.get_component(PSY.RenewableDispatch, sys, "new_wind_1")
    @test PSY.get_max_active_power(new_wind, u"MW") ≈ 80.0
    profile = PSY.get_time_series(SingleTimeSeries, new_wind, "max_active_power")
    @test IS.get_initial_timestamp(profile) == DateTime(2030, 2, 28)
    @test length(profile) == 48
    @test all(IS.get_array(profile) .== 0.4)

    battery = PSY.get_component(PSY.EnergyReservoirStorage, sys, "battery_1")
    @test PSY.get_output_active_power_limits(battery, u"MW").max ≈ 50.0
    @test PSIP._storage_capacity_mwh(battery) ≈ 200.0
    @test PSY.get_efficiency(battery) == (in=0.9, out=0.95)

    # Lines: a new corridor, two parallel unit lines, an existing line's rating raised
    new_line = PSY.get_component(PSY.Line, sys, "new_line")
    @test PSY.get_rating(new_line, u"MW") ≈ 300.0
    @test PSY.get_x(new_line, u"NU") ≈ 5.0
    for k in 1:2
        unit_line = PSY.get_component(PSY.Line, sys, "unit_line_$k")
        @test PSY.get_rating(unit_line, u"MW") ≈ 100.0
        @test PSY.get_arc(unit_line) === PSY.get_arc(PSY.get_component(PSY.Line, sys, "1"))
    end
    @test PSY.get_rating(PSY.get_component(PSY.Line, sys, "1"), u"MW") ≈ 429.0

    # Demands: the existing load scaled to the projected peak, a new load with its profile
    @test PSY.get_max_active_power(PSY.get_component(PSY.PowerLoad, sys, "Bus2"), u"MW") ≈
          300.0 * 600.0 / base_peak
    data_center = PSY.get_component(PSY.PowerLoad, sys, "data_center")
    @test PSY.get_max_active_power(data_center, u"MW") ≈ 50.0
    @test PSY.has_time_series(data_center, SingleTimeSeries, "max_active_power")

    # Existing series are restamped and forecasts removed
    alta = PSY.get_component(PSY.ThermalStandard, sys, "Alta")
    availability = PSY.get_time_series(SingleTimeSeries, alta, "availability")
    @test IS.get_initial_timestamp(availability) == DateTime(2030, 2, 28)
    @test IS.get_array(availability) == vcat(1.0:24.0, 49.0:72.0)
    @test !PSY.has_time_series(PSY.get_component(PSY.PowerLoad, sys, "Bus2"), Deterministic)

    # Later years add later decisions: the coal build scales what is left (90 + 40) by 2
    sys_2035 = build_operational_system(port, schedule, 2035)
    @test update_capacity(sys_2035, PSY.ThermalStandard, "Solitude") ≈ 180.0
    @test update_capacity(sys_2035, PSY.ThermalStandard, "Alta") ≈ 80.0

    # Before any decision only the time series change
    sys_2025 = build_operational_system(port, schedule, 2025)
    @test PSY.get_available(PSY.get_component(PSY.ThermalStandard, sys_2025, "Park City"))
    @test isnothing(PSY.get_component(PSY.ThermalStandard, sys_2025, "new_gas_1"))
    @test update_capacity(sys_2025, PSY.RenewableDispatch, "WindBusA") ≈ 120.0
end

@testset "Operational system: listed devices and retirement order" begin
    port = update_portfolio()
    schedule = InvestmentScheduleResults()
    # Alta is listed, so it goes first, then the oldest
    add_decision!(
        schedule,
        Retirement(;
            technology="coal",
            capacity=Dict(2030 => 100.0),
            devices=Dict(2030 => ["Alta"]),
        ),
    )
    sys = build_operational_system(port, schedule, 2030)
    @test !PSY.get_available(PSY.get_component(PSY.ThermalStandard, sys, "Alta"))
    @test update_capacity(sys, PSY.ThermalStandard, "Park City") ≈ 110.0
    @test update_capacity(sys, PSY.ThermalStandard, "Solitude") ≈ 520.0

    # Another order: largest first
    largest_first(_, _, devices) = sort(devices; by=d -> -PSIP._existing_capacity_mw(d))
    schedule = InvestmentScheduleResults()
    add_decision!(schedule, Retirement(; technology="coal", capacity=Dict(2030 => 100.0)))
    sys = build_operational_system(port, schedule, 2030; retirement_order=largest_first)
    @test update_capacity(sys, PSY.ThermalStandard, "Solitude") ≈ 420.0

    # More than can retire
    schedule = InvestmentScheduleResults()
    add_decision!(schedule, Retirement(; technology="coal", capacity=Dict(2030 => 1000.0)))
    @test_throws ErrorException build_operational_system(port, schedule, 2030)
end

@testset "Operational system: errors" begin
    # Zonal portfolios are not supported
    @test_throws ArgumentError build_operational_system(
        build_portfolio(),
        InvestmentScheduleResults(),
        2030,
    )

    port = update_portfolio()
    # A decision of the wrong kind for its technology
    schedule = InvestmentScheduleResults()
    add_decision!(schedule, CapacityBuild(; technology="battery"))
    @test_throws ErrorException build_operational_system(port, schedule, 2030)
    # An unknown technology
    schedule = InvestmentScheduleResults()
    add_decision!(schedule, Retirement(; technology="nuclear", capacity=Dict(2030 => 1.0)))
    @test_throws ErrorException build_operational_system(port, schedule, 2030)
end

@testset "Restamping time series" begin
    # Into a non-leap year: February 29 is dropped
    series = update_profile("x", DateTime(2024, 2, 28), collect(1.0:72.0))
    moved = restamp_time_series(series, 2030)
    @test IS.get_initial_timestamp(moved) == DateTime(2030, 2, 28)
    @test IS.get_array(moved) == vcat(1.0:24.0, 49.0:72.0)
    # Into a leap year: February 28 is repeated on February 29
    series = update_profile("x", DateTime(2023, 2, 28), collect(1.0:48.0))
    moved = restamp_time_series(series, 2028; name="y")
    @test IS.get_name(moved) == "y"
    @test length(moved) == 72
    @test IS.get_array(moved) == vcat(1.0:24.0, 1.0:24.0, 25.0:48.0)
    # Between years of the same kind nothing is dropped or added
    moved = restamp_time_series(series, 2031)
    @test IS.get_array(moved) == collect(1.0:48.0)
    @test IS.get_initial_timestamp(moved) == DateTime(2031, 2, 28)
    # Resolutions above a day are not supported
    weekly = SingleTimeSeries(;
        name="w",
        data=TimeArray(collect(range(DateTime(2024); step=Week(1), length=4)), ones(4)),
    )
    @test_throws ArgumentError restamp_time_series(weekly, 2030)
end
