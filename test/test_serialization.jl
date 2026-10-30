@testset "Test serialization of technologies" begin
    portfolio = build_portfolio()
    portfolio2 = validate_serialization(portfolio; time_series_read_only=true)

    technologies = get_technologies(Technology, portfolio)

    for t in technologies
        t2 = get_technology(typeof(t), portfolio2, PSIP.get_name(t))
        @test t2 !== nothing
        result = IS.compare_values(t, t2; compare_uuids=false)
        @test result
    end
end

@testset "Test serialization of technology requirement references" begin
    portfolio = build_portfolio()
    requirement = PSIP.get_requirement(EnergyShareRequirements, portfolio, "test_esr")
    storage = first(get_technologies(StorageTechnology, portfolio))
    set_requirements!(storage, [requirement])

    portfolio2 = validate_serialization(portfolio; time_series_read_only=true)
    storage2 = get_technology(typeof(storage), portfolio2, PSIP.get_name(storage))
    @test storage2 !== nothing
    result = IS.compare_values(storage, storage2; compare_uuids=false)
    @test result

    requirement2 = PSIP.get_requirement(EnergyShareRequirements, portfolio2, "test_esr")
    @test has_requirement(storage2, requirement2)
end

@testset "Test serialization of regions" begin
    portfolio = build_portfolio()
    portfolio2 = validate_serialization(portfolio; time_series_read_only=true)

    regions = get_regions(RegionTopology, portfolio)

    for r in regions
        r2 = get_region(typeof(r), portfolio2, PSIP.get_name(r))
        @test r2 !== nothing
        result = IS.compare_values(r, r2; compare_uuids=false)
        @test result
    end
end

@testset "Test serialization of Portfolio fields" begin
    financial_data = PortfolioFinancialData(2020, 0.07, 0.03, 0.05)
    name = "my_portfolio"
    description = "test"
    port = Portfolio(; financial_data=financial_data, name=name, description=description)
    zone = Zone(; name="zone1", id=1)
    base_sys = get_base_system(port)
    test_bus = ACBus(nothing)
    set_bustype!(test_bus, ACBusTypes.REF)
    add_component!(base_sys, test_bus)

    add_region!(port, zone)
    gen = SupplyTechnology{ThermalStandard}(;
        name="gen1",
        region=[zone],
        id=1,
        available=true,
        financial_data=TechnologyFinancialData(;
            capital_recovery_period=30,
            technology_base_year=2025,
            debt_fraction=0.5,
            debt_rate=0.07,
            return_on_equity=0.1,
            tax_rate=0.257,
        ),
        power_systems_type="test",
        operation_costs=ThermalGenerationCost(;
            variable=zero(CostCurve),
            fixed=0.0,
            start_up=0.0,
            shut_down=0.0,
        ),
    )
    add_technology!(port, gen)

    port2 = validate_serialization(port)
    @test port2.financial_data.discount_rate == financial_data.discount_rate
    @test port2.financial_data.inflation_rate == financial_data.inflation_rate
    @test port2.financial_data.interest_rate == financial_data.interest_rate
    @test port2.metadata.name == name
    @test port2.metadata.description == description
end

@testset "Test serialization/deserialization of investment schedule" begin
    portfolio = build_portfolio()

    dict_2030 = Dict(
        (SupplyTechnology{ThermalStandard}, "expensive_thermal") => 0.0,
        (StorageTechnology{EnergyReservoirStorage}, "test_storage") =>
            (build_p=0.0, build_e=0.0),
        (ColocatedSupplyStorageTechnology{RenewableDispatch}, "colocated_test") => (
            build_p=1400.6,
            build_solar=0.0,
            build_e=10176.7,
            build_inverter=1592.22,
            build_wind=1722.66,
        ),
        (SupplyTechnology{RenewableDispatch}, "wind") => 975.015,
        (AggregateTransportTechnology{ACBranch}, "test_branch") => 934.992,
        (SupplyTechnology{ThermalStandard}, "cheap_thermal") => 0.0,
    )
    dict_2035 = Dict(
        (SupplyTechnology{ThermalStandard}, "expensive_thermal") => 0.0,
        (StorageTechnology{EnergyReservoirStorage}, "test_storage") =>
            (build_p=0.0, build_e=0.0),
        (ColocatedSupplyStorageTechnology{RenewableDispatch}, "colocated_test") => (
            build_p=185.437,
            build_solar=0.0,
            build_e=1283.1,
            build_inverter=313.05,
            build_wind=0.0,
        ),
        (SupplyTechnology{RenewableDispatch}, "wind") => 135.609,
        (AggregateTransportTechnology{ACBranch}, "test_branch") => 508.671,
        (SupplyTechnology{ThermalStandard}, "cheap_thermal") => 0.0,
    )
    manual_schedule = Dict(
        (Date("2030-01-01"), Date("2034-12-01")) => dict_2030,
        (Date("2035-01-01"), Date("2039-12-01")) => dict_2035,
    )
    schedule = InvestmentScheduleResults(manual_schedule)

    set_investment_schedule!(portfolio, schedule)

    @test schedule == get_investment_schedule(portfolio)

    portfolio2 = validate_serialization(portfolio)
    schedule2 = get_investment_schedule(portfolio2)
    for key in keys(schedule.results)
        @test haskey(schedule2.results, key)
        for key2 in keys(schedule.results[key])
            @test haskey(schedule2.results[key], key2)
            if schedule.results[key][key2] isa NamedTuple
                caps = schedule.results[key][key2]
                caps2 = schedule2.results[key][key2]
                for key3 in keys(caps)
                    @test caps[key3] == caps2[key3]
                end
            else
                @test schedule.results[key][key2] == schedule2.results[key][key2]
            end
        end
    end
end

@testset "Test deserialization of component dependency order" begin
    portfolio = build_portfolio()
    requirement = PSIP.get_requirement(EnergyShareRequirements, portfolio, "test_esr")
    storage = first(get_technologies(StorageTechnology, portfolio))
    set_requirements!(storage, [requirement])

    mktempdir() do test_dir
        path = joinpath(test_dir, "test_requirement_serialization.json")
        PSIP.to_json(portfolio, path; force=true)
        data = open(path, "r") do io
            JSON3.read(io, Dict)
        end
        component_type_order = ["StorageTechnology", "EnergyShareRequirements", "Zone"]
        type_rank = Dict(type => rank for (rank, type) in enumerate(component_type_order))
        components = data["data"]["components"]
        sort!(
            components;
            by=x ->
                get(type_rank, x["__metadata__"]["type"], length(component_type_order) + 1),
        )
        open(path, "w") do io
            JSON3.pretty(io, data)
        end

        portfolio2 = Portfolio(path)
        storage2 = get_technology(typeof(storage), portfolio2, PSIP.get_name(storage))
        @test storage2 !== nothing
        result = IS.compare_values(storage, storage2; compare_uuids=false)
        @test result

        requirement2 = PSIP.get_requirement(EnergyShareRequirements, portfolio2, "test_esr")
        @test has_requirement(storage2, requirement2)
    end
end
