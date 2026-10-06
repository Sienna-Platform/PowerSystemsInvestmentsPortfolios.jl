@testset "OpenAPIRefs registration and resolution" begin
    refs = PSIP.OpenAPIRefs()
    zone = PSY.Area(; input_basis=PSY.CU, name="z1", base_power=100.0)
    node = PSY.ACBus(;
        input_basis=PSY.CU,
        number=907,
        name="n1",
        available=true,
        bustype=PSY.ACBusTypes.PQ,
        angle=0.0,
        magnitude=1.0,
        voltage_limits=(min=0.9, max=1.1),
        base_voltage=138.0,
        area=zone,
        load_zone=PSY.LoadZone(;
            input_basis=PSY.CU,
            name="z1_lz",
            peak_active_power=0.0,
            peak_reactive_power=0.0,
            base_power=100.0,
        ),
    )

    refs[1] = zone
    refs[2] = node

    @test PSIP.resolve_ref(refs, 1, PSY.Area) === zone
    @test PSIP.component_id(refs, node) == 2
    @test PSIP.has_topology_ref(refs, 1)
    @test !PSIP.has_topology_ref(refs, 99)
    # Topology and portfolio ids overlap, so a registered topology id says nothing about the
    # portfolio family: id 1 is a registered Area and still an unregistered component.
    @test !PSIP.has_component_ref(refs, 1)
    @test !isdefined(PSIP, :has_ref)
    @test PSIP.has_component_id(refs, zone)

    # `nothing` in, `nothing` out: an omitted optional reference is an absent
    # relationship, not a malformed one.
    @test isnothing(PSIP.resolve_ref(refs, nothing))
    @test PSIP.resolve_ref(refs, 2, PSY.ACBus) === node
    @test PSIP.resolve_refs(refs, [1], PSY.Area) == [zone]
    @test PSIP.resolve_refs(refs, [2], PSY.ACBus) == [node]
    @test isempty(PSIP.resolve_refs(refs, nothing, PSY.Area))
    @test PSIP.component_ids(refs, [node, zone]) == [2, 1]
end

@testset "OpenAPIRefs errors loudly on malformed input" begin
    refs = PSIP.OpenAPIRefs()
    zone = PSY.Area(; input_basis=PSY.CU, name="z1", base_power=100.0)
    refs[1] = zone

    @test_throws ErrorException refs[1] =
        PSY.Area(; input_basis=PSY.CU, name="other", base_power=100.0)
    @test_throws ErrorException refs[7]
    @test_throws ErrorException PSIP.resolve_ref(refs, 7, PSY.Area)
    @test_throws ErrorException PSIP.component_id(
        refs,
        PSY.ACBus(;
            input_basis=PSY.CU,
            number=908,
            name="n",
            available=true,
            bustype=PSY.ACBusTypes.PQ,
            angle=0.0,
            magnitude=1.0,
            voltage_limits=(min=0.9, max=1.1),
            base_voltage=138.0,
            area=zone,
            load_zone=PSY.LoadZone(;
                input_basis=PSY.CU,
                name="n_lz",
                peak_active_power=0.0,
                peak_reactive_power=0.0,
                base_power=100.0,
            ),
        ),
    )
end
