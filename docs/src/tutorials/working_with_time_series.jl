# # Working With Time Series
#
# This tutorial explains how PSIP organizes time series data across two distinct time
# dimensions — investment periods and operational periods — and shows how to add, retrieve,
# and inspect time series on portfolio technologies.
#
# ## Prerequisites
#
# This tutorial assumes you have already worked through the
# [Create and Explore a Portfolio](@ref) tutorial. We begin by building a smaller version of
# the same portfolio so this tutorial is self-contained.

using PowerSystemsInvestmentsPortfolios
using PowerSystemCaseBuilder
using PowerSystems
const PSY = PowerSystems
using Dates
using TimeSeries
import PowerSystemsInvestmentsPortfolios: add_time_series!
import PowerSystems: get_name

# `add_time_series!` and `get_name` are defined by both PSIP and PowerSystems, so we import
# the ones we want: PSIP's `add_time_series!` attaches data to a portfolio technology.

sys = build_system(PSITestSystems, "c_sys5_re")

portfolio = Portfolio(sys; financial_data=PortfolioFinancialData(2025, 0.07, 0.05, 0.03))

z1 = Area(; name="Zone_1", input_basis=u"NU")
z2 = Area(; name="Zone_2", input_basis=u"NU")
add_topology!(portfolio, z1)
add_topology!(portfolio, z2)

tech_financials = TechnologyFinancialData(;
    capital_recovery_period=30,
    technology_base_year=2025,
    debt_fraction=0.5,
    debt_rate=0.07,
    return_on_equity=0.10,
    tax_rate=0.257,
)

t_thermal = SupplyTechnology{PSY.ThermalStandard}(;
    name="coal_thermal",
    available=true,
    power_systems_type="ThermalStandard",
    prime_mover_type=PrimeMovers.ST,
    fuel=[ThermalFuels.COAL],
    region=[z1],
    capital_costs=CapitalCost(; capital_cost=LinearCurve(6_937_377.0)),
    operation_costs=ThermalGenerationCost(;
        variable_operation_cost=FuelCurve(LinearCurve(10.5), 1.12),
        fixed=0.0,
        start_up=0.0,
        shut_down=0.0,
    ),
    capacity_limits=(min=0.0, max=3000.0),
    unit_size=250.0,
    financial_data=tech_financials,
)
add_technology!(portfolio, t_thermal)

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

t_demand = DemandRequirement{PSY.PowerLoad}(;
    name="demand_zone1",
    available=true,
    power_systems_type="PowerLoad",
    region=[z1],
    value_of_lost_load=50_000.0,
)
add_technology!(portfolio, t_demand)

# ## Two Time Dimensions in PSIP
#
# PSIP organizes time series around two independent dimensions that correspond to the two
# decision problems in capacity expansion:
#
# | Dimension | Scope | Purpose | Features |
# |-----------|-------|---------|----------|
# | **Investment period** | Multiyear planning horizon | Capital cost trajectories | None |
# | **Operational period** | Representative operating days | Hourly dispatch profiles, load shapes | `"year"`, `"rep_day"` |
#
# These dimensions are configured in the optimization model (`PowerSystemsInvestments.jl`)
# and described by [`InvestmentIntervals`](@ref) and [`OperationalPeriods`](@ref). In PSIP,
# you attach time series to technologies with [`add_time_series!`](@ref); the presence or
# absence of `"year"` and `"rep_day"` *features* tells PSIP which dimension the data
# belongs to.

# ## Investment-Period Time Series
#
# Investment-period series have **one value per investment period**. They represent
# quantities that are fixed for a whole investment interval — most commonly the capital cost
# multiplier (`"inv_capex"`) that captures technology cost trajectories.
#
# The timestamp for each entry is the first day of the corresponding investment period.
# Investment-period data carries no features.

inv_timestamps = [DateTime("2024-01-01"), DateTime("2028-01-01"), DateTime("2032-01-01")]

# Capital cost index: 1.0 in the first period, declining as the technology matures.
capex_index_thermal = [1.0, 0.990, 0.975]   # coal cost trajectory
capex_index_wind = [1.0, 0.965, 0.920]      # wind — steeper cost decline

ts_thermal_capex =
    SingleTimeSeries("inv_capex", TimeArray(inv_timestamps, capex_index_thermal))
ts_wind_capex = SingleTimeSeries("inv_capex", TimeArray(inv_timestamps, capex_index_wind))

add_time_series!(portfolio, t_thermal, ts_thermal_capex)
add_time_series!(portfolio, t_wind, ts_wind_capex)

# ## Operational Time Series
#
# Operational series have **one value per time step of a representative day**. They capture
# within-day variation: capacity factors for variable renewables, load shapes for demand.
#
# Each representative day is identified by two features, passed as a `Dict`:
# - `"year"` (String) — the investment year this day belongs to, e.g., `"2024"`
# - `"rep_day"` (Int) — the index of the representative day, e.g., `1`
#
# The same series name can be added multiple times with different feature values.

ops_timestamps_2024 =
    collect(DateTime("2024-01-01T00:00:00"):Hour(1):DateTime("2024-01-01T23:00:00"))
ops_timestamps_2028 =
    collect(DateTime("2028-01-01T00:00:00"):Hour(1):DateTime("2028-01-01T23:00:00"))

# ### Supply capacity factor (thermal — flat at 1.0, always available)

ts_thermal_ops_2024 =
    SingleTimeSeries("ops_variable_cap_factor", TimeArray(ops_timestamps_2024, ones(24)))
ts_thermal_ops_2028 =
    SingleTimeSeries("ops_variable_cap_factor", TimeArray(ops_timestamps_2028, ones(24)))

add_time_series!(
    portfolio,
    t_thermal,
    ts_thermal_ops_2024;
    features=Dict("year" => "2024", "rep_day" => 1),
)
add_time_series!(
    portfolio,
    t_thermal,
    ts_thermal_ops_2028;
    features=Dict("year" => "2028", "rep_day" => 2),
)

# ### Wind capacity factor (diurnal pattern — stronger at night)

wind_cf_shape = [
    0.42,
    0.44,
    0.47,
    0.49,
    0.50,
    0.48,
    0.43,
    0.38,
    0.32,
    0.28,
    0.25,
    0.23,
    0.22,
    0.24,
    0.27,
    0.31,
    0.36,
    0.40,
    0.43,
    0.45,
    0.46,
    0.45,
    0.44,
    0.43,
]

ts_wind_ops_2024 = SingleTimeSeries(
    "ops_variable_cap_factor",
    TimeArray(ops_timestamps_2024, wind_cf_shape),
)
ts_wind_ops_2028 = SingleTimeSeries(
    "ops_variable_cap_factor",
    TimeArray(ops_timestamps_2028, wind_cf_shape),
)

add_time_series!(
    portfolio,
    t_wind,
    ts_wind_ops_2024;
    features=Dict("year" => "2024", "rep_day" => 1),
)
add_time_series!(
    portfolio,
    t_wind,
    ts_wind_ops_2028;
    features=Dict("year" => "2028", "rep_day" => 2),
)

# ### Demand profile — note the key name is `"ops_peak_load"`
#
# !!! note "Demand time series key"
#     Demand time series use the name `"ops_peak_load"`. This is the name
#     `PowerSystemsInvestments.jl` looks for when building demand constraints.

demand_shape = [
    0.58,
    0.55,
    0.53,
    0.52,
    0.54,
    0.57,
    0.63,
    0.70,
    0.76,
    0.80,
    0.82,
    0.83,
    0.82,
    0.81,
    0.80,
    0.81,
    0.84,
    0.88,
    0.91,
    0.92,
    0.90,
    0.85,
    0.76,
    0.66,
]

ts_demand_2024 =
    SingleTimeSeries("ops_peak_load", TimeArray(ops_timestamps_2024, demand_shape))
ts_demand_2028 =
    SingleTimeSeries("ops_peak_load", TimeArray(ops_timestamps_2028, demand_shape))

add_time_series!(
    portfolio,
    t_demand,
    ts_demand_2024;
    features=Dict("year" => "2024", "rep_day" => 1),
)
add_time_series!(
    portfolio,
    t_demand,
    ts_demand_2028;
    features=Dict("year" => "2028", "rep_day" => 2),
)

# ## Retrieving Time Series
#
# Three retrieval functions return data in different forms:
#
# | Function | Returns |
# |----------|---------|
# | `get_time_series_array` | `TimeSeries.TimeArray` (timestamps + values) |
# | `get_time_series_values` | `Vector` of values only |
# | `get_time_series_timestamps` | `Vector` of `DateTime` timestamps |
#
# All three accept the same signature:
# ```julia
# get_time_series_array(SingleTimeSeries, technology, "name"; features=Dict("year" => "YYYY", "rep_day" => N))
# ```
# Omit `features` for investment-period series.

# ### Read back investment-period data

capex_ta = get_time_series_array(SingleTimeSeries, t_thermal, "inv_capex")
println("Thermal capex trajectory:")
println(capex_ta)

# ### Read back operational data

wind_cf_ta = get_time_series_array(
    SingleTimeSeries,
    t_wind,
    "ops_variable_cap_factor";
    features=Dict("year" => "2024", "rep_day" => 1),
)
println("Wind capacity factors (2024, rep_day=1):")
println(wind_cf_ta)

demand_values = get_time_series_values(
    SingleTimeSeries,
    t_demand,
    "ops_peak_load";
    features=Dict("year" => "2024", "rep_day" => 1),
)
println("Demand shape (first 6 hours): ", round.(demand_values[1:6]; digits=3))

# ### Iterate over all time series in the portfolio

for ts in get_time_series_multiple(portfolio)
    println("name=", get_name(ts), "  length=", length(ts))
end

# Filter by series name to find a specific profile type:

cf_series = collect(get_time_series_multiple(portfolio; name="ops_variable_cap_factor"))
println("Operational capacity factor series count: ", length(cf_series))

# ## Naming Convention Summary
#
# | Series name | Dimension | Technology types |
# |-------------|-----------|------------------|
# | `"inv_capex"` | Investment | `SupplyTechnology`, `StorageTechnology`, `TransmissionTechnology` |
# | `"ops_variable_cap_factor"` | Operational | `SupplyTechnology`, `StorageTechnology`, `TransmissionTechnology` |
# | `"ops_peak_load"` | Operational | `DemandRequirement` |
#
# Names are conventions understood by `PowerSystemsInvestments.jl`. Non-standard names are
# ignored by the optimizer unless a formulation explicitly references them.
