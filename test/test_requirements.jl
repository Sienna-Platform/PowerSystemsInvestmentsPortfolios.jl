@testset "Test requirement internal values" begin
    port = build_portfolio()

    technology = first(get_technologies(SupplyTechnology, port))
    @test !has_requirement(technology, Requirement)

    test_req =
        CarbonTax(; name="test", target_year=2025, tax_dollars_per_ton=50.0, available=true)
    set_requirements!(technology, [test_req])

    @test has_requirement(technology, test_req)

    contributors = get_contributing_technologies(port, test_req)
    @test length(contributors) == 1 && contributors[1] === technology
end
