# A serialized Portfolio is written as one of three forms, chosen by the extension of the path
# given to `to_file` — there is no `format` keyword. Each form is a portfolio document, its
# time series sidecar, and the base `PSY.System` written by PowerSystems' own `to_file`:
#
#   - `case`         a directory
#
#                        case/
#                          portfolio.json      the OpenAPI document for the portfolio
#                          time_series.h5      the InfraStore arrays
#                          base_system/        PSY's directory form
#                            system.json
#                            time_series.h5
#
#   - `case.json`    the document itself, everything else beside it on the same stem
#
#                        case.json                 the OpenAPI document
#                        case.h5                   the InfraStore arrays
#                        case_base_system.json     PSY's document form
#                        case_base_system.h5
#
#                    Every member takes the document's stem, so several portfolios can share
#                    one directory; the document records only basenames, so the set moves
#                    together.
#
#   - `case.snp`     a flat Sienna archive (IS's container, PSIP's extension)
#
#                        case.snp
#                          portfolio.json
#                          time_series.h5
#                          time_series.h5.sqlite   InfraStore's own catalog
#                          base_system.sns         PSY's own lossless archive, as one member
#
#                    The archive is flat — `IS.create_sienna_archive` zips only the top level
#                    of its staging directory — so the base system rides as PSY's single-file
#                    `.sns` rather than as a subdirectory.
#
# The archive's extra members are the difference between the forms, and the `.sqlite` one is a
# difference about **where the association tables live** rather than about compression:
#
#   `.snp` keeps InfraStore's `.sqlite`, so the store is restored from its own tables, and its
#   base system is PSY's `.sns`, which keeps what PSY's document forms lose (subsystems). It is
#   the lossless native form, and it is Sienna-only.
#
#   The two document forms write the arrays alone and record the associations in the document's
#   own `time_series_associations` table, which `from_openapi` replays into a freshly minted
#   catalog. That is what makes them readable by any non-Julia client, and it bounds them by
#   what the wire form can express.
#
# `to_openapi(portfolio; write_catalog)` is the knob.

"""
Extension of a serialized Portfolio archive. `.sns` is PowerSystems'; a portfolio uses the same
IS container under its own extension so the two are never confused on read.
"""
const PORTFOLIO_ARCHIVE_EXTENSION = ".snp"

"""
Document member of a serialized Portfolio directory or archive.
"""
const PORTFOLIO_DOCUMENT_FILE = "portfolio.json"

"""
Base System member of a serialized Portfolio directory (PSY's directory form).
"""
const BASE_SYSTEM_DIRECTORY = "base_system"

"""
Base System member of a serialized Portfolio archive (PSY's `.sns` archive form).
"""
const BASE_SYSTEM_ARCHIVE_FILE = "base_system" * PSY.SYSTEM_ARCHIVE_EXTENSION

"""
Suffix the `.json` form gives its base system document: `case.json` → `case_base_system.json`.
"""
const BASE_SYSTEM_DOCUMENT_SUFFIX = "_base_system.json"

"""
HDF5 sidecar member of a serialized Portfolio directory or archive.
"""
const TIME_SERIES_FILE = "time_series.h5"

"""
Suffix InfraStore gives its catalog: the sidecar's own name plus this. Named once so the
document forms, which name their sidecar after the document, derive the same path.
"""
const TIME_SERIES_CATALOG_SUFFIX = ".sqlite"

"""
Whether `portfolio` has any time series, and therefore needs a sidecar written.

A portfolio with none gets no `time_series.h5` and a null `time_series_storage_file`, rather
than an empty HDF5 file that would imply the data went missing.
"""
has_time_series_data(portfolio::Portfolio) = !iszero(IS.get_num_time_series(portfolio.data))

"""
$(TYPEDSIGNATURES)

Write `portfolio` to `path`. The extension of `path` chooses the form:

  - **no extension** — `path` is a directory; writes `portfolio.json` + `time_series.h5` into
    it (the sidecar only when `portfolio` has time series) plus the base system in PSY's
    directory form under `base_system/`, creating the directory if it is absent.
  - **`.json`** — `path` is the document itself; writes it plus a `.h5` sidecar and the base
    system's `_base_system.json` document on the same stem (`case.json` → `case.h5`,
    `case_base_system.json`), so several portfolios can share one directory.
  - **`.snp`** — the document, the sidecar, InfraStore's own `.sqlite` catalog and the base
    system as PSY's `.sns` archive, zipped flat into one file. Lossless; the document forms
    are not.

Any other extension is refused rather than guessed at.

`base_system_units` (`CU` default, or `NU`) is forwarded to the base system's `PSY.to_file` as
its `units` and selects the basis its values are written on; it does not affect the portfolio
document, whose values are always natural units. An `.snp` archive writes its base system on
`CU` only, as PSY's `.sns` does.
"""
function to_file(
    portfolio::Portfolio,
    path::AbstractString;
    base_system_units::IS.AbstractUnitSystem=CU,
    force::Bool=false,
    pretty::Bool=false,
)
    # The unknown-extension case is refused here, before anything dispatches on the form: a
    # `Val`-style dispatch reached first would turn a typo'd extension into a `MethodError` on
    # an internal helper instead of this message.
    ext = lowercase(splitext(path)[2])
    if ext == PORTFOLIO_ARCHIVE_EXTENSION
        # IS owns the container (write guards, compression); PSIP supplies the extension and
        # what goes inside.
        IS.create_sienna_archive(path, PORTFOLIO_ARCHIVE_EXTENSION; force=force) do bundle
            _write_bundle(
                portfolio,
                joinpath(bundle, PORTFOLIO_DOCUMENT_FILE),
                joinpath(bundle, TIME_SERIES_FILE),
                joinpath(bundle, BASE_SYSTEM_ARCHIVE_FILE);
                base_system_units=base_system_units,
                force=true,
                pretty=pretty,
                write_catalog=true,
            )
        end
    elseif ext == ".json"
        stem = splitext(path)[1]
        _write_bundle(
            portfolio,
            path,
            stem * ".h5",
            stem * BASE_SYSTEM_DOCUMENT_SUFFIX;
            base_system_units=base_system_units,
            force=force,
            pretty=pretty,
            write_catalog=false,
        )
    elseif isempty(ext)
        _write_bundle(
            portfolio,
            joinpath(path, PORTFOLIO_DOCUMENT_FILE),
            joinpath(path, TIME_SERIES_FILE),
            joinpath(path, BASE_SYSTEM_DIRECTORY);
            base_system_units=base_system_units,
            force=force,
            pretty=pretty,
            write_catalog=false,
        )
    else
        error(
            "to_file: cannot tell from \"$path\" which form to write. Give a directory " *
            "(no extension), a .json document, or a $(PORTFOLIO_ARCHIVE_EXTENSION) archive.",
        )
    end
    @info "Serialized Portfolio to $path"
    return nothing
end

"""
Write the base system to `base_system_path`, the document to `document_path` and, when
`portfolio` has time series, its sidecar at `sidecar_path` — the one writer every form goes
through.

Every path is a direct child of the document's directory, so the document records each by
basename and the bundle stays readable after being moved.

Refuses to replace an existing file unless `force`. The catalog beside the sidecar is cleared
too even when this write produces none: its rows would otherwise point into the sidecar this
write replaces. Files are removed rather than truncated because `Hdf5TimeSeriesStorage`
appends to an existing file, which would leave orphaned series in the new bundle.

The base system goes first so a refused or failed base-system write leaves no portfolio
document behind that names it.
"""
function _write_bundle(
    portfolio::Portfolio,
    document_path::AbstractString,
    sidecar_path::AbstractString,
    base_system_path::AbstractString;
    base_system_units::IS.AbstractUnitSystem,
    force::Bool,
    pretty::Bool,
    write_catalog::Bool,
)
    dir = dirname(document_path)
    if !isempty(dir)
        mkpath(dir)
    end
    for target in (document_path, sidecar_path, sidecar_path * TIME_SERIES_CATALOG_SUFFIX)
        if isfile(target) && !force
            throw(
                IS.DataFormatError(
                    "$target already exists; pass force = true to overwrite it",
                ),
            )
        end
        rm(target; force=true)
    end
    PSY.to_file(
        get_base_system(portfolio),
        base_system_path;
        units=base_system_units,
        force=force,
        pretty=pretty,
    )
    # No sidecar at all for a Portfolio without time series, rather than an empty HDF5 file
    # that would suggest the data went missing.
    storage_path = nothing
    if has_time_series_data(portfolio)
        storage_path = sidecar_path
    end
    doc = to_openapi(
        portfolio;
        base_system_path=base_system_path,
        time_series_storage_path=storage_path,
        write_catalog=write_catalog,
    )
    PD.write_document(doc, document_path; pretty=pretty, force=force)
    return nothing
end

"""
$(TYPEDSIGNATURES)

Read a `Portfolio` written by [`to_file`](@ref). The extension of `path` chooses the form,
exactly as it does for `to_file`: no extension reads a bundle directory, `.json` a document,
and `.snp` an archive. Anything else is refused.

The sidecar and the base system are located by the document's own `time_series_storage_file`
and `base_system_file`, resolved relative to the directory the document sits in — so a bundle
stays readable after being moved or renamed. A document that names a sidecar or base system
which is not present errors rather than yielding a portfolio silently missing it.

Of the keywords, `time_series_read_only` and `time_series_directory` are the two that change
how the bundle is *read*, and both are forwarded to the base system's `PSY.from_file` as well.
Read-only opens the sidecar in place instead of copying it to a working location first, **and
rejects every later write to the time series store** — it is an enforced mode, not only an I/O
shortcut. `name` and `description` name document fields, and a value passed here outranks the
document's.

`portfolio_kwargs` pass through to the `Portfolio` being built (`time_series_in_memory`,
`time_series_directory`, ...).
"""
function from_file(path::AbstractString; portfolio_kwargs...)
    ext = lowercase(splitext(path)[2])
    if ext == PORTFOLIO_ARCHIVE_EXTENSION
        return _from_archive(path; portfolio_kwargs...)
    elseif ext == ".json"
        return _read_bundle(path; portfolio_kwargs...)
    elseif isempty(ext)
        return _read_bundle(joinpath(path, PORTFOLIO_DOCUMENT_FILE); portfolio_kwargs...)
    else
        throw(
            IS.DataFormatError(
                "from_file: cannot tell from \"$path\" which form to read. Give a bundle " *
                "directory (no extension), a .json document, or a " *
                "$(PORTFOLIO_ARCHIVE_EXTENSION) archive.",
            ),
        )
    end
end

"""
Unzip the archive under `time_series_directory` (so `/tmp` need not fit the `.h5`) and read it.

A read-only store opens the extracted sidecar in place, so the extraction outlives this call
and only the consumed members are removed here; otherwise the store has taken its own copy and
the whole extraction is removed.
"""
function _from_archive(path::AbstractString; portfolio_kwargs...)
    if !isfile(path)
        throw(
            IS.DataFormatError(
                "$path is not a $(PORTFOLIO_ARCHIVE_EXTENSION) archive file",
            ),
        )
    end
    tsdir = something(
        get(portfolio_kwargs, :time_series_directory, nothing),
        get(ENV, IS.TIME_SERIES_DIRECTORY_ENV_VAR, tempdir()),
    )
    mkpath(tsdir)
    if !get(portfolio_kwargs, :time_series_read_only, false)
        return mktempdir(dir -> _read_archive(path, dir; portfolio_kwargs...), tsdir)
    end
    dir = mktempdir(tsdir)
    portfolio = try
        _read_archive(path, dir; portfolio_kwargs...)
    catch
        rm(dir; recursive=true, force=true)
        rethrow()
    end
    for consumed in (PORTFOLIO_DOCUMENT_FILE, BASE_SYSTEM_ARCHIVE_FILE)
        rm(joinpath(dir, consumed); force=true)
    end
    return portfolio
end

function _read_archive(path::AbstractString, dir::AbstractString; portfolio_kwargs...)
    IS.extract_sienna_archive(path; directory=dir)
    return _read_bundle(joinpath(dir, PORTFOLIO_DOCUMENT_FILE); portfolio_kwargs...)
end

"""
Read the document at `document_path`, adopting the sidecar and base system it names from
beside it — the one reader every form goes through.
"""
function _read_bundle(document_path::AbstractString; portfolio_kwargs...)
    if !isfile(document_path)
        throw(IS.DataFormatError("$document_path is not a serialized Portfolio document"))
    end
    doc = PD.read_portfolio_document(document_path)
    dir = dirname(document_path)
    if isempty(dir)
        dir = "."
    end
    return from_openapi(
        Portfolio,
        doc,
        document_path;
        time_series_storage_path=_resolve_sidecar(doc, dir),
        portfolio_kwargs...,
    )
end

"""
Absolute path of the sidecar the document names, or `nothing` when it names none.

Errors when the document names a file that is absent: the alternative is a `Portfolio` quietly
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
