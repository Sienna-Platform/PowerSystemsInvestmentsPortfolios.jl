#=
This file is auto-generated. Do not edit.
=#

#! format: off

"""
    mutable struct ExistingDevices <: IS.SupplementalAttribute
        existing_devices::Vector{String}
        ext::Dict
        internal::InfrastructureSystemsInternal
    end

Supplemental attributed used to map technologies in a portfolio to the existing system. For example, contains a list of existing generators that correspond to a SupplyTechnology.

# Arguments
- `existing_devices::Vector{String}`: (default: `Vector()`) List of individual existing devices to map to a specific technology in the portfolio
- `ext::Dict`: (default: `Dict()`) Optional dictionary to provide additional data
- `internal::InfrastructureSystemsInternal`: (default: `InfrastructureSystemsInternal()`) (**Do not modify.**) PowerSystemsInvestmentsPortfolios.jl internal reference
"""
mutable struct ExistingDevices <: IS.SupplementalAttribute
    "List of individual existing devices to map to a specific technology in the portfolio"
    existing_devices::Vector{String}
    "Optional dictionary to provide additional data"
    ext::Dict
    "(**Do not modify.**) PowerSystemsInvestmentsPortfolios.jl internal reference"
    internal::InfrastructureSystemsInternal
end


function ExistingDevices(; existing_devices=Vector(), ext=Dict(), internal=InfrastructureSystemsInternal(), )
    ExistingDevices(existing_devices, ext, internal, )
end

# Constructor for demo purposes; non-functional.
function ExistingDevices(::Nothing)
    ExistingDevices(;
        existing_devices=InfrastructureSystemsInternal(),
        ext=InfrastructureSystemsInternal(),
        internal=InfrastructureSystemsInternal(),
    )
end

"""Get [`ExistingDevices`](@ref) `existing_devices`."""
get_existing_devices(value::ExistingDevices) = value.existing_devices
"""Get [`ExistingDevices`](@ref) `ext`."""
get_ext(value::ExistingDevices) = value.ext
"""Get [`ExistingDevices`](@ref) `internal`."""
get_internal(value::ExistingDevices) = value.internal

"""Set [`ExistingDevices`](@ref) `existing_devices`."""
set_existing_devices!(value::ExistingDevices, val) = value.existing_devices = val
"""Set [`ExistingDevices`](@ref) `ext`."""
set_ext!(value::ExistingDevices, val) = value.ext = val
"""Set [`ExistingDevices`](@ref) `internal`."""
set_internal!(value::ExistingDevices, val) = value.internal = val



function from_openapi(po::PI.ExistingDevices, refs::OpenAPIRefs)
    return ExistingDevices(;
        existing_devices = _or_default(po.existing_devices, Vector()),
    )
end

function to_openapi(value::ExistingDevices, refs::OpenAPIRefs)
    return PI.ExistingDevices(;
        id = get_id(value),
        existing_devices = get_existing_devices(value),
    )
end
