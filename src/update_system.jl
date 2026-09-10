"""
    update_system_with_nodal_results!(sys::PSY.System, p::Portfolio, investment_solutions_nodal::Dict)

Update a PowerSystems system with nodal investment solution results.

This function iterates through the investment solutions dictionary and updates or creates
generators in the system based on the investment decisions. Each entry in the solutions
dictionary contains information about the technology type, node location, technology name,
and capacity to be added.

# Arguments

  - `sys::PSY.System`: The PowerSystems system to update
  - `p::Portfolio`: The portfolio containing technology definitions
  - `investment_solutions_nodal::Dict`: Dictionary mapping (tech_type, node, name) tuples to capacity values

# Example

```
investment_solutions = Dict(
    (SupplyTechnology{RenewableDispatch}, node1, "Solar_PV") => 100.0,
    (SupplyTechnology{RenewableDispatch}, node2, "Wind") => 50.0
)
update_system_with_nodal_results!(sys, portfolio, investment_solutions)
```
"""
function update_system_with_nodal_results!(
    sys::PSY.System,
    p::Portfolio,
    investment_solutions_nodal::Dict,
)
    # Iterate through each investment solution entry
    for (key, cap) in investment_solutions_nodal
        # Extract technology information from the composite key
        tech_type = key[1]      # Technology type (e.g., SupplyTechnology)
        node_name = key[2].name # Name of the node/bus where capacity is added
        tech_name = key[3]           # Name of the specific technology
        unit_name = key[4]         # Name of the specific unit

        # Get the corresponding PowerSystems type for this technology
        psy_type = get_parameter_type(tech_type)

        # Update existing generator or create new one with the specified capacity
        update_or_create_new_generator!(
            psy_type,
            sys,
            p,
            node_name,
            tech_name,
            unit_name,
            cap,
        )
    end
end

"""
    update_or_create_new_generator!(
        T::Type{PSY.ThermalStandard},
        sys::PSY.System,
        p::Portfolio,
        bus_name::String,
        tech_name::String,
        unit_name::String,
        capacity::Float64
    )

Update an existing generator's capacity or create a new generator in the system.

This function searches for an existing generator of the specified type and unit name
in the system. If found, it increments the generator's rating and maximum active
power limits by the specified capacity. If not found, it creates a new generator
with the given specifications.

# Arguments

  - `T::Type{PSY.ThermalStandard}`: The PowerSystems generator type
    (e.g., ThermalStandard, RenewableDispatch)
  - `sys::PSY.System`: The PowerSystems system to update
  - `p::Portfolio`: The portfolio containing technology definitions and
    specifications
  - `bus_name::String`: The name of the bus/node where the generator is located
  - `tech_name::String`: The name of the technology
  - `unit_name::String`: The name of the specific unit/generator
  - `capacity::Float64`: The capacity (in MW) to add to existing generator or
    set for new generator

# Note

This function automatically sets the system units to "NATURAL_UNITS" for
operations.
"""
function update_or_create_new_generator!(
    T::Type{PSY.ThermalStandard},
    sys::PSY.System,
    p::Portfolio,
    bus_name::String,
    tech_name::String,
    unit_name::String,
    capacity::Float64,
)

    # Check if a generator with the same name and type already exists
    gen = PSY.get_component(T, sys, unit_name)

    if !isnothing(gen)
        # Generator exists: increment its capacity
        existing_cap = PSY.get_rating(gen, u"MW")
        new_cap = existing_cap + capacity
        set_rating!(gen, new_cap * MW)
        existing_min_power, existing_max_power = PSY.get_active_power_limits(gen, u"MW")
        new_max_power = existing_max_power + capacity
        new_limits = (min=existing_min_power * MW, max=new_max_power * MW)
        PSY.set_active_power_limits!(gen, new_limits)
        return
    else
        # Generator doesn't exist: create a new one

        # Get system base power for per-unit conversion
        sys_base_power = PSY.get_base_power(sys)

        # Retrieve the bus where this generator will be connected
        bus_sys = PSY.get_component(PSY.ACBus, sys, bus_name)

        # Get technology specifications from the portfolio
        tech = get_technology(SupplyTechnology{T}, p, tech_name)
        op_cost = get_operation_costs(tech, IS.NU)
        prime_mover_type = get_prime_mover_type(tech)
        fuel = only(get_fuel(tech))

        # Create new renewable generator with specified parameters
        new_gen = T(
            name=unit_name,
            available=true,                           # Generator is available for dispatch
            status=PSY.OperationalStates.ONLINE,      # Generator is on by default
            bus=bus_sys,                              # Connected bus
            active_power=0.0,                         # Initial active power output
            reactive_power=0.0,                       # Initial reactive power output
            rating=capacity / sys_base_power,         # Capacity in per-unit
            active_power_limits=(min=0.0, max=capacity / sys_base_power),     # Active power limits
            prime_mover_type=prime_mover_type,        # Type of prime mover (e.g., PV, WT)
            reactive_power_limits=nothing,            # No reactive power limits
            ramp_limits=nothing,                    # No ramp limits
            operation_cost=op_cost,                   # Operating cost structure
            base_power=sys_base_power,                # Base power for per-unit system
            fuel=fuel,                              # Fuel type
        )

        # Add the new generator to the system
        PSY.add_component!(sys, new_gen)
    end
end

"""
    update_or_create_new_generator!(T::Type{PSY.RenewableDispatch}, sys::PSY.System, 
                                   p::Portfolio, bus_name::String, tech_name::String, 
                                   unit_name::String, capacity::Float64)

Update an existing renewable generator's capacity or create a new one if it doesn't exist.

This function searches for a renewable generator with the specified unit name in the system.
If found, it increments the generator's capacity by the specified amount. If not found,
it creates a new RenewableDispatch generator with the given parameters and adds it to
the system along with its time series data.

# Arguments

  - `T::Type{PSY.RenewableDispatch}`: The PowerSystems generator type (RenewableDispatch)
  - `sys::PSY.System`: The PowerSystems system to modify
  - `p::Portfolio`: The portfolio containing technology specifications
  - `bus_name::String`: Name of the bus/node where the generator is connected
  - `tech_name::String`: Name of the technology
  - `unit_name::String`: Name of the specific unit/generator
  - `capacity::Float64`: Capacity to add (in MW for existing generators, or initial capacity for new ones)

# Notes

  - Sets the system units to "NATURAL_UNITS" for capacity calculations
  - For new generators, capacity is normalized by the system base power
  - Automatically adds renewable time series data for new generators
"""
function update_or_create_new_generator!(
    T::Type{PSY.RenewableDispatch},
    sys::PSY.System,
    p::Portfolio,
    bus_name::String,
    tech_name::String,
    unit_name::String,
    capacity::Float64,
)
    # Check if a generator with the same name and type already exists
    gen = PSY.get_component(T, sys, unit_name)

    if !isnothing(gen)
        # Generator exists: increment its capacity
        existing_cap = PSY.get_rating(gen, u"MW")
        new_cap = existing_cap + capacity
        set_rating!(gen, new_cap * MW)
        return
    else
        # Generator doesn't exist: create a new one

        # Get system base power for per-unit conversion
        sys_base_power = PSY.get_base_power(sys)

        # Retrieve the bus where this generator will be connected
        bus_sys = PSY.get_component(PSY.ACBus, sys, bus_name)

        # Get technology specifications from the portfolio
        tech = get_technology(SupplyTechnology{T}, p, tech_name)
        op_cost = get_operation_costs(tech, IS.NU)
        prime_mover_type = get_prime_mover_type(tech)

        # Create new renewable generator with specified parameters
        new_gen = T(
            name=unit_name,
            available=true,                           # Generator is available for dispatch
            bus=bus_sys,                              # Connected bus
            active_power=0.0,                         # Initial active power output
            reactive_power=0.0,                       # Initial reactive power output
            rating=capacity / sys_base_power,         # Capacity in per-unit
            prime_mover_type=prime_mover_type,        # Type of prime mover (e.g., PV, WT)
            reactive_power_limits=nothing,            # No reactive power limits
            power_factor=1.0,                         # Unity power factor
            operation_cost=op_cost,                   # Operating cost structure
            base_power=sys_base_power,                # Base power for per-unit system
        )

        # Add the new generator to the system
        PSY.add_component!(sys, new_gen)

        # Add renewable time series data (capacity factors) to the generator
        add_renewable_timeseries!(sys, new_gen, tech)
    end
end

"""
    add_renewable_timeseries!(sys::PSY.System, gen::PSY.RenewableDispatch, 
                             tech::SupplyTechnology)

Add capacity factor time series data to a renewable generator.

This function extracts the capacity factor time series from the technology definition
and adds it to the generator as a "max_active_power" time series. The capacity factors
represent the maximum available power output as a fraction of the generator's rated
capacity, accounting for resource availability (e.g., solar irradiance, wind speed).

# Arguments

  - `sys::PSY.System`: The PowerSystems system containing the generator
  - `gen::PSY.RenewableDispatch`: The renewable generator to add time series data to
  - `tech::SupplyTechnology`: The technology definition containing capacity factor data

# Notes

  - The time series is named "max_active_power" to comply with PowerSystems conventions
  - The values are stored as capacity factors, declared as per unit on the generator's own
    base (`IS.CU`) scaling to active power. Nothing rescales them on read; a consumer that
    wants MW multiplies by the generator's max active power itself
  - A deep copy of the time series array is made to avoid unintended data sharing
"""
function add_renewable_timeseries!(
    sys::PSY.System,
    gen::PSY.RenewableDispatch,
    tech::SupplyTechnology,
)
    # Extract capacity factor time series from technology definition
    # Deep copy ensures independence from the original data
    ts_array =
        deepcopy(PSY.get_time_series_array(PSY.SingleTimeSeries, tech, "capacity_factor"))

    # Create a SingleTimeSeries object for the generator's maximum active power
    renewable_ts = PSY.SingleTimeSeries(;
        name="max_active_power",                      # Standard PowerSystems time series name
        data=ts_array,                                 # Capacity factor time series data
        unit_system=IS.CU,                             # Values are per unit on the generator's base
        quantity_kind="active_power",                  # ...of active power
    )

    # Add the time series to the generator in the system
    PSY.add_time_series!(sys, gen, renewable_ts)
end
