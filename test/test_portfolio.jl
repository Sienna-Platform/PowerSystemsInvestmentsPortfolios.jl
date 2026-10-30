@testset "Test functionality of Portfolio" begin
    p_5bus = build_portfolio()

    technologies = collect(get_technologies(SupplyTechnology, p_5bus))
    technology = get_technology(SupplyTechnology, p_5bus, PSIP.get_name(technologies[1]))
    @test IS.get_uuid(technology) == IS.get_uuid(technologies[1])
    @test_throws(IS.ArgumentError, add_technology!(p_5bus, technology))
    @test get_available_technology(
        SupplyTechnology,
        p_5bus,
        PSIP.get_name(technologies[1]),
    ) === technology
    PSIP.set_available!(technology, false)
    available_technologies = collect(get_available_technologies(SupplyTechnology, p_5bus))
    @test length(technologies) == length(available_technologies) + 1
    PSIP.set_available!(technology, true)

    technologies2 =
        get_technologies_by_name(SupplyTechnology, p_5bus, PSIP.get_name(technologies[1]))
    @test length(technologies2) == 1
    @test IS.get_uuid(technologies2[1]) == IS.get_uuid(technologies[1])
    @test has_time_series(technologies2[1])

    @test isnothing(get_technology(SupplyTechnology, p_5bus, "not-a-name"))
    @test isempty(get_technologies_by_name(SupplyTechnology, p_5bus, "not-a-name"))

    @test isempty(get_technologies(x -> (!PSIP.get_available(x)), SupplyTechnology, p_5bus))
    @test !isempty(get_available_technologies(SupplyTechnology, p_5bus))

    # Get time_series with a name and without.
    renewables = collect(get_technologies(SupplyTechnology{RenewableDispatch}, p_5bus))
    @test !isempty(renewables)
    renewable = renewables[1]
    ts = get_time_series(
        SingleTimeSeries,
        renewable,
        "ops_variable_cap_factor";
        year="2024",
        rep_day=1,
    )
    @test ts isa SingleTimeSeries

    # Test all versions of get_time_series_[array|timestamps|values]
    values1 = get_time_series_array(renewable, ts)
    values2 = get_time_series_array(
        SingleTimeSeries,
        renewable,
        "ops_variable_cap_factor";
        year="2024",
        rep_day=1,
    )
    @test values1 == values2
    values3 = get_time_series_array(
        SingleTimeSeries,
        renewable,
        "ops_variable_cap_factor";
        year="2024",
        rep_day=1,
    )
    @test values1 == values3

    val = get_time_series_array(
        SingleTimeSeries,
        renewable,
        "ops_variable_cap_factor";
        year="2024",
        rep_day=1,
    )
    @test val isa TimeSeries.TimeArray
    val = get_time_series_timestamps(
        SingleTimeSeries,
        renewable,
        "ops_variable_cap_factor";
        year="2024",
        rep_day=1,
    )
    @test val isa Array
    @test val[1] isa Dates.DateTime
    val = get_time_series_values(
        SingleTimeSeries,
        renewable,
        "ops_variable_cap_factor";
        year="2024",
        rep_day=1,
    )
    @test val isa Array
    @test val[1] isa AbstractFloat

    val = get_time_series_array(renewable, ts)
    @test val isa TimeSeries.TimeArray
    val = get_time_series_timestamps(renewable, ts)
    @test val isa Array
    @test val[1] isa Dates.DateTime
    val = get_time_series_values(renewable, ts)
    @test val isa Array
    @test val[1] isa AbstractFloat

    PSIP.clear_time_series!(p_5bus)
    @test length(collect(get_time_series_multiple(p_5bus))) == 0
    @test IS.get_internal(p_5bus) isa IS.InfrastructureSystemsInternal
end

@testset "Test get_technologies filter_func" begin
    port = build_portfolio()
    tech = first(get_technologies(SupplyTechnology{ThermalStandard}, port))
    name = PSIP.get_name(tech)
    technologies = get_technologies(SupplyTechnology{ThermalStandard}, port) do tech
        PSIP.get_name(tech) == name && PSIP.get_available(tech)
    end

    @test length(technologies) == 1 && PSIP.get_name(first(technologies)) == name
end

@testset "Test portfolio name and description" begin
    name = "test_portfolio"
    description = "a system description"
    port = Portfolio()
    @test PSIP.get_name(port) === nothing
    @test PSIP.get_description(port) === nothing
    PSIP.set_name!(port, name)
    PSIP.set_description!(port, description)

    port = Portfolio(; name=name, description=description)
    @test PSIP.get_name(port) == name
    @test PSIP.get_description(port) == description
end

@testset "Test Portfolio constructors and financial accessors" begin
    base_system = PSY.System(100.0)

    port_default = Portfolio()
    @test PSIP.get_aggregation(port_default) == PSIP.DEFAULT_AGGREGATION
    @test PSIP.get_base_system(port_default) isa PSY.System
    @test IS.get_internal(port_default) isa IS.InfrastructureSystemsInternal
    @test PSIP.get_ext(port_default) isa Dict

    port_agg = Portfolio(PSY.LoadZone)
    @test PSIP.get_aggregation(port_agg) == PSY.LoadZone

    port_base = Portfolio(base_system)
    @test PSIP.get_base_system(port_base) === base_system

    port_fin = Portfolio(2025, 0.07, 0.02, 0.05)
    @test PSIP.get_base_year(port_fin) == 2025
    @test PSIP.get_discount_rate(port_fin) == 0.07
    @test PSIP.get_inflation_rate(port_fin) == 0.02
    @test PSIP.get_interest_rate(port_fin) == 0.05

    PSIP.set_base_year!(port_fin, 2030)
    PSIP.set_discount_rate!(port_fin, 0.08)
    PSIP.set_inflation_rate!(port_fin, 0.03)
    PSIP.set_interest_rate!(port_fin, 0.06)
    @test PSIP.get_base_year(port_fin) == 2030
    @test PSIP.get_discount_rate(port_fin) == 0.08
    @test PSIP.get_inflation_rate(port_fin) == 0.03
    @test PSIP.get_interest_rate(port_fin) == 0.06

    schedule = InvestmentScheduleResults(
        Dict{Int, Dict{Tuple{Type{<:Technology}, String}, Float64}}(),
    )
    PSIP.set_investment_schedule!(port_fin, schedule)
    @test PSIP.get_investment_schedule(port_fin) === schedule

    replacement_base = PSY.System(100.0)
    PSIP.set_base_system!(port_fin, replacement_base)
    @test PSIP.get_base_system(port_fin) === replacement_base

    port_full = Portfolio(PSY.LoadZone, base_system, 2024, 0.06, 0.02, 0.04)
    @test PSIP.get_aggregation(port_full) == PSY.LoadZone
    @test PSIP.get_base_system(port_full) === base_system
    @test PSIP.get_base_year(port_full) == 2024

    port_agg_fin = Portfolio(PSY.LoadZone, 2022, 0.05, 0.02, 0.03)
    @test PSIP.get_aggregation(port_agg_fin) == PSY.LoadZone
    @test PSIP.get_base_year(port_agg_fin) == 2022
end

@testset "Test technology attach/remove helpers" begin
    port = build_portfolio()
    thermal = first(get_technologies(SupplyTechnology{ThermalStandard}, port))
    thermal_name = PSIP.get_name(thermal)

    @test PSIP.is_attached(thermal, port)
    @test PSIP.is_attached(typeof(thermal), thermal_name, port)

    # UUID-based lookups
    uuid = IS.get_uuid(thermal)
    @test PSIP.get_technology(port, uuid) === thermal
    @test PSIP.get_technology(port, string(uuid)) === thermal

    # throw_if_not_attached should throw once removed
    PSIP.remove_technology!(port, thermal)
    @test !PSIP.is_attached(typeof(thermal), thermal_name, port)
    @test_throws ArgumentError PSIP.throw_if_not_attached(thermal, port)
end

@testset "Test iterate and bulk removal helpers" begin
    port = build_portfolio()

    @test !isempty(collect(PSIP.iterate_technologies(port)))

    removed_ds = PSIP.remove_technologies!(port, DemandSideTechnology{PSY.PowerLoad})
    @test !isempty(removed_ds)
    @test isempty(collect(PSIP.get_technologies(DemandSideTechnology{PSY.PowerLoad}, port)))

    removed_supply = PSIP.remove_technologies!(
        x -> occursin("cheap", PSIP.get_name(x)),
        port,
        SupplyTechnology{PSY.ThermalStandard},
    )
    @test length(removed_supply) == 1

    PSIP.clear_technologies!(port)
    @test isempty(collect(PSIP.iterate_technologies(port)))
end

@testset "Test region and requirement APIs" begin
    port = Portfolio()

    zone = Zone(name="zone_test", id=1)
    node = Node(name="node_test", id=2)
    PSIP.add_region!(port, zone)
    PSIP.add_region!(port, node)

    regions = collect(PSIP.get_regions(RegionTopology, port))
    @test length(regions) == 2
    @test PSIP.get_region(Zone, port, "zone_test") === zone
    @test PSIP.get_region(Node, port, "node_test") === node

    req = CarbonTax(name="req_test", id=1, available=true)
    PSIP.add_requirement!(port, req)
    @test PSIP.get_requirement(CarbonTax, port, "req_test") === req
    @test length(collect(PSIP.get_requirements(CarbonTax, port))) == 1
    @test length(collect(PSIP.get_requirements(port))) == 1
end

@testset "Test contributing technologies" begin
    port = build_portfolio()
    tech = first(get_technologies(SupplyTechnology{ThermalStandard}, port))
    req = CarbonTax(name="req_contrib", id=777, available=true)
    set_requirements!(tech, [req])

    contributors = PSIP.get_contributing_technologies(port, req)
    @test length(contributors) == 1
    @test contributors[1] === tech
end

@testset "Test time series wrappers" begin
    port = build_portfolio()
    renewable = first(get_technologies(SupplyTechnology{RenewableDispatch}, port))

    @test PSIP.get_compression_settings(port) isa IS.CompressionSettings
    @test !isempty(PSIP.get_time_series_resolution(port))
    @test PSIP.get_time_series_counts(port) isa IS.TimeSeriesCounts
    @test !isempty(collect(IS.get_time_series_multiple(port)))

    PSIP.remove_time_series!(port, SingleTimeSeries, renewable, "ops_variable_cap_factor")
    @test_throws IS.ArgumentError get_time_series(
        SingleTimeSeries,
        renewable,
        "ops_variable_cap_factor";
        year="2024",
        rep_day=1,
    )
end

@testset "Test supplemental attribute APIs" begin
    port = build_portfolio()
    zone = first(get_regions(Zone, port))

    attr = TopologyMapping(id=2, buses=["b1", "b2"])
    PSIP.add_supplemental_attribute!(port, zone, attr)

    attrs_on_component = PSIP.get_supplemental_attributes(TopologyMapping, zone)
    @test length(attrs_on_component) == 1
    @test attrs_on_component[1] === attr

    attrs_on_port = PSIP.get_supplemental_attributes(TopologyMapping, port)
    @test length(attrs_on_port) >= 1

    attr_uuid = IS.get_uuid(attr)
    @test PSIP.get_supplemental_attribute(port, attr_uuid) === attr

    PSIP.remove_supplemental_attribute!(port, zone, attr)
    @test isempty(PSIP.get_supplemental_attributes(TopologyMapping, zone))

    attr3 = TopologyMapping(id=4, buses=["b4"])
    PSIP.add_supplemental_attribute!(port, zone, attr3)
    PSIP.remove_supplemental_attributes!(TopologyMapping, port)
    @test isempty(PSIP.get_supplemental_attributes(TopologyMapping, port))
end
