"""
SQLite/DBInterface reader for the SiennaGridDB schema, staged here for later extraction
into its own package. A submodule (not a flat include) so that boundary is explicit today:
it declares its own imports rather than inheriting PSIP's ambient `using` statements, and
it exports nothing — the only call site outside this file is the qualified
`PowerSystemsInvestmentsPortfolios.DBParser.database_to_portfolio`.
"""
module DBParser

# `@u_str` is a macro, so it must be imported by name rather than reached through a
# qualified module path the way the function imports below are.
using Unitful: @u_str

import PowerSystems
const PSY = PowerSystems
import PowerSystems:
    ACBus,
    ACBranch,
    Arc,
    Area,
    FuelCurve,
    HydroGenerationCost,
    HydroReservoir,
    HydroReservoirCost,
    HydroTurbine,
    IncrementalCurve,
    InputOutputCurve,
    LinearFunctionData,
    PiecewiseStepData,
    RenewableGenerationCost,
    SingleTimeSeries,
    StorageCost,
    ThermalGenerationCost,
    ThermalFuels,
    PrimeMovers,
    StorageTech,
    RenewableDispatch,
    RenewableNonDispatch,
    ACBusTypes,
    add_component!,
    get_arc,
    get_area,
    get_base_power,
    get_base_voltage,
    get_component,
    get_components,
    get_fixed,
    get_from,
    get_max_active_power,
    get_rating,
    get_time_series_array,
    get_time_series_values,
    get_to,
    get_value_curve,
    get_variable_operation_cost,
    has_supplemental_attributes,
    set_downstream_turbines!,
    set_fixed!,
    set_upstream_turbines!,
    set_variable_operation_cost!

import InfrastructureSystems
const IS = InfrastructureSystems
import InfrastructureSystems: InfrastructureSystemsInternal, CostCurve, LinearCurve

import SQLite
import DBInterface
import Tables
import TimeSeries
import Dates
import JSON3

# PSIP's own public surface. `get_aggregation` is used below despite not being
# exported by PSIP (finding, recorded for the extraction: see
# .claude/plans/2026-08-06-psip-serde-strategy-port.md report) — everything
# else here is genuinely public.
import ..PowerSystemsInvestmentsPortfolios:
    Portfolio,
    Zone,
    Node,
    RegionTopology,
    ExistingDevices,
    TechnologyFinancialData,
    SupplyTechnology,
    StorageTechnology,
    DemandRequirement,
    NodalACTransportTechnology,
    AggregateTransportTechnology,
    add_technology!,
    add_region!,
    add_supplemental_attribute!,
    add_time_series!,
    set_capacity_limits!,
    set_capital_costs!,
    set_operation_costs!,
    get_id,
    get_name,
    get_region,
    get_fuel,
    get_prime_mover_type,
    get_fixed_cost,
    get_variable_cost,
    get_operation_costs,
    get_base_year,
    get_existing_capacity_mw,
    get_existing_devices,
    get_supplemental_attributes,
    get_technologies,
    is_new,
    get_aggregation,
    get_fuel_cost,
    DEFAULT_AGGREGATION,
    MMBtu,
    USD

"""
The physical quantity a `scaling_factor_multiplier` accessor's normalized values scale to.

Matches PowerTableDataParser's map of the same name so a profile means the same thing however
it reached a system.
"""
const MULTIPLIER_QUANTITY_KINDS = Dict(
    "get_max_active_power" => "active_power",
    "get_max_reactive_power" => "reactive_power",
    "get_requirement" => "active_power",
    "get_rating" => "apparent_power",
)

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

# RTS database was written in PSY5 and so some definitions have changed in PSY6,
# such as Transformer2W to TwoWindingTransformer. The current parser will be deprecated
# and replaced with the OpenAPI parsing so using this dictionary to temporarily resolve
# type discrepancies.
const PSY6_MAPPING = Dict("Transformer2W" => "TwoWindingTransformer")

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
    # DB entity id -> the base-system component parsed from it. The time series rows name
    # their owner by that id, and it is the only cross-reference the schema offers.
    owners = Dict{Int64, Any}()
    ids = id_allocator(db)

    # Add zones and lines, shouldn't add both aggregate lines and nodal lines to the same DB
    # User can provide a desired aggregation level and then we can select based on that

    if get_aggregation(portfolio) === PSY.ACBus
        add_nodes!(portfolio, attributes, stmts)
        add_nodal_lines!(portfolio, attributes, stmts)
    else
        add_zones!(portfolio, attributes, stmts)
        add_aggregate_lines!(portfolio, attributes, stmts, ids)
    end

    add_technologies!(portfolio, attributes, stmts, ids)
    add_demand_requirements!(portfolio, attributes, stmts)
    add_demand_technologies!(portfolio, attributes, stmts)

    add_buses!(portfolio, attributes, stmts, owners)
    add_system_lines!(portfolio, attributes, stmts, owners, ids)
    add_generation_units!(portfolio, attributes, stmts, owners)
    add_storage_units!(portfolio, attributes, stmts, owners)
    add_loads!(portfolio, attributes, stmts, owners)

    deserialize_timeseries!(portfolio.base_system, db, owners)
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
        variable_operation_cost=FuelCurve(;
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
        variable_operation_cost=CostCurve(;
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
        variable_operation_cost=CostCurve(;
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

"""
Mint portfolio component ids that cannot collide with an `entities` id.

A portfolio stores every component under its own `id`, and those ids must be unique across
every type in it. Most tables key their rows by an `entities` id, which is unique already;
`supply_technologies` and `transmission_interchanges` number their rows table-locally, and the
candidate ("_new") transport technologies have no row of their own at all. Those draw from this
counter, seeded past the entity space so the two families cannot meet.
"""
mutable struct IdAllocator
    next_id::Int
end

"""
Seed an [`IdAllocator`](@ref) past every id the database's `entities` table uses.
"""
function id_allocator(db)
    row = first(DBInterface.execute(db, "SELECT MAX(id) AS max_id FROM entities"))
    return IdAllocator(Int(row.max_id) + 1)
end

function next_id!(allocator::IdAllocator)
    id = allocator.next_id
    allocator.next_id += 1
    return id
end

function add_zones!(p::Portfolio, attributes::Dict{Int64, Dict{String, Any}}, stmts::Dict)
    for rec in DBInterface.execute(stmts[:zones])
        z = Zone(; name=rec.name)
        IS.set_id!(z, rec.id)
        add_region!(p, z)
    end
end

function add_nodes!(
    portfolio::Portfolio,
    attributes::Dict{Int64, Dict{String, Any}},
    stmts::Dict,
)
    for rec in DBInterface.execute(stmts[:balancing_topologies])
        z = Node(; name=rec.name)
        IS.set_id!(z, rec.id)
        add_region!(portfolio, z)
    end
end

function add_buses!(
    portfolio::Portfolio,
    attributes::Dict{Int64, Dict{String, Any}},
    stmts::Dict,
    owners::Dict{Int64, Any},
)
    for rec in DBInterface.execute(stmts[:zones])
        component_attr = get(attributes, rec.id, Dict{String, Any}())
        area = Area(;
            name=rec.name,
            load_response=component_attr["load_response"],
            peak_active_power=component_attr["peak_active_power"],
            peak_reactive_power=component_attr["peak_reactive_power"],
        )
        PSY.add_component!(portfolio.base_system, area)
        owners[rec.id] = area
    end
    for rec in DBInterface.execute(stmts[:balancing_topologies])
        component_attr = get(attributes, rec.id, Dict{String, Any}())
        area_name = first(DBInterface.execute(stmts[:zone], [rec.area])).name
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
        PSY.add_component!(portfolio.base_system, bus)
        owners[rec.id] = bus
    end
end

function add_aggregate_lines!(
    portfolio::Portfolio,
    attributes::Dict{Int64, Dict{String, Any}},
    stmts::Dict,
    ids::IdAllocator,
)
    for rec in DBInterface.execute(stmts[:aggregate_lines])
        component_attr = get(attributes, rec.id, Dict{String, Any}())
        area_to_id = parse(Int64, rec.area_to)
        area_from_id = parse(Int64, rec.area_from)
        t = AggregateTransportTechnology{ACBranch}(;
            name=string(rec.rowid),
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
        IS.set_id!(t, next_id!(ids))
        add_technology!(portfolio, t)
    end
end

# Will be used for new candidate transmission options in the future if in database
function add_nodal_lines!(
    portfolio::Portfolio,
    attributes::Dict{Int64, Dict{String, Any}},
    stmts::Dict,
)
    for rec in DBInterface.execute(stmts[:new_lines])
        component_attr = get(attributes, rec.id, Dict{String, Any}())
        arc = first(DBInterface.execute(stmts[:arc], [rec.arc_id]))
        balancing_topology_from =
            first(DBInterface.execute(stmts[:topology_from_arc], [arc.from_id])).name
        balancing_topology_to =
            first(DBInterface.execute(stmts[:topology_from_arc], [arc.to_id])).name
        transport = NodalACTransportTechnology{ACBranch}(;
            name=string(rec.arc_id) * "_newline",
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
        IS.set_id!(transport, rec.id)
        add_technology!(portfolio, transport)
    end
end

function add_technologies!(
    portfolio::Portfolio,
    attributes::Dict{Int64, Dict{String, Any}},
    stmts::Dict,
    ids::IdAllocator,
)
    for rec in DBInterface.execute(stmts[:technologies])
        parametric = get(PRIME_MOVER_TO_PARAMETRIC, rec.prime_mover, PSY.ThermalStandard)

        if get_aggregation(portfolio) == PSY.ACBus
            area_id = first(DBInterface.execute(stmts[:zone_for_technology], [rec.area])).id
            regions = [
                get_region(Node, portfolio, row.name) for
                row in DBInterface.execute(stmts[:area_to_topology], [area_id])
            ]
        else
            regions = [get_region(Zone, portfolio, rec.area)]
        end

        if rec.prime_mover == "STORAGE"
            technology = StorageTechnology{parametric}(;
                name=rec.prime_mover * string(rec.id),
                capital_costs_discharge=LinearCurve(0.0),
                prime_mover_type=get(PRIME_MOVER_MAPPING, rec.prime_mover, PrimeMovers.OT),
                storage_tech=get(STORAGE_MAPPING, rec.fuel, StorageTech.OTHER_THERM),
                region=regions,
                financial_data=DEFAULT_FINANCIAL_DATA,
                available=true,
                power_systems_type=string(nameof(parametric)),
                operation_costs=StorageCost(),
            )
            IS.set_id!(technology, next_id!(ids))
        elseif rec.prime_mover in ["HYDRO", "ROR", "SYNC_COND"]
            @warn "Technologies of type $(rec.prime_mover) are not currently supported in portfolios. Skipping de-serialization."
            continue
        else
            technology = SupplyTechnology{parametric}(;
                name=rec.prime_mover * string(rec.id),
                capital_costs=LinearCurve(0.0),
                prime_mover_type=get(PRIME_MOVER_MAPPING, rec.prime_mover, PrimeMovers.OT),
                fuel=[get(FUEL_MAPPING, rec.fuel, ThermalFuels.OTHER)],
                co2=Dict(get(FUEL_MAPPING, rec.fuel, ThermalFuels.OTHER) => 0.0),
                region=regions,
                financial_data=DEFAULT_FINANCIAL_DATA,
                available=true,
                power_systems_type=string(nameof(parametric)),
                operation_costs=ThermalGenerationCost(
                    variable_operation_cost=CostCurve(LinearCurve(0.0)),
                    fixed=0.0,
                    start_up=0.0,
                    shut_down=0.0,
                ),
            )
            IS.set_id!(technology, next_id!(ids))
        end
        add_technology!(portfolio, technology)
    end
end

function add_generation_units!(
    portfolio::Portfolio,
    attributes::Dict{Int64, Dict{String, Any}},
    stmts::Dict,
    owners::Dict{Int64, Any},
)
    for rec in DBInterface.execute(stmts[:generation_units])
        downstream = true

        component_type = getproperty(
            PowerSystems,
            Symbol(first(DBInterface.execute(stmts[:entity_type], [rec.id])).entity_type),
        )
        component_attr = get(attributes, rec.id, Dict{String, Any}())

        bus_name =
            first(
                DBInterface.execute(stmts[:topology_for_unit], [rec.balancing_topology]),
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
                status=component_attr["status"] ? PSY.OperationalStates.ONLINE :
                       PSY.OperationalStates.OFFLINE,
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
            reservoir_link = first(DBInterface.execute(stmts[:reservoir], [rec.id, rec.id]))
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
                head_to_volume_factor=head_to_volume_factor.function_data,
                operation_cost=parse_operational_cost(reservoir_attr["operation_cost"]),
                level_data_type=PSY.get_enum_value(
                    PSY.ReservoirDataType,
                    reservoir_attr["level_data_type"],
                ),
            )
        end
        if component_type == PSY.HydroTurbine
            add_component!(portfolio.base_system, reservoir)
            add_component!(portfolio.base_system, turbine)
            owners[rec.id] = turbine
            if downstream
                PSY.set_downstream_turbines!(reservoir, [turbine])
            else
                PSY.set_upstream_turbines!(reservoir, [turbine])
            end
        else
            add_component!(portfolio.base_system, generator)
            owners[rec.id] = generator
        end
        if component_type in
           [PSY.ThermalStandard, PSY.RenewableDispatch, PSY.RenewableNonDispatch]
            if get_aggregation(portfolio) == PSY.ACBus
                regions = [get_region(Node, portfolio, bus_name)]
            else
                area_id =
                    first(
                        DBInterface.execute(
                            stmts[:topology_to_area],
                            [rec.balancing_topology],
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
            IS.set_id!(technology, rec.id)
            add_technology!(portfolio, technology)
            existing = ExistingDevices(existing_devices=[rec.name])
            IS.set_id!(existing, rec.id)
            add_supplemental_attribute!(portfolio, technology, existing)

            set_capacity_limits!(
                technology,
                (min=0.0, max=get_existing_capacity_mw(portfolio, technology)),
                u"MW",
            )
        end
    end
end

function add_storage_units!(
    portfolio::Portfolio,
    attributes::Dict{Int64, Dict{String, Any}},
    stmts::Dict,
    owners::Dict{Int64, Any},
)
    for rec in DBInterface.execute(stmts[:storage_units])
        component_type = getproperty(
            PowerSystems,
            Symbol(first(DBInterface.execute(stmts[:entity_type], [rec.id])).entity_type),
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
                DBInterface.execute(stmts[:topology_for_unit], [rec.balancing_topology]),
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
        add_component!(portfolio.base_system, storage_unit)
        owners[rec.id] = storage_unit

        if get_aggregation(portfolio) == PSY.ACBus
            regions = [get_region(Node, portfolio, bus_name)]
        else
            area_id =
                first(
                    DBInterface.execute(stmts[:topology_to_area], [rec.balancing_topology]),
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
        IS.set_id!(storage, rec.id)
        add_technology!(portfolio, storage)
        existing = ExistingDevices(existing_devices=[rec.name])
        IS.set_id!(existing, rec.id)
        add_supplemental_attribute!(portfolio, storage, existing)
    end
end

function add_demand_requirements!(
    portfolio::Portfolio,
    attributes::Dict{Int64, Dict{String, Any}},
    stmts::Dict,
)
    for rec in DBInterface.execute(stmts[:demand_requirements])
        component_type = getproperty(
            PowerSystems,
            Symbol(first(DBInterface.execute(stmts[:entity_type], [rec.id])).entity_type),
        )
        component_attr = get(attributes, rec.id, Dict{String, Any}())

        if get_aggregation(portfolio) == PSY.ACBus
            area = rec.balancing_topology
        else
            area =
                first(
                    DBInterface.execute(stmts[:topology_to_area], [rec.balancing_topology]),
                ).area
        end

        demand = DemandRequirement{component_type}(;
            name=rec.name,
            new_demand_mw=component_attr["active_power"], #TODO: Change to "max_active_power" later when DB is fixed
            region=collect(
                IS.get_components(x -> get_id(x) == area, RegionTopology, portfolio.data),
            ),
            value_of_lost_load=1e8, #TODO: Assign a default value to this field
            power_systems_type=string(nameof(component_type)),
        )
        IS.set_id!(demand, rec.id)
        add_technology!(portfolio, demand)
    end
end

function add_loads!(
    portfolio::Portfolio,
    attributes::Dict{Int64, Dict{String, Any}},
    stmts::Dict,
    owners::Dict{Int64, Any},
)
    for rec in DBInterface.execute(stmts[:demand_requirements])
        component_type = getproperty(
            PowerSystems,
            Symbol(first(DBInterface.execute(stmts[:entity_type], [rec.id])).entity_type),
        )
        component_attr = get(attributes, rec.id, Dict{String, Any}())

        # Determine area based on balancing topology if zonal
        bus_name =
            first(
                DBInterface.execute(stmts[:topology_for_unit], [rec.balancing_topology]),
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
        add_component!(portfolio.base_system, load)
        owners[rec.id] = load
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
    owners::Dict{Int64, Any},
    ids::IdAllocator,
)
    arc_dict = Dict()
    for rec in DBInterface.execute(stmts[:arcs])
        component_attr = get(attributes, rec.id, Dict{String, Any}())
        from_bus = first(DBInterface.execute(stmts[:topology_from_arc], [rec.from_id])).name
        to_bus = first(DBInterface.execute(stmts[:topology_from_arc], [rec.to_id])).name
        arc = Arc(;
            from=PSY.get_component(ACBus, portfolio.base_system, from_bus),
            to=PSY.get_component(ACBus, portfolio.base_system, to_bus),
        )
        add_component!(portfolio.base_system, arc)
        arc_dict[rec.id] = arc
        owners[rec.id] = arc
    end

    tx_dict = Dict()
    for rec in DBInterface.execute(stmts[:transmission_lines])
        comp_string = first(DBInterface.execute(stmts[:entity_type], [rec.id])).entity_type
        if haskey(PSY6_MAPPING, comp_string)
            comp_string = PSY6_MAPPING[comp_string]
        end
        component_type = getproperty(PowerSystems, Symbol(comp_string))
        component_attr = get(attributes, rec.id, Dict{String, Any}())

        # Determine area based on balancing topology if zonal
        arc = first(DBInterface.execute(stmts[:arc], [rec.arc_id])).id

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

        elseif component_type == PSY.TwoWindingTransformer
            circuit = PSY.TransformerCircuit(;
                arc=arc_dict[arc],
                rating=rec.continuous_rating / get_base_power(portfolio.base_system),
                base_power=component_attr["base_power"],
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
                reactive_power_flow=component_attr["reactive_power_flow"] /
                                    get_base_power(portfolio.base_system),
                active_power_flow=component_attr["active_power_flow"] /
                                  get_base_power(portfolio.base_system),
            )

            line = component_type(;
                name=rec.name,
                circuit=circuit,
                magnetizing_shunt=transform_natural_impedance_to_device_base(
                    component_attr["primary_shunt"]["real"],
                    arc_dict[arc],
                    portfolio.base_system,
                ),
            )
        end
        add_component!(portfolio.base_system, line)
        owners[rec.id] = line

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
            arc = first(DBInterface.execute(stmts[:arc], [rec.arc_id]))
            balancing_topology_from =
                first(DBInterface.execute(stmts[:topology_from_arc], [arc.from_id])).name
            balancing_topology_to =
                first(DBInterface.execute(stmts[:topology_from_arc], [arc.to_id])).name

            transport = NodalACTransportTechnology{component_type}(;
                name=rec.name,
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
            IS.set_id!(transport, rec.id)
            add_technology!(portfolio, transport)
            existing = ExistingDevices(; existing_devices=[rec.name])
            IS.set_id!(existing, rec.id)
            add_supplemental_attribute!(portfolio, transport, existing)
            set_capacity_limits!(
                transport,
                (min=0.0, max=get_existing_capacity_mw(portfolio, transport)),
                u"MW",
            )

            new_transport = NodalACTransportTechnology{component_type}(;
                name=rec.name * "_new",
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
            IS.set_id!(new_transport, next_id!(ids))
            add_technology!(portfolio, new_transport)
        end
    end

    if get_aggregation(portfolio) != PSY.ACBus
        id = 1
        for (areas, lines) in tx_dict
            area_list = collect(areas)
            transport = AggregateTransportTechnology{ACBranch}(;
                name=string(area_list[1]) * "_" * string(area_list[2]),
                available=true,
                power_systems_type=string(nameof(ACBranch)),
                financial_data=DEFAULT_FINANCIAL_DATA,
                start_region=get_region(Zone, portfolio, area_list[1]),
                end_region=get_region(Zone, portfolio, area_list[2]),
                capital_costs=LinearCurve(1e5),
            )
            IS.set_id!(transport, id)
            id += 1
            add_technology!(portfolio, transport)
            existing = ExistingDevices(existing_devices=lines)
            IS.set_id!(existing, id)
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
            for ts_association in
                DBInterface.execute(stmts[:investment_timeseries], [ts_type])
                timestamps = [
                    Dates.DateTime(row.idx, 1, 1) for row in DBInterface.execute(
                        stmts[:ts_data],
                        [ts_association.time_series_uuid],
                    )
                ]
                values = [
                    row.value for row in DBInterface.execute(
                        stmts[:ts_data],
                        [ts_association.time_series_uuid],
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
                    variable_operation_cost=FuelCurve(
                        heat_rate,
                        cost_data["fuel_price"],
                        LinearCurve(0.0),
                        LinearCurve(cost_data["vom"]),
                    ),
                    fixed=cost_data["fom"] * 1000.0,
                    start_up=0.0,
                    shut_down=0.0,
                )
                set_operation_costs!(
                    tech,
                    opex,
                    (energy_unit=u"MW" * u"hr", fuel_unit=MMBtu, currency_unit=USD),
                )
                set_capital_costs!(tech, capex, (x_unit=u"MW", y_unit=USD))
            else
                capex = LinearCurve(cost_data["capcost"] * 1000.0)
                opex = RenewableGenerationCost(
                    variable_operation_cost=CostCurve(
                        LinearCurve(0.0),
                        LinearCurve(cost_data["vom"]),
                    ),
                )
                set_operation_costs!(tech, opex, (x_unit=u"MW" * u"hr", y_unit=USD))
                set_capital_costs!(tech, capex, (x_unit=u"MW", y_unit=USD))
            end
        elseif !is_new(tech)
            if haskey(cost_data, "fuel_price")
                units = (energy_unit=u"MW" * u"hr", fuel_unit=MMBtu, currency_unit=USD)
                ops = get_operation_costs(tech, units)
                fixed = get_fixed_cost(tech, units)
                vom = get_variable_cost(tech, units)
                if vom == 0.0
                    vom = LinearCurve(cost_data["vom"])
                end
                if get_fixed(ops) == 0.0
                    fixed = cost_data["fom"] * 1000.0
                end
                set_variable_operation_cost!(
                    ops,
                    FuelCurve(
                        get_value_curve(get_variable_operation_cost(ops)),
                        get_fuel_cost(tech, units),
                        IS.get_startup_fuel_offtake(get_variable_operation_cost(ops)),
                        vom,
                    ),
                )
                set_fixed!(ops, fixed)
                set_operation_costs!(
                    tech,
                    ops,
                    (energy_unit=u"MW" * u"hr", fuel_unit=MMBtu, currency_unit=USD),
                )
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
                ts_array = get_time_series_array(SingleTimeSeries, unit, "max_active_power")
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
                ts_array = get_time_series_array(SingleTimeSeries, unit, "max_active_power")
            end
            # Per unit on the unit's own base, as the source profile was declared.
            ts = SingleTimeSeries(
                "capacity_factor",
                ts_array;
                unit_system=IS.CU,
                quantity_kind="active_power",
            )
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
        ts_array = get_time_series_array(SingleTimeSeries, unit, "max_active_power")
        ts = SingleTimeSeries(
            "demand",
            ts_array;
            unit_system=IS.CU,
            quantity_kind="active_power",
        )
        add_time_series!(portfolio, demand, ts)
    end
end

#############################################################################
# Readers for SiennaGridDB's time series tables. The SQL and the column names below are
# that schema — an external input format — not a copy of any InfrastructureSystems internal.
#############################################################################

"""
`unit_system` / `quantity_kind` / `units` for a series the database normalized against an
accessor on its owner.

The `scaling_factor_multiplier` column holds a serialized function reference; every read used
to multiply the stored values by it. Nothing rescales on retrieval now, so the declaration
carries that meaning instead: `IS.CU` says the values are per unit on the owner's own base,
and `quantity_kind` names the quantity they scale to. A per-unit basis is not a units label,
so `units` stays `nothing`.

Errors on a multiplier with no mapping rather than leaving the quantity unstated: the values
are per unit either way, and a consumer that cannot tell what of is stuck.
"""
function normalized_series_declaration(raw_multiplier)
    if ismissing(raw_multiplier) || isnothing(raw_multiplier)
        return (unit_system=nothing, quantity_kind=nothing, units=nothing)
    end
    accessor = JSON3.read(raw_multiplier, Dict{String, Any})["__metadata__"]["function"]
    if !haskey(MULTIPLIER_QUANTITY_KINDS, accessor)
        error(
            "unmapped scaling_factor_multiplier=$accessor in time_series_associations; it " *
            "names no physical quantity for the normalized values to scale to",
        )
    end
    return (
        unit_system=IS.CU,
        quantity_kind=MULTIPLIER_QUANTITY_KINDS[accessor],
        units=nothing,
    )
end

"""
The values of one `static_time_series` array, in index order.
"""
function read_static_time_series(db, time_series_uuid)
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
    return Tables.columntable(rows).value
end

"""
Build the time series one `time_series_associations` row describes.

Only `SingleTimeSeries` is read: a forecast row states a horizon and an interval that the
static array alone cannot reproduce, so it is refused rather than silently flattened.
"""
function deserialize_time_series(db, row)
    if row.time_series_type != "SingleTimeSeries"
        error(
            "time_series_associations row $(row.metadata_uuid) declares " *
            "time_series_type=$(row.time_series_type); only SingleTimeSeries is supported",
        )
    end
    values = read_static_time_series(db, row.time_series_uuid)
    if length(values) != row.length
        error(
            "time series $(row.name) declares length=$(row.length) but its " *
            "static_time_series array holds $(length(values)) values",
        )
    end
    declaration = normalized_series_declaration(row.scaling_factor_multiplier)
    return SingleTimeSeries(
        row.name,
        Dates.DateTime(row.initial_timestamp),
        IS.from_iso_8601(row.resolution),
        values;
        units=declaration.units,
        quantity_kind=declaration.quantity_kind,
        unit_system=declaration.unit_system,
    )
end

"""
Attach every component-owned time series in the database to its owner in `sys`.

`owners` maps a database entity id to the component parsed from it. Rows in another
`owner_category` are the technology cost profiles, which belong to the portfolio rather than
the base system; [`deserialize_portfolio_timeseries!`](@ref) reads those.
"""
function deserialize_timeseries!(sys::PowerSystems.System, db, owners::Dict{Int64, Any})
    for row in DBInterface.execute(db, "SELECT * FROM time_series_associations")
        row.owner_category == "Component" || continue
        if !haskey(owners, row.owner_id)
            error(
                "time series $(row.name) names owner_id=$(row.owner_id), which no parsed " *
                "component claims",
            )
        end
        PowerSystems.add_time_series!(
            sys,
            owners[row.owner_id],
            deserialize_time_series(db, row),
        )
    end
    return
end

end # module DBParser
