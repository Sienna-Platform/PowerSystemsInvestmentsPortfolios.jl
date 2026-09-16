# @testset "Test parser" begin
#     db_path = joinpath(DATA_DIR, "RTS_inputs/rts_psy5.sqlite")
#     portfolio = PSIP.DBParser.database_to_portfolio(
#         db_path,
#         0.07,
#         0.03,
#         0.03,
#         2025;
#         aggregation=PSY.ACBus,
#     )
#     base_system = get_base_system(portfolio)

#     @test isa(portfolio, PSIP.Portfolio)
#     @test isa(base_system, PSY.System)

#     # Check that all components were parsed
#     @test length(collect(get_components(HydroReservoir, base_system))) == 19
#     @test length(collect(get_components(ACBus, base_system))) == 73
#     @test length(collect(get_components(Arc, base_system))) == 109
#     @test length(collect(get_components(Line, base_system))) == 105
#     @test length(collect(get_components(TwoWindingTransformer, base_system))) == 15
#     @test length(collect(get_components(PowerLoad, base_system))) == 73
#     @test length(collect(get_components(ThermalStandard, base_system))) == 73
#     @test length(collect(get_components(RenewableDispatch, base_system))) == 30
#     @test length(collect(get_components(RenewableNonDispatch, base_system))) == 31

#     # Check for existing technology attachments
#     gen_types = [ThermalStandard, RenewableDispatch, RenewableNonDispatch]
#     for g in gen_types
#         existing = 0
#         for t in get_technologies(SupplyTechnology{g}, portfolio)
#             if !is_new(t)
#                 # If existing, count to compare to base system
#                 existing += 1
#             else
#                 # If new, check that it has time series attached
#                 @test has_time_series(t)
#             end
#         end
#         @test existing == length(collect(get_components(g, base_system)))
#     end

#     # Check time series attachments in base system
#     db = SQLite.DB(db_path)
#     ts_data = DataFrame(
#         DBInterface.execute(
#             db,
#             "SELECT * FROM time_series_associations WHERE owner_category = 'Component';",
#         ),
#     )
#     total_ts = length(collect(get_time_series_multiple(base_system)))
#     @test total_ts == nrow(ts_data)
# end
