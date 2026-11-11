"""
Supertype of the investment decisions stored in an [`InvestmentScheduleResults`](@ref).

Each decision holds the whole horizon of one technology (or retrofit pair). Values are keyed
by the start year of the investment period they belong to, the year the change takes
effect, and only years with a change are stored. Capacities are in natural units (MW, MWh).
"""
abstract type InvestmentDecision end

"""
    CapacityBuild(; technology, capacity=Dict(), units=Dict())

New capacity of a supply or demand side technology.

# Fields

  - `technology::String`: name of the technology
  - `capacity::Dict{String, Dict{Int, Float64}}`: region (zone or node) name => year => MW
    built. A technology in several regions has one entry per region.
  - `units::Dict{String, Dict{Int, Int}}`: region name => year => units built, for discrete
    investment formulations (empty for continuous ones)
"""
Base.@kwdef struct CapacityBuild <: InvestmentDecision
    technology::String
    capacity::Dict{String, Dict{Int, Float64}} = Dict{String, Dict{Int, Float64}}()
    units::Dict{String, Dict{Int, Int}} = Dict{String, Dict{Int, Int}}()
end

"""
    StorageBuild(; technology, region, power=Dict(), energy=Dict(), units=Dict())

New capacity of a storage technology.

# Fields

  - `technology::String`: name of the technology
  - `region::String`: name of its region (zone or node)
  - `power::Dict{Int, Float64}`: year => MW built
  - `energy::Dict{Int, Float64}`: year => MWh built
  - `units::Dict{Int, Int}`: year => units built, for discrete investment formulations
"""
Base.@kwdef struct StorageBuild <: InvestmentDecision
    technology::String
    region::String
    power::Dict{Int, Float64} = Dict{Int, Float64}()
    energy::Dict{Int, Float64} = Dict{Int, Float64}()
    units::Dict{Int, Int} = Dict{Int, Int}()
end

"""
    LineBuild(; technology, start_region, end_region, capacity=Dict(), units=Dict())

New capacity of a transmission technology.

# Fields

  - `technology::String`: name of the technology
  - `start_region::String`, `end_region::String`: names of the zones or nodes it connects
  - `capacity::Dict{Int, Float64}`: year => MW built
  - `units::Dict{Int, Int}`: year => units built, for discrete investment formulations
"""
Base.@kwdef struct LineBuild <: InvestmentDecision
    technology::String
    start_region::String
    end_region::String
    capacity::Dict{Int, Float64} = Dict{Int, Float64}()
    units::Dict{Int, Int} = Dict{Int, Int}()
end

"""
    Retrofit(; source, option, converted=Dict(), retrofitted=Dict(), devices=Dict())

Existing capacity of the `source` technology converted into the `option` technology (see
[`RetrofitPotential`](@ref)).

# Fields

  - `source::String`, `option::String`: names of the source and option technologies
  - `converted::Dict{Int, Float64}`: year => MW of the source converted
  - `retrofitted::Dict{Int, Float64}`: year => MW of the option obtained (the converted
    capacity times the retrofit efficiency)
  - `devices::Dict{Int, Vector{String}}`: year => names of the existing units converted, once
    the decision is assigned to units
"""
Base.@kwdef struct Retrofit <: InvestmentDecision
    source::String
    option::String
    converted::Dict{Int, Float64} = Dict{Int, Float64}()
    retrofitted::Dict{Int, Float64} = Dict{Int, Float64}()
    devices::Dict{Int, Vector{String}} = Dict{Int, Vector{String}}()
end

"""
    Retirement(; technology, capacity=Dict(), planned=Dict(), devices=Dict())

Existing capacity of a technology retired (see [`RetirementPotential`](@ref)).

# Fields

  - `technology::String`: name of the technology
  - `capacity::Dict{Int, Float64}`: year => MW retired
  - `planned::Dict{Int, Float64}`: year => the part of `capacity` retired at its planned
    retirement year rather than by the model
  - `devices::Dict{Int, Vector{String}}`: year => names of the existing units retired, once
    the decision is assigned to units
"""
Base.@kwdef struct Retirement <: InvestmentDecision
    technology::String
    capacity::Dict{Int, Float64} = Dict{Int, Float64}()
    planned::Dict{Int, Float64} = Dict{Int, Float64}()
    devices::Dict{Int, Vector{String}} = Dict{Int, Vector{String}}()
end

"""
    DemandProjection(; technology, region, peak=Dict())

The projected peak of a [`ProjectedDemand`](@ref), as the investment model computed it from
the demand's base peak, growth rate and construction year. It is data, not a decision of the
model, and is stored so the operational profile can be scaled to a target year.

# Fields

  - `technology::String`: name of the demand
  - `region::String`: name of its region (zone or node)
  - `peak::Dict{Int, Float64}`: year => peak demand (MW) in each modeled year; 0 before a new
    demand is built
"""
Base.@kwdef struct DemandProjection <: InvestmentDecision
    technology::String
    region::String
    peak::Dict{Int, Float64} = Dict{Int, Float64}()
end

"""
    InvestmentScheduleResults(; builds=[], lines=[], retrofits=[], retirements=[], demands=[])

The investment decisions of a solved investment model: new capacity (including
[`DemandSideTechnology`](@ref) investments, as [`CapacityBuild`](@ref)s), retrofits,
retirements and the projected peaks of its demands, one [`InvestmentDecision`](@ref) per
technology (or retrofit pair) covering the whole horizon. Add decisions with [`add_decision!`](@ref) and find them with
[`get_decision`](@ref).

# Fields

  - `builds::Vector{Union{CapacityBuild, StorageBuild}}`
  - `lines::Vector{LineBuild}`
  - `retrofits::Vector{Retrofit}`
  - `retirements::Vector{Retirement}`
  - `demands::Vector{DemandProjection}`
"""
Base.@kwdef mutable struct InvestmentScheduleResults <: IS.InfrastructureSystemsType
    builds::Vector{Union{CapacityBuild, StorageBuild}} =
        Union{CapacityBuild, StorageBuild}[]
    lines::Vector{LineBuild} = LineBuild[]
    retrofits::Vector{Retrofit} = Retrofit[]
    retirements::Vector{Retirement} = Retirement[]
    demands::Vector{DemandProjection} = DemandProjection[]
end

get_builds(schedule::InvestmentScheduleResults) = schedule.builds
get_lines(schedule::InvestmentScheduleResults) = schedule.lines
get_retrofits(schedule::InvestmentScheduleResults) = schedule.retrofits
get_retirements(schedule::InvestmentScheduleResults) = schedule.retirements
get_demands(schedule::InvestmentScheduleResults) = schedule.demands

# Where each kind of decision is stored, and the names that identify it
_decisions(schedule, ::Type{<:Union{CapacityBuild, StorageBuild}}) = schedule.builds
_decisions(schedule, ::Type{LineBuild}) = schedule.lines
_decisions(schedule, ::Type{Retrofit}) = schedule.retrofits
_decisions(schedule, ::Type{Retirement}) = schedule.retirements
_decisions(schedule, ::Type{DemandProjection}) = schedule.demands
_decision_key(decision::InvestmentDecision) = (decision.technology,)
_decision_key(decision::Retrofit) = (decision.source, decision.option)

"""
    get_decision(schedule, T, technology)
    get_decision(schedule, Retrofit, source, option)

Return the decision of type `T` for `technology` (or the retrofit of `source` into
`option`), or `nothing` if the schedule has none.
"""
function get_decision(
    schedule::InvestmentScheduleResults,
    ::Type{T},
    names::AbstractString...,
) where {T <: InvestmentDecision}
    index = findfirst(d -> d isa T && _decision_key(d) == names, _decisions(schedule, T))
    return isnothing(index) ? nothing : _decisions(schedule, T)[index]
end

"""
Add `decision` to `schedule`. Errors if the schedule already holds a decision of the same
kind for that technology (or retrofit pair); a technology has at most one build.
"""
function add_decision!(
    schedule::InvestmentScheduleResults,
    decision::T,
) where {T <: InvestmentDecision}
    decisions = _decisions(schedule, T)
    key = _decision_key(decision)
    any(d -> _decision_key(d) == key, decisions) && throw(
        ArgumentError(
            "the schedule already has a decision of this kind for $(join(key, " => "))",
        ),
    )
    push!(decisions, decision)
    return
end

# Sum of the values of the years up to `year`
_cumulative(values::Dict{Int, <:Real}, year::Int) =
    sum(v for (y, v) in values if y <= year; init=0.0)

"""
    get_cumulative_capacity(decision, year)
    get_cumulative_capacity(build::CapacityBuild, region, year)

Capacity built, converted or retired by `decision` in the years up to and including `year`:
MW for a [`CapacityBuild`](@ref) (over all its regions, or in `region`), a
[`LineBuild`](@ref) or a [`Retirement`](@ref), `(power=MW, energy=MWh)` for a
[`StorageBuild`](@ref), and `(converted=MW, retrofitted=MW)` for a [`Retrofit`](@ref).
"""
get_cumulative_capacity(build::CapacityBuild, year::Int) =
    sum(values -> _cumulative(values, year), Base.values(build.capacity); init=0.0)
get_cumulative_capacity(build::CapacityBuild, region::AbstractString, year::Int) =
    _cumulative(get(build.capacity, region, Dict{Int, Float64}()), year)
get_cumulative_capacity(build::StorageBuild, year::Int) =
    (power=_cumulative(build.power, year), energy=_cumulative(build.energy, year))
get_cumulative_capacity(build::LineBuild, year::Int) = _cumulative(build.capacity, year)
get_cumulative_capacity(retrofit::Retrofit, year::Int) = (
    converted=_cumulative(retrofit.converted, year),
    retrofitted=_cumulative(retrofit.retrofitted, year),
)
get_cumulative_capacity(retirement::Retirement, year::Int) =
    _cumulative(retirement.capacity, year)

"""
Peak (MW) of `projection` in `year`: the peak of the last modeled year up to `year`, or 0
before the first.
"""
function get_projected_peak(projection::DemandProjection, year::Int)
    years = filter(<=(year), collect(keys(projection.peak)))
    return isempty(years) ? 0.0 : projection.peak[maximum(years)]
end
