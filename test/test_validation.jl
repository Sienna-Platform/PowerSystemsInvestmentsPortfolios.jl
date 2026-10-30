@testset "Storage validation" begin
    port = Portfolio()
    attached_region = Zone(; name="attached_region", id=1)
    add_region!(port, attached_region)

    financial_data = TechnologyFinancialData(;
        capital_recovery_period=20,
        technology_base_year=2030,
        debt_fraction=0.4,
        debt_rate=0.05,
        return_on_equity=0.12,
        tax_rate=0.21,
    )
    storage_defaults = (;
        available=true,
        power_systems_type="EnergyReservoirStorage",
        storage_tech=StorageTech.LIB,
        financial_data,
    )

    valid_storage = StorageTechnology{PSY.EnergyReservoirStorage}(;
        storage_defaults...,
        name="valid_storage",
        id=1,
        region=RegionTopology[attached_region],
    )
    add_technology!(port, valid_storage)
    @test get_technology(typeof(valid_storage), port, "valid_storage") === valid_storage

    invalid_duration = StorageTechnology{PSY.EnergyReservoirStorage}(;
        storage_defaults...,
        name="invalid_duration",
        id=2,
        region=RegionTopology[attached_region],
        duration_limits=(min=4.0, max=2.0),
    )
    @test_logs(
        (:error, r"Storage duration limits must be in ascending order"),
        min_level = Logging.Error,
        @test_throws(IS.InvalidValue, add_technology!(port, invalid_duration)),
    )
    @test isnothing(get_technology(typeof(invalid_duration), port, "invalid_duration"))

    detached_region = Zone(; name="detached_region", id=2)
    invalid_region = StorageTechnology{PSY.EnergyReservoirStorage}(;
        storage_defaults...,
        name="invalid_region",
        id=3,
        region=RegionTopology[detached_region],
    )
    @test_logs(
        (:error, r"region that is not attached to the portfolio"),
        min_level = Logging.Error,
        @test_throws(IS.InvalidValue, add_technology!(port, invalid_region)),
    )
    @test isnothing(get_technology(typeof(invalid_region), port, "invalid_region"))

    skipped_invalid = StorageTechnology{PSY.EnergyReservoirStorage}(;
        storage_defaults...,
        name="skipped_invalid",
        id=4,
        region=RegionTopology[attached_region],
        duration_limits=(min=4.0, max=2.0),
    )
    add_technology!(port, skipped_invalid; skip_validation=true)
    @test get_technology(typeof(skipped_invalid), port, "skipped_invalid") ===
          skipped_invalid
end

@testset "Technology checking" begin
    port = build_portfolio()
    supply = first(get_technologies(SupplyTechnology, port))
    set_lifetime!(supply, 0)

    @test_logs(
        (:error, r"Technology lifetime must be finite and positive"),
        min_level = Logging.Error,
        @test_throws(IS.InvalidValue, check_technology(port, supply)),
    )
    @test_logs(
        (:error, r"Technology lifetime must be finite and positive"),
        min_level = Logging.Error,
        @test_throws(IS.InvalidValue, check_technologies(port, [supply])),
    )
end

@testset "Supply validation" begin
    supply = first(get_technologies(SupplyTechnology, build_portfolio()))

    capacity_limits = get_capacity_limits(supply)
    set_capacity_limits!(supply, (min=-1.0, max=capacity_limits.max))
    @test_logs(
        (:error, r"Supply capacity limits must be nonnegative"),
        min_level = Logging.Error,
        @test(!validate_technology(supply)),
    )
    set_capacity_limits!(supply, capacity_limits)

    unit_size = get_unit_size(supply)
    set_unit_size!(supply, -1.0)
    @test_logs(
        (:error, r"Supply unit size must be finite and nonnegative"),
        min_level = Logging.Error,
        @test(!validate_technology(supply)),
    )
    set_unit_size!(supply, unit_size)

    min_generation_fraction = get_min_generation_fraction(supply)
    set_min_generation_fraction!(supply, 1.1)
    @test_logs(
        (:error, r"Supply minimum generation fraction must be in \[0, 1\]"),
        min_level = Logging.Error,
        @test(!validate_technology(supply)),
    )
    set_min_generation_fraction!(supply, min_generation_fraction)
end

@testset "Colocated supply-storage validation" begin
    port = Portfolio()
    attached_region = Zone(; name="colocated_region", id=20)
    add_region!(port, attached_region)

    financial_data = TechnologyFinancialData(;
        capital_recovery_period=20,
        technology_base_year=2030,
        debt_fraction=0.4,
        debt_rate=0.05,
        return_on_equity=0.12,
        tax_rate=0.21,
    )
    colocated = ColocatedSupplyStorageTechnology{PSY.RenewableDispatch}(;
        name="valid_colocated",
        id=20,
        operation_costs_inverter=StorageCost(),
        financial_data,
        inverter_efficiency=0.96,
        power_systems_type="RenewableDispatch",
        inverter_supply_ratio=1.0,
        capital_costs_inverter=LinearCurve(0.0),
        available=true,
        region=RegionTopology[attached_region],
    )
    add_technology!(port, colocated)
    @test get_technology(typeof(colocated), port, "valid_colocated") === colocated

    duration_limits = get_duration_limits(colocated)
    set_duration_limits!(colocated, (min=4.0, max=2.0))
    @test_logs(
        (:error, r"Colocated storage duration limits must be in ascending order"),
        min_level = Logging.Error,
        @test(!validate_technology(colocated)),
    )
    set_duration_limits!(colocated, duration_limits)

    set_min_inverter_capacity!(colocated, 2.0)
    set_max_inverter_capacity!(colocated, 1.0)
    @test_logs(
        (:error, r"Colocated inverter capacity limits must be in ascending order"),
        min_level = Logging.Error,
        @test(!validate_technology(colocated)),
    )
end

@testset "Demand region validation" begin
    port = Portfolio()
    attached_region = Zone(; name="demand_region", id=10)
    second_region = Zone(; name="second_demand_region", id=11)
    add_region!(port, attached_region)
    add_region!(port, second_region)

    valid_demand = DemandRequirement{PSY.PowerLoad}(;
        available=true,
        name="valid_demand",
        id=10,
        power_systems_type="PowerLoad",
        value_of_lost_load=1000.0,
        region=RegionTopology[attached_region, second_region],
    )
    add_technology!(port, valid_demand)
    @test get_technology(typeof(valid_demand), port, "valid_demand") === valid_demand

    duplicate_region_demand = DemandRequirement{PSY.PowerLoad}(;
        available=true,
        name="duplicate_region_demand",
        id=11,
        power_systems_type="PowerLoad",
        value_of_lost_load=1000.0,
        region=RegionTopology[attached_region, attached_region],
    )
    @test_logs(
        (:error, r"Technology contains duplicate region references"),
        min_level = Logging.Error,
        @test_throws(IS.InvalidValue, add_technology!(port, duplicate_region_demand),),
    )
    @test isnothing(
        get_technology(typeof(duplicate_region_demand), port, "duplicate_region_demand"),
    )

    invalid_demand = DemandRequirement{PSY.PowerLoad}(;
        available=true,
        name="invalid_demand",
        id=12,
        power_systems_type="PowerLoad",
        value_of_lost_load=1000.0,
        region=RegionTopology[],
    )
    @test_logs(
        (:error, r"Technology must reference at least one region"),
        min_level = Logging.Error,
        @test_throws(IS.InvalidValue, add_technology!(port, invalid_demand)),
    )
    @test isnothing(get_technology(typeof(invalid_demand), port, "invalid_demand"))
end

@testset "Region ID uniqueness" begin
    port = Portfolio()
    attached_region = Zone(; name="attached_region", id=101)
    add_region!(port, attached_region)

    duplicate_region_id = Node(; name="duplicate_region_id", id=101)
    @test_logs(
        (:error, r"Region ID is already attached to the portfolio"),
        min_level = Logging.Error,
        @test_throws(IS.InvalidValue, add_region!(port, duplicate_region_id)),
    )
    @test isnothing(get_region(Node, port, "duplicate_region_id"))
end

@testset "Transport validation" begin
    port = Portfolio()
    start_zone = Zone(; name="start_zone", id=101)
    end_zone = Zone(; name="end_zone", id=102)
    start_node = Node(; name="start_node", id=201)
    end_node = Node(; name="end_node", id=202)
    foreach(
        region -> add_region!(port, region),
        (start_zone, end_zone, start_node, end_node),
    )

    financial_data = TechnologyFinancialData(;
        capital_recovery_period=20,
        technology_base_year=2030,
        debt_fraction=0.4,
        debt_rate=0.05,
        return_on_equity=0.12,
        tax_rate=0.21,
    )
    transport_defaults = (; available=true, power_systems_type="ACBranch", financial_data)

    valid_transport = AggregateTransportTechnology{PSY.ACBranch}(;
        transport_defaults...,
        name="valid_transport",
        id=301,
        start_region=start_zone,
        end_region=end_zone,
        capacity_limits=(min=0.0, max=100.0),
        unit_size=1.0,
        line_loss=0.05,
    )
    add_technology!(port, valid_transport)
    @test get_technology(typeof(valid_transport), port, "valid_transport") ===
          valid_transport

    invalid_capacity = AggregateTransportTechnology{PSY.ACBranch}(;
        transport_defaults...,
        name="invalid_capacity",
        id=302,
        start_region=start_zone,
        end_region=end_zone,
        capacity_limits=(min=100.0, max=50.0),
    )
    @test_logs(
        (:error, r"Transport capacity limits must be in ascending order"),
        min_level = Logging.Error,
        @test_throws(IS.InvalidValue, add_technology!(port, invalid_capacity)),
    )

    invalid_unit_size = NodalACTransportTechnology{PSY.ACBranch}(;
        transport_defaults...,
        name="invalid_unit_size",
        id=303,
        start_node,
        end_node,
        unit_size=0.0,
    )
    @test_logs(
        (:error, r"Transport unit size must be finite and positive"),
        min_level = Logging.Error,
        @test_throws(IS.InvalidValue, add_technology!(port, invalid_unit_size)),
    )

    invalid_line_loss = AggregateTransportTechnology{PSY.ACBranch}(;
        transport_defaults...,
        name="invalid_line_loss",
        id=304,
        start_region=start_zone,
        end_region=end_zone,
        line_loss=1.1,
    )
    @test_logs(
        (:error, r"Aggregate transport line loss must be in \[0, 1\]"),
        min_level = Logging.Error,
        @test_throws(IS.InvalidValue, add_technology!(port, invalid_line_loss)),
    )

    detached_node = Node(; name="detached_node", id=203)
    invalid_endpoint = NodalHVDCTransportTechnology{PSY.ACBranch}(;
        transport_defaults...,
        name="invalid_endpoint",
        id=305,
        start_node,
        end_node=detached_node,
    )
    @test_logs(
        (:error, r"Transport endpoint is not attached to the portfolio"),
        min_level = Logging.Error,
        @test_throws(IS.InvalidValue, add_technology!(port, invalid_endpoint)),
    )
end
