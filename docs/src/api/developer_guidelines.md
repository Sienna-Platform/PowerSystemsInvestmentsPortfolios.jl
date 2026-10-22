```@meta
CurrentModule = PowerSystemsInvestmentsPortfolios
```

# Developer Guidelines

## Auto-generated files

The files under `src/models/generated/` are generated from the descriptor
`src/descriptors/SiennaInvestSchema.json`. **Never edit them directly.** To add or modify a
type:

 1. Edit its entry in `src/descriptors/SiennaInvestSchema.json`. A field with
    `"needs_conversion": true` and a `"conversion_unit"` token (e.g. `":mw"`, `":min"`,
    `":usd_per_mwh"`) gets units-aware getters and setters.
 2. Regenerate from the REPL:
    `PowerSystemsInvestmentsPortfolios.StructGeneration.generate_structs("src/descriptors/SiennaInvestSchema.json", "src/models/generated")`.
 3. Review the generated file and commit both the descriptor and the generated file.

## Serialization

A portfolio is written as a document of the PowerSystemsInvestments OpenAPI schema, whose
Julia models come from the registered `PowerInvestmentsOpenAPIModels`,
`PowerCoreOpenAPIModels`, and related packages. The conversion lives in `src/openapi/`:

  - `export_document.jl` — `to_openapi`, a `Portfolio` to an OpenAPI document
  - `import_document.jl` — `from_openapi`, an OpenAPI document to a `Portfolio`
  - `cost_conversion.jl`, `export_cost_conversion.jl` — cost curves in both directions
  - `file_io.jl` — [`to_file`](@ref) and [`from_file`](@ref)

A new type or field needs a mapping in both directions.

## Adding a new Technology type

 1. **Define the descriptor** entry in `src/descriptors/SiennaInvestSchema.json`, following
    an existing technology such as `SupplyTechnology`.
 2. **Regenerate** with `StructGeneration.generate_structs`.
 3. **Add validation** (`validate_technology`) in `src/validation.jl` if the type has rules.
 4. **Add the OpenAPI conversion** in `src/openapi/`.
 5. **Add tests** in `test/` covering construction, `add_technology!`, `get_technology`, and
    a `to_file` → `from_file` round trip; add the type to `test/portfolio_5bus.jl`.
 6. **Add it to the docs**: a model library page in `docs/src/model_library/` wired into
    `docs/make.jl`, and a how-to if it needs one.

## Coding style

Follow the [Sienna development conventions](https://sienna-platform.github.io/Sienna/SiennaDocs/docs/build/index.html):

  - Do not use `isa` for type checks — use multiple dispatch instead.
  - Do not access component fields with `.` notation — always use `get_*` accessor functions.
  - Do not use ternary expressions in public-facing code.
  - Keep functions short and single-purpose; prefer explicit over clever.

## Running tests

```bash
julia --project=test test/runtests.jl
```

The test suite uses `build_portfolio()` in `test/portfolio_5bus.jl` as the main test
portfolio. When adding a new type, add an instance of it there.

## Building the documentation

```bash
julia --project=docs -e 'using Pkg; Pkg.develop(PackageSpec(path=pwd())); Pkg.instantiate()'
julia --project=docs docs/make.jl
```
