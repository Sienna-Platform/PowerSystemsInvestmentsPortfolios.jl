@testset "Printing" begin
    @testset "text/plain Portfolio" begin
        port = build_portfolio()
        buf = IOBuffer()
        show(buf, MIME("text/plain"), port)
        out = String(take!(buf))

        @test occursin("Portfolio", out)
        @test occursin("Technologies", out)
        @test occursin("Topology", out)
        @test occursin("Zone", out)           # row content from topology table
        @test occursin("Node", out)           # row content from topology table
        @test occursin("Time Series", out)
    end

    @testset "text/html Portfolio" begin
        port = build_portfolio()
        buf = IOBuffer()
        show(buf, MIME("text/html"), port)
        out = String(take!(buf))

        @test occursin("Portfolio", out)
        @test occursin("Technologies", out)
        @test occursin("Topology", out)
        @test occursin("Time Series", out)
        @test occursin("<table", out)
    end

    @testset "text/plain Technology" begin
        port = build_portfolio()
        supply_techs = collect(get_technologies(SupplyTechnology, port))
        @test !isempty(supply_techs)
        tech = first(supply_techs)

        buf = IOBuffer()
        show(buf, MIME("text/plain"), tech)
        out = String(take!(buf))

        @test occursin("SupplyTechnology", out)
        @test occursin("has_time_series", out)
        @test occursin("has_supplemental_attributes", out)
    end

    @testset "show_region_topology_table empty portfolio" begin
        # Build an empty portfolio (no regions added) and verify no output is produced.
        # skip_serialization=true: PowerSystems.jl's OpenAPI export path
        # (export_cost_conversion.jl) still fails to serialize a CostCurve with no
        # vom_cost; that is a PowerSystems.jl bug, out of scope here.
        sys = build_system(PSITestSystems, "c_sys5_re"; skip_serialization=true)
        empty_port = Portfolio(sys)

        buf = IOBuffer()
        PSIP.show_region_topology_table(buf, empty_port; backend=:auto)
        out = String(take!(buf))

        @test isempty(out)
    end
end
