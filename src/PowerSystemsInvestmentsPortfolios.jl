isdefined(Base, :__precompile__) && __precompile__()

module PowerSystemsInvestmentsPortfolios

import InfrastructureSystems
# TODO: Some of these re-exports may cause name collisions with PowerSystems
import InfrastructureSystems:
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
    get_available

# Using PowerSystems in order to support deserializing with PSY parametric typing
using PowerSystems
import PowerSystems: ThermalFuels, PrimeMovers, StorageTech, ACBusTypes

import JSONSchema
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
const PC = PowerCoreOpenAPIModels
const PI = PowerInvestmentsOpenAPIModels
import StringEncodings
import Tables
import Unitful
using Unitful: @dimension, @u_str, @refunit, @unit, Quantity, Units, uconvert, ustrip, unit

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
export DemandRequirement
export DemandSideTechnology
export RetirementPotential
export RetrofitPotential
export ExistingDevices
export TopologyMapping
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

export get_name
export get_description
export get_regions
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
export add_region!
export add_topology!
export remove_topology!
export add_requirement!
export add_time_series!
export clear_time_series!
export add_supplemental_attribute!
export remove_supplemental_attribute!
export get_supplemental_attribute
export get_supplemental_attributes
export to_json
export from_json
export MinMax
export InOut
export UpDown
export from_openapi
export to_openapi

export show_region_topology_table

export get_existing_capacity_mw
export get_existing_capacity_mwh
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
export POWER, IMPEDANCE, ADMITTANCE, VOLTAGE, CURRENT, INV_TIME, OPS_TIME, ENERGY
export natural_unit, ConversionUnits, FuelCurveUnits

export ThermalFuels
export PrimeMovers
export StorageTech

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
include("openapi/cost_conversion.jl")
include("openapi/export_cost_conversion.jl")
include("models/generated/includes.jl")
include("investment_schedule.jl")

include("units/types.jl")
include("units/conversions.jl")
include("units/function_conversions.jl")

include("portfolio.jl")
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

using DocStringExtensions

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
