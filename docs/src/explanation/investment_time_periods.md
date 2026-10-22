```@meta
CurrentModule = PowerSystemsInvestmentsPortfolios
```

# Investment Time Periods

## Why capacity expansion needs multiple time dimensions

Capacity expansion models must answer two questions at very different time scales:

  - **When and where should new capacity be built?** Investment decisions span planning horizons of 10–30 years (e.g., 2025–2050), where committing to a new power plant or transmission line locks in capital for decades.
  - **Will that capacity operate reliably?** Operational adequacy is determined hour by hour, driven by the variability of renewable generation and load over a typical year.

Simulating every hour of every year across a full planning horizon is computationally intractable for most real-world systems. A 25-year horizon with 8 760 hours per year produces over 200 000 time steps — and capacity expansion models already carry large combinatorial investment decision spaces.

Capacity expansion models therefore use two separate time dimensions:

  - **Investment periods** — multi-year planning windows (e.g., 2025–2029, 2030–2034) during which no new construction is assumed to take place mid-window. At the boundary between windows, investment decisions are made: which technologies to build, expand, or retire.
  - **Representative operational periods** — a small set of days (or weeks) sampled from a full year to capture the seasonal and diurnal variability of renewable generation and demand without simulating every hour of every year.

These two dimensions are independent. Each investment period is represented operationally by the same set of representative days, re-weighted to account for the characteristics of that window.

## Investment periods

Investment periods partition the planning horizon into discrete windows. Each window has a start date and an end date. The windows are contiguous and non-overlapping, and together they span the full horizon over which the optimizer makes decisions.

Technologies added to the portfolio can carry investment-year time series — for example, capital cost multipliers that reflect technology learning curves or policy-driven cost trajectories over the planning horizon. PSI defines the investment schedule externally via a `DiscountedCashFlow` object; PSIP stores the time series data indexed to the periods that schedule defines.

PSIP uses `InvestmentIntervals` internally to represent investment periods:

```julia
struct InvestmentIntervals
    time_stamps::Vector{NTuple{2, Dates.Date}}  # (start_date, end_date) per period
    map_to_operational_slices::Dict{Int, Vector{Int}}
    map_to_feasibility_slices::Dict{Int, Vector{Int}}
end
```

The `time_stamps` vector holds one `(start, end)` date tuple per investment period, in chronological order. The two maps link each investment period index to the set of representative operational day indices that represent it during optimization.

## Representative operational periods

Rather than simulating 8 760 hours per year, PSI uses a small set of representative operating days — typically between 10 and 365 — that statistically approximate the full operational year. Each representative day captures a daily pattern of renewable availability and load, and is weighted by how many real days it represents. Time steps do not have to be hourly, but they must be evenly spaced within a representative day.

Each representative day is identified by a `year` and a `rep_day`: `year` is the investment period year (a `String`) and `rep_day` is an integer index of the day. They are stored as the `features` of every operational time series chunk.

PSIP stores time series for representative days using `OperationalPeriods` internally:

```julia
struct OperationalPeriods
    time_stamps::Vector{Dates.DateTime}
    consecutive_slices::Vector{Vector{Int}}
    inverse_invest_mapping::Vector{Int}
    feasibility_indexes::Vector{Int}
    operational_indexes::Vector{Int}
end
```

The `time_stamps` vector contains the datetime index for each time step across all representative days. The `consecutive_slices` field groups those steps into per-day blocks. The `inverse_invest_mapping` records, for each representative day, which investment period it belongs to.

## How PSIP stores time series for both dimensions

PSIP uses InfrastructureSystems (IS) `SingleTimeSeries` for all profiles. Two categories of time series live in a portfolio:

**Investment-period time series** are indexed by investment year and carry no features. They are used for quantities that change over the planning horizon, such as capital cost multipliers. These are attached to a technology with a name identifying the economic parameter they represent. For example, `"inv_capex"` carries the capital expenditure multiplier per investment period.

**Operational time series** are hourly or sub-hourly profiles for capacity factors, demand, and similar quantities. They are attached with names such as `"ops_variable_cap_factor"` for variable renewable capacity factors or `"ops_peak_load"` for load profiles. The features of each time series chunk identify which representative day it belongs to:

```julia
add_time_series!(portfolio, wind, ts; features=Dict("year" => "2024", "rep_day" => 1))
```

!!! note
    
    The time series key names (e.g., `"inv_capex"`, `"ops_variable_cap_factor"`, `"ops_peak_load"`) are conventions expected by PSI. Using non-standard key names will cause PSI to ignore or error on the time series data. Refer to the PSI documentation for the full list of expected keys.

## The `InvestmentIntervals` and `OperationalPeriods` structs

`InvestmentIntervals` and `OperationalPeriods` are internal infrastructure built by PSI from the investment schedule. When building a portfolio you do not construct them directly — PSI populates them during model construction from the `DiscountedCashFlow` object and the representative day clustering you provide.

They are documented here for completeness and for users who need to inspect the time mapping after model setup. For example, after solving, you can inspect `InvestmentIntervals` to verify which operational slices were assigned to each investment period, or check `OperationalPeriods` to confirm that the full set of representative days was correctly loaded.

## See Also

  - [`InvestmentIntervals`](@ref)
  - [`OperationalPeriods`](@ref)
  - [`TimeMapping`](@ref)
  - [Working With Time Series](@ref)
