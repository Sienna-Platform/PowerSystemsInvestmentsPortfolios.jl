# # Create and Explore a Portfolio
#
# This tutorial walks through building a capacity expansion portfolio from scratch using a
# small 5-bus test system. By the end you will know how to:
#
# - Create a [`Portfolio`](@ref) from a `PowerSystems.jl` base system
# - Attach topology (areas and buses) and assign technologies to it
# - Add supply, storage, demand, and transmission technologies
# - Attach policy requirements and link technologies to them
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
# `PowerSystems` for the PSY types used as type parameters, topology, and cost curves.

using PowerSystemsInvestmentsPortfolios
using PowerSystemCaseBuilder
using PowerSystems
const PSY = PowerSystems
import PowerSystems: get_name

# `get_name` is defined by both packages, so we bind the PowerSystems one, which works on
# technologies, requirements, and topology alike.

# ## Load the Base System
#
# The [`Portfolio`](@ref) wraps a PSY `System` — its *base system* — which holds the
# existing grid and the network topology. Here we use the `c_sys5_re` test system, a small
# 5-bus network with thermal, wind, and solar generators and three loads.

sys = build_system(PSITestSystems, "c_sys5_re")

# ## Create the Portfolio
#
# [`Portfolio`](@ref) is PSIP's central container — analogous to `System` in PSY. Here we
# pass the base system and the portfolio-level financial parameters as a
# [`PortfolioFinancialData`](@ref):
#
# - `base_year` — the year all costs are converted to
# - `discount_rate` — rate used to discount future costs to the base year
# - `inflation_rate` — annual inflation applied to costs over time
# - `interest_rate` — nominal interest rate used for financing calculations

portfolio = Portfolio(sys; financial_data=PortfolioFinancialData(
    2025,   # base_year
    0.07,   # discount_rate
    0.05,   # inflation_rate
    0.03,   # interest_rate
))

# ## Define the Topology
#
# Technologies are located with PowerSystems topology components: an `Area` or `LoadZone`
# for zonal models and an `ACBus` for nodal models. These are stored in the portfolio's base
# system and added with [`add_topology!`](@ref). A technology can only reference topology
# that has already been added.
#
# PowerSystems 6 constructors take an `input_basis`: `u"NU"` means the values passed are in
# natural units (MW, kV).

z1 = Area(; name="Zone_1", input_basis=u"NU")
z2 = Area(; name="Zone_2", input_basis=u"NU")

add_topology!(portfolio, z1)
add_topology!(portfolio, z2)

# ## Technology Financial Data
#
# [`TechnologyFinancialData`](@ref) captures the financing structure of a technology. The
# capital recovery period and cost of capital determine how its overnight capital cost is
# annualized.

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
# parameter `T` is the PSY component type this technology maps to, used by
# `PowerSystemsInvestments.jl` when building the optimization model.
#
# Capital costs are a [`CapitalCost`](@ref): an overnight cost curve (USD/MW) plus a
# last-mile interconnection cost.
#
# ### Coal Thermal

t_thermal = SupplyTechnology{PSY.ThermalStandard}(;
    name="coal_thermal",
    available=true,
    power_systems_type="ThermalStandard",
    prime_mover_type=PrimeMovers.ST,
    fuel=[ThermalFuels.COAL],
    region=[z1],
    capital_costs=CapitalCost(;
        capital_cost=LinearCurve(6_937_377.0),   # USD/MW
        interconnection_cost=0.0,
    ),
    operation_costs=ThermalGenerationCost(;
        variable_operation_cost=FuelCurve(LinearCurve(10.5), 1.12),
        fixed=0.0,
        start_up=0.0,
        shut_down=0.0,
    ),
    capacity_limits=(min=0.0, max=3000.0),             # MW
    outage_factor=(planned=0.08, forced=0.0),
    unit_size=250.0,                                   # MW
    time_limits=(up=480.0, down=480.0),                # minutes
    financial_data=tech_financials,
)

add_technology!(portfolio, t_thermal)

# ### Wind

t_wind = SupplyTechnology{PSY.RenewableDispatch}(;
    name="wind",
    available=true,
    power_systems_type="RenewableDispatch",
    prime_mover_type=PrimeMovers.WT,
    fuel=[ThermalFuels.OTHER],
    region=[z2],
    capital_costs=CapitalCost(; capital_cost=LinearCurve(1_577_392.0)),
    operation_costs=RenewableGenerationCost(CostCurve(LinearCurve(0.0))),
    capacity_limits=(min=0.0, max=300.0),
    financial_data=tech_financials,
)

add_technology!(portfolio, t_wind)

# ### Solar PV

t_solar = SupplyTechnology{PSY.RenewableDispatch}(;
    name="solar_pv",
    available=true,
    power_systems_type="RenewableDispatch",
    prime_mover_type=PrimeMovers.PVe,
    fuel=[ThermalFuels.OTHER],
    region=[z1],
    capital_costs=CapitalCost(; capital_cost=LinearCurve(1_575_766.0)),
    operation_costs=RenewableGenerationCost(CostCurve(LinearCurve(0.0))),
    financial_data=tech_financials,
)

add_technology!(portfolio, t_solar)

# ## Add a Battery
#
# [`StorageTechnology{T}`](@ref) sizes charge power, discharge power, and energy capacity
# separately, so its capital costs are a [`StorageCapitalCost`](@ref) with one curve for
# each. Duration limits (the ratio of energy to discharge capacity) are in minutes.

t_storage = StorageTechnology{PSY.EnergyReservoirStorage}(;
    name="battery_storage",
    available=true,
    power_systems_type="EnergyReservoirStorage",
    prime_mover_type=PrimeMovers.BT,
    storage_tech=StorageTech.LIB,
    region=[z1],
    capacity_limits_discharge=(min=0.0, max=300.0),   # MW
    capacity_limits_energy=(min=0.0, max=1200.0),     # MWh
    duration_limits=(min=60.0, max=480.0),            # minutes (1 to 8 hours)
    capital_costs=StorageCapitalCost(;
        discharge_capital_cost=LinearCurve(1_343_150.0),   # USD/MW
        energy_capital_cost=LinearCurve(745_250.0),        # USD/MWh
    ),
    operation_costs=StorageCost(;
        charge_variable_cost=CostCurve(LinearCurve(0.0)),
        discharge_variable_cost=CostCurve(LinearCurve(0.0)),
        fixed=0.0,
    ),
    unit_size_discharge=10.0,
    unit_size_energy=10.0,
    financial_data=tech_financials,
)

add_technology!(portfolio, t_storage)

# ## Add a Demand Technology
#
# [`DemandRequirement{T}`](@ref) represents load that must be served in a region. Despite
# its name it is a `DemandTechnology`, not a policy `Requirement`, and it carries its load
# profile as a time series (see [Working With Time Series](@ref)).

t_demand = DemandRequirement{PSY.PowerLoad}(;
    name="demand_zone1",
    available=true,
    power_systems_type="PowerLoad",
    region=[z1],
    value_of_lost_load=50_000.0,   # USD/MWh
)

add_technology!(portfolio, t_demand)

# ## Add a Transmission Technology
#
# [`AggregateTransportTechnology{T}`](@ref) models a corridor between two zones in
# transport (zonal) models. Its endpoints are topology components that must already be in
# the portfolio.

t_line = AggregateTransportTechnology{PSY.ACBranch}(;
    name="zone1_to_zone2",
    available=true,
    power_systems_type="ACBranch",
    start_region=z1,
    end_region=z2,
    capacity_limits=(min=0.0, max=900.0),
    line_loss=0.05,
    capital_costs=CapitalCost(; capital_cost=LinearCurve(5_000.0)),   # USD/MW
    financial_data=tech_financials,
)

add_technology!(portfolio, t_line)

# ## Add Policies
#
# Requirements impose policy constraints on the optimization model. They are added with
# [`add_requirement!`](@ref). A technology contributes to a requirement when the requirement
# is listed in the technology's `requirements` field, which can be set at construction or
# afterwards with `set_requirements!`.

crm = CapacityReserveMargin(;
    name="planning_reserve",
    available=true,
    target_year=2030,
    capacity_reserve_fraction=0.15,
)

esr = EnergyShareRequirements(;
    name="renewable_portfolio_standard",
    available=true,
    target_year=2030,
    generation_fraction_requirement=0.5,
)

add_requirement!(portfolio, crm)
add_requirement!(portfolio, esr)

set_requirements!(t_thermal, [crm])
set_requirements!(t_wind, [crm, esr])
set_requirements!(t_solar, [crm, esr])

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

# ### Read a field in a chosen unit
#
# Fields with physical units are stored in natural units and can be read in any compatible
# unit (see [Units and Unit Conversions](@ref)).

println(
    "Coal unit size: ",
    get_unit_size(coal, u"MW"),
    " MW = ",
    get_unit_size(coal, u"kW"),
    " kW",
)

# ### List requirements and their contributors

for req in get_requirements(portfolio)
    names = [get_name(t) for t in get_contributing_technologies(portfolio, req)]
    println(get_name(req), " => ", names)
end

# ### List the topology

println("Areas: ", [get_name(a) for a in get_topologies(Area, portfolio)])

# ### Summary print

portfolio
