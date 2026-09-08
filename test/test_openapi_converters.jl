@testset "value curve conversion round trip" begin
    for curve in (
        LinearCurve(3.0),
        LinearCurve(2.0, 5.0),
        PSY.QuadraticCurve(1.0, 2.0, 3.0),
        PSY.PiecewisePointCurve([(1.0, 10.0), (2.0, 25.0)]),
    )
        po = PSIP.convert_value_curve_to_openapi(curve)
        @test PSIP.convert_value_curve(po) == curve
    end
end

@testset "operational cost conversion round trip" begin
    # `ThermalGenerationCost`/`StorageCost`/`RenewableGenerationCost` are `@kwdef mutable
    # struct`s with no custom `Base.==`, so two field-identical instances are not `==`
    # (mutable structs fall back to identity). Compare the round-tripped cost's `variable`
    # value curve and scalar fields directly instead of `==`-ing the whole struct.
    thermal = PSY.ThermalGenerationCost(nothing)
    po = PSIP.convert_cost_to_openapi(thermal)
    round_tripped = PSIP.convert_cost(po)
    @test round_tripped isa PSY.ThermalGenerationCost
    @test get_variable_operation_cost(round_tripped) == get_variable_operation_cost(thermal)
    @test get_fixed(round_tripped) == get_fixed(thermal)
    @test get_start_up(round_tripped) == get_start_up(thermal)
    @test get_shut_down(round_tripped) == get_shut_down(thermal)

    storage = PSY.StorageCost(nothing)
    po = PSIP.convert_cost_to_openapi(storage)
    round_tripped = PSIP.convert_cost(po)
    @test round_tripped isa PSY.StorageCost
    @test get_charge_variable_cost(round_tripped) == get_charge_variable_cost(storage)
    @test get_discharge_variable_cost(round_tripped) == get_discharge_variable_cost(storage)
    @test get_fixed(round_tripped) == get_fixed(storage)
    @test get_start_up(round_tripped) == get_start_up(storage)
    @test get_shut_down(round_tripped) == get_shut_down(storage)
    @test get_energy_shortage_cost(round_tripped) == get_energy_shortage_cost(storage)
    @test get_energy_surplus_cost(round_tripped) == get_energy_surplus_cost(storage)

    renewable = PSY.RenewableGenerationCost(nothing)
    po = PSIP.convert_cost_to_openapi(renewable)
    round_tripped = PSIP.convert_cost(po)
    @test round_tripped isa PSY.RenewableGenerationCost
    @test get_variable_operation_cost(round_tripped) ==
          get_variable_operation_cost(renewable)
    # `get_curtailment_cost` is ambiguous between PSY and PSIP's own
    # `DemandSideTechnology` getter of the same name — qualify it.
    @test PSY.get_curtailment_cost(round_tripped) == PSY.get_curtailment_cost(renewable)
    @test get_fixed(round_tripped) == get_fixed(renewable)
end

@testset "financial data conversion round trip" begin
    fd = TechnologyFinancialData(
        capital_recovery_period=20,
        technology_base_year=2024,
        debt_fraction=0.6,
        debt_rate=0.05,
        return_on_equity=0.1,
        tax_rate=0.21,
    )
    po = PSIP.convert_nested_data_to_openapi(fd)
    round_tripped = PSIP.convert_nested_data(po)
    # `TechnologyFinancialData`'s getters are not in the module's export list (pre-existing,
    # out of Task 3's scope), so they must be qualified here.
    @test PSIP.get_capital_recovery_period(round_tripped) == 20
    @test PSIP.get_technology_base_year(round_tripped) == 2024
    @test PSIP.get_debt_fraction(round_tripped) == 0.6
    @test PSIP.get_debt_rate(round_tripped) == 0.05
    @test PSIP.get_return_on_equity(round_tripped) == 0.1
    @test PSIP.get_tax_rate(round_tripped) == 0.21
end

@testset "compound PO constructors" begin
    @test PSIP._minmax_po((min=1.0, max=2.0)).min == 1.0
    @test PSIP._minmax_po((min=1.0, max=2.0)).max == 2.0
    @test PSIP._updown_po((up=3.0, down=4.0)).up == 3.0
    @test PSIP._inout_po((in=0.9, out=0.8)).out == 0.8
    # `OPENAPI_COMPOUND_CTORS` names an `_optional` constructor for all three compounds,
    # so all three are reachable the moment any compound field is made nullable; test all
    # three rather than leave two of the table's entries unexercised.
    @test isnothing(PSIP._minmax_po_optional(nothing))
    @test PSIP._minmax_po_optional((min=0.0, max=1.0)).max == 1.0
    @test isnothing(PSIP._updown_po_optional(nothing))
    @test PSIP._updown_po_optional((up=3.0, down=4.0)).down == 4.0
    @test isnothing(PSIP._inout_po_optional(nothing))
    @test PSIP._inout_po_optional((in=0.9, out=0.8)).in == 0.9
end

@testset "unmapped converter input errors loudly" begin
    @test_throws ErrorException PSIP.convert_cost("not a cost model")
    @test_throws ErrorException PSIP.convert_value_curve(42)
end

# ── generated from_openapi / to_openapi round trips (Task 4) ──────────────────
#
# `build_portfolio()` is unavailable in this environment (PSCB 2.4.0 calls a PSY API
# removed in psy6), so every fixture below is built inline.

"""
The reference targets every technology round trip needs, pre-registered.
"""
function _refs_fixture()
    refs = PSIP.OpenAPIRefs()
    zone = PSY.Area(; name="zone_a", base_power=100.0)
    load_zone = PSY.LoadZone(;
        name="zone_a_lz",
        peak_active_power=0.0,
        peak_reactive_power=0.0,
        base_power=100.0,
    )
    node = PSY.ACBus(;
        number=909,
        name="node_a",
        available=true,
        bustype=PSY.ACBusTypes.PQ,
        angle=0.0,
        magnitude=1.0,
        voltage_limits=(min=0.9, max=1.1),
        base_voltage=138.0,
        area=zone,
        load_zone=load_zone,
    )
    req = CarbonTax(name="tax", available=true)
    # Identity now lives in `internal` (assigned by the container on add). These fixtures
    # never add to a portfolio, so stamp the ids the document walk would have assigned; the
    # registry keys and the objects' own `get_id` must agree.
    IS.set_id!(zone, 1)
    IS.set_id!(node, 2)
    IS.set_id!(req, 3)
    refs[1] = zone
    refs[2] = node
    refs[3] = req
    return refs, zone, node, req
end

@testset "Topology references round trip through OpenAPI" begin
    refs, zone, node, _ = _refs_fixture()

    tech = NodalACTransportTechnology{PSY.ACBranch}(;
        name="line",
        available=true,
        power_systems_type="ACBranch",
        start_node=node,
        end_node=node,
        financial_data=TechnologyFinancialData(
            capital_recovery_period=20,
            technology_base_year=2024,
            debt_fraction=0.6,
            debt_rate=0.05,
            return_on_equity=0.1,
            tax_rate=0.21,
        ),
        capital_costs=PSIP.CapitalCost(LinearCurve(1000.0), 0.0),
    )
    refs[11] = tech
    po = PSIP.to_openapi(tech, refs)
    @test po.start_node == 2
    @test po.end_node == 2
    back = PSIP.from_openapi(po, refs)
    @test PSIP.get_start_node(back) === node
    @test PSIP.get_end_node(back) === node
end

@testset "SupplyTechnology round trip through OpenAPI" begin
    refs, zone, _, req = _refs_fixture()
    tech = SupplyTechnology{ThermalStandard}(;
        name="cheap_thermal",
        available=true,
        power_systems_type="ThermalStandard",
        region=[zone],
        requirements=[req],
        prime_mover_type=PrimeMovers.CT,
        fuel=[ThermalFuels.NATURAL_GAS],
        cofire_level_limits=Dict(ThermalFuels.NATURAL_GAS => (min=0.0, max=1.0)),
        capacity_limits=(min=0.0, max=500.0),
        ramp_limits=(up=1.0, down=1.0),
        time_limits=(up=60.0, down=60.0),
        unit_size=100.0,
        capital_costs=PSIP.CapitalCost(LinearCurve(1000.0), 0.0),
        financial_data=TechnologyFinancialData(
            capital_recovery_period=20,
            technology_base_year=2024,
            debt_fraction=0.6,
            debt_rate=0.05,
            return_on_equity=0.1,
            tax_rate=0.21,
        ),
    )
    refs[10] = tech

    po = PSIP.to_openapi(tech, refs)
    # references leave as ids, not objects
    @test po.region == [1]
    @test po.requirements == [3]
    # the type parameter is carried by power_systems_type, and by nothing else
    @test po.power_systems_type == "ThermalStandard"
    # enums, enum vectors and enum-keyed dicts all cross as strings
    @test po.prime_mover_type == string(PrimeMovers.CT)
    @test po.fuel == [string(ThermalFuels.NATURAL_GAS)]
    # compounds become PC models
    @test po.capacity_limits.value.max == 500.0
    @test po.ramp_limits.up == 1.0
    # scalars are unscaled: PSIP stores natural units and the document states them
    @test po.unit_size == 100.0

    back = PSIP.from_openapi(po, refs)
    @test PSIP.get_parameter_type(back) === ThermalStandard
    @test PSIP.get_name(back) == "cheap_thermal"
    @test PSIP.get_region(back) == [zone]
    @test PSIP.get_requirements(back) == [req]
    @test PSIP.get_prime_mover_type(back) == PrimeMovers.CT
    @test PSIP.get_fuel(back) == [ThermalFuels.NATURAL_GAS]
    @test PSIP.get_capacity_limits(back, NU) == (min=0.0, max=500.0)
    @test PSIP.get_unit_size(back, NU) == 100.0
end

@testset "abstract type parameters survive the round trip" begin
    refs, zone, _, _ = _refs_fixture()
    tech = AggregateTransportTechnology{ACBranch}(;
        name="test_branch",
        available=true,
        power_systems_type="ACBranch",
        start_region=zone,
        end_region=zone,
        financial_data=TechnologyFinancialData(
            capital_recovery_period=20,
            technology_base_year=2024,
            debt_fraction=0.6,
            debt_rate=0.05,
            return_on_equity=0.1,
            tax_rate=0.21,
        ),
    )
    refs[40] = tech

    po = PSIP.to_openapi(tech, refs)
    @test po.start_region == 1
    @test po.power_systems_type == "ACBranch"
    @test PSIP.get_parameter_type(PSIP.from_openapi(po, refs)) === ACBranch
end

@testset "supplemental attribute round trip through OpenAPI" begin
    refs = PSIP.OpenAPIRefs()
    attr = ExistingDevices(existing_devices=["gen_a", "gen_b"])
    IS.set_id!(attr, 54)
    refs[54] = attr
    po = PSIP.to_openapi(attr, refs)
    @test po.id == 54
    @test po.existing_devices == ["gen_a", "gen_b"]
    @test PSIP.get_existing_devices(PSIP.from_openapi(po, refs)) == ["gen_a", "gen_b"]
end

@testset "an unregistered reference errors rather than serializing garbage" begin
    refs = PSIP.OpenAPIRefs()
    orphan = PSY.Area(; name="orphan", base_power=100.0)
    tech = DemandRequirement{PowerLoad}(;
        name="demand",
        power_systems_type="PowerLoad",
        value_of_lost_load=1e5,
        region=[orphan],
    )
    refs[78] = tech
    @test_throws ErrorException PSIP.to_openapi(tech, refs)
end

@testset "nullable fields round trip through OpenAPI" begin
    # StorageTechnology is the only type with nullable scalar, compound and curve fields
    # (`unit_size_charge`, `capacity_limits_charge`, `capital_costs_charge`); all three
    # default to `nothing`, so an otherwise-default instance exercises every one.
    refs, zone, _, _ = _refs_fixture()
    tech = StorageTechnology{PSY.EnergyReservoirStorage}(;
        name="battery",
        available=true,
        power_systems_type="EnergyReservoirStorage",
        region=[zone],
        storage_tech=StorageTech.OTHER_CHEM,
        financial_data=TechnologyFinancialData(
            capital_recovery_period=20,
            technology_base_year=2024,
            debt_fraction=0.6,
            debt_rate=0.05,
            return_on_equity=0.1,
            tax_rate=0.21,
        ),
    )
    refs[20] = tech

    po = PSIP.to_openapi(tech, refs)
    @test isnothing(po.unit_size_charge)
    @test po.storage_tech == string(StorageTech.OTHER_CHEM)
    @test po.efficiency.in == 1

    back = PSIP.from_openapi(po, refs)
    @test PSIP.get_parameter_type(back) === PSY.EnergyReservoirStorage
    @test isnothing(PSIP.get_unit_size_charge(back, NU))
    @test PSIP.get_storage_tech(back) == StorageTech.OTHER_CHEM
end

@testset "duplicate component ids are rejected on addition" begin
    # A component's `id` is the identity `IS.SystemData` stores it under, so two portfolio
    # components sharing one collide when the second is attached — before any document is
    # built. Regions now live in the base system's own id space, so this container check is
    # exercised between two `portfolio.data` components (here, two requirements).
    portfolio = Portfolio()
    first_req = CarbonTax(name="tax_a", available=true)
    PSIP.add_requirement!(portfolio, first_req)
    id = PSIP.get_id(first_req)

    tax = CarbonTax(name="tax_b", available=true)
    IS.set_id!(tax, id)

    @test_throws ArgumentError PSIP.add_requirement!(portfolio, tax)
end

@testset "every generated type has both OpenAPI converters" begin
    descriptor =
        JSON3.read(joinpath(BASE_DIR, "src", "descriptors", "SiennaInvestSchema.json"))
    for component in descriptor["components"]
        type = getproperty(PSIP, Symbol(component["name"]))
        # `from_openapi` now dispatches on the OpenAPI wire type, not the target PSIP type.
        wire_type = PSIP._openapi_wire_type(type)
        @test hasmethod(PSIP.from_openapi, Tuple{wire_type, PSIP.OpenAPIRefs})
        @test !isempty(methods(PSIP.to_openapi, (type, PSIP.OpenAPIRefs)))
        # `methods` matches by signature INTERSECTION, so the check above still passes when
        # the emitted `where` bound names the wrong PSY supertype — the resulting
        # MethodError would only surface on a real save. Compare the bound the generator
        # actually wrote against the descriptor's `parametric` key.
        if haskey(component, :parametric)
            expected = Base.eval(PSIP, Meta.parse(String(component["parametric"])))
            signature = only(methods(PSIP.to_openapi, (type, PSIP.OpenAPIRefs))).sig
            @test signature.var.ub === expected
            # The method's bound and the struct's own bound are separate runtime facts
            # emitted from one descriptor key; a template that ever sourced them
            # differently would show up here and nowhere else.
            @test signature.var.ub === type.var.ub
        end
    end
end

@testset "available defaults to true when the kwarg is omitted" begin
    # The descriptor once defaulted `available` to the Python literal "True", which the
    # generator copied through verbatim into an UndefVarError at construction time.
    financials = TechnologyFinancialData(
        capital_recovery_period=20,
        technology_base_year=2024,
        debt_fraction=0.6,
        debt_rate=0.05,
        return_on_equity=0.1,
        tax_rate=0.21,
    )
    supply = SupplyTechnology{ThermalStandard}(;
        name="default_available_supply",
        power_systems_type="ThermalStandard",
        financial_data=financials,
    )
    storage = StorageTechnology{PSY.EnergyReservoirStorage}(;
        name="default_available_storage",
        available=true,
        power_systems_type="EnergyReservoirStorage",
        storage_tech=StorageTech.OTHER_CHEM,
        financial_data=financials,
    )
    @test PSIP.get_available(supply) === true

    colocated = ColocatedSupplyStorageTechnology{RenewableDispatch}(;
        name="default_available_colocated",
        power_systems_type="RenewableDispatch",
        financial_data=financials,
        capital_costs_inverter=PSIP.CapitalCost(LinearCurve(1000.0), 0.0),
        operation_costs_inverter=CostCurve(LinearCurve(0.0)),
        inverter_efficiency=0.98,
        inverter_supply_ratio=1.2,
        supply_technology=supply,
        storage_technology=storage,
    )
    @test PSIP.get_available(colocated) === true
end

@testset "portfolio serializes through the OpenAPI path" begin
    # Financial data is not optional on the read-back path: `from_dict` indexes into the
    # serialized `financial_data` object, so an empty `Portfolio()` cannot round trip.
    portfolio = Portfolio(2024, 0.07, 0.025, 0.05)
    zone = PSY.Area(; name="zone_a", base_power=100.0)
    zone_b = PSY.Area(; name="zone_b", base_power=100.0)
    req = CarbonTax(name="tax", available=true)
    IS.set_id!(zone, 1)
    IS.set_id!(zone_b, 2)
    IS.set_id!(req, 3)
    PSIP.add_topology!(portfolio, zone)
    PSIP.add_topology!(portfolio, zone_b)
    PSIP.add_requirement!(portfolio, req)
    financial_data = TechnologyFinancialData(
        capital_recovery_period=20,
        technology_base_year=2024,
        debt_fraction=0.6,
        debt_rate=0.05,
        return_on_equity=0.1,
        tax_rate=0.21,
    )
    tech = SupplyTechnology{ThermalStandard}(;
        name="cheap_thermal",
        available=true,
        power_systems_type="ThermalStandard",
        region=[zone],
        requirements=[req],
        capacity_limits=(min=0.0, max=500.0),
        capital_costs=PSIP.CapitalCost(LinearCurve(1000.0), 0.0),
        operation_costs=PSY.ThermalGenerationCost(nothing),
        fuel=[ThermalFuels.NATURAL_GAS],
        cofire_level_limits=Dict(ThermalFuels.NATURAL_GAS => (min=0.0, max=1.0)),
        financial_data=financial_data,
    )
    IS.set_id!(tech, 10)
    PSIP.add_technology!(portfolio, tech)

    # A transmission technology exercises the scalar `component_id`/`resolve_ref` path;
    # `SupplyTechnology` above only covers the `component_ids`/`resolve_refs` list form.
    line = AggregateTransportTechnology{PSY.ACBranch}(;
        name="test_branch",
        available=true,
        power_systems_type="ACBranch",
        start_region=zone,
        end_region=zone_b,
        capacity_limits=(min=0.0, max=900.0),
        line_loss=0.05,
        capital_costs=PSIP.CapitalCost(LinearCurve(5000.0), 0.0),
        financial_data=financial_data,
    )
    IS.set_id!(line, 11)
    PSIP.add_technology!(portfolio, line)

    # Colocated now references concrete supply/storage technologies and carries only
    # inverter economics on itself.
    storage_ref = StorageTechnology{PSY.EnergyReservoirStorage}(;
        name="colo_storage_ref",
        available=true,
        power_systems_type="EnergyReservoirStorage",
        storage_tech=StorageTech.OTHER_CHEM,
        financial_data=financial_data,
        region=[zone],
    )
    IS.set_id!(storage_ref, 13)
    PSIP.add_technology!(portfolio, storage_ref)

    colocated = ColocatedSupplyStorageTechnology{PSY.RenewableDispatch}(;
        name="colo",
        available=true,
        power_systems_type="RenewableDispatch",
        region=[zone],
        financial_data=financial_data,
        capital_costs_inverter=PSIP.CapitalCost(LinearCurve(700.0), 0.0),
        operation_costs_inverter=CostCurve(LinearCurve(6.0)),
        inverter_efficiency=0.96,
        inverter_supply_ratio=1.0,
        supply_technology=tech,
        storage_technology=storage_ref,
    )
    IS.set_id!(colocated, 12)
    PSIP.add_technology!(portfolio, colocated)

    retirement = RetirementPotential(
        eligible_generators=["Solitude"],
        retirement_cost=LinearCurve(100.0),
    )
    existing = ExistingDevices(existing_devices=["Solitude", "Alta"])
    IS.set_id!(retirement, 51)
    IS.set_id!(existing, 54)
    PSIP.add_supplemental_attribute!(portfolio, tech, retirement)
    PSIP.add_supplemental_attribute!(portfolio, line, existing)

    path = joinpath(mktempdir(), "portfolio.json")
    PSIP.to_json(portfolio, path; force=true)
    raw = JSON3.read(read(path, String), Dict)
    components = raw["data"]["components"]
    colocated_po = only(filter(c -> c["name"] == "colo", components))
    @test colocated_po["supply_technology"] == 10
    @test colocated_po["storage_technology"] == 13
    @test colocated_po["capital_costs_inverter"]["capital_cost"]["function_data"]["proportional_term"] ==
          700.0
    @test colocated_po["operation_costs_inverter"]["value_curve"]["function_data"]["proportional_term"] ==
          6.0
end

@testset "serialized aggregation is a fully qualified type name" begin
    # `Portfolio.aggregation` is a `Type`, and `IS` has no `serialize(::Type)` method, so
    # without an explicit emission JSON3 stringifies it through `show` — which resolves the
    # name against `Base.active_module()`. A writing session with `using PowerSystems` in
    # scope (the normal Sienna workflow) would then write the bare `"ACBus"`, which
    # `_deserialize_type_name` rejects, and the same portfolio would serialize differently
    # depending on who wrote it.
    #
    # The assertion is on the DOCUMENT TEXT, not on a round trip: ReTest's `Main` has no
    # `using PowerSystems`, so the `show` path happens to produce the qualified form here
    # and a round-trip-only test would pass either way. That is exactly how this got through.
    @test PSIP._serialize_type_name(PSY.ACBus) == "PowerSystems.ACBus"
    @test PSIP._serialize_type_name(PSY.Area) == "PowerSystems.Area"

    for aggregation in (PSY.ACBus, PSY.Area)
        portfolio = Portfolio(
            aggregation;
            financial_data=PortfolioFinancialData(2024, 0.07, 0.025, 0.05),
        )
        PSIP.add_topology!(portfolio, PSY.Area(; name="zone_a", base_power=100.0))
        path = joinpath(mktempdir(), "portfolio.json")
        PSIP.to_json(portfolio, path; force=true)

        raw = JSON3.read(read(path, String), Dict)
        @test raw["aggregation"] == "PowerSystems.$(nameof(aggregation))"
    end
end

@testset "serializing a lone component emits OpenAPI metadata" begin
    zone = PSY.Area(; name="orphan", base_power=100.0)
    raw = JSON3.read(PSIP.to_json(zone), Dict)
    @test raw["name"] == "orphan"
    @test raw["__metadata__"] == Dict("module" => "PowerSystems", "type" => "Area")
end
