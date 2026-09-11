@testset "Storage validation" begin
    port = Portfolio()
    attached_region = PSY.Area(; name="attached_region", base_power=100.0)
    add_topology!(port, attached_region)

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
        region=PSY.Topology[attached_region],
    )
    add_technology!(port, valid_storage)
    @test get_technology(typeof(valid_storage), port, "valid_storage") === valid_storage

    invalid_duration = StorageTechnology{PSY.EnergyReservoirStorage}(;
        storage_defaults...,
        name="invalid_duration",
        region=PSY.Topology[attached_region],
        duration_limits=(min=4.0, max=2.0),
    )
    @test_logs(
        (:error, r"Storage duration limits must be in ascending order"),
        min_level = Logging.Error,
        @test_throws(IS.InvalidValue, add_technology!(port, invalid_duration)),
    )
    @test isnothing(get_technology(typeof(invalid_duration), port, "invalid_duration"))

    detached_region = PSY.Area(; name="detached_region", base_power=100.0)
    invalid_region = StorageTechnology{PSY.EnergyReservoirStorage}(;
        storage_defaults...,
        name="invalid_region",
        region=PSY.Topology[detached_region],
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
        region=PSY.Topology[attached_region],
        duration_limits=(min=4.0, max=2.0),
    )
    add_technology!(port, skipped_invalid; skip_validation=true)
    @test get_technology(typeof(skipped_invalid), port, "skipped_invalid") ===
          skipped_invalid
end

@testset "Technology checking" begin
    port = build_portfolio()
    supply = first(get_technologies(SupplyTechnology, port))
    set_lifetime!(supply, 0, IS.NU)

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

    capacity_limits = get_capacity_limits(supply, IS.NU)
    set_capacity_limits!(supply, (min=-1.0, max=capacity_limits.max), IS.NU)
    @test_logs(
        (:error, r"Supply capacity limits must be nonnegative"),
        min_level = Logging.Error,
        @test(!validate_technology(supply)),
    )
    set_capacity_limits!(supply, capacity_limits, IS.NU)

    unit_size = get_unit_size(supply, IS.NU)
    set_unit_size!(supply, -1.0, IS.NU)
    @test_logs(
        (:error, r"Supply unit size must be finite and nonnegative"),
        min_level = Logging.Error,
        @test(!validate_technology(supply)),
    )
    set_unit_size!(supply, unit_size, IS.NU)

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
    attached_region = PSY.Area(; name="colocated_region", base_power=100.0)
    add_topology!(port, attached_region)

    financial_data = TechnologyFinancialData(;
        capital_recovery_period=20,
        technology_base_year=2030,
        debt_fraction=0.4,
        debt_rate=0.05,
        return_on_equity=0.12,
        tax_rate=0.21,
    )
    supply_ref = SupplyTechnology{PSY.RenewableDispatch}(;
        name="colocated_supply_ref",
        available=true,
        power_systems_type="RenewableDispatch",
        financial_data=financial_data,
        region=PSY.Topology[attached_region],
    )
    storage_ref = StorageTechnology{PSY.EnergyReservoirStorage}(;
        name="colocated_storage_ref",
        available=true,
        power_systems_type="EnergyReservoirStorage",
        storage_tech=StorageTech.OTHER_CHEM,
        financial_data=financial_data,
        region=PSY.Topology[attached_region],
    )
    add_technology!(port, supply_ref)
    add_technology!(port, storage_ref)

    colocated = ColocatedSupplyStorageTechnology{PSY.RenewableDispatch}(;
        name="valid_colocated",
        operation_costs_inverter=CostCurve(LinearCurve(0.0)),
        financial_data,
        inverter_efficiency=0.96,
        power_systems_type="RenewableDispatch",
        inverter_supply_ratio=1.0,
        capital_costs_inverter=PSIP.CapitalCost(LinearCurve(0.0), 0.0),
        available=true,
        region=PSY.Topology[attached_region],
        supply_technology=supply_ref,
        storage_technology=storage_ref,
    )
    add_technology!(port, colocated)
    @test get_technology(typeof(colocated), port, "valid_colocated") === colocated

    inverter_capacity_limits = get_inverter_capacity_limits(colocated, IS.NU)
    set_inverter_capacity_limits!(colocated, (min=2.0, max=1.0), IS.NU)
    @test_logs(
        (:error, r"Colocated inverter capacity limits must be in ascending order"),
        min_level = Logging.Error,
        @test(!validate_technology(colocated)),
    )
    set_inverter_capacity_limits!(colocated, inverter_capacity_limits, IS.NU)

    set_inverter_efficiency!(colocated, 1.1)
    @test_logs(
        (:error, r"Colocated inverter efficiency must be in \(0, 1\]"),
        min_level = Logging.Error,
        @test(!validate_technology(colocated)),
    )
    set_inverter_efficiency!(colocated, 0.96)

    set_inverter_supply_ratio!(colocated, 0.0)
    @test_logs(
        (:error, r"Colocated inverter supply ratio must be finite and positive"),
        min_level = Logging.Error,
        @test(!validate_technology(colocated)),
    )
end

@testset "Demand region validation" begin
    port = Portfolio()
    attached_region = PSY.Area(; name="demand_region", base_power=100.0)
    second_region = PSY.Area(; name="second_demand_region", base_power=100.0)
    add_topology!(port, attached_region)
    add_topology!(port, second_region)

    valid_demand = DemandRequirement{PSY.PowerLoad}(;
        available=true,
        name="valid_demand",
        power_systems_type="PowerLoad",
        value_of_lost_load=1000.0,
        region=PSY.Topology[attached_region, second_region],
    )
    add_technology!(port, valid_demand)
    @test get_technology(typeof(valid_demand), port, "valid_demand") === valid_demand

    duplicate_region_demand = DemandRequirement{PSY.PowerLoad}(;
        available=true,
        name="duplicate_region_demand",
        power_systems_type="PowerLoad",
        value_of_lost_load=1000.0,
        region=PSY.Topology[attached_region, attached_region],
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
        power_systems_type="PowerLoad",
        value_of_lost_load=1000.0,
        region=PSY.Topology[],
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
    attached_region = PSY.Area(; name="attached_region", base_power=100.0)
    IS.set_id!(attached_region, 101)
    add_topology!(port, attached_region)

    duplicate_region_load_zone = PSY.LoadZone(;
        name="duplicate_region_load_zone",
        peak_active_power=0.0,
        peak_reactive_power=0.0,
        base_power=100.0,
    )
    duplicate_region_id = PSY.ACBus(;
        number=903,
        name="duplicate_region_id",
        available=true,
        bustype=PSY.ACBusTypes.PQ,
        angle=0.0,
        magnitude=1.0,
        voltage_limits=(min=0.9, max=1.1),
        base_voltage=138.0,
        area=attached_region,
        load_zone=duplicate_region_load_zone,
    )
    IS.set_id!(duplicate_region_id, 101)
    @test_logs(
        (:error, r"Region ID is already attached to the portfolio"),
        min_level = Logging.Error,
        @test_throws(IS.InvalidValue, add_topology!(port, duplicate_region_id)),
    )
    @test isnothing(get_region(PSY.ACBus, port, "duplicate_region_id"))
end

@testset "Transport validation" begin
    port = Portfolio()
    start_zone = PSY.Area(; name="start_zone", base_power=100.0)
    end_zone = PSY.Area(; name="end_zone", base_power=100.0)
    start_lz = PSY.LoadZone(;
        name="start_zone_lz",
        peak_active_power=0.0,
        peak_reactive_power=0.0,
        base_power=100.0,
    )
    end_lz = PSY.LoadZone(;
        name="end_zone_lz",
        peak_active_power=0.0,
        peak_reactive_power=0.0,
        base_power=100.0,
    )
    start_node = PSY.ACBus(;
        number=904,
        name="start_node",
        available=true,
        bustype=PSY.ACBusTypes.PQ,
        angle=0.0,
        magnitude=1.0,
        voltage_limits=(min=0.9, max=1.1),
        base_voltage=138.0,
        area=start_zone,
        load_zone=start_lz,
    )
    end_node = PSY.ACBus(;
        number=905,
        name="end_node",
        available=true,
        bustype=PSY.ACBusTypes.PQ,
        angle=0.0,
        magnitude=1.0,
        voltage_limits=(min=0.9, max=1.1),
        base_voltage=138.0,
        area=end_zone,
        load_zone=end_lz,
    )
    foreach(
        topology -> add_topology!(port, topology),
        (start_zone, end_zone, start_lz, end_lz, start_node, end_node),
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
        start_region=start_zone,
        end_region=end_zone,
        capacity_limits=(min=0.0, max=100.0),
        unit_size=1.0,
        line_loss=0.05,
        capital_costs=PSIP.CapitalCost(LinearCurve(0.0), 0.0),
    )
    add_technology!(port, valid_transport)
    @test get_technology(typeof(valid_transport), port, "valid_transport") ===
          valid_transport

    invalid_capacity = AggregateTransportTechnology{PSY.ACBranch}(;
        transport_defaults...,
        name="invalid_capacity",
        start_region=start_zone,
        end_region=end_zone,
        capacity_limits=(min=100.0, max=50.0),
        capital_costs=PSIP.CapitalCost(LinearCurve(0.0), 0.0),
    )
    @test_logs(
        (:error, r"Transport capacity limits must be in ascending order"),
        min_level = Logging.Error,
        @test_throws(IS.InvalidValue, add_technology!(port, invalid_capacity)),
    )

    invalid_unit_size = NodalACTransportTechnology{PSY.ACBranch}(;
        transport_defaults...,
        name="invalid_unit_size",
        start_node,
        end_node,
        unit_size=0.0,
        capital_costs=PSIP.CapitalCost(LinearCurve(0.0), 0.0),
    )
    @test_logs(
        (:error, r"Transport unit size must be finite and positive"),
        min_level = Logging.Error,
        @test_throws(IS.InvalidValue, add_technology!(port, invalid_unit_size)),
    )

    invalid_line_loss = AggregateTransportTechnology{PSY.ACBranch}(;
        transport_defaults...,
        name="invalid_line_loss",
        start_region=start_zone,
        end_region=end_zone,
        line_loss=1.1,
        capital_costs=PSIP.CapitalCost(LinearCurve(0.0), 0.0),
    )
    @test_logs(
        (:error, r"Aggregate transport line loss must be in \[0, 1\]"),
        min_level = Logging.Error,
        @test_throws(IS.InvalidValue, add_technology!(port, invalid_line_loss)),
    )

    detached_lz = PSY.LoadZone(;
        name="detached_node_lz",
        peak_active_power=0.0,
        peak_reactive_power=0.0,
        base_power=100.0,
    )
    detached_node = PSY.ACBus(;
        number=906,
        name="detached_node",
        available=true,
        bustype=PSY.ACBusTypes.PQ,
        angle=0.0,
        magnitude=1.0,
        voltage_limits=(min=0.9, max=1.1),
        base_voltage=138.0,
        area=end_zone,
        load_zone=detached_lz,
    )
    invalid_endpoint = NodalHVDCTransportTechnology{PSY.ACBranch}(;
        transport_defaults...,
        name="invalid_endpoint",
        start_node,
        end_node=detached_node,
        capital_costs=PSIP.CapitalCost(LinearCurve(0.0), 0.0),
    )
    @test_logs(
        (:error, r"Transport endpoint is not attached to the portfolio"),
        min_level = Logging.Error,
        @test_throws(IS.InvalidValue, add_technology!(port, invalid_endpoint)),
    )
end
