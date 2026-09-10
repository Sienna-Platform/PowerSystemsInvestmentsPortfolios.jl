# A serialized Portfolio is written as one of three forms, chosen by the extension of the path
# given to `to_file` — there is no `format` keyword:
#
#   - `case`         a directory of four members
#
#                        case/
#                          portfolio.json      the OpenAPI document for the portfolio
#                          time_series.h5      the InfraStore arrays
#                          base_system/
#                            base_system.json    the OpenAPI document for the base system
#                            time_series_base_system.h5      the InfraStore arrays
#
#   - `case.json`    the same two members, named after the document and sitting beside it
#
#                        case.json          the OpenAPI document
#                        case.h5            the InfraStore arrays
#                        base_system/
#                          case.json    the OpenAPI document for the base system
#                          case.h5      the InfraStore arrays
#
#                    The sidecar takes the document's stem so several systems can share one
#                    directory; the document records only its basename, so the pair moves
#                    together.
#
#   - `case.sn`      four members, tar+gzip'd into one file
#
#                        case.sn
#                          portfolio.json
#                          time_series.h5
#                          time_series.h5.sqlite   InfraStore's own catalog
#                          base_system/
#                            base_system.json
#                            time_series.h5
#                            time_series.h5.sqlite   InfraStore's own catalog
#                            sienna_extras.json
#
#                    Entries sit at the archive root rather than under a `case/` prefix,
#                    because `Tar.create` archives a directory's contents, not the
#                    directory itself.
#
# The archive's extra members are the difference between the forms, and the `.sqlite` one is a
# difference about **where the association tables live** rather than about compression:
#
#   `.sn` keeps InfraStore's `.sqlite`, so the store is restored from its own tables. It is the
#   lossless native form — the catalog holds columns the OpenAPI wire form has no field for —
#   and it is Sienna-only, since reading it means reading InfraStore's catalog. It also carries
#   `sienna_extras.json`, which is what makes it the only form that keeps subsystems.
#
#   The two document forms write the arrays alone and record the associations in the document's
#   own `time_series_associations` table, which `from_openapi` replays into a freshly minted
#   catalog. That is what makes them readable by any non-Julia client, and it bounds them by
#   what the wire form can express.
#
# `to_openapi(portfolio; write_catalog)` is the knob.

"""Document member of a serialized Portfolio directory."""
const PORTFOLIO_DOCUMENT_FILE = "portfolio.json"

"""Base System document member of a serialized Portfolio directory."""
const BASE_SYSTEM_DOCUMENT_FILE = "base_system.json"

"""Base System subdirectory for a serialized Portfolio directory."""
const BASE_SYSTEM_DIRECTORY = "base_system"

"""HDF5 sidecar member of a serialized Portfolio directory."""
const TIME_SERIES_FILE = "time_series.h5"

"""Suffix InfraStore gives its catalog: the sidecar's own name plus this. Named once so the
document forms, which name their sidecar after the document, derive the same path."""
const TIME_SERIES_CATALOG_SUFFIX = ".sqlite"

"""InfraStore's SQLite catalog, beside the HDF5 sidecar.

A member of a `:sienna` bundle and not of a `:json` one — that is the difference between the
formats. Named here either way, because a directory being overwritten is cleared of it: the
arrays-only write refuses to publish beside a catalog whose rows would then point into the
file it just replaced.
"""
const TIME_SERIES_CATALOG_FILE = TIME_SERIES_FILE * TIME_SERIES_CATALOG_SUFFIX

"""
Whether `portfolio` has any time series, and therefore needs a sidecar written.

A portfolio with none gets no `time_series.h5` and a null `time_series_storage_file`, rather
than an empty HDF5 file that would imply the data went missing.
"""
has_time_series_data(portfolio::Portfolio) = !iszero(IS.get_num_time_series(portfolio.data))

# PSY's `to_file` takes `power_units::Symbol` (`:component_base`/`:natural_units`), decoupled from
# the IS unit-system markers PSIP's public `to_file` accepts (`DU`/`NU`). Map at the boundary.
_base_system_power_units(::DeviceBaseUnit) = :component_base
_base_system_power_units(::NaturalUnit) = :natural_units
_base_system_power_units(u::IS.AbstractUnitSystem) = error(
    "base_system_units=$(u) is not exportable for the base system; use DU (component base) " *
    "or NU (natural units)",
)

"""
Clear the paths a write is about to publish, or refuse the write.

The catalog is listed even though neither document form writes one: an arrays-only write must
not publish beside a catalog left by an earlier archive-shaped write, whose rows would then
point into the file it just replaced.
"""
function _prepare_write_targets(paths, force::Bool)
    for path in paths
        if isfile(path) && !force
            throw(
                IS.DataFormatError(
                    "$path already exists; pass force = true to overwrite it",
                ),
            )
        end
        # Removed rather than truncated: Hdf5TimeSeriesStorage appends to an existing file,
        # so a stale sidecar would leave orphaned series behind in the new bundle.
        if force
            rm(path; force = true)
        end
    end
    return nothing
end

"""Create `dir` when it names one; a bare filename has no parent to create."""
function _ensure_parent_dir(dir::AbstractString)
    if !isempty(dir)
        mkpath(dir)
    end
    return nothing
end


"""
$(TYPEDSIGNATURES)

Write `portfolio` to `path`. The extension of `path` chooses the form:

  - **no extension** — `path` is a directory; writes `portfolio.json` + `time_series.h5` into
    it (the sidecar only when `portfolio` has time series) plus the base system under a
    `base_system/` subdirectory, creating the directory if it is absent.
  - **`.json`** — `path` is the document itself; writes it plus a `.h5` sidecar on the same
    stem (`case.json` → `case.h5`) beside it, so several portfolios can share one directory.
  - **`$(IS.SIENNA_ARCHIVE_EXTENSION)`** — the directory form plus InfraStore's own `.sqlite`
    catalog, `Tar` + gzip'd into one file. Lossless; the document forms are not.

Any other extension is refused rather than guessed at.

`base_system_units` (`DU` default, or `NU`) is forwarded to the base system's `PSY.to_file`
and selects the basis its values are written on; it does not affect the portfolio document.
"""
function to_file(
    portfolio::Portfolio,
    path::AbstractString;
    base_system_units::IS.AbstractUnitSystem = DU,
    force::Bool = false,
    pretty::Bool = false,
)
    # The unknown-extension case is refused here, before anything dispatches on the form: a
    # `Val`-style dispatch reached first would turn a typo'd extension into a `MethodError` on
    # an internal helper instead of this message.
    ext = lowercase(splitext(path)[2])
    if ext == IS.SIENNA_ARCHIVE_EXTENSION
        _to_file_sienna(portfolio, path; force = force, pretty = pretty)
    elseif ext == ".json"
        _to_file_document(portfolio, path; base_system_units = base_system_units, force = force, pretty = pretty)
    elseif isempty(ext)
        _to_file_directory(portfolio, path; base_system_units = base_system_units, force = force, pretty = pretty)
    else
        error(
            "to_file: cannot tell from \"$path\" which form to write. Give a directory " *
            "(no extension), a .json document, or a $(IS.SIENNA_ARCHIVE_EXTENSION) archive.",
        )
    end

    return nothing
end


"""Write the directory form: both members named by convention inside `dir`."""
function _to_file_directory(
    portfolio::Portfolio,
    dir::AbstractString;
    base_system_units::IS.AbstractUnitSystem,
    force::Bool,
    pretty::Bool,
    write_catalog::Bool = false,
)
    mkpath(dir)
    _prepare_write_targets(
        (
            joinpath(dir, PORTFOLIO_DOCUMENT_FILE),
            joinpath(dir, TIME_SERIES_FILE),
            joinpath(dir, TIME_SERIES_CATALOG_FILE),
        ),
        force,
    )
    _write_bundle(
        portfolio,
        joinpath(dir, PORTFOLIO_DOCUMENT_FILE),
        _sidecar_path_for_write(portfolio, joinpath(dir, TIME_SERIES_FILE));
        force = force,
        pretty = pretty,
        write_catalog = write_catalog,
    )
    @info "Serialized Portfolio to $dir"

    base_system = get_base_system(portfolio)
    PSY.to_file(
        base_system, 
        joinpath(dir, BASE_SYSTEM_DIRECTORY); 
        power_units = _base_system_power_units(base_system_units), 
        force=force,
        pretty=pretty,
    )

    return nothing
end

"""Write the document form: the document at `path`, its sidecar beside it on the same stem."""
function _to_file_document(
    portfolio::Portfolio,
    path::AbstractString;
    base_system_units::IS.AbstractUnitSystem,
    force::Bool,
    pretty::Bool,
)
    _ensure_parent_dir(dirname(path))
    sidecar = _document_sidecar_path(path)
    _prepare_write_targets(
        (path, sidecar, sidecar * TIME_SERIES_CATALOG_SUFFIX),
        force,
    )
    _write_bundle(
        portfolio,
        path,
        _sidecar_path_for_write(portfolio, sidecar);
        force = force,
        pretty = pretty,
        write_catalog = false,
    )
    @info "Serialized Portfolio to $path"

    base_system = get_base_system(portfolio)
    PSY.to_file(
        base_system, 
        joinpath(dirname(path), BASE_SYSTEM_DIRECTORY); 
        power_units = _base_system_power_units(base_system_units), 
        force=force,
        pretty=pretty,
    )

    return nothing
end

"""
Build the document against `storage_path` and write it to `document_path`.

The one writer both document forms share: they differ only in where the two members sit, which
their callers have already resolved.
"""
function _write_bundle(
    portfolio::Portfolio,
    document_path::AbstractString,
    storage_path;
    force::Bool,
    pretty::Bool,
    write_catalog::Bool,
)
    base_system_path = joinpath(dirname(document_path), BASE_SYSTEM_DIRECTORY)
    doc = to_openapi(
        portfolio;
        base_system_path = base_system_path,
        time_series_storage_path = storage_path,
        write_catalog = write_catalog,
    )
    PD.write_document(doc, document_path; pretty = pretty, force = force)
    return nothing
end

"""The sidecar beside a `.json` document: its stem, with the HDF5 extension."""
_document_sidecar_path(path::AbstractString) = string(splitext(path)[1], ".h5")

function _to_file_sienna(
    portfolio::Portfolio,
    path::AbstractString;
    force::Bool,
    pretty::Bool,
)
    # `IS.create_sienna_archive` owns the container — the extension rule, the guards, and the
    # compression. What is PSIP's is only what goes inside it.
    IS.create_sienna_archive(path; force = force) do bundle
        # The archive keeps InfraStore's own `.sqlite` — see the format notes at the top of
        # this file for why that is what makes `:sienna` the lossless one.
        _to_file_directory(
            portfolio,
            bundle;
            base_system_units = DU,
            force = true,
            pretty = pretty,
            write_catalog = true,
        )
    end
    @info "Serialized Portfolio to $path"
    return nothing
end

"""The sidecar path a write should use, or `nothing` when `sys` has no time series to put in
one. The caller resolves *where* the sidecar goes; this decides only whether there is one."""
function _sidecar_path_for_write(portfolio::Portfolio, candidate::AbstractString)
    return _sidecar_path_for_write(Val(has_time_series_data(portfolio)), candidate)
end

_sidecar_path_for_write(::Val{false}, ::AbstractString) = nothing
_sidecar_path_for_write(::Val{true}, candidate::AbstractString) = candidate

"""
$(TYPEDSIGNATURES)

Read a `System` written by [`to_file`](@ref). The form is inferred from `path`: a directory
reads the directory form, a `.json` file reads the document form, and a
`$(IS.SIENNA_ARCHIVE_EXTENSION)` file reads the archive. Anything else is refused.

The sidecar is located by the document's own `time_series_storage_file`, resolved relative to
the directory the document sits in — so a bundle stays readable after being moved or renamed. A
document that names a sidecar which is not present errors rather than yielding a system
silently missing its time series.

Of `System`'s keywords, `time_series_read_only` and `time_series_directory` are the two that
change how the bundle is *read*. Read-only opens the sidecar in place instead of copying it to
a working location first, **and rejects every later write to the time series store** — it is an
enforced mode, not only an I/O shortcut. `name`, `description` and `frequency` name document
fields, and a value passed here outranks the document's.

`system_kwargs` pass through to the `System` being built (`time_series_in_memory`,
`time_series_directory`, `runchecks`, ...).
"""
function from_file(path::AbstractString; system_kwargs...)
    if isdir(path)
        return _from_file_directory(path; system_kwargs...)
    elseif IS.is_sienna_archive(path)
        return _from_file_sienna(path; system_kwargs...)
    elseif lowercase(splitext(path)[2]) == ".json"
        return _from_file_document(path; system_kwargs...)
    else
        throw(
            IS.DataFormatError(
                "$path is not a serialized System: expected a bundle directory, a .json " *
                "document, or a $(IS.SIENNA_ARCHIVE_EXTENSION) archive",
            ),
        )
    end
end


"""Read the directory form, whose document member is named by convention."""
function _from_file_directory(dir::AbstractString; system_kwargs...)
    document_path = joinpath(dir, PORTFOLIO_DOCUMENT_FILE)
    if !isfile(document_path)
        throw(
            IS.DataFormatError(
                "$dir is not a serialized System bundle: no $PORTFOLIO_DOCUMENT_FILE in it",
            ),
        )
    end
    return _from_file_document(document_path; system_kwargs...)
end

"""
Read a document at an explicit path, sidecar and all.

The one reader every form goes through: the document records its sidecar's basename, so the
directory the document sits in is all that is needed to find it, whichever form put it there.
"""
function _from_file_document(document_path::AbstractString; system_kwargs...)
    if !isfile(document_path)
        throw(IS.DataFormatError("$document_path is not a file"))
    end
    doc = PD.read_portfolio_document(document_path)
    dir = dirname(document_path)
    return from_openapi(
        Portfolio,
        doc,
        document_path;
        time_series_storage_path = _resolve_sidecar(doc, isempty(dir) ? "." : dir),
        system_kwargs...,
    )
end

function _from_file_sienna(path::AbstractString; system_kwargs...)
    # The extracted directory outlives this call, which `time_series_read_only = true` needs:
    # IS then opens the extracted sidecar in place rather than copying it out first.
    dir = IS.extract_sienna_archive(path)
    portfolio = _from_file_directory(dir; system_kwargs...)
    return portfolio
end

"""
Absolute path of the sidecar the document names, or `nothing` when it names none.

Errors when the document names a file that is absent: the alternative is a `System` quietly
missing every time series the document declared.
"""
function _resolve_sidecar(doc::PD.PortfolioDocument, dir::AbstractString)
    named = PD.get_time_series_storage_file(doc)
    return _resolve_sidecar(named, dir)
end

_resolve_sidecar(::Nothing, ::AbstractString) = nothing

function _resolve_sidecar(named::AbstractString, dir::AbstractString)
    path = joinpath(dir, named)
    if !isfile(path)
        throw(
            IS.DataFormatError(
                "the document names time_series_storage_file=\"$named\" but $path does " *
                "not exist — refusing to build a Portfolio missing its time series",
            ),
        )
    end
    return path
end