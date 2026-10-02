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

# ── every struct, with its value variants ──────────────────────────────────────
#
# The facet test above proves the plumbing; this one proves the converters. A type that is
# present but only ever holds default values hides exactly the bugs that matter — an unset
# nullable field written as a `null` the schema rejects, a populated map passed where the wire
# wants a wrapper, an attribute id that collides with a topology id — so the fixture below
# holds every document and supplemental-attribute type *and* the value shapes each can take:
# nullable fields both set and unset, zero (omitted) and non-zero optional cost curves, every
# cost container and curve family, per-topology capacity bounds, populated enum- and
# string-keyed maps, requirement memberships across technology families, and time series on
# more than one owner type. Each is compared field by field, as its encoded OpenAPI payload,
# before and after every on-disk form.

"""
The 5-bus portfolio, extended with every document type it does not hold and with the value
variants it only holds at their defaults.
"""
function _build_wide_roundtrip_portfolio()
    portfolio = build_portfolio()
    base = PSIP.get_base_system(portfolio)
    zone_1 = PSY.get_component(PSY.Area, base, "Zone_1")
    zone_2 = PSY.get_component(PSY.Area, base, "Zone_2")
    buses = sort!(collect(PSY.get_components(PSY.ACBus, base)); by=PSY.get_name)
    thermal = PSIP.get_technology(
        SupplyTechnology{PSY.ThermalStandard},
        portfolio,
        "cheap_thermal",
    )
    storage = first(PSIP.get_technologies(StorageTechnology, portfolio))
    financial_data = PSIP.get_financial_data(thermal)
    region = PSIP.get_region(thermal)

    # Multi-fuel thermal: FuelCurve cost, multi-stage start-up, populated cofire maps,
    # per-topology capacity bounds, non-default compounds and enum.
    multifuel = SupplyTechnology{PSY.ThermalStandard}(;
        name="rt_multifuel",
        power_systems_type="ThermalStandard",
        region=[zone_1, zone_2],
        prime_mover_type=PrimeMovers.CC,
        fuel=[ThermalFuels.COAL, ThermalFuels.NATURAL_GAS],
        cofire_start_limits=Dict(
            ThermalFuels.COAL => (min=0.1, max=0.6),
            ThermalFuels.NATURAL_GAS => (min=0.2, max=0.9),
        ),
        cofire_level_limits=Dict(ThermalFuels.COAL => (min=0.0, max=0.5)),
        capital_costs=PSIP.CapitalCost(LinearCurve(1200.0), 35.0),
        operation_costs=ThermalGenerationCost(;
            variable_operation_cost=FuelCurve(LinearCurve(9.5), 3.25),
            fixed=4.0,
            start_up=(hot=1.0, warm=2.0, cold=3.0),
            shut_down=1.5,
        ),
        unit_size=120.0,
        capacity_limits=Dict{PSY.Topology, PSIP.MinMax}(
            zone_1 => (min=0.0, max=500.0),
            zone_2 => (min=10.0, max=250.0),
        ),
        outage_factor=(planned=0.04, forced=0.02),
        min_generation_fraction=0.3,
        ramp_limits=(up=0.5, down=0.4),
        time_limits=(up=4.0, down=2.0),
        start_fuel_mmbtu_per_mw=1.7,
        lifetime=40,
        financial_data=financial_data,
    )
    PSIP.add_technology!(portfolio, multifuel)

    # Renewable with a non-zero curtailment cost (the zero one is omitted on the wire).
    renewable = SupplyTechnology{PSY.RenewableDispatch}(;
        name="rt_renewable_curtailed",
        power_systems_type="RenewableDispatch",
        region=region,
        prime_mover_type=PrimeMovers.WT,
        operation_costs=RenewableGenerationCost(;
            variable_operation_cost=CostCurve(LinearCurve(0.5)),
            curtailment_cost=CostCurve(LinearCurve(7.0)),
            fixed=1.0,
        ),
        financial_data=financial_data,
    )
    PSIP.add_technology!(portfolio, renewable)

    # Storage with every nullable / optional field set — the counterpart of the fixture's own
    # storage, which leaves them unset.
    storage_set = StorageTechnology{PSY.EnergyReservoirStorage}(;
        name="rt_storage_optionals",
        region=region,
        available=true,
        power_systems_type="EnergyReservoirStorage",
        storage_tech=StorageTech.LIB,
        capital_costs=PSIP.StorageCapitalCost(
            LinearCurve(1.0),
            LinearCurve(2.0),
            LinearCurve(3.0),
            4.0,
        ),
        operation_costs=StorageCost(;
            charge_variable_cost=CostCurve(LinearCurve(2.0)),
            discharge_variable_cost=CostCurve(LinearCurve(3.0)),
            fixed=1.0,
            start_up=(charge=0.5, discharge=0.7),
            shut_down=0.2,
            energy_shortage_cost=100.0,
            energy_surplus_cost=10.0,
        ),
        min_discharge_fraction=0.1,
        unit_size_charge=5.0,
        unit_size_discharge=6.0,
        unit_size_energy=20.0,
        capacity_limits_charge=Dict{PSY.Topology, PSIP.MinMax}(
            zone_1 => (min=0.0, max=80.0),
        ),
        duration_limits=(min=1.0, max=8.0),
        efficiency=(in=0.95, out=0.9),
        losses=0.01,
        lifetime=15,
        financial_data=financial_data,
    )
    PSIP.add_technology!(portfolio, storage_set)

    # Demand types with non-default curves from every value-curve family.
    PSIP.add_technology!(
        portfolio,
        DemandSideTechnology{PSY.PowerLoad}(;
            name="rt_demand_side",
            available=true,
            power_systems_type="PowerLoad",
            region=region,
            technology_efficiency=0.9,
            price_per_unit=PSY.QuadraticCurve(0.1, 2.0, 0.0),
            min_power=1.0,
            peak_demand_mw=75.0,
            curtailment_cost=PSY.PiecewisePointCurve([(0.0, 0.0), (10.0, 50.0)]),
            max_demand_curtailment=0.2,
            max_demand_delay=2.0,
            max_demand_advance=1.0,
            demand_energy_efficiency=0.05,
            shift_variable_cost=LinearCurve(3.0),
        ),
    )
    PSIP.add_technology!(
        portfolio,
        DemandRequirement{PSY.PowerLoad}(;
            name="rt_demand_requirement",
            power_systems_type="PowerLoad",
            new_demand_mw=25.0,
            new_construction_year=2031,
            growth_rate=0.02,
            conformity=PSY.LoadConformity.CONFORMING,
            value_of_lost_load=9000.0,
            unserved_demand_curve=LinearCurve(5000.0),
            region=region,
        ),
    )

    # The two document types the 5-bus portfolio does not hold at all.
    PSIP.add_technology!(
        portfolio,
        ColocatedSupplyStorageTechnology{PSY.RenewableDispatch}(;
            name="rt_colocated",
            financial_data=financial_data,
            power_systems_type="RenewableDispatch",
            operation_costs_inverter=CostCurve(LinearCurve(0.8)),
            inverter_efficiency=0.96,
            inverter_supply_ratio=1.0,
            capital_costs_inverter=PSIP.CapitalCost(LinearCurve(70.0), 0.0),
            available=true,
            region=region,
            supply_technology=renewable,
            storage_technology=storage_set,
        ),
    )
    PSIP.add_technology!(
        portfolio,
        NodalHVDCTransportTechnology{PSY.ACBranch}(;
            name="rt_hvdc",
            start_node=buses[1],
            end_node=buses[2],
            capacity_limits=(min=0.0, max=400.0),
            unit_size=50.0,
            line_loss=LinearCurve(0.03),
            financial_data=financial_data,
            power_systems_type="ACBranch",
            available=true,
        ),
    )

    # Supplemental attributes: populated string-keyed maps, a non-default retrofit, and an
    # empty device list — on several owners, so attribute ids land among the topology ids.
    retirement = first(IS.get_supplemental_attributes(RetirementPotential, thermal))
    PSIP.set_planned_retirement_year!(retirement, Dict("unit_a" => 2035))
    PSIP.set_build_year!(retirement, Dict("unit_a" => 1990, "unit_b" => 2001))
    PSIP.add_supplemental_attribute!(
        portfolio,
        multifuel,
        RetrofitPotential(;
            eligible_generators=["unit_a", "unit_b"],
            retrofit_fraction=0.25,
            retrofit_cost=PSY.QuadraticCurve(0.01, 5.0, 2.0),
        ),
    )
    PSIP.add_supplemental_attribute!(
        portfolio,
        storage_set,
        ExistingDevices(; existing_devices=String[]),
    )

    # Requirement memberships across technology families.
    tax = PSIP.get_requirement(CarbonTax, portfolio, "test_tax")
    cap = PSIP.get_requirement(CarbonCaps, portfolio, "test_cap")
    crm = PSIP.get_requirement(CapacityReserveMargin, portfolio, "test_crm")
    PSIP.set_requirements!(thermal, [tax, cap])
    PSIP.set_requirements!(multifuel, [tax, crm])
    PSIP.set_requirements!(storage, [crm])

    # Time series on more owner types than the fixture's supply technologies.
    timestamps =
        collect(DateTime("2030-01-01T00:00:00"):Hour(1):DateTime("2030-01-01T23:00:00"))
    for (owner, name) in ((storage_set, "rt_storage_ts"), (renewable, "rt_renewable_ts"))
        PSIP.add_time_series!(
            portfolio,
            owner,
            SingleTimeSeries(; data=TimeArray(timestamps, rand(24)), name=name);
            features=Dict("year" => "2030", "rep_day" => 1),
        )
    end

    PSIP.set_investment_schedule!(
        portfolio,
        InvestmentScheduleResults(
            Dict(
                (Date("2030-01-01"), Date("2034-12-31")) => Dict(
                    (SupplyTechnology{PSY.ThermalStandard}, "rt_multifuel") => 120.0,
                    (
                        StorageTechnology{PSY.EnergyReservoirStorage},
                        "rt_storage_optionals",
                    ) => (power=10.0, energy=40.0),
                ),
            ),
        ),
    )
    return portfolio
end

"""
Every `to_openapi` payload of `T` in `portfolio`, as plain JSON keyed by id.
"""
function _roundtrip_payloads(portfolio, ::Type{T}) where {T}
    refs = PSIP._build_export_refs(portfolio)
    components = if T <: IS.SupplementalAttribute
        IS.get_supplemental_attributes(T, portfolio.data)
    else
        collect(PSIP._plan_components(portfolio, T))
    end
    return Dict(
        IS.get_id(c) =>
            JSON3.read(JSON3.write(PSIP.IC.encode(PSIP.to_openapi(c, refs))), Dict) for
        c in components
    )
end

"""
Each technology's requirement memberships, by technology id, as requirement names.
"""
_roundtrip_memberships(portfolio) = Dict(
    IS.get_id(t) => Set(PSIP.get_name.(PSIP.get_requirements(t))) for
    t in PSIP.get_technologies(Technology, portfolio) if PSIP.supports_requirements(t)
)

"""
Every time series in `portfolio` as a sorted `(owner id, name, values)` list — a multiset, so
same-name series attached under different features stay distinct by their values.
"""
_roundtrip_time_series(portfolio) = sort!(
    [
        (IS.get_id(t), IS.get_name(ts), TimeSeries.values(IS.get_data(ts))) for
        t in PSIP.get_technologies(Technology, portfolio) for
        ts in IS.get_time_series_multiple(t)
    ];
    by=string,
)

function _check_wide_roundtrip(before, after, form)
    for (T, key) in vcat(PSIP.DOCUMENT_PLAN, PSIP.SUPPLEMENTAL_ATTRIBUTE_PLAN)
        payloads = _roundtrip_payloads(before, T)
        payloads2 = _roundtrip_payloads(after, T)
        # Coverage: a type the fixture does not hold is not exercised at all.
        @test !isempty(payloads)
        isempty(payloads) && @error "wide round-trip fixture holds no $key"
        @test keys(payloads2) == keys(payloads)
        for (id, payload) in payloads
            payload2 = get(payloads2, id, nothing)
            @test payload2 == payload
            payload2 == payload ||
                @error "$key id=$id changed across the $form round trip" payload payload2
        end
    end
    @test _roundtrip_memberships(after) == _roundtrip_memberships(before)
    @test _roundtrip_time_series(after) == _roundtrip_time_series(before)
    @test PSIP.get_investment_schedule(after).results ==
          PSIP.get_investment_schedule(before).results
    return
end

@testset "every struct and value variant round trips through every form" begin
    portfolio = _build_wide_roundtrip_portfolio()
    mktempdir() do dir
        for (form, path) in (
            ("directory", joinpath(dir, "wide")),
            ("document", joinpath(dir, "wide.json")),
            ("archive", joinpath(dir, "wide.snp")),
        )
            PSIP.to_file(portfolio, path; force=true)
            _check_wide_roundtrip(portfolio, PSIP.from_file(path), form)
        end
    end
end
