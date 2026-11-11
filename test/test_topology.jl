topology_financials() = TechnologyFinancialData(;
    capital_recovery_period=20,
    technology_base_year=2024,
    debt_fraction=0.5,
    debt_rate=0.05,
    return_on_equity=0.1,
    tax_rate=0.2,
)

topology_supply(name, region) = SupplyTechnology{PSY.ThermalStandard}(;
    name=name,
    power_systems_type="ThermalStandard",
    region=PSY.Topology[region],
    financial_data=topology_financials(),
)

@testset "Zones and nodes" begin
    port = Portfolio()
    @test PSIP.get_zone_type(port) == PSY.Area

    west = PSY.Area("West")
    east = PSY.Area("East")
    add_topology!(port, west)
    add_topology!(port, east)
    PSY.set_peak_active_power!(east, 250.0u"MW")
    @test get_name(west) == "West"
    @test PSY.get_peak_active_power(east, u"MW") ≈ 250.0
    @test Set(get_name.(get_zones(port))) == Set(["West", "East"])
    @test get_zone(port, "West") === west
    @test isnothing(get_zone(port, "North"))

    bus1 = PSY.ACBus("bus1"; zone=west, reference=true)
    bus2 = PSY.ACBus("bus2"; zone=west, base_voltage=345.0)
    bus3 = PSY.ACBus("bus3"; zone=east, number=10)
    foreach(bus -> add_topology!(port, bus), (bus1, bus2, bus3))
    @test PSY.get_bustype(bus1) == PSY.ACBusTypes.REF
    @test PSY.get_bustype(bus2) == PSY.ACBusTypes.PQ
    @test PSY.get_number.((bus1, bus2, bus3)) == (1, 2, 10)
    @test PSY.get_base_voltage(bus2) == 345.0
    @test get_node(port, "bus2") === bus2
    @test length(collect(get_nodes(port))) == 3
    @test Set(get_name.(get_nodes(port, west))) == Set(["bus1", "bus2"])
    @test get_zone(port, bus3) === east
    bus4 = PSY.ACBus("bus4")
    add_topology!(port, bus4)
    @test PSY.get_number(bus4) == 11
    # add_topology! numbers a bus too, so number 0 is never stored
    bus5, bus6 = PSY.ACBus("bus5"), PSY.ACBus("bus6")
    add_topology!(port, bus5)
    add_topology!(port, bus6)
    @test PSY.get_number.((bus5, bus6)) == (12, 13)
    # A peak power set before attachment is flagged
    @test_logs (:warn, r"before it was attached") add_topology!(
        port,
        PSY.Area("North", 10.0),
    )
end

@testset "Load zones as zones" begin
    port = Portfolio(PSY.LoadZone)
    @test PSIP.get_zone_type(port) == PSY.LoadZone
    zone = PSY.LoadZone("LZ")
    add_topology!(port, zone)
    node = PSY.ACBus("bus"; zone=zone)
    add_topology!(port, node)
    @test PSY.get_load_zone(node) === zone
    @test get_zone(port, node) === zone
    @test get_nodes(port, zone) == [node]
end

@testset "Technologies and lines by location" begin
    port = Portfolio()
    west, east, unused = PSY.Area("West"), PSY.Area("East"), PSY.Area("Unused")
    foreach(zone -> add_topology!(port, zone), (west, east, unused))
    PSIP.add_technology!(port, topology_supply("gas_west", west))
    PSIP.add_technology!(port, topology_supply("gas_east", east))
    line = AggregateTransportTechnology{PSY.ACBranch}(;
        name="west_east",
        start_region=west,
        end_region=east,
        power_systems_type="ACBranch",
        available=true,
        financial_data=topology_financials(),
    )
    PSIP.add_technology!(port, line)

    @test get_name.(get_technologies(SupplyTechnology, port, west)) == ["gas_west"]
    @test isempty(collect(get_technologies(SupplyTechnology, port, unused)))
    @test collect(get_lines(port, east)) == [line]
    @test isempty(collect(get_lines(port, unused)))

    # The zones an investment model builds over: those holding a technology or ending a line
    @test get_model_topologies(port, PSY.Area) == [east, west]
    @test isempty(get_model_topologies(port, PSY.ACBus))
end
