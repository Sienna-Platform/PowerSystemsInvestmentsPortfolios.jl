# # Create and Explore a Portfolio
#
# This tutorial walks through building a capacity expansion portfolio from scratch using a
# small 5-bus test system. By the end you will know how to:
#
# - Create a [`Portfolio`](@ref) from a `PowerSystems.jl` base system
# - Define regions and assign technologies to them
# - Add supply, storage, demand, and transmission technologies
# - Attach policy requirements
# - Query the portfolio's contents
#
# !!! tip "New to PowerSystems.jl?"
#     PSIP builds on top of `PowerSystems.jl` (PSY). The essential concepts you need:
#
#     - A **System** is a container for all power grid components at a single point in time.
#       Think of it as a snapshot database of buses, generators, lines, and loads.
#     - A **Component** is any typed object in the System — a bus (`ACBus`), a generator
#       (`ThermalStandard`, `RenewableDispatch`), a load (`PowerLoad`).
#     - **Time series** in a System are hourly or sub-hourly profiles (capacity factors,
#       demand) stored separately from the component struct.
#
#     For a full introduction, see the
#     [PowerSystems.jl documentation](https://sienna-platform.github.io/PowerSystems.jl/stable/).

# ## Setup
#
# We load `PowerSystemCaseBuilder` to access the `c_sys5_re` 5-bus test system and
# `PowerSystems` for the PSY type names used as type parameters.

using PowerSystemsInvestmentsPortfolios
using PowerSystemCaseBuilder
using PowerSystems
const PSY = PowerSystems
using Dates
using TimeSeries
import PowerSystemsInvestmentsPortfolios: add_time_series!
import PowerSystems: get_name

# ## Load the Base System
#
# The [`Portfolio`](@ref) wraps a PSY `System`, which provides the underlying network
# topology and component library. Here we use the `c_sys5_re` test system — a small
# 5-bus network with thermal, wind, and solar generators and three load buses.

sys = build_system(PSITestSystems, "c_sys5_re")

# Switch to natural units (MW) so capacity values are in megawatts.
set_units_base_system!(sys, "NATURAL_UNITS")

# ## Create the Portfolio
#
# [`Portfolio`](@ref) is PSIP's central container — analogous to `System` in PSY. The
# constructor takes the base system and portfolio-level financial parameters.
#
# - `base_year` — the reference year for all capital cost data
# - `discount_rate` — weighted average cost of capital for NPV calculations
# - `inflation_rate` — annual general inflation applied to costs over time
# - `interest_rate` — nominal interest rate used for financing calculations

portfolio = Portfolio(sys; financial_data=PortfolioFinancialData(
    2025,   # base_year
    0.07,   # discount_rate
    0.05,   # inflation_rate
    0.03,   # interest_rate
))

# ## Define Regions
#
# Technologies are always assigned to one or more [`RegionTopology`](@ref) objects.
# PSIP supports two region types:
#
# - **[`Zone`](@ref)** — an aggregated load zone for zonal (transport-based) models
# - **[`Node`](@ref)** — a specific AC bus for nodal (power-flow-based) models
#
# We create two zones for this tutorial. Zone IDs must be unique across the portfolio.

z1 = Zone(name="Zone_1", id=1)
z2 = Zone(name="Zone_2", id=2)

add_region!(portfolio, z1)
add_region!(portfolio, z2)

# ## Technology Financial Data
#
# [`TechnologyFinancialData`](@ref) captures the financing structure for a technology and
# overrides the portfolio-level defaults when provided. The capital recovery period drives
# the annualized capital cost formula.

tech_financials = TechnologyFinancialData(;
    capital_recovery_period=30,
    technology_base_year=2025,
    debt_fraction=0.5,
    debt_rate=0.07,
    return_on_equity=0.10,
    tax_rate=0.257,
)

# ## Add Supply Technologies
#
# [`SupplyTechnology{T}`](@ref) models a dispatchable or variable generator. The type
# parameter `T` is the PSY component type this technology maps to (used by `PSI` when
# building the optimization model).
#
# ### Coal Thermal

t_thermal = SupplyTechnology{PSY.ThermalStandard}(;
    name="coal_thermal",
    id=1,
    available=true,
    power_systems_type="ThermalStandard",
    prime_mover_type=PrimeMovers.ST,
    fuel=[ThermalFuels.COAL],
    region=[z1],
    capital_costs=LinearCurve(6_937_377.0),   # $/MW
    operation_costs=ThermalGenerationCost(
        variable=FuelCurve(LinearCurve(22.5), 1.12),
        fixed=0.0,
        start_up=0.0,
        shut_down=0.0,
    ),
    capacity_limits=(0.0, 3000.0),
    outage_factor=0.92,
    unit_size=250.0,
    financial_data=tech_financials,
)

add_technology!(portfolio, t_thermal)

# ### Wind

t_wind = SupplyTechnology{PSY.RenewableDispatch}(;
    name="wind",
    id=2,
    available=true,
    power_systems_type="RenewableDispatch",
    prime_mover_type=PrimeMovers.WT,
    fuel=[ThermalFuels.OTHER],
    region=[z2],
    capital_costs=LinearCurve(1_577_392.0),   # $/MW
    operation_costs=ThermalGenerationCost(
        variable=CostCurve(LinearCurve(0.0)),
        fixed=4.5,
        start_up=0.0,
        shut_down=0.0,
    ),
    capacity_limits=(0.0, 300.0),
    outage_factor=0.92,
    financial_data=tech_financials,
)

add_technology!(portfolio, t_wind)

# ### Solar PV

t_solar = SupplyTechnology{PSY.RenewableDispatch}(;
    name="solar_pv",
    id=3,
    available=true,
    power_systems_type="RenewableDispatch",
    prime_mover_type=PrimeMovers.PVe,
    fuel=[ThermalFuels.OTHER],
    region=[z1],
    capital_costs=LinearCurve(1_575_766.0),   # $/MW
    operation_costs=ThermalGenerationCost(
        variable=CostCurve(LinearCurve(0.0)),
        fixed=0.0,
        start_up=0.0,
        shut_down=0.0,
    ),
    capacity_limits=(0.0, 1e8),
    outage_factor=0.92,
    financial_data=tech_financials,
)

add_technology!(portfolio, t_solar)

# ## Add a Storage Technology
#
# [`StorageTechnology{T}`](@ref) has separate power (discharge) and energy capacity
# limits and capital costs, reflecting the two-dimensional sizing of battery storage.

t_storage = StorageTechnology{PSY.EnergyReservoirStorage}(;
    name="battery_storage",
    id=4,
    available=true,
    power_systems_type="EnergyReservoirStorage",
    prime_mover_type=PrimeMovers.BT,
    storage_tech=StorageTech.LIB,
    region=[z1],
    capacity_limits_discharge=(0.0, 300.0),   # MW
    capacity_limits_energy=(0.0, 1200.0),     # MWh
    capital_costs_discharge=LinearCurve(1_343_150.0),  # $/MW
    capital_costs_energy=LinearCurve(745_250.0),       # $/MWh
    operation_costs=StorageCost(
        charge_variable_cost=CostCurve(LinearCurve(0.0)),
        discharge_variable_cost=CostCurve(LinearCurve(0.0)),
        fixed=0.0,
    ),
    unit_size_discharge=10.0,
    unit_size_energy=10.0,
    financial_data=tech_financials,
)

add_technology!(portfolio, t_storage)

# ## Add Demand Technologies
#
# [`DemandRequirement{T}`](@ref) represents a load node in the portfolio. Unlike supply
# technologies, demand is not a `Requirement` — it is a `DemandTechnology` that carries
# load profiles via time series.

t_demand = DemandRequirement{PSY.PowerLoad}(;
    name="demand_zone1",
    id=5,
    available=true,
    power_systems_type="PowerLoad",
    region=[z1],
    unserved_demand_cost=LinearCurve(50_000.0),   # $/MWh
)

add_technology!(portfolio, t_demand)

# ## Add a Transmission Technology
#
# [`AggregateTransportTechnology{T}`](@ref) models a corridor between two zones in
# transport (zonal) models. It has a single capacity limit and a line loss fraction.

t_line = AggregateTransportTechnology{PSY.ACBranch}(;
    name="zone1_to_zone2",
    id=6,
    available=true,
    power_systems_type="TransportTechnology",
    start_region=z1,
    end_region=z2,
    capacity_limits=(min=0, max=900),
    line_loss=0.05,
    capital_costs=LinearCurve(5_000_000.0),   # $/MW
    financial_data=tech_financials,
)

add_technology!(portfolio, t_line)

# ## Add Policy Requirements
#
# Requirements impose constraints on the optimization model. They are stored separately
# from technologies and added with [`add_requirement!`](@ref).

crm = CapacityReserveMargin(;
    name="planning_reserve",
    id=7,
    available=true,
    target_year=2030,
    eligible_regions=[z1, z2],
    eligible_technologies=[t_thermal],
)

esr = EnergyShareRequirements(;
    name="renewable_portfolio_standard",
    id=8,
    available=true,
    eligible_regions=[z1, z2],
    eligible_resources=[t_wind, t_solar],
)

add_requirement!(portfolio, crm)
add_requirement!(portfolio, esr)

# ## Explore the Portfolio
#
# ### Count technologies by type

supply_techs = collect(get_technologies(SupplyTechnology, portfolio))
println("Supply technologies: ", length(supply_techs))

storage_techs = collect(get_technologies(StorageTechnology, portfolio))
println("Storage technologies: ", length(storage_techs))

demand_techs = collect(get_technologies(DemandRequirement, portfolio))
println("Demand technologies: ", length(demand_techs))

# ### Look up a technology by name

coal = get_technology(SupplyTechnology{PSY.ThermalStandard}, portfolio, "coal_thermal")
println("Coal capital cost: ", get_capital_costs(coal))

# ### List requirements

requirements = collect(get_requirements(portfolio))
println("Requirements: ", [get_name(r) for r in requirements])

# ### Summary print

show(portfolio)
