@testset "OpenAPIRefs registration and resolution" begin
    refs = PSIP.OpenAPIRefs()
    zone = PSY.Area(; name="z1", base_power=100.0)
    node = PSY.ACBus(;
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
    @test PSIP.has_ref(refs, 1)
    @test !PSIP.has_ref(refs, 99)
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
    zone = PSY.Area(; name="z1", base_power=100.0)
    refs[1] = zone

    @test_throws ErrorException refs[1] = PSY.Area(; name="other", base_power=100.0)
    @test_throws ErrorException refs[7]
    @test_throws ErrorException PSIP.resolve_ref(refs, 7, PSY.Area)
    @test_throws ErrorException PSIP.component_id(
        refs,
        PSY.ACBus(;
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
                name="n_lz",
                peak_active_power=0.0,
                peak_reactive_power=0.0,
                base_power=100.0,
            ),
        ),
    )
end
