##############################################
######## Operational system from results #####
##############################################

# Names of the chronological (full-year) series a technology carries, without features,
# next to its representative-period series: copied to the devices built for it
const SUPPLY_PROFILE_NAME = "max_active_power"
const DEMAND_PROFILE_NAME = "demand"

# Below this many MW, capacity is treated as zero
const CAPACITY_TOLERANCE = 1e-6

"""
    build_operational_system(portfolio, schedule, year; retirement_order=oldest_first)

Return a copy of the portfolio's base system updated with the decisions of `schedule` up to
and including `year`, for use in a production cost model. The portfolio and its base
system are not modified.

A technology with [`ExistingDevices`](@ref) is represented by those devices in the base
system, so its decisions change them instead of adding devices:

  - builds scale its devices up, each keeping its share of the technology's capacity;
  - retirements and retrofits take its units out (marked unavailable) in the order given by
    `retirement_order` (units listed in a decision's `devices` go first), scaling the last
    unit down when only part of it goes;
  - a demand's loads are scaled to its projected peak.

Scaling multiplies every size-dependent field of a device (rating, active and reactive power
limits, ramp limits, set points; the energy capacity of storage by its own factor).
Technologies without existing devices get new devices: `units` devices per node (one for a
continuous investment), a parallel line per unit of a discrete line, and a load for a new
demand. New renewables and demands copy the chronological profile of their technology
(`"$(SUPPLY_PROFILE_NAME)"` and `"$(DEMAND_PROFILE_NAME)"`, without features).

Every `SingleTimeSeries` of the system is restamped to `year` (see
[`restamp_time_series`](@ref)); forecasts are removed, so call
`transform_single_time_series!` before running a simulation.

Only nodal portfolios (aggregated by `ACBus`) are supported.

Parallel lines are grouped by PowerSimulations, which by default limits a group to its N-1
rating; use the `"sum_of_max"` parallel branch rating method to match the investment model.

# Arguments

  - `portfolio::Portfolio`: the portfolio the schedule was solved for
  - `schedule::InvestmentScheduleResults`: the investment decisions
  - `year::Int`: the target year
  - `retirement_order`: a function `(portfolio, technology, devices)` returning `devices`
    in the order they retire or are retrofitted (default [`oldest_first`](@ref))
"""
function build_operational_system(
    portfolio::Portfolio,
    schedule::InvestmentScheduleResults,
    year::Int;
    retirement_order=oldest_first,
)
    if get_aggregation(portfolio) != PSY.ACBus
        throw(
            ArgumentError(
                "build_operational_system only supports nodal portfolios (aggregated by " *
                "ACBus); this portfolio is aggregated by $(get_aggregation(portfolio))",
            ),
        )
    end
    sys = deepcopy(get_base_system(portfolio))
    restamp_time_series!(sys, year)
    # Capacity added to technologies with existing devices, applied after the units that
    # leave so the remaining units are scaled
    added = Dict{String, Float64}()
    for retirement in get_retirements(schedule)
        _apply!(sys, portfolio, retirement, year, retirement_order)
    end
    for retrofit in get_retrofits(schedule)
        _apply!(sys, portfolio, retrofit, year, retirement_order, added)
    end
    for build in get_builds(schedule)
        _apply!(sys, portfolio, build, year, added)
    end
    for (name, capacity) in added
        _add_capacity!(sys, _technology(portfolio, name), capacity)
    end
    for line in get_lines(schedule)
        _apply!(sys, portfolio, line, year)
    end
    for demand in get_demands(schedule)
        _apply!(sys, portfolio, demand, year)
    end
    return sys
end

"""
Order `devices` of `technology` oldest first, by the `build_year` of its
[`RetirementPotential`](@ref). Devices without a build year go last, by name.
"""
function oldest_first(portfolio::Portfolio, technology::Technology, devices::Vector)
    build_years = Dict{String, Int}()
    for attribute in IS.get_supplemental_attributes(RetirementPotential, technology)
        merge!(build_years, get_build_year(attribute))
    end
    return sort(
        devices;
        by=d -> (get(build_years, PSY.get_name(d), typemax(Int)), PSY.get_name(d)),
    )
end

##### Retirements and retrofits #####

# Devices listed by a decision up to `year`
_listed_devices(devices::Dict{Int, Vector{String}}, year::Int) =
    reduce(vcat, (names for (y, names) in devices if y <= year); init=String[])

function _apply!(sys, portfolio, retirement::Retirement, year, retirement_order)
    capacity = _cumulative(retirement.capacity, year)
    capacity <= CAPACITY_TOLERANCE && return
    technology = _technology(portfolio, retirement.technology)
    candidates = _retirement_candidates(sys, technology)
    _take_out!(
        portfolio,
        technology,
        candidates,
        _listed_devices(retirement.devices, year),
        capacity,
        retirement_order,
    )
    return
end

# Units that can retire: the eligible units of its RetirementPotential, or else all its
# existing devices
function _retirement_candidates(sys, technology)
    attributes = IS.get_supplemental_attributes(RetirementPotential, technology)
    isempty(attributes) && return _existing_devices(sys, technology)
    names = unique(reduce(vcat, get_eligible_generators.(attributes)))
    return _devices(sys, technology, names)
end

function _apply!(sys, portfolio, retrofit::Retrofit, year, retirement_order, added)
    converted = _cumulative(retrofit.converted, year)
    converted <= CAPACITY_TOLERANCE && return
    source = _technology(portfolio, retrofit.source)
    option = _technology(portfolio, retrofit.option)
    attribute = _retrofit_attribute(portfolio, source, option)
    candidates = _devices(sys, source, get_eligible_generators(attribute))
    taken = _take_out!(
        portfolio,
        source,
        candidates,
        _listed_devices(retrofit.devices, year),
        converted,
        retirement_order,
    )
    # MW of the option per MW of the source converted
    ratio = _cumulative(retrofit.retrofitted, year) / converted
    if is_new(option)
        for (device, capacity) in taken
            _new_device!(
                sys,
                option,
                "$(get_name(option))_$(PSY.get_name(device))",
                PSY.get_bus(device),
                capacity * ratio,
                year,
            )
        end
    else
        added[get_name(option)] =
            get(added, get_name(option), 0.0) + ratio * sum(last, taken; init=0.0)
    end
    return
end

function _retrofit_attribute(portfolio, source, option)
    attributes = filter(
        a -> any(t -> t === source, get_associated_technologies(portfolio, a)),
        collect(IS.get_supplemental_attributes(RetrofitPotential, option)),
    )
    length(attributes) == 1 || error(
        "Retrofit of $(get_name(source)) into $(get_name(option)) needs exactly one " *
        "RetrofitPotential shared by both; found $(length(attributes))",
    )
    return only(attributes)
end

# Take `capacity` MW of `candidates` out: listed devices first, then in `retirement_order`.
# Whole units are marked unavailable and the last one is scaled down. Returns the devices
# and the MW taken from each.
function _take_out!(portfolio, technology, candidates, listed, capacity, retirement_order)
    available = filter(PSY.get_available, candidates)
    first_out = filter(d -> PSY.get_name(d) in listed, available)
    rest = filter(d -> !(PSY.get_name(d) in listed), available)
    ordered = vcat(first_out, retirement_order(portfolio, technology, rest))
    taken = Tuple{Any, Float64}[]
    remaining = capacity
    for device in ordered
        remaining <= CAPACITY_TOLERANCE && break
        unit_capacity = _existing_capacity_mw(device)
        amount = min(unit_capacity, remaining)
        if unit_capacity - amount <= CAPACITY_TOLERANCE
            PSY.set_available!(device, false)
        else
            _scale_device!(device, (unit_capacity - amount) / unit_capacity)
        end
        push!(taken, (device, amount))
        remaining -= amount
    end
    if remaining > CAPACITY_TOLERANCE
        error(
            "$(get_name(technology)) has $(capacity - remaining) MW of units that can " *
            "retire or be retrofitted, less than the $capacity MW the schedule takes out",
        )
    end
    return taken
end

##### Builds #####

function _apply!(sys, portfolio, build::CapacityBuild, year, added)
    technology = _technology(portfolio, build.technology)
    _check_technology(build, technology, Union{SupplyTechnology, DemandSideTechnology})
    if is_new(technology)
        for (node, capacities) in build.capacity
            capacity = _cumulative(capacities, year)
            units = round(Int, _cumulative(get(build.units, node, Dict{Int, Int}()), year))
            _new_devices!(
                sys,
                technology,
                node,
                capacity,
                units,
                length(build.capacity),
                year,
            )
        end
    else
        added[build.technology] =
            get(added, build.technology, 0.0) + get_cumulative_capacity(build, year)
    end
    return
end

function _apply!(sys, portfolio, build::StorageBuild, year, added)
    technology = _technology(portfolio, build.technology)
    _check_technology(build, technology, StorageTechnology)
    capacity = get_cumulative_capacity(build, year)
    capacity.power <= CAPACITY_TOLERANCE && capacity.energy <= CAPACITY_TOLERANCE && return
    if is_new(technology)
        units = round(Int, _cumulative(build.units, year))
        count = max(units, 1)
        for k in 1:count
            _new_storage!(
                sys,
                technology,
                _new_name(technology, build.region, k, 1),
                _bus(sys, build.region),
                capacity.power / count,
                capacity.energy / count,
            )
        end
    else
        devices = filter(PSY.get_available, _existing_devices(sys, technology))
        power = sum(_existing_capacity_mw, devices; init=0.0)
        energy = sum(_storage_capacity_mwh, devices; init=0.0)
        (power > CAPACITY_TOLERANCE && energy > CAPACITY_TOLERANCE) ||
            error("Storage $(get_name(technology)) has no existing capacity left to scale")
        for device in devices
            _scale_device!(device, (power + capacity.power) / power)
            _scale_energy!(device, (energy + capacity.energy) / energy)
        end
    end
    return
end

# Scale the available existing devices of a technology up by `capacity` MW in total
function _add_capacity!(sys, technology, capacity)
    capacity <= CAPACITY_TOLERANCE && return
    devices = filter(PSY.get_available, _existing_devices(sys, technology))
    existing = sum(_existing_capacity_mw, devices; init=0.0)
    existing > CAPACITY_TOLERANCE || error(
        "$(get_name(technology)) has no existing capacity left to scale up by " *
        "$capacity MW (all its devices retired or were retrofitted)",
    )
    foreach(d -> _scale_device!(d, (existing + capacity) / existing), devices)
    return
end

# `units` devices (one for a continuous investment) sharing `capacity` at `node`
function _new_devices!(sys, technology, node, capacity, units, regions, year)
    capacity <= CAPACITY_TOLERANCE && return
    bus = _bus(sys, node)
    count = max(units, 1)
    for k in 1:count
        name = _new_name(technology, node, k, regions)
        _new_device!(sys, technology, name, bus, capacity / count, year)
    end
    return
end

_new_name(technology, node, k, regions) =
    regions > 1 ? "$(get_name(technology))_$(node)_$(k)" : "$(get_name(technology))_$(k)"

##### Lines #####

function _apply!(sys, portfolio, build::LineBuild, year)
    technology = _technology(portfolio, build.technology)
    _check_technology(build, technology, NodalACTransportTechnology)
    capacity = _cumulative(build.capacity, year)
    capacity <= CAPACITY_TOLERANCE && return
    units = round(Int, _cumulative(build.units, year))
    if units > 0
        # A discrete line: one parallel line per unit, as the investment model has a branch
        # per unit
        for k in 1:units
            _new_line!(sys, technology, "$(get_name(technology))_$(k)", capacity / units)
        end
    elseif is_new(technology)
        _new_line!(sys, technology, get_name(technology), capacity)
    else
        # A continuous line on an existing corridor: the investment model keeps the
        # susceptance of the existing lines and raises their limit, so only the ratings scale
        devices = filter(PSY.get_available, _existing_devices(sys, technology))
        existing = sum(_existing_capacity_mw, devices; init=0.0)
        foreach(d -> _scale_device!(d, (existing + capacity) / existing), devices)
    end
    return
end

function _new_line!(sys, technology, name, capacity)
    get_parameter_type(technology) <: PSY.Line ||
        _unsupported(technology, "new $(get_parameter_type(technology)) branches")
    from = _bus(sys, get_name(get_start_node(technology)))
    to = _bus(sys, get_name(get_end_node(technology)))
    line = PSY.Line(;
        input_basis=u"NU",
        name=name,
        available=true,
        active_power_flow=0.0,
        reactive_power_flow=0.0,
        arc=_arc!(sys, from, to),
        r=get_resistance(technology, u"NU"),
        x=get_reactance(technology, u"NU"),
        b=(from=0.0, to=0.0),
        rating=capacity,
        angle_limits=(min=-π / 2, max=π / 2),
    )
    _add_device!(sys, line)
    return
end

function _arc!(sys, from, to)
    arc = findfirst(
        a -> PSY.get_from(a) === from && PSY.get_to(a) === to,
        collect(PSY.get_components(PSY.Arc, sys)),
    )
    isnothing(arc) || return collect(PSY.get_components(PSY.Arc, sys))[arc]
    new_arc = PSY.Arc(; from=from, to=to)
    PSY.add_component!(sys, new_arc)
    return new_arc
end

##### Demands #####

function _apply!(sys, portfolio, projection::DemandProjection, year)
    technology = _technology(portfolio, projection.technology)
    _check_technology(projection, technology, ProjectedDemand)
    peak = get_projected_peak(projection, year)
    if is_new(technology)
        peak <= CAPACITY_TOLERANCE && return
        _new_load!(sys, technology, _bus(sys, projection.region), peak, year)
    else
        factor = peak / get_peak_demand_mw(portfolio, technology)
        for load in _existing_devices(sys, technology)
            factor <= CAPACITY_TOLERANCE ? PSY.set_available!(load, false) :
            _scale_device!(load, factor)
        end
    end
    return
end

function _new_load!(sys, technology, bus, peak, year)
    get_parameter_type(technology) <: PSY.PowerLoad ||
        _unsupported(technology, "new $(get_parameter_type(technology)) loads")
    load = PSY.PowerLoad(;
        input_basis=u"NU",
        name=get_name(technology),
        available=true,
        bus=bus,
        active_power=peak,
        reactive_power=0.0,
        base_power=peak,
        max_active_power=peak,
        max_reactive_power=0.0,
        conformity=get_conformity(technology),
    )
    _add_device!(sys, load)
    _add_profile!(sys, load, technology, DEMAND_PROFILE_NAME, year)
    return
end

##### New supply and storage devices #####

_new_device!(sys, technology::Technology, name, bus, capacity, year) =
    _new_device!(get_parameter_type(technology), sys, technology, name, bus, capacity, year)

_new_device!(::Type{T}, sys, technology, name, bus, capacity, year) where {T} =
    _unsupported(technology, "new $T devices")

function _new_device!(
    ::Type{PSY.ThermalStandard},
    sys,
    technology::SupplyTechnology,
    name,
    bus,
    capacity,
    year,
)
    # Ramp limits are a fraction of capacity per hour; PowerSystems takes MW/min
    ramp_limits = get_ramp_limits(technology, u"MW/hr")
    fuels = get_fuel(technology)
    length(fuels) > 1 &&
        @warn "$(get_name(technology)) has several fuels; device $name uses $(first(fuels))"
    device = PSY.ThermalStandard(;
        input_basis=u"NU",
        name=name,
        available=true,
        status=PSY.OperationalStates.ONLINE,
        bus=bus,
        active_power=0.0,
        reactive_power=0.0,
        rating=capacity,
        active_power_limits=(
            min=get_min_generation_fraction(technology) * capacity,
            max=capacity,
        ),
        reactive_power_limits=nothing,
        ramp_limits=(
            up=ramp_limits.up * capacity / 60.0,
            down=ramp_limits.down * capacity / 60.0,
        ),
        operation_cost=get_operation_costs(technology, u"NU"),
        base_power=capacity,
        time_limits=get_time_limits(technology, u"hr"),
        prime_mover_type=get_prime_mover_type(technology),
        fuel=isempty(fuels) ? PSY.ThermalFuels.OTHER : first(fuels),
    )
    _add_device!(sys, device)
    return
end

function _new_device!(
    ::Type{PSY.RenewableDispatch},
    sys,
    technology::SupplyTechnology,
    name,
    bus,
    capacity,
    year,
)
    device = PSY.RenewableDispatch(;
        input_basis=u"NU",
        name=name,
        available=true,
        bus=bus,
        active_power=0.0,
        reactive_power=0.0,
        rating=capacity,
        prime_mover_type=get_prime_mover_type(technology),
        reactive_power_limits=nothing,
        power_factor=1.0,
        operation_cost=get_operation_costs(technology, u"NU"),
        base_power=capacity,
    )
    _add_device!(sys, device)
    _add_profile!(sys, device, technology, SUPPLY_PROFILE_NAME, year)
    return
end

function _new_storage!(sys, technology::StorageTechnology, name, bus, power, energy)
    get_parameter_type(technology) <: PSY.EnergyReservoirStorage ||
        _unsupported(technology, "new $(get_parameter_type(technology)) devices")
    efficiency = get_efficiency(technology)
    device = PSY.EnergyReservoirStorage(;
        input_basis=u"NU",
        name=name,
        available=true,
        bus=bus,
        prime_mover_type=get_prime_mover_type(technology),
        storage_technology_type=get_storage_tech(technology),
        storage_capacity=energy,
        storage_level_limits=(min=0.0, max=1.0),
        initial_storage_capacity_level=0.5,
        rating=power,
        active_power=0.0,
        input_active_power_limits=(min=0.0, max=power),
        output_active_power_limits=(min=0.0, max=power),
        efficiency=(in=efficiency.in, out=efficiency.out),
        reactive_power=0.0,
        reactive_power_limits=nothing,
        base_power=power,
        operation_cost=get_operation_costs(technology, u"NU"),
    )
    _add_device!(sys, device)
    return
end

function _add_device!(sys, device)
    if !isnothing(PSY.get_component(typeof(device), sys, PSY.get_name(device)))
        error(
            "The base system already has a $(typeof(device)) named " *
            "$(PSY.get_name(device)), so the device built for it can't be added",
        )
    end
    PSY.add_component!(sys, device)
    return
end

# Copy the chronological profile of a technology onto a new device, restamped to `year`
function _add_profile!(sys, device, technology, name, year)
    rows = filter(
        md -> isempty(IS.get_features(md)),
        IS.list_time_series_metadata(
            technology;
            time_series_type=PSY.SingleTimeSeries,
            name=name,
        ),
    )
    isempty(rows) && error(
        "$(get_name(technology)) has no \"$name\" time series without features, the " *
        "chronological profile copied to the devices built for it",
    )
    series = IS.get_time_series(technology, IS.get_time_series_key(only(rows)))
    # Devices take their profile as "max_active_power"
    PSY.add_time_series!(
        sys,
        device,
        restamp_time_series(series, year; name=SUPPLY_PROFILE_NAME),
    )
    return
end

##### Scaling #####

# Size-dependent fields of devices. Stored values are per unit of the device's own base, so
# scaling them scales the quantity whatever its units.
# TODO: review which fields should scale with capacity
const SIZE_FIELDS = (
    :active_power,
    :reactive_power,
    :rating,
    :rating_b,
    :rating_c,
    :active_power_limits,
    :reactive_power_limits,
    :input_active_power_limits,
    :output_active_power_limits,
    :ramp_limits,
    :max_active_power,
    :max_reactive_power,
)

function _scale_device!(device, factor::Float64)
    for field in SIZE_FIELDS
        hasfield(typeof(device), field) &&
            setfield!(device, field, _scaled(getfield(device, field), factor))
    end
    return
end

# PowerSystems puts storage capacity in the power category: in MW it reads in MWh
_storage_capacity_mwh(device::PSY.Storage) = PSY.get_storage_capacity(device, u"MW")

_scale_energy!(device::PSY.Storage, factor::Float64) =
    device.storage_capacity = device.storage_capacity * factor

_scaled(value::Real, factor) = value * factor
_scaled(value::NamedTuple, factor) = map(v -> v * factor, value)
_scaled(::Nothing, factor) = nothing

##### Lookups #####

function _technology(portfolio, name)
    technologies =
        collect(get_technologies(t -> get_name(t) == name, Technology, portfolio))
    isempty(technologies) && error("The portfolio has no technology named $name")
    length(technologies) > 1 && error("The portfolio has several technologies named $name")
    return only(technologies)
end

_check_technology(decision, technology, ::Type{T}) where {T} =
    technology isa T || error(
        "$(nameof(typeof(decision))) of $(get_name(technology)) needs a $T, not a " *
        "$(nameof(typeof(technology)))",
    )

_unsupported(technology, what) =
    error("Building $what (for $(get_name(technology))) is not supported yet")

function _bus(sys, name)
    bus = PSY.get_component(PSY.ACBus, sys, name)
    isnothing(bus) && error("The base system has no bus named $name")
    return bus
end

# The devices of the system (a copy of the base system) a technology's ExistingDevices list
_existing_devices(sys, technology) =
    is_new(technology) ? [] :
    _devices(
        sys,
        technology,
        get_existing_devices(
            only(IS.get_supplemental_attributes(ExistingDevices, technology)),
        ),
    )

function _devices(sys, technology, names)
    devices = [PSY.get_component(get_parameter_type(technology), sys, n) for n in names]
    missing_names = names[isnothing.(devices)]
    isempty(missing_names) || error(
        "$(join(missing_names, ", ")) of $(get_name(technology)) are not " *
        "$(get_parameter_type(technology)) components of the base system",
    )
    return devices
end

##### Restamping #####

"""
    restamp_time_series!(sys, year)

Restamp every `SingleTimeSeries` of the components of `sys` to `year` (see
[`restamp_time_series`](@ref)) and remove the other time series (forecasts), whose windows
no longer match.
"""
function restamp_time_series!(sys::PSY.System, year::Int)
    forecasts = 0
    for component in PSY.get_components(PSY.has_time_series, PSY.Component, sys)
        for row in IS.list_time_series_metadata(component)
            IS.get_time_series_type(IS.get_time_series_key(row)) <: PSY.SingleTimeSeries &&
                continue
            _remove_time_series!(sys, component, row)
            forecasts += 1
        end
        for row in
            IS.list_time_series_metadata(component; time_series_type=PSY.SingleTimeSeries)
            Dates.year(IS.get_initial_timestamp(row)) == year && continue
            key = IS.get_time_series_key(row)
            series = IS.get_time_series(component, key)
            _remove_time_series!(sys, component, row)
            PSY.add_time_series!(
                sys,
                component,
                restamp_time_series(series, year);
                features=IS.get_features(row),
            )
        end
    end
    forecasts > 0 &&
        @warn "Removed $forecasts forecasts from the operational system; call " *
              "transform_single_time_series! to create them for the restamped time series."
    return
end

_remove_time_series!(sys, component, row) = PSY.remove_time_series!(
    sys,
    IS.get_time_series_type(IS.get_time_series_key(row)),
    component,
    IS.get_name(row);
    resolution=IS.get_resolution(row),
    interval=IS.get_interval(row),
    features=IS.get_features(row),
)

"""
    restamp_time_series(series::SingleTimeSeries, year; name=get_name(series))

Return `series` (renamed `name`) moved to start in `year`: each time stamp moves by the same number of years,
values on February 29 are dropped when the new year isn't a leap year, and February 28's
values are repeated on February 29 when only the new year is a leap year. The resolution
must be at most a day.
"""
function restamp_time_series(
    series::PSY.SingleTimeSeries,
    year::Int;
    name::AbstractString=IS.get_name(series),
)
    resolution = IS.get_resolution(series)
    resolution <= Dates.Day(1) || throw(
        ArgumentError(
            "Can't restamp time series $(IS.get_name(series)) with a resolution of " *
            "$resolution; it must be at most a day",
        ),
    )
    data = IS.get_array(series)
    stamps = collect(
        range(IS.get_initial_timestamp(series); step=resolution, length=size(data, 1)),
    )
    shift = Dates.Year(year - Dates.year(first(stamps)))
    rows = Int[]
    new_stamps = Dates.DateTime[]
    feb28 = Int[]
    for (i, stamp) in enumerate(stamps)
        target_year = Dates.year(stamp + shift)
        leap_gained = Dates.isleapyear(target_year) && !Dates.isleapyear(Dates.year(stamp))
        if Dates.monthday(stamp) == (3, 1) && leap_gained && !isempty(feb28)
            append!(rows, feb28)
            append!(new_stamps, [stamps[j] + shift + Dates.Day(1) for j in feb28])
            empty!(feb28)
        end
        if Dates.monthday(stamp) == (2, 29) && !Dates.isleapyear(target_year)
            continue
        end
        push!(rows, i)
        push!(new_stamps, stamp + shift)
        Dates.monthday(stamp) == (2, 28) && leap_gained && push!(feb28, i)
    end
    expected = range(first(new_stamps); step=resolution, length=length(new_stamps))
    new_stamps == collect(expected) || error(
        "Restamping time series $(IS.get_name(series)) to $year left uneven time stamps",
    )
    return PSY.SingleTimeSeries(
        name,
        first(new_stamps),
        resolution,
        copy(selectdim(data, 1, rows));
        units=series.units,
        quantity_kind=series.quantity_kind,
        unit_system=series.unit_system,
        value_axes=series.value_axes,
    )
end
