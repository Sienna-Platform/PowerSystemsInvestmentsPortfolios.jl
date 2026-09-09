"""
Constructs a Portfolio from a file path ending with .json
"""
function Portfolio(file_path::AbstractString; try_reimport=true, kwargs...)
    ext = lowercase(splitext(file_path)[2])
    if ext == ".json"
        unsupported = setdiff(keys(kwargs), SYSTEM_KWARGS)
        !isempty(unsupported) && error("Unsupported kwargs = $unsupported")
        time_series_read_only = get(kwargs, :time_series_read_only, false)
        time_series_directory = get(kwargs, :time_series_directory, nothing)
        # TODO: `runchecks` governs the base system read only; portfolio-level validation on
        # load is not wired up yet.
        return deserialize(
            Portfolio,
            file_path;
            time_series_read_only=time_series_read_only,
            time_series_directory=time_series_directory,
            runchecks=get(kwargs, :runchecks, false),
        )
    else
        throw(IS.DataFormatError("$file_path is not a supported file type"))
    end
end
function deserialize(::Type{Portfolio}, filename::AbstractString; kwargs...)
    raw = open(filename) do io
        JSON3.read(io, Dict)
    end

    if raw["data_format_version"] != DATA_FORMAT_VERSION
        pre_read_conversion!(raw)
    end

    # These file paths are relative to the portfolio file.
    directory = dirname(filename)
    for file_key in ("time_series_storage_file",)
        if haskey(raw["data"], file_key) && !isabspath(raw["data"][file_key])
            raw["data"][file_key] = joinpath(directory, raw["data"][file_key])
        end
    end

    return from_dict(Portfolio, raw, filename; kwargs...)
end
"""
Serializes a portfolio to a JSON file and saves time series to an HDF5 file.

# Arguments

  - `portfolio::Portfolio`: portfolio
  - `filename::AbstractString`: filename to write

# Keyword arguments

  - `user_data::Union{Nothing, Dict} = nothing`: optional metadata to record
  - `pretty::Bool = false`: whether to pretty-print the JSON
  - `force::Bool = false`: whether to overwrite existing files
  - `runchecks::Bool = false`: whether to run portfolio validation checks

Refer to [`check_component`](@ref) for exceptions thrown if `check = true`.
"""
function to_json(
    portfolio::Portfolio,
    filename::AbstractString;
    user_data=nothing,
    pretty=false,
    force=false,
    runchecks=false,
)
    IS.prepare_for_serialization_to_file!(portfolio.data, filename; force=force)
    data = to_json(portfolio; pretty=pretty)

    open(filename, "w") do io
        write(io, data)
    end

    mfile = joinpath(dirname(filename), splitext(basename(filename))[1] * "_metadata.json")
    _serialize_portfolio_metadata_to_file(portfolio, mfile, user_data)
    @info "Serialized Portfolio to $filename"

    # Serialize base system to a separate file
    base_system_file =
        joinpath(dirname(filename), splitext(basename(filename))[1] * "_base_system.json")
    PSY.to_json(portfolio.base_system, base_system_file; pretty=pretty, force=force)

    return
end
"""
Serializes a InfrastructureSystemsType to a JSON string.

Component-level serialization is portfolio-scoped: a technology, region, requirement or
supplemental attribute records its references as document ids, which only the owning
`Portfolio` can assign, so passing one here on its own raises. Pass the `Portfolio` — or
use [`to_json(portfolio, filename)`](@ref) to write the whole document to disk.
"""
function to_json(obj::T; pretty=false, indent=2) where {T <: InfrastructureSystemsType}
    try
        if pretty
            io = IOBuffer()
            JSON3.pretty(io, serialize(obj), JSON3.AlignmentContext(; indent=indent))
            return take!(io)
        else
            return JSON3.write(serialize(obj))
        end
    catch e
        @error "Failed to serialize $(summary(obj))"
        rethrow(e)
    end
end
function _serialize_portfolio_metadata_to_file(portfolio::Portfolio, filename, user_data)
    name = get_name(portfolio)
    description = get_description(portfolio)
    metadata = OrderedDict(
        "name" => isnothing(name) ? "" : name,
        "description" => isnothing(description) ? "" : description,
        "component_counts" => IS.get_component_counts_by_type(portfolio.data),
        "time_series_counts" => IS.get_time_series_counts_by_type(portfolio.data),
    )
    if !isnothing(user_data)
        metadata["user_data"] = user_data
    end

    open(filename, "w") do io
        JSON3.pretty(io, metadata)
    end

    @info "Serialized Portfolio metadata to $filename"
end
"""
Construct a Portfolio from a serialized JSON string or stream.

Warning: time series data is not restored by this method. If that is needed, use the normal
process to construct the portfolio from a serialized JSON file instead, such as with
`Portfolio("portfolio.json")`.
"""
function IS.from_json(io::Union{IO, String}, ::Type{Portfolio}; kwargs...)
    data = JSON3.read(io, Dict)
    # These objects could be removed in to_json(portfolio). Doing it here will allow us to
    # keep that JSON string fully consistent with time series and potentially use it in the
    # future.
    for component in data["data"]["components"]
        if haskey(component, "time_series_container")
            empty!(component["time_series_container"])
        end
    end

    return from_dict(Portfolio, data; kwargs...)
end
