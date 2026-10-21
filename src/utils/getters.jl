"""
Get the maximum value from a MinMax NamedTuple.
"""
get_max(x::MinMax) = x.max

"""
Get the minimum value from a MinMax NamedTuple.
"""
get_min(x::MinMax) = x.min

"""
Get the input value from an InOut NamedTuple.
"""
get_in(x::InOut) = x.in

"""
Get the output value from an InOut NamedTuple.
"""
get_out(x::InOut) = x.out

"""
Get the PowerSystems.jl parametric type T from a parametric Technology type.
Returns the type parameter used in the technology's type signature.
"""
get_parameter_type(t::SupplyTechnology{T}) where {T} = T
get_parameter_type(::Type{SupplyTechnology{T}}) where {T} = T
get_parameter_type(t::StorageTechnology{T}) where {T} = T
get_parameter_type(::Type{StorageTechnology{T}}) where {T} = T
get_parameter_type(t::AggregateTransportTechnology{T}) where {T} = T
get_parameter_type(::Type{AggregateTransportTechnology{T}}) where {T} = T
get_parameter_type(t::NodalACTransportTechnology{T}) where {T} = T
get_parameter_type(::Type{NodalACTransportTechnology{T}}) where {T} = T
get_parameter_type(t::NodalHVDCTransportTechnology{T}) where {T} = T
get_parameter_type(::Type{NodalHVDCTransportTechnology{T}}) where {T} = T
get_parameter_type(t::DemandRequirement{T}) where {T} = T
get_parameter_type(::Type{DemandRequirement{T}}) where {T} = T
get_parameter_type(t::DemandSideTechnology{T}) where {T} = T
get_parameter_type(::Type{DemandSideTechnology{T}}) where {T} = T

# Capacity (MW, in natural units) that one base-system component contributes to the existing
# capacity of a technology: maximum active power for injection devices, maximum output for
# storage, and thermal rating for branches.
_existing_capacity(c::PSY.StaticInjection) = PSY.get_max_active_power(c)
_existing_capacity(c::PSY.Storage) = PSY.get_output_active_power_limits(c).max
_existing_capacity(c::PSY.Branch) = PSY.get_rating(c)

"""
Calculates the amount of existing capacity (in MW) associated with a given Technology in the Portfolio.
Technology must have an ExistingDevices supplemental attribute attached to it to be non-zero.
This attribute contains a list of names of existing assets in the base system that correspond to this technology.
For generators this is the maximum active power, not the MVA rating. For StorageTechnology,
this function returns existing discharge capacity in MW; see
[`get_existing_capacity_mwh`](@ref) for existing energy capacity in MWh. For
TransmissionTechnology it is the thermal rating.

# Arguments

  - `p::Portfolio`: The portfolio containing the base system and technology
  - `t::Union{ResourceTechnology, TransmissionTechnology}`: The technology to get existing capacity
"""
function get_existing_capacity_mw(
    p::Portfolio,
    t::Union{ResourceTechnology, TransmissionTechnology},
)
    if typeof(t) <: ColocatedSupplyStorageTechnology
        @warn "Co-located technologies are not supported for ExistingDevices, assuming an existing capacity of 0"
        return 0.0
    end

    if !is_new(t)
        attr = IS.get_supplemental_attributes(ExistingDevices, t)
        if length(attr) > 1
            @warn "Multiple ExistingDevices attributes are attached to this technology, assuming a capacity of 0.0"
            return 0.0
        end

        gen_names = get_existing_devices(only(attr))
        if length(gen_names) == 0
            @warn "No names listed in ExistingDevices attribute, returning capacity of 0.0."
            return 0.0
        end

        comp = PSY.get_component.(get_parameter_type(t), Ref(p.base_system), gen_names)

        # Check if any of the components returned nothing
        filtered_comp = filter(x -> !isnothing(x), comp)
        if length(filtered_comp) != length(gen_names)
            @error "Not all names in ExistingDevices matched generators in the base system"
        end

        existing_capacity = with_units_base(get_base_system(p), "NATURAL_UNITS") do
            sum(_existing_capacity(c) for c in comp)
        end

        return existing_capacity
    else
        return 0.0
    end
end

"""
Calculates the amount of existing energy capacity (in MWh) associated with a given StorageTechnology.
Technology must have an ExistingDevices supplemental attribute attached to it to be non-zero.
This attribute contains a list of names of existing assets in the base system that correspond to this technology.
To get the charge/discharge capacity in MW, see [`get_existing_capacity_mw`](@ref).

# Arguments

  - `p::Portfolio`: The portfolio containing the base system and technology
  - `t::StorageTechnology`: The storage technology to get existing energy capacity
"""
function get_existing_capacity_mwh(p::Portfolio, t::StorageTechnology)
    if !is_new(t)
        attr = IS.get_supplemental_attributes(ExistingDevices, t)
        if length(attr) > 1
            @warn "Multiple ExistingDevices attributes are attached to this technology, assuming a capacity of 0.0"
            return 0.0
        end
        gen_names = get_existing_devices(only(attr))
        comp = PSY.get_component.(get_parameter_type(t), Ref(p.base_system), gen_names)

        # Check if any of the components returned nothing
        filtered_comp = filter(x -> !isnothing(x), comp)
        if length(filtered_comp) != length(gen_names)
            @error "Not all names in ExistingDevices matched generators in the base system"
        end

        existing_capacity = with_units_base(get_base_system(p), "NATURAL_UNITS") do
            sum(PSY.get_storage_capacity(t) for t in comp)
        end

        return existing_capacity
    else
        return 0.0
    end
end

"""
Calculates the peak demand (in MW) associated with a given Technology in the Portfolio.
Technology must have an ExistingDevices supplemental attribute attached to it to be non-zero.
This attribute contains a list of names of existing assets in the base system that correspond to this technology.

# Arguments

  - `p::Portfolio`: The portfolio containing the base system and technology
  - `t::DemandTechnology`: The technology to get peak demand
"""
function get_peak_demand_mw(p::Portfolio, t::DemandTechnology)
    if !is_new(t)
        attr = IS.get_supplemental_attributes(ExistingDevices, t)
        if length(attr) > 1
            @warn "Multiple ExistingDevices attributes are attached to this technology, assuming a peak demand of 0.0"
            return 0.0
        end

        gen_names = get_existing_devices(only(attr))
        if length(gen_names) == 0
            @warn "No names listed in ExistingDevices attribute, returning peak demand of 0.0."
            return 0.0
        end

        comp = PSY.get_component.(get_parameter_type(t), Ref(p.base_system), gen_names)

        # Check if any of the components returned nothing
        filtered_comp = filter(x -> !isnothing(x), comp)
        if length(filtered_comp) != length(gen_names)
            @error "Not all names in ExistingDevices matched generators in the base system"
        end

        existing_capacity = with_units_base(get_base_system(p), "NATURAL_UNITS") do
            sum(PSY.get_max_active_power(t) for t in comp)
        end

        return existing_capacity
    else
        @warn "Demand technology has no existing loads attached, returning a peak demand of 0.0. If this technology is meant to represent existing demand, please attach an ExistingDevices supplemental attribute with the names of the corresponding loads in the base system."
        return 0.0
    end
end

function scale_conforming_load(t::DemandTechnology, p::Portfolio, year::Int64)
    if get_conformity(t) == PSY.LoadConformity.NON_CONFORMING
        @warn "Load is not conforming, returning original peak demand without scaling."
        return get_peak_demand_mw(p, t)
    else
        peak_demand = get_peak_demand_mw(p, t)
        growth_rate = get_growth_rate(t)
        if is_new(t)
            reference_year = get_new_construction_year(t)
        else
            reference_year = get_base_year_for_load(t, p)
        end
        scaled_demand = peak_demand * (1 + growth_rate)^(year - reference_year)
        return scaled_demand
    end
end

"""
Determines if a technology is a completely new build and is not associated with any pre-existing capacity
"""
is_new(t::Technology) = !(IS.has_supplemental_attributes(ExistingDevices, t))

"""
Get constant heat rate value from FuelCurve stored in a SupplyTechnology
"""
get_heat_rate(t::SupplyTechnology) =
    IS.get_proportional_term(IS.get_value_curve(PSY.get_variable(get_operation_costs(t))))

"""
Get constant fuel cost from FuelCurve stored in a SupplyTechnology
"""
get_fuel_cost(t::SupplyTechnology) =
    IS.get_fuel_cost(PSY.get_variable(get_operation_costs(t)))

"""
Get constant variable OM costs from OperationalCost in a SupplyTechnology
"""
get_variable_cost(t::SupplyTechnology) =
    IS.get_proportional_term(IS.get_vom_cost(PSY.get_variable(get_operation_costs(t))))

"""
Get constant variable OM costs for storage charging from OperationalCost in a StorageTechnology
"""
get_variable_cost_charge(t::StorageTechnology) = PSY.get_proportional_term(
    PSY.get_vom_cost(PSY.get_charge_variable_cost(get_operation_costs(t))),
)

"""
Get constant variable OM costs for storage discharging from OperationalCost in a StorageTechnology
"""
get_variable_cost_discharge(t::StorageTechnology) = PSY.get_proportional_term(
    PSY.get_vom_cost(PSY.get_discharge_variable_cost(get_operation_costs(t))),
)

"""
Get constant fixed OM costs from OperationalCost for a SupplyTechnology
"""
get_fixed_cost(t::Technology) = PSY.get_fixed(get_operation_costs(t))

"""
Get constant fixed OM costs for storage charge from OperationalCost in a StorageTechnology
"""
get_fixed_cost_charge(t::StorageTechnology) = PSY.get_proportional_term(
    PSY.get_value_curve(PSY.get_charge_variable_cost(get_operation_costs(t))),
)

"""
Get constant fixed OM costs for storage discharge from OperationalCost in a StorageTechnology
"""
get_fixed_cost_discharge(t::StorageTechnology) = PSY.get_proportional_term(
    PSY.get_value_curve(PSY.get_discharge_variable_cost(get_operation_costs(t))),
)

"""
Get the base year for a DemandRequirement, which is the same as the base year for the portfolio it belongs to.
"""
get_base_year_for_load(t::DemandRequirement, p::Portfolio) = get_base_year(p)

"""
Calculate the weighted average cost of capital (WACC) for a Technology based on its TechnologyFinancialData.
We defined WACC such that `WACC = D * Rd * (1 - Tc) + E * Re``
where D is the debt fraction, Rd is the debt rate, Tc is the tax rate, E is the equity fraction, and Re is the return on equity.

Will return an error if the debt fraction is not between 0.0 and 1.0.
"""
function get_wacc(tech_financials::TechnologyFinancialData)
    dr = tech_financials.debt_rate
    tr = tech_financials.tax_rate
    re = tech_financials.return_on_equity
    df = tech_financials.debt_fraction
    ef = 1.0 - df
    if df > 1.0 || df < 0.0
        error("Debt fraction must be between 0.0 and 1.0")
    end
    return df * dr * (1.0 - tr) + ef * re
end
