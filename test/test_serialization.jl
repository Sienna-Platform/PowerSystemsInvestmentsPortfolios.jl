# Round-trip tests for the OpenAPI document serialization (`to_file`/`from_file`).
#
# Builds a small-but-complete portfolio exercising every serialized facet — base system,
# technology + financial_data, policy requirement + membership, supplemental attribute, time
# series, portfolio financial_data, and investment schedule — writes it to each on-disk form
# (directory, `.json` document, `.snp` archive), reads it back, and asserts each facet survives.

function _build_roundtrip_portfolio()
    financial_data = PortfolioFinancialData(2020, 0.07, 0.03, 0.05)
    port = Portfolio(;
        financial_data=financial_data,
        name="roundtrip_portfolio",
        description="round-trip case",
    )

    # Base system with a bus, so the base_system/ sidecar round-trips.
    base_sys = PSIP.get_base_system(port)
    ref_bus = ACBus(nothing)
    PSY.set_name!(ref_bus, "ref_bus")
    PSY.set_bustype!(ref_bus, ACBusTypes.REF)
    PSY.add_component!(base_sys, ref_bus)

    # Topology region referenced by the technology.
    zone = PSY.Area(; input_basis=PSY.CU, name="zone1", base_power=100.0)
    PSIP.add_topology!(port, zone)

    # One technology, with its own financial data + operation costs.
    gen = SupplyTechnology{ThermalStandard}(;
        name="gen1",
        region=[zone],
        available=true,
        power_systems_type=string(nameof(ThermalStandard)),
        financial_data=TechnologyFinancialData(;
            capital_recovery_period=30,
            technology_base_year=2025,
            debt_fraction=0.5,
            debt_rate=0.07,
            return_on_equity=0.1,
            tax_rate=0.257,
        ),
        operation_costs=ThermalGenerationCost(;
            variable_operation_cost=zero(CostCurve),
            fixed=0.0,
            start_up=0.0,
            shut_down=0.0,
        ),
    )
    PSIP.add_technology!(port, gen)

    # A policy requirement, with membership on the technology (requirements_associations table).
    req = MaximumCapacityRequirements(; name="max_cap", available=true, target_year=2030)
    PSIP.add_requirement!(port, req)
    PSIP.set_requirements!(gen, [req])

    # A supplemental attribute on the technology.
    PSIP.add_supplemental_attribute!(
        port,
        gen,
        ExistingDevices(; existing_devices=["gen1"]),
    )

    # A time series on the technology.
    timestamps =
        collect(DateTime("2024-01-01T00:00:00"):Hour(1):DateTime("2024-01-01T23:00:00"))
    ts =
        SingleTimeSeries(; data=TimeArray(timestamps, collect(1.0:24.0)), name="cap_factor")
    PSIP.add_time_series!(port, gen, ts; features=Dict("year" => "2024", "rep_day" => 1))

    # An investment schedule (model output).
    schedule = InvestmentScheduleResults(
        Dict(
            (Date("2030-01-01"), Date("2034-12-01")) =>
                Dict((SupplyTechnology{ThermalStandard}, "gen1") => 123.45),
        ),
    )
    PSIP.set_investment_schedule!(port, schedule)

    return port
end

function _check_roundtrip_portfolio(port2)
    # Portfolio-level financial_data
    fd2 = PSIP.get_financial_data(port2)
    @test fd2 !== nothing
    @test fd2.base_year == 2020
    @test fd2.discount_rate == 0.07
    @test fd2.inflation_rate == 0.03
    @test fd2.interest_rate == 0.05

    # Metadata
    @test PSIP.get_name(port2) == "roundtrip_portfolio"
    @test PSIP.get_description(port2) == "round-trip case"

    # Technology, with its region resolved against the re-read base system
    gen2 = PSIP.get_technology(SupplyTechnology{ThermalStandard}, port2, "gen1")
    @test gen2 !== nothing
    @test only(PSIP.get_region(gen2)) ===
          PSY.get_component(PSY.Area, PSIP.get_base_system(port2), "zone1")

    # Requirement + membership (association-table round trip)
    req2 = PSIP.get_requirement(MaximumCapacityRequirements, port2, "max_cap")
    @test req2 !== nothing
    @test PSIP.has_requirement(gen2, req2)

    # Supplemental attribute
    attrs = collect(IS.get_supplemental_attributes(ExistingDevices, gen2))
    @test length(attrs) == 1
    @test attrs[1].existing_devices == ["gen1"]

    # Time series
    ts_list = collect(IS.get_time_series_multiple(port2))
    @test length(ts_list) == 1
    @test TimeSeries.values(IS.get_data(ts_list[1])) == collect(1.0:24.0)

    # Investment schedule
    sched2 = PSIP.get_investment_schedule(port2)
    @test sched2 !== nothing
    key = (Date("2030-01-01"), Date("2034-12-01"))
    @test haskey(sched2.results, key)
    @test sched2.results[key][(SupplyTechnology{ThermalStandard}, "gen1")] == 123.45

    # Base system
    bsys2 = PSIP.get_base_system(port2)
    @test bsys2 isa PSY.System
    @test any(b -> PSY.get_name(b) == "ref_bus", PSY.get_components(ACBus, bsys2))
    return
end

@testset "OpenAPI document round-trip (to_file/from_file)" begin
    port = _build_roundtrip_portfolio()

    mktempdir() do dir
        # Directory form: the base system in PSY's directory form beside the document.
        bundle = joinpath(dir, "case")
        PSIP.to_file(port, bundle; force=true)
        @test isfile(joinpath(bundle, "portfolio.json"))
        @test isfile(joinpath(bundle, "time_series.h5"))
        @test !isfile(joinpath(bundle, "time_series.h5.sqlite"))
        @test isdir(joinpath(bundle, "base_system"))
        _check_roundtrip_portfolio(PSIP.from_file(bundle))

        # Document form: every member on the document's stem, no catalog.
        document = joinpath(dir, "case.json")
        PSIP.to_file(port, document; force=true)
        @test isfile(joinpath(dir, "case.h5"))
        @test !isfile(joinpath(dir, "case.h5.sqlite"))
        @test isfile(joinpath(dir, "case_base_system.json"))
        _check_roundtrip_portfolio(PSIP.from_file(document))

        # Archive form: one file, readable whether or not the store is read-only.
        archive = joinpath(dir, "case.snp")
        PSIP.to_file(port, archive; force=true)
        @test isfile(archive)
        _check_roundtrip_portfolio(PSIP.from_file(archive))
        _check_roundtrip_portfolio(PSIP.from_file(archive; time_series_read_only=true))

        # Writes refuse to overwrite without `force`, and unknown extensions are refused.
        @test_throws IS.DataFormatError PSIP.to_file(port, document)
        @test_throws ErrorException PSIP.to_file(port, joinpath(dir, "case.txt"))
        @test_throws IS.DataFormatError PSIP.from_file(joinpath(dir, "case.txt"))
    end
end
