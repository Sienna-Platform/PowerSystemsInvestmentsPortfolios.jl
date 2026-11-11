@testset "Investment schedule" begin
    schedule = InvestmentScheduleResults()
    @test isempty(get_builds(schedule))

    gas = CapacityBuild(;
        technology="gas",
        capacity=Dict(
            "West" => Dict(2030 => 100.0, 2035 => 50.0),
            "East" => Dict(2035 => 20.0),
        ),
        units=Dict("West" => Dict(2030 => 2, 2035 => 1), "East" => Dict(2035 => 1)),
    )
    battery = StorageBuild(;
        technology="battery",
        region="West",
        power=Dict(2030 => 10.0),
        energy=Dict(2030 => 40.0, 2040 => 20.0),
    )
    line = LineBuild(;
        technology="west_east",
        start_region="West",
        end_region="East",
        capacity=Dict(2035 => 300.0),
    )
    ccs = Retrofit(;
        source="coal",
        option="coal_ccs",
        converted=Dict(2035 => 200.0),
        retrofitted=Dict(2035 => 170.0),
    )
    coal = Retirement(;
        technology="coal",
        capacity=Dict(2030 => 50.0, 2040 => 100.0),
        planned=Dict(2030 => 50.0),
    )
    foreach(d -> add_decision!(schedule, d), (gas, battery, line, ccs, coal))

    @test get_builds(schedule) == [gas, battery]
    @test get_lines(schedule) == [line]
    @test get_retrofits(schedule) == [ccs]
    @test get_retirements(schedule) == [coal]
    @test get_decision(schedule, CapacityBuild, "gas") === gas
    @test get_decision(schedule, StorageBuild, "battery") === battery
    @test isnothing(get_decision(schedule, CapacityBuild, "battery"))
    @test get_decision(schedule, LineBuild, "west_east") === line
    @test get_decision(schedule, Retrofit, "coal", "coal_ccs") === ccs
    @test isnothing(get_decision(schedule, Retrofit, "coal", "gas"))
    @test get_decision(schedule, Retirement, "coal") === coal
    @test isnothing(get_decision(schedule, Retirement, "gas"))
    # One decision of each kind per technology
    @test_throws ArgumentError add_decision!(schedule, CapacityBuild(; technology="gas"))
    @test_throws ArgumentError add_decision!(
        schedule,
        StorageBuild(; technology="gas", region="West"),
    )
    @test_throws ArgumentError add_decision!(
        schedule,
        Retrofit(; source="coal", option="coal_ccs"),
    )
    # A technology can be both built and retired
    add_decision!(schedule, Retirement(; technology="gas", capacity=Dict(2040 => 10.0)))
    @test !isnothing(get_decision(schedule, Retirement, "gas"))

    # Cumulative capacity up to and including a year
    @test get_cumulative_capacity(gas, 2025) == 0.0
    @test get_cumulative_capacity(gas, 2030) == 100.0
    @test get_cumulative_capacity(gas, 2035) == 170.0
    @test get_cumulative_capacity(gas, "West", 2035) == 150.0
    @test get_cumulative_capacity(gas, "North", 2035) == 0.0
    @test get_cumulative_capacity(battery, 2035) == (power=10.0, energy=40.0)
    @test get_cumulative_capacity(battery, 2040) == (power=10.0, energy=60.0)
    @test get_cumulative_capacity(line, 2034) == 0.0
    @test get_cumulative_capacity(line, 2035) == 300.0
    @test get_cumulative_capacity(ccs, 2040) == (converted=200.0, retrofitted=170.0)
    @test get_cumulative_capacity(coal, 2035) == 50.0
    @test get_cumulative_capacity(coal, 2040) == 150.0

    # Demands: data for scaling profiles, and demand side investments as builds
    load = DemandProjection(;
        technology="load_west",
        region="West",
        peak=Dict(2030 => 100.0, 2035 => 110.0),
    )
    data_center = DemandProjection(;
        technology="data_center",
        region="East",
        peak=Dict(2030 => 0.0, 2035 => 50.0),
    )
    electrolyzer = CapacityBuild(;
        technology="electrolyzer",
        capacity=Dict("West" => Dict(2035 => 25.0)),
    )
    foreach(d -> add_decision!(schedule, d), (load, data_center, electrolyzer))
    @test get_demands(schedule) == [load, data_center]
    @test get_decision(schedule, DemandProjection, "load_west") === load
    @test get_decision(schedule, CapacityBuild, "electrolyzer") === electrolyzer
    @test_throws ArgumentError add_decision!(
        schedule,
        DemandProjection(; technology="load_west", region="West"),
    )
    @test get_projected_peak(load, 2025) == 0.0
    @test get_projected_peak(load, 2030) == 100.0
    @test get_projected_peak(load, 2033) == 100.0
    @test get_projected_peak(load, 2040) == 110.0
    @test get_projected_peak(data_center, 2034) == 0.0
    @test get_projected_peak(data_center, 2035) == 50.0
end
