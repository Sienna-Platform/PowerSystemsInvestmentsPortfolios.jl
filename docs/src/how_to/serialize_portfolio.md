```@meta
CurrentModule = PowerSystemsInvestmentsPortfolios
```

# Save and Load a Portfolio

[`to_file`](@ref) writes a [`Portfolio`](@ref) — its technologies, requirements,
supplemental attributes, time series, and base system — to disk, and [`from_file`](@ref)
reads it back. The extension of the path chooses the form. Neither function is exported, so
call them through the module:

```julia
import PowerSystemsInvestmentsPortfolios as PSIP

PSIP.to_file(portfolio, "data/case")          # a directory bundle
PSIP.to_file(portfolio, "data/case.json")     # a JSON document with files beside it
PSIP.to_file(portfolio, "data/case.snp")      # a single-file archive

portfolio = PSIP.from_file("data/case")
```

## Choose a form

| Path             | Writes                                                                 | Use it to                                |
|:---------------- |:---------------------------------------------------------------------- |:---------------------------------------- |
| `case` (no ext.) | `case/portfolio.json`, `case/time_series.h5`, `case/base_system/`      | Keep one portfolio per directory         |
| `case.json`      | `case.json`, `case.h5`, `case_base_system.json`, `case_base_system.h5` | Keep several portfolios in one directory |
| `case.snp`       | One zip archive with the document, time series, and base system        | Move or share a portfolio as one file    |

The `portfolio.json` document follows the PowerSystemsInvestments OpenAPI schema, so the
directory and `.json` forms can be read by tools outside Julia. The `.snp` archive also keeps
the time series catalog and the base system's own archive, so it is the lossless form.

A portfolio without time series is written without a `.h5` file.

## Options

  - `force=true` overwrites files that already exist; without it, `to_file` refuses.
  - `pretty=true` indents the JSON document.
  - `base_system_units` selects the units the base system is written in: `CU` (the
    default) or `NU`. The portfolio document is always in natural units.

```julia
PSIP.to_file(portfolio, "data/case.json"; force=true, pretty=true)
```

When reading, `time_series_read_only=true` opens the time series file in place instead of
copying it, and rejects later writes to the time series.

## What is stored

  - **Technologies and requirements** — every field, and which requirements each
    technology contributes to
  - **Topology and existing data** — the base system, written by PowerSystems' own `to_file`
  - **Supplemental attributes** — `ExistingDevices`, `RetirementPotential`,
    `RetrofitPotential`, and their attachments
  - **Time series** — stored in HDF5 beside the document, never inside it
  - **Metadata and financial data** — name, description, and `PortfolioFinancialData`

The parts of a [`ColocatedSupplyStorageTechnology`](@ref) are written as ordinary
technologies and are masked again when the file is read.

## See also

  - [`to_file`](@ref)
  - [`from_file`](@ref)
  - [Migrate to the PowerSystems 6 data model](@ref)
