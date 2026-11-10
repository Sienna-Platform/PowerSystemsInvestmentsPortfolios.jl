tech_financials() = TechnologyFinancialData(;
    capital_recovery_period=30,
    technology_base_year=2025,
    debt_fraction=0.5,
    debt_rate=0.07,
    return_on_equity=0.1,
    tax_rate=0.257,
)

supply() = SupplyTechnology{PSY.ThermalStandard}(;
    name="supply",
    available=true,
    power_systems_type=string(PSY.ThermalStandard),
    financial_data=tech_financials(),
    capital_costs=PSIP.CapitalCost(LinearCurve(10000.0), 0.0),
    operation_costs=ThermalGenerationCost(CostCurve(LinearCurve(10.0)), 100.0, 0.0, 0.0),
    unit_size=100.0,
    capacity_limits=(min=0.0, max=500.0),
    ramp_limits=(up=1.0, down=2.0),
    time_limits=(up=600.0, down=1200.0),
    start_fuel_mmbtu_per_mw=5.0,
    lifetime=30,
    outage_factor=(planned=0.0, forced=0.0),
)

storage() = StorageTechnology{PSY.EnergyReservoirStorage}(;
    name="storage",
    available=true,
    power_systems_type=string(PSY.EnergyReservoirStorage),
    financial_data=tech_financials(),
    unit_size_charge=10.0,
    unit_size_discharge=20.0,
    unit_size_energy=200.0,
    capacity_limits_charge=(min=0.0, max=100.0),
    capacity_limits_discharge=(min=0.0, max=200.0),
    capacity_limits_energy=(min=0.0, max=1000.0),
    duration_limits=(min=60.0, max=600.0),
    capital_costs=PSIP.StorageCapitalCost(
        LinearCurve(1000.0),
        LinearCurve(2000.0),
        LinearCurve(3000.0),
        0.0,
    ),
    operation_costs=StorageCost(),
    storage_tech=StorageTech.LIB,
    lifetime=15,
)

agg_transport() = AggregateTransportTechnology{PSY.ACBranch}(;
    name="agg",
    available=true,
    power_systems_type=string(PSY.ACBranch),
    start_region=PSY.Area(; input_basis=u"CU", name="z1", base_power=100.0),
    end_region=PSY.Area(; input_basis=u"CU", name="z2", base_power=100.0),
    financial_data=tech_financials(),
    capacity_limits=(min=0.0, max=800.0),
    unit_size=40.0,
    capital_costs=PSIP.CapitalCost(LinearCurve(500.0), 0.0),
)

acline() = NodalACTransportTechnology{PSY.ACBranch}(;
    name="ac",
    available=true,
    power_systems_type=string(PSY.ACBranch),
    start_node=PSY.ACBus(;
        input_basis=u"CU",
        number=911,
        name="n1",
        available=true,
        bustype=PSY.ACBusTypes.PQ,
        angle=0.0,
        magnitude=1.0,
        voltage_limits=(min=0.9, max=1.1),
        base_voltage=138.0,
        area=PSY.Area(; input_basis=u"CU", name="n1_area", base_power=100.0),
        load_zone=PSY.LoadZone(;
            input_basis=u"CU",
            name="n1_lz",
            peak_active_power=0.0,
            peak_reactive_power=0.0,
            base_power=100.0,
        ),
    ),
    end_node=PSY.ACBus(;
        input_basis=u"CU",
        number=912,
        name="n2",
        available=true,
        bustype=PSY.ACBusTypes.PQ,
        angle=0.0,
        magnitude=1.0,
        voltage_limits=(min=0.9, max=1.1),
        base_voltage=138.0,
        area=PSY.Area(; input_basis=u"CU", name="n2_area", base_power=100.0),
        load_zone=PSY.LoadZone(;
            input_basis=u"CU",
            name="n2_lz",
            peak_active_power=0.0,
            peak_reactive_power=0.0,
            base_power=100.0,
        ),
    ),
    financial_data=tech_financials(),
    capacity_limits=(min=0.0, max=600.0),
    unit_size=50.0,
    capital_costs=PSIP.CapitalCost(LinearCurve(1000.0), 0.0),
    resistance=2.0,
    reactance=3.0,
    voltage=230.0,
)

hvdc() = NodalHVDCTransportTechnology{PSY.ACBranch}(;
    name="hvdc",
    available=true,
    power_systems_type=string(PSY.ACBranch),
    start_node=PSY.ACBus(;
        input_basis=u"CU",
        number=913,
        name="n3",
        available=true,
        bustype=PSY.ACBusTypes.PQ,
        angle=0.0,
        magnitude=1.0,
        voltage_limits=(min=0.9, max=1.1),
        base_voltage=138.0,
        area=PSY.Area(; input_basis=u"CU", name="n3_area", base_power=100.0),
        load_zone=PSY.LoadZone(;
            input_basis=u"CU",
            name="n3_lz",
            peak_active_power=0.0,
            peak_reactive_power=0.0,
            base_power=100.0,
        ),
    ),
    end_node=PSY.ACBus(;
        input_basis=u"CU",
        number=914,
        name="n4",
        available=true,
        bustype=PSY.ACBusTypes.PQ,
        angle=0.0,
        magnitude=1.0,
        voltage_limits=(min=0.9, max=1.1),
        base_voltage=138.0,
        area=PSY.Area(; input_basis=u"CU", name="n4_area", base_power=100.0),
        load_zone=PSY.LoadZone(;
            input_basis=u"CU",
            name="n4_lz",
            peak_active_power=0.0,
            peak_reactive_power=0.0,
            base_power=100.0,
        ),
    ),
    financial_data=tech_financials(),
    capacity_limits=(min=0.0, max=700.0),
    unit_size=60.0,
    capital_costs=PSIP.CapitalCost(LinearCurve(1500.0), 0.0),
)

demand_req() = ProjectedDemand{PSY.PowerLoad}(;
    name="dreq",
    available=true,
    power_systems_type=string(PSY.PowerLoad),
    peak_demand_mw=300.0,
    value_of_lost_load=1e5,
    curtailment_cost=LinearCurve(50.0),
    shift_cost=LinearCurve(12.0),
    max_demand_advance=240.0,
    max_demand_delay=360.0,
)

demand_side() = DemandSideTechnology{PSY.PowerLoad}(;
    name="demand_side",
    available=true,
    power_systems_type=string(PSY.PowerLoad),
    capacity_limits=(min=0.0, max=250.0),
    # USD/t, not derived: no valid MMBtu->t factor exists (fuel-dependent). Chosen
    # to be plausible for a per-tonne hydrogen output price; see report.
    price_per_unit=LinearCurve(3000.0),
    financial_data=tech_financials(),
)

carbon_caps() =
    CarbonCaps(; name="carbon_caps", available=true, max_tons_mwh=2.0e-6, max_mtons=50.0)

carbon_tax() = CarbonTax(; name="carbon_tax", available=true, tax_dollars_per_ton=50.0)

max_capacity_req() =
    MaximumCapacityRequirements(; name="max_cap", available=true, max_capacity_mw=400.0)

min_capacity_req() =
    MinimumCapacityRequirements(; name="min_cap", available=true, min_capacity_mw=100.0)

colocated() = ColocatedSupplyStorageTechnology{PSY.ThermalStandard}(;
    name="colocated",
    power_systems_type=string(PSY.ThermalStandard),
    available=true,
    financial_data=tech_financials(),
    capital_costs_inverter=PSIP.CapitalCost(LinearCurve(1300.0), 0.0),
    operation_costs_inverter=CostCurve(LinearCurve(6.0)),
    inverter_capacity_limits=(min=50.0, max=600.0),
    inverter_efficiency=0.95,
    inverter_supply_ratio=1.2,
    supply_technology=supply(),
    storage_technology=storage(),
)

# ---------------------------------------------------------------------------
# Reusable field-check helpers. `get` / `set` are closures over the component.
# ---------------------------------------------------------------------------
conversion_unit(x, y) = (x_unit=x, y_unit=y)
get_proportional(vc) = vc.function_data.proportional_term

# Scalar field: value stored in `nat`, retrievable in `alt` scaled by `ratio`.
function check_scalar(get, set, nat, alt; base, ratio)
    @test get(nat) ≈ base
    @test get(alt) ≈ base * ratio
    set(base * ratio, alt)          # round trip: provide in alt units
    @test get(nat) ≈ base
end

function check_minmax(get, set, nat, alt; mn, mx, ratio)
    r = get(nat)
    @test r.min ≈ mn && r.max ≈ mx
    r2 = get(alt)
    @test r2.min ≈ mn * ratio && r2.max ≈ mx * ratio
    set((min=mn * ratio, max=mx * ratio), alt)
    r3 = get(nat)
    @test r3.min ≈ mn && r3.max ≈ mx
end

function check_updown(get, set, nat, alt; up, down, ratio)
    r = get(nat)
    @test r.up ≈ up && r.down ≈ down
    r2 = get(alt)
    @test r2.up ≈ up * ratio && r2.down ≈ down * ratio
    set((up=up * ratio, down=down * ratio), alt)
    r3 = get(nat)
    @test r3.up ≈ up && r3.down ≈ down
end

function check_valuecurve(get, set, nat, alt; prop, ratio)
    @test get_proportional(get(nat)) ≈ prop
    @test get_proportional(get(alt)) ≈ prop * ratio
    set(LinearCurve(prop * ratio), alt)
    @test get_proportional(get(nat)) ≈ prop
end

@testset "natural_unit definitions" begin
    @test PSIP.natural_unit(PSIP.POWER) == u"MW"
    @test PSIP.natural_unit(PSIP.ENERGY) == u"MW" * u"hr"
    @test PSIP.natural_unit(PSIP.VOLTAGE) == u"kV"
    @test PSIP.natural_unit(PSIP.IMPEDANCE) == u"Ω"
    @test PSIP.natural_unit(PSIP.OPS_TIME) == u"hr"
    @test PSIP.natural_unit(PSIP.INV_TIME) == u"yr"
    @test PSIP.natural_unit(PSIP.MINUTE_TIME) == u"minute"
    @test PSIP.natural_unit(PSIP.COST) == USD
    @test PSIP.natural_unit(PSIP.FUEL) == MMBtu
    # Custom composite units added on this branch.
    @test PSIP.natural_unit(PSIP.EMISSIONS_MASS) == Mt
    @test PSIP.natural_unit(PSIP.EMISSIONS_COST) == USD / tonne
    @test PSIP.natural_unit(PSIP.EMISSIONS_FUEL) == tonne / MMBtu
    @test PSIP.natural_unit(PSIP.EMISSIONS_ENERGY) == Mt / (u"MW" * u"hr")
    @test PSIP.natural_unit(PSIP.RAMPING) == u"MW" / u"minute"
    @test PSIP.natural_unit(PSIP.FUEL_CONSUMPTION_POWER) == MMBtu / u"MW"

    # Compound (x_unit, y_unit) categories.
    @test PSIP.natural_unit(PSIP.POWER_COST) == (x_unit=u"MW", y_unit=USD)
    @test PSIP.natural_unit(PSIP.ENERGY_COST) == (x_unit=u"MW" * u"hr", y_unit=USD)
    @test PSIP.natural_unit(PSIP.FUEL_COST) == (x_unit=MMBtu, y_unit=USD)

    # _unit_category resolves the schema tokens used by the generated code.
    @test PSIP._unit_category(Val(:mw)) === PSIP.POWER
    @test PSIP._unit_category(Val(:mwh)) === PSIP.ENERGY
    @test PSIP._unit_category(Val(:kv)) === PSIP.VOLTAGE
    @test PSIP._unit_category(Val(:ohm)) === PSIP.IMPEDANCE
    @test PSIP._unit_category(Val(:hr)) === PSIP.OPS_TIME
    @test PSIP._unit_category(Val(:min)) === PSIP.MINUTE_TIME
    @test PSIP._unit_category(Val(:yr)) === PSIP.INV_TIME
    @test PSIP._unit_category(Val(:mw_per_min)) === PSIP.RAMPING
    @test PSIP._unit_category(Val(:mmbtu_per_mw)) === PSIP.FUEL_CONSUMPTION_POWER
    @test PSIP._unit_category(Val(:usd_per_mw)) === PSIP.POWER_COST
    @test PSIP._unit_category(Val(:usd_per_mwh)) === PSIP.ENERGY_COST
    @test PSIP._unit_category(Val(:usd_per_mmbtu)) === PSIP.FUEL_COST
    @test PSIP._unit_category(Val(:mt)) === PSIP.EMISSIONS_MASS
    @test PSIP._unit_category(Val(:usd_per_t)) === PSIP.EMISSIONS_COST
    @test PSIP._unit_category(Val(:t_per_mmbtu)) === PSIP.EMISSIONS_FUEL
    @test PSIP._unit_category(Val(:mt_per_mwh)) === PSIP.EMISSIONS_ENERGY
end

@testset "scalar conversions" begin
    t = supply()
    @test ustrip(PSIP._natural_unit_conversions(t, 1.0, u"MW", u"kW")) ≈ 1000.0
    @test ustrip(PSIP._natural_unit_conversions(t, 2.5, u"MW", u"MW")) ≈ 2.5
    @test PSIP._natural_unit_conversions(t, nothing, Val(:mw), USD) === nothing

    mm = PSIP._natural_unit_conversions(t, (min=0.0, max=1.0), u"MW", u"kW")
    @test ustrip(mm.min) ≈ 0.0 && ustrip(mm.max) ≈ 1000.0

    ud = PSIP._natural_unit_conversions(t, (up=1.0, down=2.0), u"hr", u"minute")
    @test ustrip(ud.up) ≈ 60.0 && ustrip(ud.down) ≈ 120.0
end

@testset "FunctionData conversions" begin
    t = supply()
    cu_kw = conversion_unit(u"kW", USD)
    cu_mw = conversion_unit(u"MW", USD)

    lin = LinearFunctionData(0.5, 10.0)
    nl = PSIP._natural_unit_conversions(t, lin, cu_kw, cu_mw)
    @test nl isa LinearFunctionData
    @test nl.proportional_term ≈ 500.0
    @test nl.constant_term ≈ 10.0

    quad = QuadraticFunctionData(1.0, 0.5, 10.0)
    nq = PSIP._natural_unit_conversions(t, quad, cu_kw, cu_mw)
    @test nq.quadratic_term ≈ 1.0e6
    @test nq.proportional_term ≈ 500.0
    @test nq.constant_term ≈ 10.0

    pcl = PiecewiseLinearData([(x=0.0, y=10.0), (x=1.0, y=20.0), (x=2.0, y=30.0)])
    npcl = PSIP._natural_unit_conversions(t, pcl, cu_mw, cu_kw)
    pts = PSY.get_points(npcl)
    @test [p.x for p in pts] ≈ [0.0, 1000.0, 2000.0]
    @test [p.y for p in pts] ≈ [10.0, 20.0, 30.0]

    pcs = PiecewiseStepData([0.0, 1.0, 2.0], [10.0, 20.0])
    npcs = PSIP._natural_unit_conversions(t, pcs, cu_kw, cu_mw)
    @test npcs.x_coords ≈ [0.0, 0.001, 0.002]
    @test npcs.y_coords ≈ [10000.0, 20000.0]
end

@testset "ValueCurve conversions" begin
    t = supply()
    lin = LinearFunctionData(0.5, 10.0)
    cu_kw = conversion_unit(u"kW", USD)
    cu_mw = conversion_unit(u"MW", USD)

    io = InputOutputCurve(lin, 1.0)
    nio = PSIP._natural_unit_conversions(t, io, cu_kw, cu_mw)
    @test nio isa InputOutputCurve
    @test nio.function_data.proportional_term ≈ 500.0
    @test nio.input_at_zero ≈ 1.0

    inc = IncrementalCurve(lin, 1.0, 2.0)
    ninc = PSIP._natural_unit_conversions(t, inc, cu_kw, cu_mw)
    @test ninc isa IncrementalCurve
    @test ninc.function_data.proportional_term ≈ 500.0
    @test ninc.initial_input ≈ 1.0
    @test ninc.input_at_zero ≈ 2.0

    avg = AverageRateCurve(lin, 1.0, 2.0)
    navg = PSIP._natural_unit_conversions(
        t,
        avg,
        conversion_unit(u"MW" * u"hr", MMBtu),
        conversion_unit(u"MW" * u"hr", u"btu"),
    )
    @test navg isa AverageRateCurve
    @test navg.function_data.proportional_term ≈ 5.0e5
    @test navg.function_data.constant_term ≈ 1.0e7
    @test navg.initial_input ≈ 1.0e6
    @test navg.input_at_zero ≈ 2.0e6
end

@testset "Operating costs carry their own units" begin
    t = supply()
    io = InputOutputCurve(LinearFunctionData(10.0, 2.0))
    fuel_curve = FuelCurve(;
        value_curve=io,
        fuel_units=u"GJ",
        fuel_cost=4.0,
        startup_fuel_offtake=LinearCurve(2.0),
        vom_cost=LinearCurve(1.0),
    )
    cost = ThermalGenerationCost(fuel_curve, 100.0, (hot=100.0, warm=50.0, cold=10.0), 0.0)
    PSIP.set_operation_costs!(t, cost, IS.NU)

    # Natural units return the cost as stored, its fuel in GJ
    @test PSIP.get_operation_costs(t, IS.NU) === cost
    @test PSIP.get_operation_costs(t, u"NU") === cost

    # A fuel unit converts the fuel of the fuel curve and nothing else
    gj = ustrip(uconvert(MMBtu, 1.0u"GJ"))
    converted = PSIP.get_operation_costs(t, MMBtu)
    curve = converted.variable_operation_cost
    @test IS.get_fuel_units(curve) == MMBtu
    @test get_value_curve(curve).function_data.proportional_term ≈ 10.0 * gj
    @test get_value_curve(curve).function_data.constant_term ≈ 2.0 * gj
    @test IS.get_fuel_cost(curve) ≈ 4.0 / gj
    @test get_proportional_term(IS.get_startup_fuel_offtake(curve)) ≈ 2.0 * gj
    @test get_vom_cost(curve) == LinearCurve(1.0)
    @test converted.fixed == 100.0
    @test converted.start_up == (hot=100.0, warm=50.0, cold=10.0)
    @test PSIP.get_operation_costs(t, u"GJ") === cost

    # Cost curves have no fuel to convert
    storage_cost = StorageCost(;
        charge_variable_cost=CostCurve(LinearCurve(1.0)),
        discharge_variable_cost=CostCurve(LinearCurve(1.0)),
        fixed=2.0,
    )
    @test PSIP.convert_fuel_units(storage_cost, MMBtu) === storage_cost

    # Power and currency conversions are not available for curves that carry units
    @test_throws ArgumentError PSIP.get_operation_costs(t, u"kW")
    @test_throws ArgumentError PSIP.get_operation_costs(
        t,
        conversion_unit(u"kW" * u"hr", USD),
    )
    @test_throws ArgumentError PSIP.set_operation_costs!(t, cost, u"MW")
    @test_throws Unitful.DimensionError PSIP.get_operation_costs(t, u"L")

    # A portfolio has no base power, so per-unit curves are rejected
    per_unit = ThermalGenerationCost(CostCurve(LinearCurve(1.0), IS.SU), 0.0, 0.0, 0.0)
    @test_throws IS.InvalidValue PSIP.set_operation_costs!(t, per_unit, IS.NU)
    t.operation_costs = per_unit
    @test_throws IS.InvalidValue PSIP.get_operation_costs(t, IS.NU)
    @test !(@test_logs (:error, r"natural units") IS.validate_struct(t))
end

@testset "SupplyTechnology getters/setters" begin
    t = supply()
    check_scalar(
        u -> PSIP.get_unit_size(t, u),
        (v, u) -> PSIP.set_unit_size!(t, v, u),
        u"MW",
        u"kW";
        base=100.0,
        ratio=1000.0,
    )
    check_scalar(
        u -> PSIP.get_start_fuel_mmbtu_per_mw(t, u),
        (v, u) -> PSIP.set_start_fuel_mmbtu_per_mw!(t, v, u),
        u"MMBtu/MW",
        u"MMBtu/kW";
        base=5.0,
        ratio=0.001,
    )
    check_minmax(
        u -> PSIP.get_capacity_limits(t, u),
        (v, u) -> PSIP.set_capacity_limits!(t, v, u),
        u"MW",
        u"kW";
        mn=0.0,
        mx=500.0,
        ratio=1000.0,
    )
    check_updown(
        u -> PSIP.get_ramp_limits(t, u),
        (v, u) -> PSIP.set_ramp_limits!(t, v, u),
        u"MW/minute",
        u"MW/s";
        up=1.0,
        down=2.0,
        ratio=1 / 60,
    )
    check_updown(
        u -> PSIP.get_time_limits(t, u),
        (v, u) -> PSIP.set_time_limits!(t, v, u),
        u"minute",
        u"hr";
        up=600.0,
        down=1200.0,
        ratio=1 / 60,
    )
    # capital_costs is a `CapitalCost` struct with no unit-aware accessor; its nested
    # accessors are covered below.
    @test PSIP.get_capital_cost(PSIP.get_capital_costs(t)) == LinearCurve(10000.0)

    PSIP.set_outage_factor!(t, (planned=0.08, forced=0.0))
    @test PSIP.get_outage_factor(t) == (planned=0.08, forced=0.0)

    # operation_costs carry their own units
    oc = PSIP.get_operation_costs(t, IS.NU)
    @test oc.variable_operation_cost.value_curve.function_data.proportional_term ≈ 10.0
    @test oc.fixed ≈ 100.0
    # lifetime (yr, Int)
    @test PSIP.get_lifetime(t, u"yr") == 30
    PSIP.set_lifetime!(t, 20, u"yr")
    @test PSIP.get_lifetime(t, u"yr") == 20
    # _unitful companion returns a Quantity
    @test PSIP.get_unit_size_unitful(t, u"MW") == 100.0u"MW"
end

@testset "StorageTechnology getters/setters" begin
    t = storage()
    check_scalar(
        u -> PSIP.get_unit_size_charge(t, u),
        (v, u) -> PSIP.set_unit_size_charge!(t, v, u),
        u"MW",
        u"kW";
        base=10.0,
        ratio=1000.0,
    )
    check_scalar(
        u -> PSIP.get_unit_size_discharge(t, u),
        (v, u) -> PSIP.set_unit_size_discharge!(t, v, u),
        u"MW",
        u"kW";
        base=20.0,
        ratio=1000.0,
    )
    check_scalar(
        u -> PSIP.get_unit_size_energy(t, u),
        (v, u) -> PSIP.set_unit_size_energy!(t, v, u),
        u"MW" * u"hr",
        u"kW" * u"hr";
        base=200.0,
        ratio=1000.0,
    )
    check_minmax(
        u -> PSIP.get_capacity_limits_charge(t, u),
        (v, u) -> PSIP.set_capacity_limits_charge!(t, v, u),
        u"MW",
        u"kW";
        mn=0.0,
        mx=100.0,
        ratio=1000.0,
    )
    check_minmax(
        u -> PSIP.get_capacity_limits_discharge(t, u),
        (v, u) -> PSIP.set_capacity_limits_discharge!(t, v, u),
        u"MW",
        u"kW";
        mn=0.0,
        mx=200.0,
        ratio=1000.0,
    )
    check_minmax(
        u -> PSIP.get_capacity_limits_energy(t, u),
        (v, u) -> PSIP.set_capacity_limits_energy!(t, v, u),
        u"MW" * u"hr",
        u"kW" * u"hr";
        mn=0.0,
        mx=1000.0,
        ratio=1000.0,
    )
    check_minmax(
        u -> PSIP.get_duration_limits(t, u),
        (v, u) -> PSIP.set_duration_limits!(t, v, u),
        u"minute",
        u"hr";
        mn=60.0,
        mx=600.0,
        ratio=1 / 60,
    )

    sc = PSIP.StorageCapitalCost(
        LinearCurve(1000.0),
        LinearCurve(2000.0),
        LinearCurve(3000.0),
        7.0,
    )
    PSIP.set_capital_costs!(t, sc)
    sc2 = PSIP.get_capital_costs(t)
    @test PSIP.get_charge_capital_cost(sc2) == LinearCurve(1000.0)
    @test PSIP.get_discharge_capital_cost(sc2) == LinearCurve(2000.0)
    @test PSIP.get_energy_capital_cost(sc2) == LinearCurve(3000.0)
    @test PSIP.get_interconnection_cost(sc2) == 7.0
end

@testset "Transport technology getters/setters" begin
    for t in (agg_transport(), acline(), hvdc())
        check_scalar(
            u -> PSIP.get_unit_size(t, u),
            (v, u) -> PSIP.set_unit_size!(t, v, u),
            u"MW",
            u"kW";
            base=PSIP.get_unit_size(t, u"MW"),
            ratio=1000.0,
        )
        check_minmax(
            u -> PSIP.get_capacity_limits(t, u),
            (v, u) -> PSIP.set_capacity_limits!(t, v, u),
            u"MW",
            u"kW";
            mn=0.0,
            mx=PSIP.get_capacity_limits(t, u"MW").max,
            ratio=1000.0,
        )
        PSIP.set_capital_costs!(t, PSIP.CapitalCost(LinearCurve(1500.0), 3.0))
        @test PSIP.get_capital_cost(PSIP.get_capital_costs(t)) == LinearCurve(1500.0)
        @test PSIP.get_interconnection_cost(PSIP.get_capital_costs(t)) == 3.0
    end
end

@testset "ProjectedDemand getters/setters" begin
    t = demand_req()
    check_scalar(
        u -> PSIP.get_peak_demand_mw(t, u),
        (v, u) -> PSIP.set_peak_demand_mw!(t, v, u),
        u"MW",
        u"kW";
        base=300.0,
        ratio=1000.0,
    )
    check_valuecurve(
        u -> PSIP.get_curtailment_cost(t, u),
        (v, u) -> PSIP.set_curtailment_cost!(t, v, u),
        conversion_unit(u"MW" * u"hr", USD),
        conversion_unit(u"kW" * u"hr", USD);
        prop=50.0,
        ratio=1e-3,
    )
    check_scalar(
        u -> PSIP.get_value_of_lost_load(t, u),
        (v, u) -> PSIP.set_value_of_lost_load!(t, v, u),
        USD / (u"MW" * u"hr"),
        USD / (u"kW" * u"hr");
        base=1e5,
        ratio=1e-3,
    )
    check_scalar(
        u -> PSIP.get_max_demand_advance(t, u),
        (v, u) -> PSIP.set_max_demand_advance!(t, v, u),
        u"minute",
        u"hr";
        base=240.0,
        ratio=1 / 60,
    )
    check_scalar(
        u -> PSIP.get_max_demand_delay(t, u),
        (v, u) -> PSIP.set_max_demand_delay!(t, v, u),
        u"minute",
        u"hr";
        base=360.0,
        ratio=1 / 60,
    )
end

@testset "DemandSideTechnology getters/setters" begin
    t = demand_side()
    @test PSIP.get_price_per_unit(t, IS.NU) == LinearCurve(3000.0)
    PSIP.set_capacity_limits!(t, (min=10.0, max=300.0), IS.NU)
    @test PSIP.get_capacity_limits(t, IS.NU) == (min=10.0, max=300.0)
end

@testset "Supplemental attribute getters/setters" begin
    r = RetirementPotential(eligible_generators=["g1"], retirement_cost=LinearCurve(100.0))
    x = RetrofitPotential(eligible_generators=["g1"], retrofit_cost=LinearCurve(150.0))
    check_valuecurve(
        u -> PSIP.get_retirement_cost(r, u),
        (v, u) -> PSIP.set_retirement_cost!(r, v, u),
        conversion_unit(u"MW", USD),
        conversion_unit(u"kW", USD);
        prop=100.0,
        ratio=1e-3,
    )
    check_valuecurve(
        u -> PSIP.get_retrofit_cost(x, u),
        (v, u) -> PSIP.set_retrofit_cost!(x, v, u),
        conversion_unit(u"MW", USD),
        conversion_unit(u"kW", USD);
        prop=150.0,
        ratio=1e-3,
    )
end

@testset "Carbon and capacity requirement getters/setters" begin
    t = carbon_caps()
    check_scalar(
        u -> PSIP.get_max_mtons(t, u),
        (v, u) -> PSIP.set_max_mtons!(t, v, u),
        Mt,
        tonne;
        base=50.0,
        ratio=1.0e6,
    )
    check_scalar(
        u -> PSIP.get_max_tons_mwh(t, u),
        (v, u) -> PSIP.set_max_tons_mwh!(t, v, u),
        Mt / (u"MW" * u"hr"),
        Mt / (u"kW" * u"hr");
        base=2.0e-6,
        ratio=1e-3,
    )

    tax = carbon_tax()
    check_scalar(
        u -> PSIP.get_tax_dollars_per_ton(tax, u),
        (v, u) -> PSIP.set_tax_dollars_per_ton!(tax, v, u),
        USD / tonne,
        USD / u"kg";
        base=50.0,
        ratio=1e-3,
    )

    maxc = max_capacity_req()
    minc = min_capacity_req()
    check_scalar(
        u -> PSIP.get_max_capacity_mw(maxc, u),
        (v, u) -> PSIP.set_max_capacity_mw!(maxc, v, u),
        u"MW",
        u"kW";
        base=400.0,
        ratio=1000.0,
    )
    check_scalar(
        u -> PSIP.get_min_capacity_mw(minc, u),
        (v, u) -> PSIP.set_min_capacity_mw!(minc, v, u),
        u"MW",
        u"kW";
        base=100.0,
        ratio=1000.0,
    )
end

@testset "ColocatedSupplyStorageTechnology getters/setters" begin
    t = colocated()
    check_minmax(
        u -> PSIP.get_inverter_capacity_limits(t, u),
        (v, u) -> PSIP.set_inverter_capacity_limits!(t, v, u),
        u"MW",
        u"kW";
        mn=50.0,
        mx=600.0,
        ratio=1000.0,
    )
    inverter_cost = PSIP.get_operation_costs_inverter(t, IS.NU)
    @test get_proportional(get_value_curve(inverter_cost)) ≈ 6.0
    @test_throws ArgumentError PSIP.get_operation_costs_inverter(t, u"kW")

    PSIP.set_capital_costs_inverter!(t, PSIP.CapitalCost(LinearCurve(1300.0), 4.0))
    @test PSIP.get_capital_cost(PSIP.get_capital_costs_inverter(t)) == LinearCurve(1300.0)
    @test PSIP.get_interconnection_cost(PSIP.get_capital_costs_inverter(t)) == 4.0
end

@testset "display_units_arg" begin
    t = supply()
    @test IS.display_units_arg(PSIP.get_unit_size, typeof(t)) === IS.NU
    @test IS.display_units_arg(PSIP.get_capacity_limits, typeof(t)) === IS.NU
    @test IS.display_units_arg(PSIP.get_unit_size_unitful, typeof(t)) === IS.NU
    # Fields without units have no display_units_arg method -> default `missing`.
    @test ismissing(IS.display_units_arg(PSIP.get_name, typeof(t)))
    @test ismissing(IS.display_units_arg(PSIP.get_available, typeof(t)))
end

# ---------------------------------------------------------------------------
# Cross-repo unit pin: PSIP's descriptor `conversion_unit` must denote the same
# physical unit as SiennaSchemas' `x-unit` for every field this branch
# corrected. Both sides are read from their own JSON/engine source of truth —
# no unit string is hard-coded here — so this fails the moment either side
# drifts again, rather than only at the next manual audit.
# ---------------------------------------------------------------------------
@testset "PSIP conversion_unit matches SiennaSchemas x-unit" begin
    schemas_root = joinpath(dirname(BASE_DIR), "SiennaSchemas", "Investments")
    if !isdir(schemas_root)
        @info "SiennaSchemas sibling checkout not found; skipping cross-repo unit-parity check" schemas_root
    else
        descriptor =
            JSON3.read(joinpath(BASE_DIR, "src", "descriptors", "SiennaInvestSchema.json"))
        components = Dict(String(c["name"]) => c for c in descriptor["components"])

        # SiennaSchemas spells a few units differently than Unitful's registered
        # symbols (minute abbreviates to "min" there, "MWh"/"kWh" aren't atomic
        # Unitful symbols); translate token-by-token, then let Unitful parse it.
        function schema_unit_token(tok)
            tok == "min" && return "minute"
            tok == "t" && return "tonne"
            tok == "MWh" && return "(MW*hr)"
            tok == "kWh" && return "(kW*hr)"
            return tok
        end
        function parse_schema_unit(str)
            s = join(schema_unit_token.(split(str, "/")), "/")
            return Unitful.uparse(s; unit_context=[PSIP, Unitful])
        end
        # A curve-shaped category's "unit" is its rate y_unit/x_unit; a scalar
        # category's natural_unit already is that rate.
        function psip_rate_unit(conversion_unit_str)
            sym = Symbol(lstrip(conversion_unit_str, ':'))
            nu = PSIP.natural_unit(PSIP._unit_category(Val(sym)))
            return nu isa NamedTuple ? nu.y_unit / nu.x_unit : nu
        end
        function find_schema_file(type_name)
            for (root, _, files) in walkdir(schemas_root)
                "$type_name.json" in files && return joinpath(root, "$type_name.json")
            end
            return nothing
        end

        # (Sienna component type, field name) for every field corrected on this
        # branch — the 9 scale/basis mismatches plus the 2 fields SiennaSchemas
        # annotated but PSIP never converted at all.
        #
        # Three entries are skipped: the schemas no longer carry these fields at all
        # (ColocatedSupplyStorageTechnology.duration_limits and .operation_costs_power
        # per the f95da63 restructure; SupplyTechnology.co2 per 7c4ad0c's "move
        # EmissionsData to Core"), so there is nothing on the schema side left to
        # compare a unit against. These are parity drifts, not fixed here — see the
        # parity-drift table in the PR body.
        checked_fields = [
            ("SupplyTechnology", "time_limits"),
            ("StorageTechnology", "duration_limits"),
            ("ProjectedDemand", "max_demand_delay"),
            ("ProjectedDemand", "max_demand_advance"),
            ("CarbonCaps", "max_mtons"),
            ("CarbonCaps", "max_tons_mwh"),
            ("DemandSideTechnology", "price_per_unit"),
            ("RetirementPotential", "retirement_cost"),
            ("RetrofitPotential", "retrofit_cost"),
        ]

        for (type_name, field_name) in checked_fields
            props = components[type_name]["properties"]
            prop = only(filter(p -> p["name"] == field_name, props))
            @test get(prop, "needs_conversion", false)

            schema_file = find_schema_file(type_name)
            @test !isnothing(schema_file)
            schema = JSON3.read(schema_file)
            x_unit = schema["properties"][Symbol(field_name)]["x-unit"]

            psip_unit = psip_rate_unit(prop["conversion_unit"])
            schema_unit = parse_schema_unit(x_unit)
            @test uconvert(psip_unit, 1.0 * schema_unit) ≈ 1.0 * psip_unit
        end
    end
end
