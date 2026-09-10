function build_portfolio()
    # skip_serialization=true: PowerSystems.jl's OpenAPI export path
    # (export_cost_conversion.jl) still fails to serialize a CostCurve with no vom_cost
    # (passes `nothing` where PC.CostCurve requires an InputOutputCurve); that is a
    # PowerSystems.jl bug, out of scope here. Building in memory does not exercise it.
    sys = build_system(PSITestSystems, "c_sys5_re"; skip_serialization=true)

    ###################
    ###### Zones ######
    ###################

    z1 = Zone(name="Zone_1")

    z2 = Zone(name="Zone_2")

    n1 = Node(name="node1")

    n2 = Node(name="node2")

    ###################
    ### Time Series ###
    ###################

    tstamp_2024_ops = collect(
        DateTime("1/1/2024  0:00:00", "d/m/y  H:M:S"):Hour(1):DateTime(
            "1/1/2024  23:00:00",
            "d/m/y  H:M:S",
        ),
    )
    tstamp_2028_ops = collect(
        DateTime("1/1/2028  0:00:00", "d/m/y  H:M:S"):Hour(1):DateTime(
            "1/1/2028  23:00:00",
            "d/m/y  H:M:S",
        ),
    )

    tstamp_ops = vcat(tstamp_2024_ops, tstamp_2028_ops)
    tstamp_inv = [
        DateTime("1/1/2024  0:00:00", "d/m/y  H:M:S"),
        DateTime("1/1/2028  0:00:00", "d/m/y  H:M:S"),
    ]

    ####################
    ##### Thermals #####
    ####################

    tech_financials = TechnologyFinancialData(;
        capital_recovery_period=30,
        technology_base_year=2025,
        debt_fraction=0.5,
        debt_rate=0.07,
        return_on_equity=0.1,
        tax_rate=0.257,
    )

    thermals = collect(get_components(ThermalStandard, sys))
    var_cost = PSY.get_variable_operation_cost.(get_operation_cost.(thermals))
    op_cost = get_proportional_term.(get_value_curve.(var_cost))

    cheap_th_ixs = 2:4
    exp_th_ixs = [1, 5]
    cheap_th_var_cost = mean(op_cost[cheap_th_ixs])
    exp_th_var_cost = mean(op_cost[exp_th_ixs])

    initial_cap_cheap = 100.0
    initial_cap_exp = 100.0
    # From Conservative 2024-ABT CAPEX: year 2024
    coal_igcc_capex = 6937.377 # $/kW
    coal_new_capex = 3823.56 # $/kW

    coal_igcc_capex_2028 = 6869.263 # $/kW
    coal_new_capex_2028 = 3664.307 # $/kW

    ts_th_cheap_inv_capex = SingleTimeSeries(
        "inv_capex",
        TimeArray(tstamp_inv, [1.0, coal_igcc_capex / coal_igcc_capex_2028]),
    )
    #
    ts_th_exp_inv_capex = SingleTimeSeries(
        "inv_capex",
        TimeArray(tstamp_inv, [1.0, coal_new_capex / coal_new_capex_2028]),
    )
    #, coal_new_capex / coal_new_capex_2028
    t_th = SupplyTechnology{PSY.ThermalStandard}(;
        prime_mover_type=PrimeMovers.ST,
        capital_costs=LinearCurve(coal_igcc_capex * 1000.0),
        available=true,
        name="cheap_thermal",
        fuel=[ThermalFuels.COAL],
        power_systems_type="ThermalStandard",
        operation_costs=ThermalGenerationCost(
            variable_operation_cost=FuelCurve(LinearCurve(cheap_th_var_cost), 1.12),
            fixed=0.0,
            start_up=0.0,
            shut_down=0.0,
        ),#LinearCurve(0.0),
        capacity_limits=(0.0, 3000.0),
        outage_factor=0.92,
        region=[z1],
        unit_size=250.0,
        financial_data=tech_financials,
    )

    t_th_exp = SupplyTechnology{PSY.ThermalStandard}(;
        prime_mover_type=PrimeMovers.ST,
        capital_costs=LinearCurve(coal_new_capex * 1000.0),
        available=true,
        name="expensive_thermal",
        fuel=[ThermalFuels.COAL],
        power_systems_type="ThermalStandard",
        operation_costs=ThermalGenerationCost(
            variable_operation_cost=CostCurve(LinearCurve(exp_th_var_cost)),
            fixed=0.0,
            start_up=0.0,
            shut_down=0.0,
        ),
        capacity_limits=(0.0, 3000.0),
        outage_factor=0.95,
        region=[z2],
        unit_size=75.0,
        financial_data=tech_financials,
    )

    ts_thermal_2024 = SingleTimeSeries(;
        data=TimeArray(tstamp_2024_ops, ones(24)),
        name="ops_variable_cap_factor",
    )
    ts_thermal_2028 = SingleTimeSeries(;
        data=TimeArray(tstamp_2028_ops, ones(24)),
        name="ops_variable_cap_factor",
    )
    #####################
    ##### Renewable #####
    #####################

    #### Wind ####
    local_path = @__DIR__
    data = CSV.read(joinpath(local_path, "data_utils/ts_data.csv"), DataFrame)
    wind_ts_vec = data[!, "Wind"] ./ 451.0
    renewables = collect(get_components(RenewableDispatch, sys))
    wind_op_costs =
        get_proportional_term.(
            get_value_curve.(
                PSY.get_variable_operation_cost.(get_operation_cost.(renewables))
            )
        )
    wind_op_cost = mean(wind_op_costs)
    # initial_cap_wind = sum(get_max_active_power.(renewables))
    initial_cap_wind = 0.0
    # From Conservative 2024-ABT CAPEX: year 2024 for Wind Class 4 Technology 1
    wind_capex = 1577.392 # $/kW
    wind_capex_2028 = 1522.152 #

    ts_wind_2024_data = wind_ts_vec[1:24]
    ts_wind_2028_data = wind_ts_vec[1:24]

    #ts_wind = SingleTimeSeries("ops_variable_cap_factor", TimeArray(tstamp_ops, vcat(ts_wind_2024, ts_wind_2028)))
    ts_wind_2024 = SingleTimeSeries(;
        data=TimeArray(tstamp_2024_ops, ts_wind_2024_data),
        name="ops_variable_cap_factor",
    )
    ts_wind_2028 = SingleTimeSeries(;
        data=TimeArray(tstamp_2028_ops, ts_wind_2028_data),
        name="ops_variable_cap_factor",
    )

    ts_wind_inv_capex = SingleTimeSeries(
        "inv_capex",
        TimeArray(tstamp_inv, [1.0, wind_capex / wind_capex_2028]),
    )

    t_wind = SupplyTechnology{PSY.RenewableDispatch}(;
        prime_mover_type=PrimeMovers.WT,
        capital_costs=LinearCurve(wind_capex * 1000.0), # to $/MW
        available=true,
        name="wind",
        fuel=[ThermalFuels.OTHER],
        power_systems_type="RenewableDispatch",
        operation_costs=ThermalGenerationCost(
            variable_operation_cost=CostCurve(LinearCurve(0.0)),
            fixed=wind_op_cost,
            start_up=0.0,
            shut_down=0.0,
        ),
        capacity_limits=(0.0, 300.0),
        outage_factor=0.92,
        region=[z2],
        financial_data=tech_financials,
    )

    #### Solar ###
    pv1_ts = data[!, "SolarPV1"] ./ 384.0
    pv2_ts = data[!, "SolarPV2"] ./ 384.0

    # From Conservative 2024-ABT CAPEX: year 2024 for Utility PV Class 4 
    pv_capex = 1575.766 # $/kW
    pv_capex_2028 = 1189.247 #

    ts_pv1_2024_data = pv1_ts[1:24]
    ts_pv1_2028_data = pv1_ts[1:24]
    ts_pv2_2024_data = pv2_ts[1:24]
    ts_pv2_2028_data = pv2_ts[1:24]

    #ts_wind = SingleTimeSeries("ops_variable_cap_factor", TimeArray(tstamp_ops, vcat(ts_wind_2024, ts_wind_2028)))
    ts_pv1_2024 = SingleTimeSeries(;
        data=TimeArray(tstamp_2024_ops, ts_pv1_2024_data),
        name="ops_variable_cap_factor",
    )
    ts_pv1_2028 = SingleTimeSeries(;
        data=TimeArray(tstamp_2028_ops, ts_pv1_2028_data),
        name="ops_variable_cap_factor",
    )

    ts_pv2_2024 = SingleTimeSeries(;
        data=TimeArray(tstamp_2024_ops, ts_pv2_2024_data),
        name="ops_variable_cap_factor",
    )
    ts_pv2_2028 = SingleTimeSeries(;
        data=TimeArray(tstamp_2028_ops, ts_pv2_2028_data),
        name="ops_variable_cap_factor",
    )

    ts_pv1_inv_capex = SingleTimeSeries(
        "inv_capex",
        TimeArray(tstamp_inv, [1.0, pv_capex / pv_capex_2028]),
    )
    ts_pv2_inv_capex = SingleTimeSeries(
        "inv_capex",
        TimeArray(tstamp_inv, [1.0, pv_capex / pv_capex_2028]),
    )

    t_pv1 = SupplyTechnology{PSY.RenewableDispatch}(;
        prime_mover_type=PrimeMovers.PVe,
        capital_costs=LinearCurve(pv_capex * 1000.0), # to $/MW
        available=true,
        name="PV1",
        fuel=[ThermalFuels.OTHER],
        power_systems_type="RenewableDispatch",
        operation_costs=ThermalGenerationCost(
            variable_operation_cost=CostCurve(LinearCurve(0.0)),
            fixed=0.0,
            start_up=0.0,
            shut_down=0.0,
        ),
        capacity_limits=(0.0, 1e8),
        outage_factor=0.92,
        region=[z1],
        financial_data=tech_financials,
    )

    t_pv2 = SupplyTechnology{PSY.RenewableDispatch}(;
        prime_mover_type=PrimeMovers.PVe,
        capital_costs=LinearCurve(pv_capex * 1000.0), # to $/MW
        available=true,
        name="PV2",
        fuel=[ThermalFuels.OTHER],
        power_systems_type="RenewableDispatch",
        operation_costs=ThermalGenerationCost(
            variable_operation_cost=CostCurve(LinearCurve(0.0)),
            fixed=0.0,
            start_up=0.0,
            shut_down=0.0,
        ),
        capacity_limits=(0.0, 1e8),
        outage_factor=0.92,
        region=[z2],
        financial_data=tech_financials,
    )

    #############################################################
    ######## Retirement, Retrofits, and Existing Capacity #######
    #############################################################

    thermal = collect(get_components(ThermalStandard, sys))

    # The schemas merged the aggregate variants into these two (SiennaSchemas d26fc75),
    # dropping the scalar `retrofit_potential`/`retirement_potential` in favour of an
    # eligible-generator list plus a cost curve, so these fixtures carry the fields that
    # survived rather than a per-technology aggregate total.
    retro1 = RetrofitPotential(retrofit_fraction=0.5)

    retire1 = RetirementPotential(retirement_cost=LinearCurve(100.0))

    retro2 = RetrofitPotential(eligible_generators=[PSY.get_name(t) for t in thermal[1:3]])

    retire2 =
        RetirementPotential(eligible_generators=[PSY.get_name(t) for t in thermal[4:5]])

    existing = ExistingDevices(existing_devices=[PSY.get_name(t) for t in thermal[1:3]])
    existing2 = ExistingDevices(existing_devices=["Solitude", "dummy name", "Alta"])

    ########################
    ######## Storage #######
    ########################
    stor_kw_capex = 1343.15 #$/kW
    stor_kwh_capex = 745.25 #$/kW
    t_stor = StorageTechnology{PSY.EnergyReservoirStorage}(;
        name="test_storage",
        region=[z1],
        storage_tech=StorageTech.LIB,
        capacity_limits_discharge=(0.0, 300.0),
        capacity_limits_energy=(0.0, 1000.0),
        power_systems_type="EnergyReservoirStorage",
        prime_mover_type=PrimeMovers.BT,
        available=true,
        capital_costs_discharge=LinearCurve(stor_kw_capex * 1000),
        capital_costs_energy=LinearCurve(stor_kwh_capex * 1000),
        operation_costs=StorageCost(
            charge_variable_cost=CostCurve(LinearCurve(0.0)),
            discharge_variable_cost=CostCurve(LinearCurve(0.0)),
            fixed=0.0,
        ),
        unit_size_discharge=10.0,
        unit_size_energy=10.0,
        financial_data=tech_financials,
    )
    ts_sto_2024 = SingleTimeSeries(;
        data=TimeArray(tstamp_2024_ops, ts_wind_2024_data),
        name="ops_variable_cap_factor",
    )
    ts_sto_2028 = SingleTimeSeries(;
        data=TimeArray(tstamp_2028_ops, ts_wind_2028_data),
        name="ops_variable_cap_factor",
    )

    #####################
    ######## Load #######
    #####################

    loads = collect(get_components(PowerLoad, sys))

    load_b_ts = data[!, "node_b"]
    load_c_ts = data[!, "node_c"]
    load_d_ts = data[!, "node_d"]

    ts_load_b_2024 = load_b_ts[1:24]
    ts_load_b_2028 = load_b_ts[1:24]

    ts_load_c_2024 = load_c_ts[1:24]
    ts_load_c_2028 = load_c_ts[1:24]

    ts_load_d_2024 = load_d_ts[1:24]
    ts_load_d_2028 = load_d_ts[1:24]

    ts_demand_b_2024 = SingleTimeSeries(
        "ops_peak_load",
        TimeArray(tstamp_2024_ops, ts_load_b_2024),
        #scaling_factor_multiplier=get_peak_load,
    )
    ts_demand_b_2028 = SingleTimeSeries(
        "ops_peak_load",
        TimeArray(tstamp_2028_ops, ts_load_b_2028),
        #scaling_factor_multiplier=get_peak_load,
    )

    t_demand_b = DemandRequirement{PSY.PowerLoad}(
        #load_growth=0.05,
        name="demand_b",
        available=true,
        power_systems_type="PowerLoad",
        region=[z1],
        value_of_lost_load=0.0,
        #peak_load=peak_load,
    )

    ts_demand_c_2024 = SingleTimeSeries(
        "ops_peak_load",
        TimeArray(tstamp_2024_ops, ts_load_c_2024),
        #scaling_factor_multiplier=get_peak_load,
    )
    ts_demand_c_2028 = SingleTimeSeries(
        "ops_peak_load",
        TimeArray(tstamp_2028_ops, ts_load_c_2028),
        #scaling_factor_multiplier=get_peak_load,
    )

    t_demand_c = DemandRequirement{PSY.PowerLoad}(
        #load_growth=0.05,
        name="demand_c",
        available=true,
        power_systems_type="PowerLoad",
        region=[z1],
        value_of_lost_load=0.0,
        #peak_load=peak_load,
    )

    ts_demand_d_2024 =
        SingleTimeSeries("ops_peak_load", TimeArray(tstamp_2024_ops, ts_load_d_2024))
    ts_demand_d_2028 =
        SingleTimeSeries("ops_peak_load", TimeArray(tstamp_2028_ops, ts_load_d_2028))

    t_demand_d = DemandRequirement{PSY.PowerLoad}(
        name="demand_d",
        available=true,
        power_systems_type="PowerLoad",
        region=[z2],
        value_of_lost_load=0.0,
    )

    demand_technology = DemandSideTechnology{PSY.PowerLoad}(
        name="test_demand",
        available=true,
        power_systems_type="PowerLoad",
        region=[z1],
    )

    ########################
    ##### Transmission #####
    ########################

    line = AggregateTransportTechnology{PSY.ACBranch}(
        name="test_branch",
        start_region=z1,
        end_region=z2,
        capacity_limits=(min=0, max=900),
        line_loss=0.05,
        capital_costs=LinearCurve(5000.0),
        available=true,
        power_systems_type=string(nameof(PSY.ACBranch)),
        financial_data=tech_financials,
    )

    line2 = AggregateTransportTechnology{PSY.ACBranch}(
        name="test_branch2",
        start_region=z1,
        end_region=z2,
        capacity_limits=(min=0, max=900),
        line_loss=0.05,
        capital_costs=LinearCurve(5000.0),
        available=true,
        power_systems_type=string(nameof(PSY.ACBranch)),
        financial_data=tech_financials,
    )

    acline = NodalACTransportTechnology{PSY.ACBranch}(
        name="test",
        available=true,
        power_systems_type=string(nameof(PSY.ACBranch)),
        capacity_limits=(min=0, max=900),
        capital_costs=LinearCurve(5000.0),
        start_node=n1,
        end_node=n2,
        financial_data=tech_financials,
        reactance=1,
    )

    ts_line_2024 = SingleTimeSeries(;
        data=TimeArray(tstamp_2024_ops, ts_wind_2024_data),
        name="ops_variable_cap_factor",
    )
    ts_line_2028 = SingleTimeSeries(;
        data=TimeArray(tstamp_2028_ops, ts_wind_2028_data),
        name="ops_variable_cap_factor",
    )

    ########################
    ##### Requirements #####
    ########################

    carbon_tax = CarbonTax(; name="test_tax", available=true, target_year=2030)
    carbon_cap = CarbonCaps(; name="test_cap", available=true, target_year=2030)

    crm = CapacityReserveMargin(; name="test_crm", available=true, target_year=2030)

    matching = HourlyMatching(; name="hourly_matching", available=true)
    max_req =
        MaximumCapacityRequirements(; name="test_max", available=true, target_year=2030)
    min_req =
        MinimumCapacityRequirements(; name="test_min", available=true, target_year=2030)

    esr = EnergyShareRequirements(;
        name="test_esr",
        available=true,
        generation_fraction_requirement=0.5,
    )

    #####################
    ##### Portfolio #####
    #####################

    # Build portfolio with base_system
    p_5bus = Portfolio(sys; financial_data=PortfolioFinancialData(2025, 0.07, 0.05, 0.03))

    #Regions
    PSIP.add_region!(p_5bus, z1)
    PSIP.add_region!(p_5bus, z2)
    PSIP.add_region!(p_5bus, n1)
    PSIP.add_region!(p_5bus, n2)

    #Supply
    PSIP.add_technology!(p_5bus, t_th)
    PSIP.add_technology!(p_5bus, t_wind)
    PSIP.add_technology!(p_5bus, t_pv1)
    PSIP.add_technology!(p_5bus, t_pv2)
    PSIP.add_technology!(p_5bus, t_th_exp)

    #Demands
    PSIP.add_technology!(p_5bus, t_demand_b)
    PSIP.add_technology!(p_5bus, t_demand_c)
    PSIP.add_technology!(p_5bus, t_demand_d)
    PSIP.add_technology!(p_5bus, demand_technology)

    #storage
    PSIP.add_technology!(p_5bus, t_stor)

    #Transmission
    PSIP.add_technology!(p_5bus, line)
    PSIP.add_technology!(p_5bus, line2)
    PSIP.add_technology!(p_5bus, acline)

    #Policy requirement
    PSIP.add_requirement!(p_5bus, carbon_tax)
    PSIP.add_requirement!(p_5bus, carbon_cap)
    PSIP.add_requirement!(p_5bus, crm)
    PSIP.add_requirement!(p_5bus, matching)
    PSIP.add_requirement!(p_5bus, min_req)
    PSIP.add_requirement!(p_5bus, max_req)
    PSIP.add_requirement!(p_5bus, esr)

    #Supplemental attributes
    PSIP.add_supplemental_attribute!(p_5bus, t_th_exp, retro1)
    PSIP.add_supplemental_attribute!(p_5bus, t_th_exp, retire1)
    PSIP.add_supplemental_attribute!(p_5bus, t_th, retro2)
    PSIP.add_supplemental_attribute!(p_5bus, t_th, retire2)
    PSIP.add_supplemental_attribute!(p_5bus, t_th, existing)
    PSIP.add_supplemental_attribute!(p_5bus, t_th_exp, existing2)

    #Time series
    PSIP.add_time_series!(p_5bus, t_th, ts_th_cheap_inv_capex)
    PSIP.add_time_series!(p_5bus, t_th_exp, ts_th_exp_inv_capex)
    PSIP.add_time_series!(
        p_5bus,
        t_th,
        ts_thermal_2024;
        features=Dict("year" => "2024", "rep_day" => 1),
    )
    PSIP.add_time_series!(
        p_5bus,
        t_th,
        ts_thermal_2028;
        features=Dict("year" => "2028", "rep_day" => 2),
    )
    PSIP.add_time_series!(
        p_5bus,
        t_th_exp,
        ts_thermal_2024;
        features=Dict("year" => "2024", "rep_day" => 1),
    )
    PSIP.add_time_series!(
        p_5bus,
        t_th_exp,
        ts_thermal_2028;
        features=Dict("year" => "2028", "rep_day" => 2),
    )

    PSIP.add_time_series!(
        p_5bus,
        t_wind,
        ts_wind_2024;
        features=Dict("year" => "2024", "rep_day" => 1),
    )
    PSIP.add_time_series!(
        p_5bus,
        t_wind,
        ts_wind_2028;
        features=Dict("year" => "2028", "rep_day" => 2),
    )
    PSIP.add_time_series!(p_5bus, t_wind, ts_wind_inv_capex)

    PSIP.add_time_series!(
        p_5bus,
        t_pv1,
        ts_pv1_2024;
        features=Dict("year" => "2024", "rep_day" => 1),
    )
    PSIP.add_time_series!(
        p_5bus,
        t_pv1,
        ts_pv1_2028;
        features=Dict("year" => "2028", "rep_day" => 2),
    )
    PSIP.add_time_series!(p_5bus, t_pv1, ts_pv1_inv_capex)
    PSIP.add_time_series!(
        p_5bus,
        t_pv2,
        ts_pv2_2024;
        features=Dict("year" => "2024", "rep_day" => 1),
    )
    PSIP.add_time_series!(
        p_5bus,
        t_pv2,
        ts_pv2_2028;
        features=Dict("year" => "2028", "rep_day" => 2),
    )
    PSIP.add_time_series!(p_5bus, t_pv2, ts_pv2_inv_capex)

    PSIP.add_time_series!(
        p_5bus,
        t_stor,
        ts_sto_2024;
        features=Dict("year" => "2024", "rep_day" => 1),
    )
    PSIP.add_time_series!(
        p_5bus,
        t_stor,
        ts_sto_2028;
        features=Dict("year" => "2028", "rep_day" => 2),
    )

    PSIP.add_time_series!(
        p_5bus,
        line,
        ts_line_2024;
        features=Dict("year" => "2024", "rep_day" => 1),
    )
    PSIP.add_time_series!(
        p_5bus,
        line,
        ts_line_2028;
        features=Dict("year" => "2028", "rep_day" => 2),
    )

    PSIP.add_time_series!(
        p_5bus,
        t_demand_b,
        ts_demand_b_2024;
        features=Dict("year" => "2024", "rep_day" => 1),
    )
    PSIP.add_time_series!(
        p_5bus,
        t_demand_b,
        ts_demand_b_2028;
        features=Dict("year" => "2028", "rep_day" => 2),
    )
    PSIP.add_time_series!(
        p_5bus,
        t_demand_c,
        ts_demand_c_2024;
        features=Dict("year" => "2024", "rep_day" => 1),
    )
    PSIP.add_time_series!(
        p_5bus,
        t_demand_c,
        ts_demand_c_2028;
        features=Dict("year" => "2028", "rep_day" => 2),
    )
    PSIP.add_time_series!(
        p_5bus,
        t_demand_d,
        ts_demand_d_2024;
        features=Dict("year" => "2024", "rep_day" => 1),
    )
    PSIP.add_time_series!(
        p_5bus,
        t_demand_d,
        ts_demand_d_2028;
        features=Dict("year" => "2028", "rep_day" => 2),
    )

    PSIP.add_time_series!(
        p_5bus,
        t_th,
        ts_thermal_2024;
        features=Dict("year" => "2024", "rep_day" => 3),
    )
    PSIP.add_time_series!(
        p_5bus,
        t_th,
        ts_thermal_2028;
        features=Dict("year" => "2028", "rep_day" => 4),
    )
    PSIP.add_time_series!(
        p_5bus,
        t_th_exp,
        ts_thermal_2024;
        features=Dict("year" => "2024", "rep_day" => 3),
    )
    PSIP.add_time_series!(
        p_5bus,
        t_th_exp,
        ts_thermal_2028;
        features=Dict("year" => "2028", "rep_day" => 4),
    )

    PSIP.add_time_series!(
        p_5bus,
        t_wind,
        ts_wind_2024;
        features=Dict("year" => "2024", "rep_day" => 3),
    )
    PSIP.add_time_series!(
        p_5bus,
        t_wind,
        ts_wind_2028;
        features=Dict("year" => "2028", "rep_day" => 4),
    )

    PSIP.add_time_series!(
        p_5bus,
        t_pv1,
        ts_pv1_2024;
        features=Dict("year" => "2024", "rep_day" => 3),
    )
    PSIP.add_time_series!(
        p_5bus,
        t_pv1,
        ts_pv1_2028;
        features=Dict("year" => "2028", "rep_day" => 4),
    )
    PSIP.add_time_series!(
        p_5bus,
        t_pv2,
        ts_pv2_2024;
        features=Dict("year" => "2024", "rep_day" => 3),
    )
    PSIP.add_time_series!(
        p_5bus,
        t_pv2,
        ts_pv2_2028;
        features=Dict("year" => "2028", "rep_day" => 4),
    )

    PSIP.add_time_series!(
        p_5bus,
        t_stor,
        ts_sto_2024;
        features=Dict("year" => "2024", "rep_day" => 3),
    )
    PSIP.add_time_series!(
        p_5bus,
        t_stor,
        ts_sto_2028;
        features=Dict("year" => "2028", "rep_day" => 4),
    )

    PSIP.add_time_series!(
        p_5bus,
        line,
        ts_line_2024;
        features=Dict("year" => "2024", "rep_day" => 3),
    )
    PSIP.add_time_series!(
        p_5bus,
        line,
        ts_line_2028;
        features=Dict("year" => "2028", "rep_day" => 4),
    )

    PSIP.add_time_series!(
        p_5bus,
        t_demand_b,
        ts_demand_b_2024;
        features=Dict("year" => "2024", "rep_day" => 3),
    )
    PSIP.add_time_series!(
        p_5bus,
        t_demand_b,
        ts_demand_b_2028;
        features=Dict("year" => "2028", "rep_day" => 4),
    )
    PSIP.add_time_series!(
        p_5bus,
        t_demand_c,
        ts_demand_c_2024;
        features=Dict("year" => "2024", "rep_day" => 3),
    )
    PSIP.add_time_series!(
        p_5bus,
        t_demand_c,
        ts_demand_c_2028;
        features=Dict("year" => "2028", "rep_day" => 4),
    )
    PSIP.add_time_series!(
        p_5bus,
        t_demand_d,
        ts_demand_d_2024;
        features=Dict("year" => "2024", "rep_day" => 3),
    )
    PSIP.add_time_series!(
        p_5bus,
        t_demand_d,
        ts_demand_d_2028;
        features=Dict("year" => "2028", "rep_day" => 4),
    )
    return p_5bus
end
