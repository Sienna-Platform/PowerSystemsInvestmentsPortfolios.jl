"""
Validate a technology using only information contained within the technology.

Return `true` if the technology is valid.
"""
validate_technology(::Technology) = true

function _validate_nonnegative_limits(technology, limits, field_name)
    is_valid = true
    if !isfinite(limits.min) || !isfinite(limits.max)
        @error(
            "$field_name must be finite",
            technology = get_name(technology),
            minimum = limits.min,
            maximum = limits.max,
        )
        is_valid = false
    end
    if limits.min < 0.0 || limits.max < 0.0
        @error(
            "$field_name must be nonnegative",
            technology = get_name(technology),
            minimum = limits.min,
            maximum = limits.max,
        )
        is_valid = false
    end
    if limits.min > limits.max
        @error(
            "$field_name must be in ascending order",
            technology = get_name(technology),
            minimum = limits.min,
            maximum = limits.max,
        )
        is_valid = false
    end
    return is_valid
end

function _validate_nonnegative_value(technology, value, field_name)
    if !isfinite(value) || value < 0.0
        @error(
            "$field_name must be finite and nonnegative",
            technology = get_name(technology),
            value,
        )
        return false
    end
    return true
end

function _validate_positive_value(technology, value, field_name)
    if !isfinite(value) || value <= 0.0
        @error(
            "$field_name must be finite and positive",
            technology = get_name(technology),
            value,
        )
        return false
    end
    return true
end

function _validate_fraction(technology, value, field_name; strictly_positive=false)
    lower_bound_is_valid = strictly_positive ? value > 0.0 : value >= 0.0
    if !isfinite(value) || !lower_bound_is_valid || value > 1.0
        interval = strictly_positive ? "(0, 1]" : "[0, 1]"
        @error(
            "$field_name must be in $interval",
            technology = get_name(technology),
            value,
        )
        return false
    end
    return true
end

function _validate_storage_fields(technology::StorageTechnology)
    is_valid = true

    is_valid &= _validate_nonnegative_limits(
        technology,
        get_duration_limits(technology),
        "Storage duration limits",
    )
    is_valid &= _validate_nonnegative_limits(
        technology,
        get_capacity_limits_energy(technology),
        "Storage energy capacity limits",
    )
    is_valid &= _validate_nonnegative_limits(
        technology,
        get_capacity_limits_discharge(technology),
        "Storage discharge capacity limits",
    )

    charge_capacity_limits = get_capacity_limits_charge(technology)
    if !isnothing(charge_capacity_limits)
        is_valid &= _validate_nonnegative_limits(
            technology,
            charge_capacity_limits,
            "Storage charge capacity limits",
        )
    end

    is_valid &= _validate_nonnegative_value(
        technology,
        get_unit_size_energy(technology),
        "Storage energy unit size",
    )
    is_valid &= _validate_nonnegative_value(
        technology,
        get_unit_size_discharge(technology),
        "Storage discharge unit size",
    )

    charge_unit_size = get_unit_size_charge(technology)
    if !isnothing(charge_unit_size)
        is_valid &= _validate_nonnegative_value(
            technology,
            charge_unit_size,
            "Storage charge unit size",
        )
    end

    is_valid &= _validate_fraction(
        technology,
        get_min_discharge_fraction(technology),
        "Storage minimum discharge fraction",
    )
    is_valid &= _validate_fraction(technology, get_losses(technology), "Storage losses")

    efficiency = get_efficiency(technology)
    is_valid &= _validate_fraction(
        technology,
        efficiency.in,
        "Storage charging efficiency";
        strictly_positive=true,
    )
    is_valid &= _validate_fraction(
        technology,
        efficiency.out,
        "Storage discharging efficiency";
        strictly_positive=true,
    )

    return is_valid
end

function validate_technology(technology::SupplyTechnology)
    is_valid = _validate_positive_value(
        technology,
        get_lifetime(technology),
        "Technology lifetime",
    )
    is_valid &= _validate_nonnegative_limits(
        technology,
        get_capacity_limits(technology),
        "Supply capacity limits",
    )
    is_valid &= _validate_nonnegative_value(
        technology,
        get_unit_size(technology),
        "Supply unit size",
    )
    is_valid &= _validate_fraction(
        technology,
        get_min_generation_fraction(technology),
        "Supply minimum generation fraction",
    )
    return is_valid
end

function validate_technology(technology::StorageTechnology)
    is_valid = _validate_positive_value(
        technology,
        get_lifetime(technology),
        "Technology lifetime",
    )
    is_valid &= _validate_storage_fields(technology)
    return is_valid
end

function _validate_colocated_supply_storage_fields(
    technology::ColocatedSupplyStorageTechnology,
)
    is_valid = _validate_nonnegative_limits(
        technology,
        get_capacity_limits_wind(technology),
        "Colocated wind capacity limits",
    )
    is_valid &= _validate_nonnegative_limits(
        technology,
        get_capacity_limits_solar(technology),
        "Colocated solar capacity limits",
    )
    is_valid &= _validate_nonnegative_limits(
        technology,
        get_capacity_power_limits(technology),
        "Colocated storage power capacity limits",
    )
    is_valid &= _validate_nonnegative_limits(
        technology,
        get_capacity_energy_limits(technology),
        "Colocated storage energy capacity limits",
    )
    is_valid &= _validate_nonnegative_limits(
        technology,
        get_duration_limits(technology),
        "Colocated storage duration limits",
    )
    is_valid &= _validate_nonnegative_limits(
        technology,
        (
            min=get_min_inverter_capacity(technology),
            max=get_max_inverter_capacity(technology),
        ),
        "Colocated inverter capacity limits",
    )

    efficiency = get_efficiency_storage(technology)
    is_valid &= _validate_fraction(
        technology,
        efficiency.in,
        "Colocated storage charging efficiency";
        strictly_positive=true,
    )
    is_valid &= _validate_fraction(
        technology,
        efficiency.out,
        "Colocated storage discharging efficiency";
        strictly_positive=true,
    )
    is_valid &= _validate_fraction(
        technology,
        get_inverter_efficiency(technology),
        "Colocated inverter efficiency";
        strictly_positive=true,
    )
    is_valid &= _validate_fraction(
        technology,
        get_losses_storage(technology),
        "Colocated storage losses",
    )
    return is_valid
end

function validate_technology(technology::ColocatedSupplyStorageTechnology)
    is_valid = _validate_positive_value(
        technology,
        get_lifetime_storage(technology),
        "Colocated storage lifetime",
    )
    is_valid &= _validate_positive_value(
        technology,
        get_lifetime_wind(technology),
        "Colocated wind lifetime",
    )
    is_valid &= _validate_positive_value(
        technology,
        get_lifetime_solar(technology),
        "Colocated solar lifetime",
    )
    is_valid &= _validate_colocated_supply_storage_fields(technology)
    return is_valid
end

function _validate_transmission_fields(technology::TransmissionTechnology)
    is_valid = _validate_nonnegative_limits(
        technology,
        get_capacity_limits(technology),
        "Transport capacity limits",
    )
    is_valid &= _validate_positive_value(
        technology,
        get_unit_size(technology),
        "Transport unit size",
    )
    return is_valid
end

validate_technology(technology::TransmissionTechnology) =
    _validate_transmission_fields(technology)

function validate_technology(technology::AggregateTransportTechnology)
    is_valid = _validate_transmission_fields(technology)
    is_valid &= _validate_fraction(
        technology,
        get_line_loss(technology),
        "Aggregate transport line loss",
    )
    return is_valid
end

IS.validate_struct(technology::Technology) = validate_technology(technology)

"""
Validate a technology using data from the portfolio.

Use [`validate_technology`](@ref) when validation only requires data contained within the
technology itself.

Return `true` if the technology is valid.
"""
validate_technology_with_portfolio(::Technology, ::Portfolio) = true

function _validate_unique_region_id(region::RegionTopology, portfolio::Portfolio)
    region_id = get_id(region)
    for stored_region in get_regions(RegionTopology, portfolio)
        if get_id(stored_region) == region_id
            @error(
                "Region ID is already attached to the portfolio",
                region = summary(region),
                id = region_id,
                stored_region = summary(stored_region),
            )
            return false
        end
    end
    return true
end

function _validate_unique_references(
    technology::Technology,
    references,
    reference_type::AbstractString,
)
    uuids = IS.get_uuid.(references)
    if !allunique(uuids)
        @error(
            "Technology contains duplicate $reference_type references",
            technology = get_name(technology),
        )
        return false
    end
    return true
end

function _validate_attached_references(
    technology::Technology,
    references,
    portfolio::Portfolio,
    reference_type::AbstractString,
)
    is_valid = true
    for reference in references
        if !IS.has_component(portfolio.data, reference)
            @error(
                "Technology references a $reference_type that is not attached to the portfolio",
                technology = get_name(technology),
                reference = summary(reference),
            )
            is_valid = false
        end
    end
    return is_valid
end

function _validate_region_references(
    technology::Union{ResourceTechnology, DemandTechnology},
    portfolio::Portfolio,
)
    regions = get_region(technology)
    if isempty(regions)
        @error(
            "Technology must reference at least one region",
            technology = get_name(technology),
        )
        return false
    end

    is_valid = _validate_unique_references(technology, regions, "region")
    is_valid &= _validate_attached_references(technology, regions, portfolio, "region")
    return is_valid
end

_get_transport_endpoints(technology::AggregateTransportTechnology) =
    (get_start_region(technology), get_end_region(technology))

_get_transport_endpoints(technology::NodalACTransportTechnology) =
    (get_start_node(technology), get_end_node(technology))

_get_transport_endpoints(technology::NodalHVDCTransportTechnology) =
    (get_start_node(technology), get_end_node(technology))

function _validate_transport_endpoints(
    technology::TransmissionTechnology,
    portfolio::Portfolio,
)
    start_endpoint, end_endpoint = _get_transport_endpoints(technology)
    is_valid = true
    for (endpoint_name, endpoint) in (("start", start_endpoint), ("end", end_endpoint))
        if !IS.has_component(portfolio.data, endpoint)
            @error(
                "Transport endpoint is not attached to the portfolio",
                technology = get_name(technology),
                endpoint = endpoint_name,
                reference = summary(endpoint),
            )
            is_valid = false
        end
    end
    return is_valid
end

validate_technology_with_portfolio(
    technology::TransmissionTechnology,
    portfolio::Portfolio,
) = _validate_transport_endpoints(technology, portfolio)

function validate_technology_with_portfolio(
    technology::Union{ResourceTechnology, DemandTechnology},
    portfolio::Portfolio,
)
    return _validate_region_references(technology, portfolio)
end

function _validate_or_skip!(
    portfolio::Portfolio,
    technology::Technology,
    skip_validation::Bool,
)
    if !skip_validation && !validate_technology_with_portfolio(technology, portfolio)
        throw(IS.InvalidValue("Invalid value for $(summary(technology))"))
    end
    return skip_validation
end

function _validate_or_skip!(
    portfolio::Portfolio,
    region::RegionTopology,
    skip_validation::Bool,
)
    if !skip_validation && !_validate_unique_region_id(region, portfolio)
        throw(IS.InvalidValue("Invalid value for $(summary(region))"))
    end
    return skip_validation
end

"""
Check one technology using technology-only and portfolio-aware validation.

Throw [`IS.InvalidValue`](@ref) if the technology is invalid.
"""
function check_technology(portfolio::Portfolio, technology::Technology)
    if !validate_technology_with_portfolio(technology, portfolio)
        throw(IS.InvalidValue("Invalid value for $(summary(technology))"))
    end
    IS.check_component(portfolio.data, technology)
    return
end

"""
Check every technology in an iterable.

Throw [`IS.InvalidValue`](@ref) when a technology is invalid.
"""
function check_technologies(portfolio::Portfolio, technologies)
    for technology in technologies
        check_technology(portfolio, technology)
    end
    return
end
