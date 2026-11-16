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
    get_available,
    DeviceParameter

#################################################################################

using DocStringExtensions

@template (FUNCTIONS, METHODS) = """
                                 $(TYPEDSIGNATURES)
                                 $(DOCSTRING)
                                 """

#################################################################################

# Using PowerSystems in order to support deserializing with PSY parametric typing
using PowerSystems

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
import StringEncodings
import HDF5
import Tables

export Portfolio
export Requirement
export Technology
export ResourceTechnology
export DemandTechnology
export TransmissionTechnology
export FinancialData
export RegionTopology
export SupplyTechnology
export ColocatedSupplyStorageTechnology
export NodalACTransportTechnology
export AggregateTransportTechnology
export NodalHVDCTransportTechnology
export StorageTechnology
export DemandRequirement
export DemandSideTechnology
export RetirementPotential
export AggregateRetirementPotential
export RetrofitPotential
export AggregateRetrofitPotential
export ExistingDevices
export TopologyMapping
export CarbonCaps
export CapacityReserveMargin
export CarbonTax
export HourlyMatching
export EnergyShareRequirements
export MinimumCapacityRequirements
export MaximumCapacityRequirements
export RegionTopology
export Zone
export Node
export PortfolioFinancialData
export InvestmentScheduleResults
export TechnologyFinancialData
export TimeMapping
export InvestmentIntervals
export OperationalPeriods

export get_name
export get_description
export get_regions
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
export add_requirement!
export add_time_series!
export clear_time_series!
export read_json_data
export generate_invest_structs
export generate_structs
export database_to_portfolio
export add_supplemental_attribute!
export remove_supplemental_attribute!
export get_supplemental_attribute
export get_supplemental_attributes
export to_json
export from_json
export MinMax
export InOut
export UpDown
export set_units_base_system!
export CapitalCost
export InvestmentCost
export StorageCapitalCost
export OutageFactors

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

##### Imports #####

import PowerSystems: ThermalFuels, PrimeMovers, StorageTech, ACBusTypes

##### Exports #####

export ThermalFuels
export PrimeMovers
export StorageTech

#submodule for OpenAPI structs 
include("models/generated/open_api_models/src/APIServer.jl")
using .APIServer

include("definitions.jl")

include("models/cost_functions/investment_cost.jl")
include("models/cost_functions/CapitalCost.jl")
include("models/cost_functions/StorageCapitalCost.jl")

include("models/requirements.jl")
include("models/technologies.jl")
include("models/regions.jl")
include("models/financial_data/financial_data.jl")
include("models/financial_data/TechnologyFinancialData.jl")
include("models/generated/includes.jl")
include("investment_schedule.jl")

include("portfolio.jl")
include("validation.jl")
include("time_mapping.jl")
include("serialization.jl")
include("generate_structs.jl")
include("db_parser.jl")
include("utils/print.jl")
@static if pkgversion(PrettyTables).major == 2
    include("utils/print_pt_v2.jl")
else
    include("utils/print_pt_v3.jl")
end
include("utils/getters.jl")
include("update_system.jl")

end
