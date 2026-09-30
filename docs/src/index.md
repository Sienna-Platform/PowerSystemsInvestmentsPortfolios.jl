# Welcome to PowerSystemsInvestmentsPortfolios.jl

```@meta
CurrentModule = PowerSystemsInvestmentsPortfolios
```

## About

`PowerSystemsInvestmentsPortfolios.jl` (PSIP) is part of the National Laboratory of the
Rockies' [Sienna ecosystem](https://www.nlr.gov/analysis/sienna.html), an open source
framework for power systems analysis. The Sienna ecosystem can be
[found on GitHub](https://github.com/Sienna-Platform/Sienna). It contains three
applications:

  - [Sienna\\Data](https://github.com/Sienna-Platform/Sienna?tab=readme-ov-file#siennadata)
    enables efficient data input, analysis, and transformation
  - [Sienna\\Ops](https://github.com/Sienna-Platform/Sienna?tab=readme-ov-file#siennaops)
    enables system scheduling simulations by formulating and solving optimization problems
  - [Sienna\\Dyn](https://github.com/Sienna-Platform/Sienna?tab=readme-ov-file#siennadyn)
    enables system transient analysis including small signal stability and full dynamic
    simulations

`PowerSystemsInvestmentsPortfolios.jl` lives in Sienna\\Data. It is the portfolio data
model for capacity expansion modeling — the structured container that your optimization
engine reads from and writes to. Data flows from PSIP into
[`PowerSystemsInvestments.jl`](https://github.com/NREL-Sienna/PowerSystemsInvestments.jl)
(PSI), which builds and solves the capacity expansion problem. PSIP's central container is
[`Portfolio`](@ref), which holds technologies, regions, policy requirements, financial
parameters, and time series profiles that together fully describe a capacity expansion
scenario.

The main features include:

  - Comprehensive library of data structures for capacity expansion modeling, including
    supply, storage, transmission, and demand technologies.
  - Support for both zonal and nodal spatial resolution, with region types that link
    directly to existing `PowerSystems.jl` topology.
  - Optimized container for technology data and time series supporting serialization to
    portable file formats and configurable validation routines.

## How To Use This Documentation

There are five main sections containing different information:

  - **Tutorials** — Detailed walk-throughs to help you *learn* how to use
    `PowerSystemsInvestmentsPortfolios.jl`
  - **How to...** — Directions to help *guide* your work for a particular task
  - **Explanation** — Additional details and background information to help you *understand*
    `PowerSystemsInvestmentsPortfolios.jl`, its structure, and how it works behind the scenes
  - **Reference** — Technical references and API for a quick *look-up* during your work
  - **Model Library** — Technical references of the data types and their functions that
    `PowerSystemsInvestmentsPortfolios.jl` uses to model capacity expansion components

`PowerSystemsInvestmentsPortfolios.jl` strives to follow the
[Diataxis](https://diataxis.fr/) documentation framework.

!!! tip "New to PowerSystems.jl?"
    
    PSIP builds on top of `PowerSystems.jl` (PSY). If you are coming from a different
    capacity expansion tool (GenX, Switch, PLEXOS), here is the minimum you need to know:
    
      - A **System** is a container for all power grid components at a single point in time.
        Think of it as a database of buses, generators, lines, and loads.
      - A **Component** is any typed object in the System: a bus (`ACBus`), a generator
        (`ThermalStandard`, `RenewableDispatch`), a load (`PowerLoad`).
      - **Time series** in a System are hourly or sub-hourly profiles (capacity factors,
        demand) stored outside the component struct for memory efficiency.
    
    For a full introduction, see the
    [PowerSystems.jl tutorials](https://sienna-platform.github.io/PowerSystems.jl/stable/tutorials/generated_creating_system/).

!!! tip "Already familiar with PowerSystems.jl?"
    
    The mental model transfers directly: [`Portfolio`](@ref) is to PSIP what `System` is
    to PSY. Jump straight to the [Quick Start Guide](@ref "Quick Start Guide") or the
    [Tutorials](@ref "Create and Explore a Portfolio") to get started.

## Installation and Quick Links

  - [Sienna installation page](https://sienna-platform.github.io/Sienna/SiennaDocs/docs/build/how-to/install/):
    Instructions to install Sienna packages and their dependencies

To install `PowerSystemsInvestmentsPortfolios.jl` directly:

```julia
using Pkg
Pkg.add("PowerSystemsInvestmentsPortfolios")
```

!!! note
    
    `PowerSystemsInvestmentsPortfolios.jl` uses
    [`InfrastructureSystems.jl`](https://sienna-platform.github.io/InfrastructureSystems.jl/stable/)
    as a utility library. Many methods are re-exported from `InfrastructureSystems.jl`.
    For most users there is no need to import `InfrastructureSystems.jl` directly.

  - [Central Sienna documentation](https://sienna-platform.github.io/Sienna/SiennaDocs/docs/build/index.html):
    Cross-linked documentation website for the core user-facing Sienna packages
