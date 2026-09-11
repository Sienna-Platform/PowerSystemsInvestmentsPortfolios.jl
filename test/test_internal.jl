"""
Recursively validates that every component reachable from `obj` carries an id assigned by
the system it is attached to.
"""
validate_ids(::Any) = true

function validate_ids(component::IS.InfrastructureSystemsComponent)
    result = true
    if IS.get_id(component) == IS.UNASSIGNED_ID
        result = false
        @error "component has no id assigned" component
    end
    for fieldname in fieldnames(typeof(component))
        if !validate_ids(getfield(component, fieldname))
            result = false
        end
    end
    return result
end

function validate_ids(objs::AbstractArray)
    result = true
    for elem in objs
        if !validate_ids(elem)
            result = false
        end
    end
    return result
end

validate_ids(objs::AbstractDict) = validate_ids(collect(values(objs)))

@testset "Test internal values" begin
    port = build_portfolio()

    technologies = collect(get_technologies(PSIP.Technology, port))
    regions = collect(PSIP.get_regions(PSY.Topology, port))
    @test !isempty(technologies)
    @test !isempty(regions)
    @test validate_ids(technologies)
    @test validate_ids(regions)
end
