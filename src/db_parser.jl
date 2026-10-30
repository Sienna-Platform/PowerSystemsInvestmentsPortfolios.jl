
"""
Set of queries to extract relevant data from the database. Need to be maintained to be consistent with the most recent version of the database
"""
#TODO: Support scenario handling
const QUERIES = Dict(
    :zones => "SELECT * FROM planning_regions",
    :zone => "SELECT name FROM planning_regions WHERE id = ?",
    :zone_for_technology => "SELECT id FROM planning_regions WHERE name = ?",
    :balancing_topologies => "SELECT * FROM balancing_topologies WHERE area >= 1",
    :area_to_topology => "SELECT name FROM balancing_topologies WHERE area = ?",
    :topology_to_area => "SELECT area FROM balancing_topologies WHERE id = ?",
    :topology_for_unit => "SELECT name FROM balancing_topologies WHERE id = ?",
    :arcs => "SELECT * FROM arcs",
    :arc => "SELECT * FROM arcs WHERE id = ?",
    :topology_from_arc => "SELECT * FROM balancing_topologies WHERE id = ?",
    :aggregate_lines => "SELECT * FROM transmission_interchanges",
    :new_lines => "SELECT * from transport_technologies",
    :transmission_lines => "SELECT * FROM transmission_lines",
    :technologies => "SELECT * FROM supply_technologies",
    :generation_units => "SELECT * FROM generation_units",
    :storage_units => "SELECT * FROM storage_units",
    :demand_requirements => "SELECT * FROM loads",
    :entity_type => "SELECT entity_type FROM entities WHERE id = ?",
    :investment_timeseries => "SELECT * FROM time_series_associations WHERE owner_type = ?",
    :ts_data => "SELECT * FROM static_time_series WHERE uuid = ?",
    :reservoir => "SELECT * FROM hydro_reservoir_connections WHERE source_id = ? OR sink_id = ?",
    :reservoir_names => "SELECT * FROM hydro_reservoir WHERE id = ?",
    # add additional queries here as needed
)

# Ported from SiennaGridDB
const DB_TO_OPENAPI_FIELDS = Dict(
    ("transmission_lines", "arc_id") => "arc_",
    ("generation_units", "balancing_topology") => "bus",
    ("storage_units", "balancing_topology") => "bus",
    ("supply_technologies", "balancing_topology") => "bus",
    ("loads", "balancing_topology") => "bus",
    ("generation_units", "prime_mover") => "prime_mover_type",
    ("storage_units", "prime_mover") => "prime_mover_type",
    ("arcs", "from_id") => "from",
    ("arcs", "to_id") => "to",
    ("transmission_lines", "continuous_rating") => "rating",
)

const STORAGE_MAPPING =
    Dict("Hydro" => StorageTech.PTES, "Solar" => StorageTech.OTHER_THERM)

const FUEL_MAPPING = Dict(
    "NG" => ThermalFuels.NATURAL_GAS,
    "NATURAL_GAS" => ThermalFuels.NATURAL_GAS,
    "Nuclear" => ThermalFuels.NUCLEAR,
    "Coal" => ThermalFuels.COAL,
    "COAL" => ThermalFuels.COAL,
    "Oil" => ThermalFuels.DISTILLATE_FUEL_OIL,
    "DISTILLATE_FUEL_OIL" => ThermalFuels.DISTILLATE_FUEL_OIL,
)

const PRIME_MOVER_MAPPING = Dict(
    "CT" => PrimeMovers.CT,
    "STEAM" => PrimeMovers.ST,
    "CC" => PrimeMovers.CC,
    "SYNC_COND" => PrimeMovers.OT,
    "NUCLEAR" => PrimeMovers.ST,
    "HYDRO" => PrimeMovers.PS,
    "ROR" => PrimeMovers.IC,
    "PV" => PrimeMovers.PVe,
    "CSP" => PrimeMovers.CP,
    "RTPV" => PrimeMovers.PVe,
    "WIND" => PrimeMovers.WT,
    "Wind" => PrimeMovers.WT,
    "STORAGE" => PrimeMovers.BA,
    "CSP" => PrimeMovers.CP,
)

const PRIME_MOVER_TO_PARAMETRIC = Dict(
    "CT" => PSY.ThermalStandard,
    "STEAM" => PSY.ThermalStandard,
    "CC" => PSY.ThermalStandard,
    "ST" => PSY.ThermalStandard,
    "SYNC_COND" => PSY.ThermalStandard,
    "NUCLEAR" => PSY.ThermalStandard,
    "HYDRO" => PSY.ThermalStandard,
    "ROR" => PSY.RenewableDispatch,
    "PV" => PSY.RenewableDispatch,
    "PVe" => PSY.RenewableDispatch,
    "CSP" => PSY.RenewableDispatch,
    "RTPV" => PSY.RenewableDispatch,
    "WIND" => PSY.RenewableDispatch,
    "Wind" => PSY.RenewableDispatch,
    "WT" => PSY.RenewableDispatch,
    "BA" => PSY.EnergyReservoirStorage,
    "PS" => PSY.EnergyReservoirStorage,
    "STORAGE" => PSY.EnergyReservoirStorage,
    "CP" => PSY.RenewableDispatch,
)

const PRIME_MOVER_TO_TIMESERIES = Dict(
    [PrimeMovers.BA, ThermalFuels.OTHER] => "Battery",
    [PrimeMovers.PVe, ThermalFuels.OTHER] => "PV",
    [PrimeMovers.CP, ThermalFuels.OTHER] => "CSP",
    [PrimeMovers.WT, ThermalFuels.OTHER] => "Wind",
    [PrimeMovers.CT, ThermalFuels.NATURAL_GAS] => "NGCT",
    [PrimeMovers.CT, ThermalFuels.DISTILLATE_FUEL_OIL] => "OGS",
    [PrimeMovers.ST, ThermalFuels.COAL] => "Coal",
    [PrimeMovers.ST, ThermalFuels.DISTILLATE_FUEL_OIL] => "OGS",
    [PrimeMovers.ST, ThermalFuels.NUCLEAR] => "Nuclear",
    [PrimeMovers.CC, ThermalFuels.NATURAL_GAS] => "NGCC",

    #Defaults for others
    [PrimeMovers.ST, ThermalFuels.OTHER] => "Coal",
    [PrimeMovers.CT, ThermalFuels.OTHER] => "NGCT",
    [PrimeMovers.CC, ThermalFuels.OTHER] => "NGCC",
)

# Remove later, or make this optional later depending on what is in the dataset
const DEFAULT_FINANCIAL_DATA = TechnologyFinancialData(;
    capital_recovery_period=30,
    technology_base_year=2025,
    debt_fraction=0.5,
    debt_rate=0.07,
    return_on_equity=0.1,
    tax_rate=0.257,
)

"""
The following function imports from the database and generates the structs for a portfolio.
Portfolio-level financial data is not stored in the database and must be provided separately.
See `PortfolioFinancialData`(@ref) for more details.

# Arguments

  - `database_filepath::AbstractString`: The path to the SQLite database file
  - `discount_rate::Float64`: The discount rate for the portfolio
  - `inflation_rate::Float64`: The inflation rate for the portfolio
  - `interest_rate::Float64`: The interest rate for the portfolio
  - `base_year::Int64`: The base year for the portfolio
  - `aggregation::Type{<:Union{PSY.ACBus, PSY.AggregationTopology}}`: (default: `PSY.ACBus`) The aggregation level for the portfolio. Defaults to a nodal aggregation level
  - `system::PSY.System`: (default: `PSY.System(100.0)`) The base power system for the portfolio
"""
function database_to_portfolio(
    database_filepath::AbstractString,
    discount_rate::Float64,
    inflation_rate::Float64,
    interest_rate::Float64,
    base_year::Int64;
    aggregation::Type{<:Union{PSY.ACBus, PSY.AggregationTopology}}=DEFAULT_AGGREGATION,
    system::PSY.System=PSY.System(100.0),
)
    portfolio = Portfolio(
        aggregation,
        base_year,
        discount_rate,
        inflation_rate,
        interest_rate;
        base_system=system,
    )
    portfolio = database_to_structs(database_filepath, portfolio)

    return portfolio
end

function database_to_structs(db_path::AbstractString, portfolio::Portfolio)
    # Connect to the SQLite database
    db = SQLite.DB(db_path)

    #Prepare SQL statements
    stmts = prepare_statements(db)

    attributes = get_entity_attributes(db)

    # Add zones and lines, shouldn't add both aggregate lines and nodal lines to the same DB
    # User can provide a desired aggregation level and then we can select based on that

    if get_aggregation(portfolio) === PSY.ACBus
        add_nodes!(portfolio, attributes, stmts)
        add_nodal_lines!(portfolio, attributes, stmts)
    else
        add_zones!(portfolio, attributes, stmts)
        add_aggregate_lines!(portfolio, attributes, stmts)
    end

    add_technologies!(portfolio, attributes, stmts)
    add_demand_requirements!(portfolio, attributes, stmts)
    add_demand_technologies!(portfolio, attributes, stmts)

    add_buses!(portfolio, attributes, stmts)
    add_system_lines!(portfolio, attributes, stmts)
    add_generation_units!(portfolio, attributes, stmts)
    add_storage_units!(portfolio, attributes, stmts)
    add_loads!(portfolio, attributes, stmts)

    deserialize_timeseries!(portfolio.base_system, db, attributes)
    deserialize_portfolio_timeseries!(portfolio, stmts)

    return portfolio
end

function prepare_statements(db::SQLite.DB)
    stmts = Dict()
    for (k, v) in QUERIES
        stmts[k] = DBInterface.prepare(db, v)
    end
    return stmts
end

# Ported from SiennaGridDB
function get_entity_attributes(db)
    # First, get all attributes for this entity type and group them by entity_id
    attributes_query = """
    SELECT entity_id,
           json_group_object(name, json(value)) AS attribute_json
    FROM attributes
    GROUP BY entity_id
    """

    attributes_result = DBInterface.execute(db, attributes_query, strict=true)

    # Create a dictionary of entity_id => attributes
    attributes_dict = Dict{Int64, Dict{String, Any}}()
    for row in attributes_result
        attributes_dict[row.entity_id] = JSON3.read(row.attribute_json, Dict{String, Any})
    end

    return attributes_dict
end

# Ported from SiennaGridDB
function make_dict(
    ::Type{T},
    table_name::AbstractString,
    row,
    extra_attributes::Dict{String, Any},
) where {T}
    return merge(
        Dict(
            get(DB_TO_OPENAPI_FIELDS, (table_name, string(k)), string(k)) =>
                coalesce(v, nothing) for (k, v) in zip(propertynames(row), row)
        ),
        extra_attributes,
    )
end
function parse_thermal_cost(ops_cost::Dict{String, Any})
    start_up_dict = ops_cost["start_up"]
    variable_dict = ops_cost["variable"]
    operational_cost = ThermalGenerationCost(;
        start_up=(
            hot=Float64(start_up_dict["hot"]),
            warm=Float64(start_up_dict["warm"]),
            cold=Float64(start_up_dict["cold"]),
        ),
        shut_down=ops_cost["shut_down"],
        fixed=ops_cost["fixed"],
        variable=FuelCurve(;
            fuel_cost=variable_dict["fuel_cost"],
            value_curve=IncrementalCurve(
                PiecewiseStepData(
                    variable_dict["value_curve"]["function_data"]["x_coords"],
                    variable_dict["value_curve"]["function_data"]["y_coords"],
                ),
                variable_dict["value_curve"]["initial_input"],
            ),
            vom_cost=InputOutputCurve(
                LinearFunctionData(
                    constant_term=variable_dict["vom_cost"]["function_data"]["constant_term"],
                    proportional_term=variable_dict["vom_cost"]["function_data"]["proportional_term"],
                ),
            ),
        ),
    )
    return operational_cost
end

function parse_renewable_cost(ops_cost::Dict{String, Any})
    curtailment_dict = ops_cost["curtailment_cost"]
    variable_dict = ops_cost["variable"]
    operational_cost = RenewableGenerationCost(;
        curtailment_cost=CostCurve(;
            value_curve=InputOutputCurve(
                LinearFunctionData(
                    constant_term=curtailment_dict["value_curve"]["function_data"]["constant_term"],
                    proportional_term=curtailment_dict["value_curve"]["function_data"]["proportional_term"],
                ),
            ),
            vom_cost=InputOutputCurve(
                LinearFunctionData(
                    constant_term=curtailment_dict["vom_cost"]["function_data"]["constant_term"],
                    proportional_term=curtailment_dict["vom_cost"]["function_data"]["proportional_term"],
                ),
            ),
        ),
        variable=CostCurve(;
            value_curve=InputOutputCurve(
                LinearFunctionData(
                    constant_term=variable_dict["value_curve"]["function_data"]["constant_term"],
                    proportional_term=variable_dict["value_curve"]["function_data"]["proportional_term"],
                ),
            ),
            vom_cost=InputOutputCurve(
                LinearFunctionData(
                    constant_term=variable_dict["vom_cost"]["function_data"]["constant_term"],
                    proportional_term=variable_dict["vom_cost"]["function_data"]["proportional_term"],
                ),
            ),
        ),
    )
    return operational_cost
end

function parse_storage_cost(ops_cost::Dict{String, Any})
    charge_variable_dict = ops_cost["charge_variable_cost"]
    discharge_variable_dict = ops_cost["discharge_variable_cost"]
    operational_cost = StorageCost(;
        charge_variable_cost=CostCurve(;
            value_curve=InputOutputCurve(
                LinearFunctionData(
                    constant_term=charge_variable_dict["value_curve"]["function_data"]["constant_term"],
                    proportional_term=charge_variable_dict["value_curve"]["function_data"]["proportional_term"],
                ),
            ),
            vom_cost=InputOutputCurve(
                LinearFunctionData(
                    constant_term=charge_variable_dict["vom_cost"]["function_data"]["constant_term"],
                    proportional_term=charge_variable_dict["vom_cost"]["function_data"]["proportional_term"],
                ),
            ),
        ),
        discharge_variable_cost=CostCurve(;
            value_curve=InputOutputCurve(
                LinearFunctionData(
                    constant_term=discharge_variable_dict["value_curve"]["function_data"]["constant_term"],
                    proportional_term=discharge_variable_dict["value_curve"]["function_data"]["proportional_term"],
                ),
            ),
            vom_cost=InputOutputCurve(
                LinearFunctionData(
                    constant_term=discharge_variable_dict["vom_cost"]["function_data"]["constant_term"],
                    proportional_term=discharge_variable_dict["vom_cost"]["function_data"]["proportional_term"],
                ),
            ),
        ),
        start_up=Float64(ops_cost["start_up"]),
        shut_down=ops_cost["shut_down"],
        energy_shortage_cost=ops_cost["energy_shortage_cost"],
        energy_surplus_cost=ops_cost["energy_surplus_cost"],
        fixed=ops_cost["fixed"],
    )
    return operational_cost
end

function parse_hydro_cost(ops_cost::Dict{String, Any})
    variable_dict = ops_cost["variable"]
    operational_cost = HydroGenerationCost(;
        variable=CostCurve(;
            value_curve=InputOutputCurve(
                LinearFunctionData(
                    constant_term=variable_dict["value_curve"]["function_data"]["constant_term"],
                    proportional_term=variable_dict["value_curve"]["function_data"]["proportional_term"],
                ),
            ),
            vom_cost=InputOutputCurve(
                LinearFunctionData(
                    constant_term=variable_dict["vom_cost"]["function_data"]["constant_term"],
                    proportional_term=variable_dict["vom_cost"]["function_data"]["proportional_term"],
                ),
            ),
        ),
        fixed=ops_cost["fixed"],
    )
    return operational_cost
end

function parse_hydro_res_cost(ops_cost::Dict{String, Any})
    operational_cost = HydroReservoirCost(;
        level_shortage_cost=ops_cost["level_shortage_cost"],
        level_surplus_cost=ops_cost["level_surplus_cost"],
        spillage_cost=ops_cost["spillage_cost"],
    )
    return operational_cost
end

function parse_operational_cost(ops_cost::Dict{String, Any})
    if ops_cost["cost_type"] == "THERMAL"
        operational_cost = parse_thermal_cost(ops_cost)
    elseif ops_cost["cost_type"] == "RENEWABLE"
        operational_cost = parse_renewable_cost(ops_cost)
    elseif ops_cost["cost_type"] == "STORAGE"
        operational_cost = parse_storage_cost(ops_cost)
    elseif ops_cost["cost_type"] == "HYDRO_GEN"
        operational_cost = parse_hydro_cost(ops_cost)
    elseif ops_cost["cost_type"] == "HYDRO_RES"
        operational_cost = parse_hydro_res_cost(ops_cost)
    else
        error("Unsupported operational cost of type $(ops_cost["cost_type"])")
    end
    return operational_cost
end

function add_zones!(p::Portfolio, attributes::Dict{Int64, Dict{String, Any}}, stmts::Dict)
    for rec in IS.execute(stmts[:zones], nothing, IS.LOG_GROUP_SERIALIZATION)
        z = Zone(; name=rec.name, id=rec.id)
        add_region!(p, z)
    end
end

function add_nodes!(
    portfolio::Portfolio,
    attributes::Dict{Int64, Dict{String, Any}},
    stmts::Dict,
)
    for rec in IS.execute(stmts[:balancing_topologies], nothing, IS.LOG_GROUP_SERIALIZATION)
        z = Node(; name=rec.name, id=rec.id)
        add_region!(portfolio, z)
    end
end

function add_buses!(
    portfolio::Portfolio,
    attributes::Dict{Int64, Dict{String, Any}},
    stmts::Dict,
)
    for rec in IS.execute(stmts[:zones], nothing, IS.LOG_GROUP_SERIALIZATION)
        component_attr = get(attributes, rec.id, Dict{String, Any}())
        area = Area(;
            name=rec.name,
            load_response=component_attr["load_response"],
            peak_active_power=component_attr["peak_active_power"],
            peak_reactive_power=component_attr["peak_reactive_power"],
        )
        if haskey(component_attr, "uuid")
            IS.set_uuid!(IS.get_internal(area), Base.UUID(component_attr["uuid"]))
        else
            warn("UUID for component named $(rec.name) not found in database")
        end
        PSY.add_component!(portfolio.base_system, area)
    end
    for rec in IS.execute(stmts[:balancing_topologies], nothing, IS.LOG_GROUP_SERIALIZATION)
        component_attr = get(attributes, rec.id, Dict{String, Any}())
        area_name =
            first(IS.execute(stmts[:zone], [rec.area], IS.LOG_GROUP_SERIALIZATION)).name
        bus = PSY.ACBus(;
            name=rec.name,
            number=rec.id,
            available=component_attr["available"],
            bustype=PSY.get_enum_value(PSY.ACBusTypes, component_attr["bustype"]),
            angle=component_attr["angle"],
            magnitude=component_attr["magnitude"],
            area=get_component(Area, portfolio.base_system, area_name),
            voltage_limits=nothing,
            base_voltage=component_attr["base_voltage"],
            load_zone=nothing,
        )
        if haskey(component_attr, "uuid")
            IS.set_uuid!(IS.get_internal(bus), Base.UUID(component_attr["uuid"]))
        else
            warn("UUID for component named $(rec.name) not found in database")
        end
        PSY.add_component!(portfolio.base_system, bus)
    end
end

function add_aggregate_lines!(
    portfolio::Portfolio,
    attributes::Dict{Int64, Dict{String, Any}},
    stmts::Dict,
)
    for rec in IS.execute(stmts[:aggregate_lines], nothing, IS.LOG_GROUP_SERIALIZATION)
        component_attr = get(attributes, rec.id, Dict{String, Any}())
        area_to_id = parse(Int64, rec.area_to)
        area_from_id = parse(Int64, rec.area_from)
        t = AggregateTransportTechnology{ACBranch}(;
            name=string(rec.rowid),
            id=rec.rowid,
            available=component_attr["available"],
            base_power=100.0,
            power_systems_type=string(nameof(ACBranch)),
            financial_data=DEFAULT_FINANCIAL_DATA,
            start_region=collect(
                IS.get_components(
                    x -> get_id(x) == area_from_id,
                    RegionTopology,
                    portfolio.data,
                ),
            )[1],
            end_region=collect(
                IS.get_components(
                    x -> get_id(x) == area_to_id,
                    RegionTopology,
                    portfolio.data,
                ),
            )[1],
            capacity_limits=(min=0.0, max=max(rec.max_flow_from, rec.max_flow_to)),
            capital_costs=LinearCurve(1e5),
        )
        add_technology!(portfolio, t)
    end
end

# Will be used for new candidate transmission options in the future if in database
function add_nodal_lines!(
    portfolio::Portfolio,
    attributes::Dict{Int64, Dict{String, Any}},
    stmts::Dict,
)
    for rec in IS.execute(stmts[:new_lines], nothing, IS.LOG_GROUP_SERIALIZATION)
        component_attr = get(attributes, rec.id, Dict{String, Any}())
        arc = first(IS.execute(stmts[:arc], [rec.arc_id], IS.LOG_GROUP_SERIALIZATION))
        balancing_topology_from =
            first(
                IS.execute(
                    stmts[:topology_from_arc],
                    [arc.from_id],
                    IS.LOG_GROUP_SERIALIZATION,
                ),
            ).name
        balancing_topology_to =
            first(
                IS.execute(
                    stmts[:topology_from_arc],
                    [arc.to_id],
                    IS.LOG_GROUP_SERIALIZATION,
                ),
            ).name
        @show rec.id
        transport = NodalACTransportTechnology{ACBranch}(;
            name=string(rec.arc_id) * "_newline",
            id=rec.id,
            available=true,
            power_systems_type=string(nameof(ACBranch)),
            financial_data=DEFAULT_FINANCIAL_DATA,
            start_node=get_region(Node, portfolio, balancing_topology_from),
            end_node=get_region(Node, portfolio, balancing_topology_to),
            reactance=component_attr["reactance"],
            resistance=component_attr["resistance"],
            capital_costs=LinearCurve(1e5),
            unit_size=component_attr["unit_size"],
        )
        add_technology!(portfolio, transport)
    end
end

function add_technologies!(
    portfolio::Portfolio,
    attributes::Dict{Int64, Dict{String, Any}},
    stmts::Dict,
)
    for rec in IS.execute(stmts[:technologies], nothing, IS.LOG_GROUP_SERIALIZATION)
        parametric = get(PRIME_MOVER_TO_PARAMETRIC, rec.prime_mover, PSY.ThermalStandard)

        if get_aggregation(portfolio) == PSY.ACBus
            area_id =
                first(
                    IS.execute(
                        stmts[:zone_for_technology],
                        [rec.area],
                        IS.LOG_GROUP_SERIALIZATION,
                    ),
                ).id
            regions = [
                get_region(Node, portfolio, row.name) for row in IS.execute(
                    stmts[:area_to_topology],
                    [area_id],
                    IS.LOG_GROUP_SERIALIZATION,
                )
            ]
        else
            regions = [get_region(Zone, portfolio, rec.area)]
        end

        if rec.prime_mover == "STORAGE"
            technology = StorageTechnology{parametric}(;
                name=rec.prime_mover * string(rec.id),
                id=rec.id,
                capital_costs_discharge=LinearCurve(0.0),
                prime_mover_type=get(PRIME_MOVER_MAPPING, rec.prime_mover, PrimeMovers.OT),
                storage_tech=get(STORAGE_MAPPING, rec.fuel, StorageTech.OTHER_THERM),
                region=regions,
                financial_data=DEFAULT_FINANCIAL_DATA,
                available=true,
                power_systems_type=string(nameof(parametric)),
                operation_costs=StorageCost(),
            )
        elseif rec.prime_mover in ["HYDRO", "ROR", "SYNC_COND"]
            @warn "Technologies of type $(rec.prime_mover) are not currently supported in portfolios. Skipping de-serialization."
            continue
        else
            technology = SupplyTechnology{parametric}(;
                name=rec.prime_mover * string(rec.id),
                id=rec.id,
                capital_costs=LinearCurve(0.0),
                prime_mover_type=get(PRIME_MOVER_MAPPING, rec.prime_mover, PrimeMovers.OT),
                fuel=[get(FUEL_MAPPING, rec.fuel, ThermalFuels.OTHER)],
                co2=Dict(get(FUEL_MAPPING, rec.fuel, ThermalFuels.OTHER) => 0.0),
                region=regions,
                financial_data=DEFAULT_FINANCIAL_DATA,
                available=true,
                power_systems_type=string(nameof(parametric)),
                operation_costs=ThermalGenerationCost(
                    variable=CostCurve(LinearCurve(0.0)),
                    fixed=0.0,
                    start_up=0.0,
                    shut_down=0.0,
                ),
            )
        end
        add_technology!(portfolio, technology)
    end
end

function add_generation_units!(
    portfolio::Portfolio,
    attributes::Dict{Int64, Dict{String, Any}},
    stmts::Dict,
)
    for rec in IS.execute(stmts[:generation_units], nothing, IS.LOG_GROUP_SERIALIZATION)
        downstream = true

        component_type = getproperty(
            PowerSystems,
            Symbol(
                first(
                    IS.execute(stmts[:entity_type], [rec.id], IS.LOG_GROUP_SERIALIZATION),
                ).entity_type,
            ),
        )
        component_attr = get(attributes, rec.id, Dict{String, Any}())

        bus_name =
            first(
                IS.execute(
                    stmts[:topology_for_unit],
                    [rec.balancing_topology],
                    IS.LOG_GROUP_SERIALIZATION,
                ),
            ).name

        if component_type == PSY.ThermalStandard
            time_limits = (
                up=component_attr["time_limits"]["up"],
                down=component_attr["time_limits"]["down"],
            )
            ramp_limits = (
                up=component_attr["ramp_limits"]["up"] / rec.base_power,
                down=component_attr["ramp_limits"]["down"] / rec.base_power,
            )
            active_limits = (
                min=component_attr["active_power_limits"]["min"] / rec.base_power,
                max=component_attr["active_power_limits"]["max"] / rec.base_power,
            )
            reactive_limits = (
                min=component_attr["reactive_power_limits"]["min"] / rec.base_power,
                max=component_attr["reactive_power_limits"]["max"] / rec.base_power,
            )

            ops_cost = parse_operational_cost(component_attr["operation_cost"])
            generator = component_type(;
                name=rec.name,
                rating=rec.rating / rec.base_power,
                base_power=rec.base_power,
                available=component_attr["available"],
                status=component_attr["status"],
                bus=PSY.get_component(PSY.ACBus, portfolio.base_system, bus_name),
                prime_mover_type=PSY.get_enum_value(PSY.PrimeMovers, rec.prime_mover),
                active_power_limits=active_limits,
                active_power=get(component_attr, "active_power", rec.rating) /
                             rec.base_power,
                reactive_power=get(component_attr, "reactive_power", rec.rating) /
                               rec.base_power,
                reactive_power_limits=reactive_limits,
                ramp_limits=ramp_limits,
                time_limits=time_limits,
                operation_cost=ops_cost,
                fuel=get(FUEL_MAPPING, component_attr["fuel_type"], ThermalFuels.OTHER),
            )

        elseif component_type == PSY.RenewableDispatch
            reactive_limits = (
                min=component_attr["reactive_power_limits"]["min"] / rec.base_power,
                max=component_attr["reactive_power_limits"]["max"] / rec.base_power,
            )
            ops_cost = parse_operational_cost(component_attr["operation_cost"])
            generator = component_type(;
                name=rec.name,
                rating=rec.rating / rec.base_power,
                base_power=rec.base_power,
                available=component_attr["available"],
                bus=PSY.get_component(PSY.ACBus, portfolio.base_system, bus_name),
                prime_mover_type=PSY.get_enum_value(PSY.PrimeMovers, rec.prime_mover),
                active_power=get(component_attr, "active_power", rec.rating) /
                             rec.base_power,
                reactive_power=get(component_attr, "reactive_power", rec.rating) /
                               rec.base_power,
                reactive_power_limits=reactive_limits,
                power_factor=get(component_attr, "power_factor", 1.0),
                operation_cost=ops_cost,
            )

        elseif component_type == PSY.RenewableNonDispatch
            ops_cost = RenewableGenerationCost(nothing)
            generator = component_type(;
                name=rec.name,
                rating=rec.rating / rec.base_power,
                base_power=rec.base_power,
                available=component_attr["available"],
                bus=PSY.get_component(PSY.ACBus, portfolio.base_system, bus_name),
                prime_mover_type=PSY.get_enum_value(PSY.PrimeMovers, rec.prime_mover),
                active_power=get(component_attr, "active_power", rec.rating) /
                             rec.base_power,
                reactive_power=get(component_attr, "reactive_power", rec.rating) /
                               rec.base_power,
                power_factor=get(component_attr, "power_factor", 1.0),
            )
        elseif component_type == PSY.HydroDispatch
            time_limits = (
                up=component_attr["time_limits"]["up"],
                down=component_attr["time_limits"]["down"],
            )
            ramp_limits = (
                up=component_attr["ramp_limits"]["up"] / rec.base_power,
                down=component_attr["ramp_limits"]["down"] / rec.base_power,
            )
            active_limits = (
                min=component_attr["active_power_limits"]["min"] / rec.base_power,
                max=component_attr["active_power_limits"]["max"] / rec.base_power,
            )
            reactive_limits = (
                min=component_attr["reactive_power_limits"]["min"] / rec.base_power,
                max=component_attr["reactive_power_limits"]["max"] / rec.base_power,
            )
            generator = component_type(;
                name=rec.name,
                rating=rec.rating / rec.base_power,
                base_power=rec.base_power,
                available=component_attr["available"],
                bus=PSY.get_component(PSY.ACBus, portfolio.base_system, bus_name),
                prime_mover_type=PSY.get_enum_value(PSY.PrimeMovers, rec.prime_mover),
                active_power=get(component_attr, "active_power", rec.rating) /
                             rec.base_power,
                reactive_power=get(component_attr, "reactive_power", rec.rating) /
                               rec.base_power,
                active_power_limits=active_limits,
                reactive_power_limits=reactive_limits,
                ramp_limits=ramp_limits,
                time_limits=time_limits,
            )

        elseif component_type == PSY.HydroTurbine
            active_limits = (
                min=component_attr["active_power_limits"]["min"] / rec.base_power,
                max=component_attr["active_power_limits"]["max"] / rec.base_power,
            )
            reactive_limits = (
                min=component_attr["reactive_power_limits"]["min"] / rec.base_power,
                max=component_attr["reactive_power_limits"]["max"] / rec.base_power,
            )
            time_limits = (
                up=component_attr["time_limits"]["up"],
                down=component_attr["time_limits"]["down"],
            )
            ramp_limits = (
                up=component_attr["ramp_limits"]["up"] / rec.base_power,
                down=component_attr["ramp_limits"]["down"] / rec.base_power,
            )
            ops_cost = parse_operational_cost(component_attr["operation_cost"])

            turbine = HydroTurbine(;
                name=rec.name,
                available=component_attr["available"],
                bus=PSY.get_component(PSY.ACBus, portfolio.base_system, bus_name),
                active_power=component_attr["active_power"] / rec.base_power,
                reactive_power=component_attr["reactive_power"] / rec.base_power,
                rating=rec.rating / rec.base_power,
                active_power_limits=active_limits,
                reactive_power_limits=reactive_limits,
                base_power=rec.base_power,
                operation_cost=ops_cost,
                ramp_limits=ramp_limits,
                time_limits=time_limits,
                outflow_limits=nothing,
                powerhouse_elevation=component_attr["powerhouse_elevation"],
                turbine_type=PSY.get_enum_value(
                    PSY.HydroTurbineType,
                    component_attr["turbine_type"],
                ),
                conversion_factor=component_attr["conversion_factor"],
                efficiency=component_attr["efficiency"],
            )
            # find the correct reservoir ID associated with this turbine
            reservoir_link = first(
                IS.execute(stmts[:reservoir], [rec.id, rec.id], IS.LOG_GROUP_SERIALIZATION),
            )
            if reservoir_link.source_id !== rec.id
                reservoir_id = reservoir_link.source_id
                downstream = true
            else
                reservoir_id = reservoir_link.sink_id
                downstream = false
            end

            reservoir_attr = get(attributes, reservoir_id, Dict{String, Any}())
            storage_level_limits = (
                min=reservoir_attr["storage_level_limits"]["min"],
                max=reservoir_attr["storage_level_limits"]["max"],
            )
            head_to_volume_factor = LinearCurve(
                reservoir_attr["head_to_volume_factor"]["function_data"]["proportional_term"],
                reservoir_attr["head_to_volume_factor"]["function_data"]["constant_term"],
            )
            reservoir = HydroReservoir(;
                name=string(rec.name, "_reservoir"),
                available=reservoir_attr["available"],
                storage_level_limits=storage_level_limits,
                initial_level=reservoir_attr["initial_level"],
                spillage_limits=nothing,
                inflow=reservoir_attr["inflow"],
                outflow=reservoir_attr["outflow"],
                level_targets=get(reservoir_attr, "level_targets", nothing),
                intake_elevation=reservoir_attr["intake_elevation"],
                head_to_volume_factor=head_to_volume_factor,
                operation_cost=parse_operational_cost(reservoir_attr["operation_cost"]),
                level_data_type=PSY.get_enum_value(
                    PSY.ReservoirDataType,
                    reservoir_attr["level_data_type"],
                ),
            )
        end
        if component_type == PSY.HydroTurbine
            if haskey(component_attr, "uuid")
                IS.set_uuid!(IS.get_internal(turbine), Base.UUID(component_attr["uuid"]))
            else
                warn("UUID for component named $(rec.name) not found in database")
            end
            add_component!(portfolio.base_system, reservoir)
            add_component!(portfolio.base_system, turbine)
            if downstream
                PSY.set_downstream_turbines!(reservoir, [turbine])
            else
                PSY.set_upstream_turbines!(reservoir, [turbine])
            end
        else
            if haskey(component_attr, "uuid")
                IS.set_uuid!(IS.get_internal(generator), Base.UUID(component_attr["uuid"]))
            else
                warn("UUID for component named $(rec.name) not found in database")
            end
            add_component!(portfolio.base_system, generator)
        end
        if component_type in
           [PSY.ThermalStandard, PSY.RenewableDispatch, PSY.RenewableNonDispatch]
            if get_aggregation(portfolio) == PSY.ACBus
                regions = [get_region(Node, portfolio, bus_name)]
            else
                area_id =
                    first(
                        IS.execute(
                            stmts[:topology_to_area],
                            [rec.balancing_topology],
                            IS.LOG_GROUP_SERIALIZATION,
                        ),
                    ).area
                regions = collect(
                    IS.get_components(
                        x -> get_id(x) == area_id,
                        RegionTopology,
                        portfolio.data,
                    ),
                )
            end

            if haskey(component_attr, "fuel_type")
                fuel = get(FUEL_MAPPING, component_attr["fuel_type"], ThermalFuels.OTHER)
            else
                fuel = ThermalFuels.OTHER
            end
            technology = SupplyTechnology{component_type}(;
                name=rec.name,
                id=rec.id,
                capital_costs=LinearCurve(0.0),
                prime_mover_type=PSY.get_enum_value(PSY.PrimeMovers, rec.prime_mover),
                fuel=[fuel],
                region=regions,
                financial_data=DEFAULT_FINANCIAL_DATA,
                available=true,
                power_systems_type=string(nameof(component_type)),
                operation_costs=ops_cost,
                ramp_limits=(@isdefined ramp_limits) ? ramp_limits : (up=1.0, down=1.0),
                time_limits=(@isdefined time_limits) ? time_limits : (up=1.0, down=1.0),
                capacity_limits=(min=0, max=rec.rating),
                co2=Dict(fuel => 0.0),
            )
            add_technology!(portfolio, technology)
            existing = ExistingDevices(id=rec.id, existing_devices=[rec.name])
            add_supplemental_attribute!(portfolio, technology, existing)

            set_capacity_limits!(
                technology,
                (min=0, max=get_existing_capacity_mw(portfolio, technology)),
            )
        end
    end
end

function add_storage_units!(
    portfolio::Portfolio,
    attributes::Dict{Int64, Dict{String, Any}},
    stmts::Dict,
)
    for rec in IS.execute(stmts[:storage_units], nothing, IS.LOG_GROUP_SERIALIZATION)
        component_type = getproperty(
            PowerSystems,
            Symbol(
                first(
                    IS.execute(stmts[:entity_type], [rec.id], IS.LOG_GROUP_SERIALIZATION),
                ).entity_type,
            ),
        )
        component_attr = get(attributes, rec.id, Dict{String, Any}())

        level_limits = (
            min=component_attr["storage_level_limits"]["min"],
            max=component_attr["storage_level_limits"]["max"],
        )
        input_active_limits = (
            min=component_attr["input_active_power_limits"]["min"] / rec.base_power,
            max=component_attr["input_active_power_limits"]["max"] / rec.base_power,
        )
        output_active_limits = (
            min=component_attr["output_active_power_limits"]["min"] / rec.base_power,
            max=component_attr["output_active_power_limits"]["max"] / rec.base_power,
        )
        reactive_limits = (
            min=component_attr["reactive_power_limits"]["min"] / rec.base_power,
            max=component_attr["reactive_power_limits"]["max"] / rec.base_power,
        )

        # Get name of bus
        bus_name =
            first(
                IS.execute(
                    stmts[:topology_for_unit],
                    [rec.balancing_topology],
                    IS.LOG_GROUP_SERIALIZATION,
                ),
            ).name

        ops_cost = parse_operational_cost(component_attr["operation_cost"])

        storage_unit = component_type(;
            #Data pulled from DB
            name=rec.name,
            rating=rec.rating / rec.base_power,
            base_power=rec.base_power,
            available=component_attr["available"],
            bus=PSY.get_component(PSY.ACBus, portfolio.base_system, bus_name),
            prime_mover_type=PSY.get_enum_value(PSY.PrimeMovers, rec.prime_mover),
            storage_technology_type=PSY.StorageTech(
                component_attr["storage_technology_type"],
            ),
            conversion_factor=component_attr["conversion_factor"],
            cycle_limits=component_attr["cycle_limits"],
            storage_capacity=component_attr["storage_capacity"] / rec.base_power,
            storage_level_limits=level_limits,
            storage_target=component_attr["storage_target"],
            initial_storage_capacity_level=component_attr["initial_storage_capacity_level"],
            input_active_power_limits=input_active_limits,
            output_active_power_limits=output_active_limits,
            active_power=component_attr["active_power"] / rec.base_power,
            reactive_power=component_attr["reactive_power"] / rec.base_power,
            reactive_power_limits=reactive_limits,
            efficiency=(in=rec.efficiency_up, out=rec.efficiency_down),
            operation_cost=ops_cost,
        )
        if haskey(component_attr, "uuid")
            IS.set_uuid!(IS.get_internal(storage_unit), Base.UUID(component_attr["uuid"]))
        else
            warn("UUID for component named $(rec.name) not found in database")
        end
        add_component!(portfolio.base_system, storage_unit)

        if get_aggregation(portfolio) == PSY.ACBus
            regions = [get_region(Node, portfolio, bus_name)]
        else
            area_id =
                first(
                    IS.execute(
                        stmts[:topology_to_area],
                        [rec.balancing_topology],
                        IS.LOG_GROUP_SERIALIZATION,
                    ),
                ).area
            regions = collect(
                IS.get_components(
                    x -> get_id(x) == area_id,
                    RegionTopology,
                    portfolio.data,
                ),
            )
        end
        storage = StorageTechnology{component_type}(;
            name=rec.name,
            id=rec.id,
            capital_costs_discharge=LinearCurve(0.0),
            capital_costs_energy=LinearCurve(0.0),
            prime_mover_type=PSY.get_enum_value(PSY.PrimeMovers, rec.prime_mover),
            storage_tech=PSY.StorageTech(component_attr["storage_technology_type"]),
            region=regions,
            financial_data=DEFAULT_FINANCIAL_DATA,
            available=true,
            power_systems_type=string(nameof(component_type)),
            operation_costs=ops_cost,
            capacity_limits_discharge=(min=0, max=rec.rating),
            capacity_limits_energy=(min=0, max=component_attr["storage_capacity"]),
        )
        add_technology!(portfolio, storage)
        existing = ExistingDevices(id=rec.id, existing_devices=[rec.name])
        add_supplemental_attribute!(portfolio, storage, existing)
    end
end

function add_demand_requirements!(
    portfolio::Portfolio,
    attributes::Dict{Int64, Dict{String, Any}},
    stmts::Dict,
)
    for rec in IS.execute(stmts[:demand_requirements], nothing, IS.LOG_GROUP_SERIALIZATION)
        component_type = getproperty(
            PowerSystems,
            Symbol(
                first(
                    IS.execute(stmts[:entity_type], [rec.id], IS.LOG_GROUP_SERIALIZATION),
                ).entity_type,
            ),
        )
        component_attr = get(attributes, rec.id, Dict{String, Any}())

        if get_aggregation(portfolio) == PSY.ACBus
            area = rec.balancing_topology
        else
            area =
                first(
                    IS.execute(
                        stmts[:topology_to_area],
                        [rec.balancing_topology],
                        IS.LOG_GROUP_SERIALIZATION,
                    ),
                ).area
        end

        demand = DemandRequirement{component_type}(;
            name=rec.name,
            id=rec.id,
            new_demand_mw=component_attr["active_power"], #TODO: Change to "max_active_power" later when DB is fixed
            region=collect(
                IS.get_components(x -> get_id(x) == area, RegionTopology, portfolio.data),
            ),
            value_of_lost_load=1e8, #TODO: Assign a default value to this field
            power_systems_type=string(nameof(component_type)),
        )
        add_technology!(portfolio, demand)
    end
end

function add_loads!(
    portfolio::Portfolio,
    attributes::Dict{Int64, Dict{String, Any}},
    stmts::Dict,
)
    for rec in IS.execute(stmts[:demand_requirements], nothing, IS.LOG_GROUP_SERIALIZATION)
        component_type = getproperty(
            PowerSystems,
            Symbol(
                first(
                    IS.execute(stmts[:entity_type], [rec.id], IS.LOG_GROUP_SERIALIZATION),
                ).entity_type,
            ),
        )
        component_attr = get(attributes, rec.id, Dict{String, Any}())

        # Determine area based on balancing topology if zonal
        bus_name =
            first(
                IS.execute(
                    stmts[:topology_for_unit],
                    [rec.balancing_topology],
                    IS.LOG_GROUP_SERIALIZATION,
                ),
            ).name

        load = component_type(;
            name=rec.name,
            base_power=rec.base_power,
            bus=PSY.get_component(ACBus, portfolio.base_system, bus_name),
            max_active_power=component_attr["active_power"] / rec.base_power, #TODO: Change to "max_active_power" later when DB is fixed
            max_reactive_power=component_attr["max_reactive_power"] / rec.base_power,
            reactive_power=component_attr["reactive_power"] / rec.base_power,
            active_power=component_attr["active_power"] / rec.base_power,
            available=component_attr["available"],
        )
        if haskey(component_attr, "uuid")
            IS.set_uuid!(IS.get_internal(load), Base.UUID(component_attr["uuid"]))
        else
            warn("UUID for component named $(rec.name) not found in database")
        end
        add_component!(portfolio.base_system, load)
    end
end

function transform_natural_impedance_to_device_base(natural_units_impedance, arc, sys)
    base_voltage = arc.from.base_voltage
    if isnothing(base_voltage)
        error("Base voltage is not defined")
    end
    base_power = get_base_power(sys)
    z_base = base_voltage^2 / base_power
    device_base_impedance = natural_units_impedance / z_base
    return device_base_impedance
end

function transform_natural_admittance_to_device_base(natural_units_admittance, arc, sys)
    base_voltage = arc.from.base_voltage
    if isnothing(base_voltage)
        error("Base voltage is not defined")
    end
    base_power = get_base_power(sys)
    z_base = base_voltage^2 / base_power
    device_base_impedance = natural_units_admittance * z_base
    return device_base_impedance
end

function add_system_lines!(
    portfolio::Portfolio,
    attributes::Dict{Int64, Dict{String, Any}},
    stmts::Dict,
)
    arc_dict = Dict()
    for rec in IS.execute(stmts[:arcs], nothing, IS.LOG_GROUP_SERIALIZATION)
        component_attr = get(attributes, rec.id, Dict{String, Any}())
        from_bus =
            first(
                IS.execute(
                    stmts[:topology_from_arc],
                    [rec.from_id],
                    IS.LOG_GROUP_SERIALIZATION,
                ),
            ).name
        to_bus =
            first(
                IS.execute(
                    stmts[:topology_from_arc],
                    [rec.to_id],
                    IS.LOG_GROUP_SERIALIZATION,
                ),
            ).name
        arc = Arc(;
            from=PSY.get_component(ACBus, portfolio.base_system, from_bus),
            to=PSY.get_component(ACBus, portfolio.base_system, to_bus),
        )
        if haskey(component_attr, "uuid")
            IS.set_uuid!(IS.get_internal(arc), Base.UUID(component_attr["uuid"]))
        else
            warn("UUID for component named $(rec.name) not found in database")
        end
        add_component!(portfolio.base_system, arc)
        arc_dict[rec.id] = arc
    end

    tx_dict = Dict()
    for rec in IS.execute(stmts[:transmission_lines], nothing, IS.LOG_GROUP_SERIALIZATION)
        component_type = getproperty(
            PowerSystems,
            Symbol(
                first(
                    IS.execute(stmts[:entity_type], [rec.id], IS.LOG_GROUP_SERIALIZATION),
                ).entity_type,
            ),
        )
        component_attr = get(attributes, rec.id, Dict{String, Any}())

        # Determine area based on balancing topology if zonal
        arc = first(IS.execute(stmts[:arc], [rec.arc_id], IS.LOG_GROUP_SERIALIZATION)).id

        if component_type == PSY.Line
            b = (
                from=transform_natural_admittance_to_device_base(
                    component_attr["b"]["from"],
                    arc_dict[arc],
                    portfolio.base_system,
                ),
                to=transform_natural_admittance_to_device_base(
                    component_attr["b"]["to"],
                    arc_dict[arc],
                    portfolio.base_system,
                ),
            )
            g = (from=component_attr["g"]["from"], to=component_attr["g"]["to"])
            angle_limits = (
                min=component_attr["angle_limits"]["min"],
                max=component_attr["angle_limits"]["max"],
            )
            line = component_type(;
                name=rec.name,
                rating=rec.continuous_rating / get_base_power(portfolio.base_system),
                arc=arc_dict[arc],
                reactive_power_flow=component_attr["reactive_power_flow"] /
                                    get_base_power(portfolio.base_system),
                active_power_flow=component_attr["active_power_flow"] /
                                  get_base_power(portfolio.base_system),
                available=component_attr["available"],
                angle_limits=angle_limits,
                x=transform_natural_impedance_to_device_base(
                    component_attr["x"],
                    arc_dict[arc],
                    portfolio.base_system,
                ),
                r=transform_natural_impedance_to_device_base(
                    component_attr["r"],
                    arc_dict[arc],
                    portfolio.base_system,
                ),
                b=b,
                g=g,
            )

        elseif component_type == PSY.Transformer2W
            line = component_type(;
                name=rec.name,
                rating=rec.continuous_rating / get_base_power(portfolio.base_system),
                base_power=component_attr["base_power"],
                arc=arc_dict[arc],
                primary_shunt=transform_natural_impedance_to_device_base(
                    component_attr["primary_shunt"]["real"],
                    arc_dict[arc],
                    portfolio.base_system,
                ),
                reactive_power_flow=component_attr["reactive_power_flow"] /
                                    get_base_power(portfolio.base_system),
                active_power_flow=component_attr["active_power_flow"] /
                                  get_base_power(portfolio.base_system),
                available=component_attr["available"],
                x=transform_natural_impedance_to_device_base(
                    component_attr["x"],
                    arc_dict[arc],
                    portfolio.base_system,
                ),
                r=transform_natural_impedance_to_device_base(
                    component_attr["r"],
                    arc_dict[arc],
                    portfolio.base_system,
                ),
            )
        end
        if haskey(component_attr, "uuid")
            IS.set_uuid!(IS.get_internal(line), Base.UUID(component_attr["uuid"]))
        else
            warn("UUID for component named $(rec.name) not found in database")
        end
        add_component!(portfolio.base_system, line)

        #If Line is between areas, add to dictionary
        from_area = PSY.get_name(get_area(get_from(get_arc(line))))
        to_area = PSY.get_name(get_area(get_to(get_arc(line))))
        if from_area != to_area
            areas = Set([from_area, to_area])
            if haskey(tx_dict, areas)
                push!(tx_dict[areas], PSY.get_name(line))
            else
                tx_dict[areas] = [PSY.get_name(line)]
            end
        end

        #Build Portfolio transmission based on existing transmission
        #Also new candidates lines for each connection
        if get_aggregation(portfolio) == PSY.ACBus
            component_attr = get(attributes, rec.id, Dict{String, Any}())
            arc = first(IS.execute(stmts[:arc], [rec.arc_id], IS.LOG_GROUP_SERIALIZATION))
            balancing_topology_from =
                first(
                    IS.execute(
                        stmts[:topology_from_arc],
                        [arc.from_id],
                        IS.LOG_GROUP_SERIALIZATION,
                    ),
                ).name
            balancing_topology_to =
                first(
                    IS.execute(
                        stmts[:topology_from_arc],
                        [arc.to_id],
                        IS.LOG_GROUP_SERIALIZATION,
                    ),
                ).name

            transport = NodalACTransportTechnology{component_type}(;
                name=rec.name,
                id=rec.id,
                available=true,
                power_systems_type=string(nameof(component_type)),
                financial_data=DEFAULT_FINANCIAL_DATA,
                start_node=get_region(Node, portfolio, balancing_topology_from),
                end_node=get_region(Node, portfolio, balancing_topology_to),
                reactance=component_attr["x"],
                resistance=component_attr["r"],
                voltage=get_base_voltage(
                    PSY.get_component(
                        PSY.ACBus,
                        portfolio.base_system,
                        balancing_topology_from,
                    ),
                ),
                capital_costs=LinearCurve(1e5),
            )
            add_technology!(portfolio, transport)
            existing = ExistingDevices(; id=rec.id, existing_devices=[rec.name])
            add_supplemental_attribute!(portfolio, transport, existing)
            set_capacity_limits!(
                transport,
                (min=0, max=get_existing_capacity_mw(portfolio, transport)),
            )

            new_transport = NodalACTransportTechnology{component_type}(;
                name=rec.name * "_new",
                id=rec.id,
                available=true,
                power_systems_type=string(nameof(component_type)),
                financial_data=DEFAULT_FINANCIAL_DATA,
                start_node=get_region(Node, portfolio, balancing_topology_from),
                end_node=get_region(Node, portfolio, balancing_topology_to),
                reactance=component_attr["x"],
                resistance=component_attr["r"],
                voltage=get_base_voltage(
                    PSY.get_component(
                        PSY.ACBus,
                        portfolio.base_system,
                        balancing_topology_from,
                    ),
                ),
                capital_costs=LinearCurve(1e5),
            )
            add_technology!(portfolio, new_transport)
        end
    end

    if get_aggregation(portfolio) != PSY.ACBus
        id = 1
        for (areas, lines) in tx_dict
            area_list = collect(areas)
            transport = AggregateTransportTechnology{ACBranch}(;
                name=string(area_list[1]) * "_" * string(area_list[2]),
                id=id,
                available=true,
                power_systems_type=string(nameof(ACBranch)),
                financial_data=DEFAULT_FINANCIAL_DATA,
                start_region=get_region(Zone, portfolio, area_list[1]),
                end_region=get_region(Zone, portfolio, area_list[2]),
                capital_costs=LinearCurve(1e5),
            )
            id += 1
            add_technology!(portfolio, transport)
            existing = ExistingDevices(id=id, existing_devices=lines)
            add_supplemental_attribute!(portfolio, transport, existing)
            id += 1
        end
    end
end

#TODO: Implement DemandSideTechnologies if/when they are in the database
function add_demand_technologies!(
    portfolio::Portfolio,
    attributes::Dict{Int64, Dict{String, Any}},
    stmts::Dict,
) end

function deserialize_portfolio_timeseries!(portfolio::Portfolio, stmts::Dict)
    supply_technologies = get_technologies(SupplyTechnology, portfolio)
    for tech in supply_technologies
        fuel = first(get_fuel(tech))
        prime_mover = get_prime_mover_type(tech)
        ts_type = get(PRIME_MOVER_TO_TIMESERIES, [prime_mover, fuel], nothing)
        cost_data = Dict()
        if !isnothing(ts_type)
            for ts_association in IS.execute(
                stmts[:investment_timeseries],
                [ts_type],
                IS.LOG_GROUP_SERIALIZATION,
            )
                timestamps = [
                    Dates.DateTime(row.idx, 1, 1) for row in IS.execute(
                        stmts[:ts_data],
                        [ts_association.time_series_uuid],
                        IS.LOG_GROUP_SERIALIZATION,
                    )
                ]
                values = [
                    row.value for row in IS.execute(
                        stmts[:ts_data],
                        [ts_association.time_series_uuid],
                        IS.LOG_GROUP_SERIALIZATION,
                    )
                ]
                ts_data = TimeSeries.TimeArray(timestamps, values)
                cost_year = get_base_year(portfolio)
                cost_data[ts_association.name] =
                    first(TimeSeries.values(ts_data[Dates.DateTime(cost_year, 1, 1)]))

                if is_new(tech)
                    ts = SingleTimeSeries(
                        ts_association.name,
                        ts_data;
                        resolution=Dates.Year(1),
                    )
                    add_time_series!(portfolio, tech, ts)
                end
            end
        end
        if is_new(tech)
            if haskey(cost_data, "fuel_price")
                capex = LinearCurve(cost_data["capcost"] * 1000.0)
                if haskey(cost_data, "heatrate")
                    heat_rate = LinearCurve(cost_data["heatrate"])
                else
                    heat_rate = LinearCurve(0.0)
                end
                opex = ThermalGenerationCost(
                    variable=FuelCurve(
                        heat_rate,
                        cost_data["fuel_price"],
                        LinearCurve(0.0),
                        LinearCurve(cost_data["vom"]),
                    ),
                    fixed=cost_data["fom"] * 1000.0,
                    start_up=0.0,
                    shut_down=0.0,
                )
                set_operation_costs!(tech, opex)
                set_capital_costs!(tech, capex)
            else
                capex = LinearCurve(cost_data["capcost"] * 1000.0)
                opex = RenewableGenerationCost(
                    variable=CostCurve(LinearCurve(0.0), LinearCurve(cost_data["vom"])),
                )
                set_operation_costs!(tech, opex)
                set_capital_costs!(tech, capex)
            end
        elseif !is_new(tech)
            ops = get_operation_costs(tech)
            if haskey(cost_data, "fuel_price")
                fixed = get_fixed_cost(tech)
                vom = get_variable_cost(tech)
                if get_variable_cost(tech) == 0.0
                    vom = LinearCurve(cost_data["vom"])
                end
                if get_fixed(ops) == 0.0
                    fixed = cost_data["fom"] * 1000.0
                end
                set_variable!(
                    ops,
                    FuelCurve(
                        get_value_curve(get_variable(ops)),
                        get_fuel_cost(tech),
                        IS.get_startup_fuel_offtake(get_variable(ops)),
                        vom,
                    ),
                )
                set_fixed!(ops, fixed)
                set_operation_costs!(tech, ops)
            end
        end

        if typeof(tech) in
           [SupplyTechnology{RenewableDispatch}, SupplyTechnology{RenewableNonDispatch}]
            if has_supplemental_attributes(tech)
                #If there are existing capacity associated with a technology
                #Use an existing unit to extract timeseries
                existing_names = get_existing_devices(
                    only(get_supplemental_attributes(ExistingDevices, tech)),
                )
                unit = first(
                    IS.get_components(
                        x -> PSY.get_name(x) == first(existing_names),
                        typeof(tech).parameters[1],
                        portfolio.base_system,
                    ),
                )
                ts_array =
                    get_time_series_array(SingleTimeSeries, unit, "max_active_power") ./
                    get_rating(unit)
            else
                #If technology does not have existing capacity associated with it,
                #select a similar technology from the base system to get required timeseries
                #based on prime mover
                prime_mover = get_prime_mover_type(tech)
                unit = first(
                    IS.get_components(
                        x -> PSY.get_prime_mover_type(x) == prime_mover,
                        typeof(tech).parameters[1],
                        portfolio.base_system,
                    ),
                )
                ts_array =
                    get_time_series_array(SingleTimeSeries, unit, "max_active_power") ./
                    get_rating(unit)
            end
            ts = SingleTimeSeries("capacity_factor", ts_array)
            add_time_series!(portfolio, tech, ts)
        end
    end

    #Duplicate hourly demand profile on the portfolio level
    demands = get_technologies(DemandRequirement, portfolio)
    for demand in demands
        unit = first(
            IS.get_components(
                x -> PSY.get_name(x) == get_name(demand),
                typeof(demand).parameters[1],
                portfolio.base_system,
            ),
        )
        if get_max_active_power(unit) != 0
            ts_array =
                get_time_series_array(SingleTimeSeries, unit, "max_active_power") ./
                get_max_active_power(unit)
        else
            ts_array = get_time_series_array(SingleTimeSeries, unit, "max_active_power")
        end
        ts = SingleTimeSeries("demand", ts_array)
        add_time_series!(portfolio, demand, ts)
    end
end

#############################################################################
# Code below is ported from SiennaGridDB. Can remove this and call these
# functions directly once there is an official release of SiennaGridDB
#############################################################################

function deserialize_timedata(db, sts_meta::IS.SingleTimeSeriesMetadata, time_series_uuid)
    stmt = DBInterface.prepare(
        db,
        """
        SELECT idx, value
        FROM static_time_series
        WHERE uuid = ?
        ORDER BY idx
        """,
    )
    rows = DBInterface.execute(stmt, (string(time_series_uuid),))
    column_table = Tables.columntable(rows)
    timestamps =
        range(sts_meta.initial_timestamp; length=sts_meta.length, step=sts_meta.resolution)
    return PowerSystems.TimeSeries.TimeArray(timestamps, column_table.value)
end

function deserialize_timedata(_, ts::IS.DeterministicMetadata, _)
    error("Cannot deserialize deterministic timeseries $ts")
end

function deserialize_time_series_row!(sys, db, row)
    metadata = deserialize_metadata(row)
    component_attr = get(attributes, row.owner_id, Dict{String, Any}())
    owner_uuid = component_attr["uuid"]
    if isa(metadata, IS.DeterministicMetadata) &&
       metadata.time_series_type <: IS.DeterministicSingleTimeSeries
        component = PowerSystems.get_component(sys, owner_uuid)
        IS.add_metadata!(sys.data.time_series_manager.metadata_store, component, metadata)
    else
        time_array = deserialize_timedata(db, metadata, row.time_series_uuid)
        ts = IS.time_series_metadata_to_data(metadata)(metadata, time_array)
        PowerSystems.add_time_series!(sys, PowerSystems.get_component(sys, owner_uuid), ts)
    end
end

# TODO: STOLEN FROM InfrastructureSystems. This should be made an IS functions.
function deserialize_metadata(row)
    exclude_keys = Set((:metadata_uuid, :owner_uuid, :time_series_type))
    time_series_type = IS.TIME_SERIES_STRING_TO_TYPE[row.time_series_type]
    metadata_type = IS.time_series_data_to_metadata(time_series_type)
    fields = Set(fieldnames(metadata_type))
    data = Dict{Symbol, Any}(
        :internal =>
            IS.InfrastructureSystemsInternal(; uuid=Base.UUID(row.metadata_uuid)),
    )
    if time_series_type <: IS.Forecast
        # Special case because the table column does not match the field name.
        data[:count] = row.window_count
    end
    if time_series_type <: IS.AbstractDeterministic
        data[:time_series_type] = time_series_type
    end
    for field in keys(row)
        if !in(field, fields) || field in exclude_keys
            continue
        end
        val = getproperty(row, field)
        if field == :initial_timestamp
            data[field] = Dates.DateTime(val)
        elseif field == :resolution
            data[field] = IS.from_iso_8601(val)
        elseif field == :horizon || field == :interval
            if !ismissing(val)
                data[field] = IS.from_iso_8601(val)
            end
        elseif field == :time_series_uuid
            data[field] = Base.UUID(val)
        elseif field == :features
            features_array = JSON3.read(val, Array)
            features_dict = Dict{String, Union{Bool, Int, String}}()
            for obj in features_array
                length(obj) != 1 && error("Invalid features: $obj")
                key = first(keys(obj))
                key in keys(features_dict) && error("Duplicate features: $key")
                features_dict[key] = obj[key]
            end
            data[field] = features_dict
        elseif field == :scaling_factor_multiplier
            if !ismissing(val)
                val2 = JSON3.read(val, Dict{String, Any})
                data[field] = IS.deserialize(Function, val2)
            end
        else
            data[field] = val
        end
    end
    metadata = metadata_type(; data...)
    return metadata
end

function get_example_metadata(db)
    time_series_uuid_rows = DBInterface.execute(
        db,
        "SELECT * FROM time_series_associations WHERE time_series_type != 'DeterministicSingleTimeSeries' GROUP BY time_series_uuid",
    )
    return time_series_uuid_rows
end

function deserialize_time_series_from_metadata!(
    sys::PowerSystems.System,
    db,
    metadata,
    row,
    owner_uuid,
)
    time_array = deserialize_timedata(db, metadata, row.time_series_uuid)
    ts = IS.time_series_metadata_to_data(metadata)(metadata, time_array)
    component = PowerSystems.get_component(sys, owner_uuid)
    PowerSystems.add_time_series!(sys, PowerSystems.get_component(sys, owner_uuid), ts)
    if PSY.get_name(component) == "122_HYDRO_4"
        PSY.get_name(component),
        maximum(get_time_series_values(SingleTimeSeries, component, ts.name))
    end
end

function deserialize_timeseries!(sys::PowerSystems.System, db, attributes)
    DBInterface.transaction(db) do
        # For each time_series_uuid, we'll pick a "real" metadata_uuid (so no DeterministicSingleTimeSeries),
        # then we will deserialize and add them to the system. Finally, we'll go through and add_metadata!
        # for all others.
        serialized_metadata = Set{String}()
        for row in get_example_metadata(db)
            if row.owner_category == "Component" #Including this to skip over the temporary investment timeseries
                component_attr = get(attributes, row.owner_id, Dict{String, Any}())
                owner_uuid = component_attr["uuid"]
                metadata = deserialize_metadata(row)
                deserialize_time_series_from_metadata!(sys, db, metadata, row, owner_uuid)
                push!(serialized_metadata, row.metadata_uuid)
            end
        end
        associations = DBInterface.execute(db, "SELECT * FROM time_series_associations")
        for row in associations
            if row.owner_category == "Component"
                component_attr = get(attributes, row.owner_id, Dict{String, Any}())
                owner_uuid = component_attr["uuid"]
                metadata = deserialize_metadata(row)
                if in(row.metadata_uuid, serialized_metadata)
                    continue
                end
                component = PowerSystems.get_component(sys, owner_uuid)
                IS.add_metadata!(
                    sys.data.time_series_manager.metadata_store,
                    component,
                    metadata,
                )
            end
        end
    end
end
