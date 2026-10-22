```@meta
CurrentModule = PowerSystemsInvestmentsPortfolios
```

# The Sienna Stack

`PowerSystemsInvestmentsPortfolios.jl` is one package in a layered stack of Sienna
packages. Understanding where PSIP sits in that stack helps clarify what each package is
responsible for and which one to reach for at each stage of a capacity expansion workflow.

## Package layers

| Layer                     | Package                                                                                   | Role                                                                   |
|:------------------------- |:----------------------------------------------------------------------------------------- |:---------------------------------------------------------------------- |
| Data infrastructure       | [`InfrastructureSystems.jl`](https://github.com/NREL-Sienna/InfrastructureSystems.jl)     | Shared component framework, time series storage, serialization         |
| Grid snapshots            | [`PowerSystems.jl`](https://sienna-platform.github.io/PowerSystems.jl/stable/)            | Buses, generators, loads, lines — steady-state grid data               |
| **Investment portfolios** | **`PowerSystemsInvestmentsPortfolios.jl`**                                                | **Technologies, regions, requirements, financial data — this package** |
| Investment optimization   | [`PowerSystemsInvestments.jl`](https://github.com/NREL-Sienna/PowerSystemsInvestments.jl) | Builds and solves capacity expansion models from a `Portfolio`         |
| File format               | `PowerInvestmentsOpenAPIModels.jl`                                                        | OpenAPI models of the document [`to_file`](@ref) writes                |

## Data flow

A typical capacity expansion workflow moves data through the stack in order:

 1. **`InfrastructureSystems.jl`** provides the underlying component and time series
    infrastructure. Both PSY and PSIP build on top of it; most users never interact with it
    directly.
 2. **`PowerSystems.jl`** holds the existing grid snapshot — buses, existing generators,
    loads, and transmission lines, along with the topology (areas, load zones, buses) that
    technologies are located in. A [`Portfolio`](@ref) always references a `PSY.System` as
    its `base_system`.
 3. **`PowerSystemsInvestmentsPortfolios.jl`** (this package) adds the investment layer:
    technology candidates, policy requirements, financial data, and time series profiles
    for the investment horizon.
 4. **`PowerSystemsInvestments.jl`** reads the `Portfolio` and builds the optimization
    model. After solving, investment decisions are written back into the `Portfolio`'s
    `investment_schedule` field.

## See Also

  - [`Portfolio`](@ref)
  - [PowerSystems.jl documentation](https://sienna-platform.github.io/PowerSystems.jl/stable/)
  - [PowerSystemsInvestments.jl](https://github.com/NREL-Sienna/PowerSystemsInvestments.jl)
