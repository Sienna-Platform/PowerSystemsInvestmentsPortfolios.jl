isdefined(Base, :__precompile__) && __precompile__()

module PowerSystemsInvestmentsPortfolios

import InfrastructureSystems
# TODO: Some of these re-exports may cause name collisions with PowerSystems
# `get_name` extends InfrastructureSystems' (and so PowerSystems') function, so one `get_name`
# names technologies, requirements and PowerSystems topology alike
import InfrastructureSystems:
    get_name,
    from_json,
    serialize,
    has_time_series,
    get_time_series_multiple,
    get_time_series_array,
    get_time_series_timestamps,
    get_time_series_values,
    supports_time_series,
    InfrastructureSystemsInternal,
    CompressionSettings,
    CompressionTypes,
    MultiLogger,
    LogEventTracker,
    StructField,
    CostCurve,
    LinearCurve,
    InfrastructureSystemsComponent,
    InfrastructureSystemsType,
    get_available,
    TimeSeriesInputOutputCurve,
    TimeSeriesIncrementalCurve,
    TimeSeriesAverageRateCurve,
    TimeSeriesFunctionData,
    StaticFunctionData,
    TimeSeriesLinearCurve,
    TimeSeriesQuadraticCurve,
    TimeSeriesPiecewisePointCurve,
    TimeSeriesPiecewiseIncrementalCurve,
    TimeSeriesPiecewiseAverageCurve

# Using PowerSystems in order to support deserializing with PSY parametric typing
using PowerSystems
import PowerSystems: ThermalFuels, PrimeMovers, StorageTech, ACBusTypes, LoadConformity

import JSONSchema
import JSON
import JSON3
import PrettyTables
import SQLite
import DataFrames
import DBInterface
import TimeSeries
import Dates
import DataStructures: OrderedDict, SortedDict
import OpenAPI
import PowerCoreOpenAPIModels
import PowerInvestmentsOpenAPIModels
import InfrastructureCoreOpenAPIModels
import InfrastructureTimeSeriesOpenAPIModels
const PC = PowerCoreOpenAPIModels
const PI = PowerInvestmentsOpenAPIModels
const IC = InfrastructureCoreOpenAPIModels
const PTS = InfrastructureTimeSeriesOpenAPIModels
import StringEncodings
import Tables
import Unitful
using Unitful: @u_str, @unit, Quantity, Units, uconvert, ustrip, unit
using DocStringExtensions

export Portfolio
export Requirement
export Technology
export ResourceTechnology
export DemandTechnology
export TransmissionTechnology
export FinancialData
export SupplyTechnology
export ColocatedSupplyStorageTechnology
export NodalACTransportTechnology
export AggregateTransportTechnology
export NodalHVDCTransportTechnology
export StorageTechnology
export ProjectedDemand
export DemandSideTechnology
export RetirementPotential
export RetrofitPotential
export ExistingDevices
export CarbonCaps
export CapacityReserveMargin
export CarbonTax
export HourlyMatching
export EnergyShareRequirements
export MinimumCapacityRequirements
export MaximumCapacityRequirements
export PortfolioFinancialData
export InvestmentScheduleResults
export TechnologyFinancialData
export TimeMapping
export InvestmentIntervals
export OperationalPeriods
export CapitalCost
export StorageCapitalCost

export get_name
export get_description
export get_topologies
export get_topology
export get_technologies
export get_technology
export get_available_technology
export get_available_technologies
export get_technologies_by_name
export get_requirement
export get_requirements
export get_contributing_technologies
export has_requirement
export get_ext
export get_description
export get_financial_data
export get_base_year
export get_inflation_rate
export get_interest_rate
export get_discount_rate
export get_investment_schedule
export get_base_system
export set_description!
export set_name!
export set_base_year!
export set_inflation_rate!
export set_interest_rate!
export set_discount_rate!
export set_investment_schedule!
export set_base_system!
export add_technology!
export add_technologies!
export validate_technology
export check_technology
export check_technologies
export remove_technology!
export get_subcomponents
export get_masked_technologies
export is_masked
export add_topology!
export get_zone_type
export get_zones
export get_zone
export get_nodes
export get_node
export get_lines
export get_model_topologies
export remove_topology!
export add_requirement!
export add_time_series!
export clear_time_series!
export add_supplemental_attribute!
export remove_supplemental_attribute!
export get_supplemental_attribute
export get_supplemental_attributes
export MinMax
export InOut
export UpDown
export from_openapi
export to_openapi
export get_associated_technologies
export InvestmentCost
export OutageFactors

export show_region_topology_table

export get_existing_capacity_mw
export get_existing_capacity_mwh
export get_retrofit_capacity_mw
export is_new
export get_heat_rate
export get_fuel_cost
export get_variable_cost
export get_variable_cost_charge
export get_variable_cost_discharge
export get_fixed_cost
export get_fixed_cost_charge
export get_fixed_cost_discharge
export get_wacc

export update_system_with_nodal_results!

const PSY = PowerSystems
const IS = InfrastructureSystems
const MU = IS.Mustache

export USD, MMBtu, tonne, Mt, ustrip, uconvert, @u_str
export POWER, IMPEDANCE, VOLTAGE, INV_TIME, OPS_TIME, ENERGY
export natural_unit

export ThermalFuels
export PrimeMovers
export StorageTech

# Topology lives in the base `PSY.System` and technologies reference it directly, so the
# PowerSystems topology types are re-exported: building a portfolio needs no `PSY.` prefix.
# These are the same bindings PowerSystems exports, so `using` both packages does not clash.
export Topology
export AggregationTopology
export Area
export LoadZone
export Arc
export Bus
export ACBus
export DCBus
# What constructing that topology needs. `input_basis` is a Unitful unit — `u"CU"` (component
# base) or `u"NU"` (natural units) — and `@u_str` only finds those when the `PerUnit` unit
# module is bound by name in the calling module, so it is re-exported next to `@u_str`.
export PerUnit
export ACBusTypes
# The unit-system markers `to_file`'s `base_system_units` takes. PSIP has no system-base
# representation, so `SU` is deliberately not re-exported.
export CU
export NU

include("definitions.jl")

include("models/requirements.jl")
include("models/technologies.jl")
include("models/regions.jl")
include("models/financial_data/financial_data.jl")
include("models/financial_data/TechnologyFinancialData.jl")
include("models/cost_functions/investment_cost.jl")
include("models/cost_functions/CapitalCost.jl")
include("models/cost_functions/StorageCapitalCost.jl")
include("openapi/refs.jl")
include("models/generated/includes.jl")
include("investment_schedule.jl")

include("units/types.jl")
include("units/conversions.jl")
include("units/function_conversions.jl")

include("portfolio.jl")
include("topology.jl")
include("openapi/cost_conversion.jl")
include("openapi/export_cost_conversion.jl")
include("openapi/sqlite_load.jl")
include("openapi/import_document.jl")
include("validation.jl")
include("time_mapping.jl")
include("openapi/export_document.jl")
include("openapi/file_io.jl")
include("utils/getters.jl")
include("db_parser.jl")
include("utils/generate_structs.jl")
include("utils/print.jl")
@static if pkgversion(PrettyTables).major == 2
    include("utils/print_pt_v2.jl")
else
    include("utils/print_pt_v3.jl")
end
include("update_system.jl")

const localunits = Unitful.basefactors
const localpromotion = copy(Unitful.promotion)
function __init__()
    merge!(Unitful.basefactors, localunits)
    merge!(Unitful.promotion, localpromotion)
    Unitful.register(PowerSystemsInvestmentsPortfolios)
end

@template (FUNCTIONS, METHODS) = """
                                 $(TYPEDSIGNATURES)
                                 $(DOCSTRING)
                                 """

end
