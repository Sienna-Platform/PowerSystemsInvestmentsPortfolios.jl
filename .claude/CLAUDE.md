# PowerSystemsInvestmentsPortfolios.jl — Claude Guide

Platform-wide Sienna conventions (performance, type stability, formatter, environments, code style) live in the `sienna-psy6` skill — invoke it. This file is repo-specific and does not restate them.

## Purpose & place in the stack

This is a **data package** — the data-model layer for power-systems capacity-expansion / investment modeling. It defines the `Portfolio` data container and the component/technology data structures that `PowerSystemsInvestments.jl` consumes to build optimization models. It is analogous to `PowerSystems.jl`: it holds, validates, serializes, and parses data; it does **not** build JuMP models. There is therefore no optimization-model layer here.

Dependency facts verified in `Project.toml`:

- Builds on **InfrastructureSystems.jl** (`^3.1`) — `Portfolio`, `PortfolioMetadata`, `PortfolioFinancialData`, and the technology abstract types all subtype `IS.InfrastructureSystemsType` / `IS.InfrastructureSystemsComponent`. The container stores an `IS.SystemData` and an `IS.InfrastructureSystemsInternal`.
- Builds on **PowerSystems.jl** (`^5.3`) — aliased `const PSY`. The `Portfolio` wraps a base `PSY.System`, generated technology structs are parameterized on PSY types (e.g. `SupplyTechnology{T <: PSY.Generator}`), and PSY is `using`-imported so PSY parametric types deserialize correctly. `ThermalFuels`, `PrimeMovers`, `StorageTech` are re-exported from PSY.
- Builds on **`PowerCoreOpenAPIModels` / `PowerInvestmentsOpenAPIModels`** — the platform OpenAPI transport structs, aliased `PC` / `PI`. Path deps on the sibling `PowerOpenAPIModels` monorepo via `[sources]`; they replaced the tree PSIP used to vendor.
- Other deps: SQLite/DBInterface/DataFrames (the database parser), JSON3/JSONSchema/OpenAPI/Mustache (struct generation + serialization), TimeSeries/TimeZones (time series).

## Architecture & `src/` layout

Module file `src/PowerSystemsInvestmentsPortfolios.jl` defines all exports and fixes include order — respect it when adding definitions. Key files:

- `definitions.jl` — module-wide constants/enums.
- `models/technologies.jl` — abstract type tree: `Technology <: IS.InfrastructureSystemsComponent`, with `ResourceTechnology`, `TransmissionTechnology`, `DemandTechnology <: Technology`, plus shared `get_*` accessors on `Technology`.
- `models/regions.jl` (`RegionTopology`), `models/requirements.jl` (`Requirement`), `models/financial_data/` (`PortfolioFinancialData`, `TechnologyFinancialData`).
- `models/generated/` — **auto-generated** concrete technology/requirement structs (see below). `includes.jl` (also generated) `include`s every struct file and exports its accessors/setters.
- `investment_schedule.jl` — `InvestmentScheduleResults` (model-output container held by a `Portfolio`).
- `portfolio.jl` — the `Portfolio` mutable struct and its constructors/accessors. Fields: `aggregation`, `data::IS.SystemData`, `base_system::PSY.System`, `investment_schedule`, `time_series_directory`, `financial_data`, `metadata`, `internal`.
- `time_mapping.jl` — `TimeMapping`, `InvestmentIntervals`, `OperationalPeriods` for investment/operational period structure.
- `serialization.jl` — `IS.serialize` / `deserialize` for `Portfolio` and `InvestmentScheduleResults`, plus `to_json` / `from_json` round-trips. Drives each component through the generated `to_openapi` / `from_openapi` pair and renders with `OpenAPI.to_json`, which is what unwraps the `oneOf` wrappers and stamps their discriminators.
- `openapi/` — the serde support layer, included in this order: `refs.jl` (`OpenAPIRefs`, the id⇄component registry for one conversion pass, plus the empty `from_openapi` / `to_openapi` generics — **must precede `models/generated/includes.jl`**), `converters.jl` (hand-written value converters both directions: curves, operational costs, financial data, compound `MinMax`/`UpDown`/`InOut` constructors), then after `portfolio.jl`: `document.jl` (`DOCUMENT_PLAN` and `SUPPLEMENTAL_ATTRIBUTE_PLAN`, the dependency-ordered type lists both directions share, plus `_build_export_refs`). There is no id⇄UUID ledger: identity is the component's own integer `id`, and `_adopt_domain_id!` (portfolio.jl) makes that the id `IS.SystemData` stores it under, so a document id, a container id, and a supplemental-attribute association row all name the same number.
- `db_parser.jl` — `database_to_portfolio` reads a SiennaGridDB-style SQLite DB (the `QUERIES` and `DB_TO_OPENAPI_FIELDS` maps) into a `Portfolio`.
- `update_system.jl` — `update_system_with_nodal_results!` writes investment results back onto a `PSY.System`.
- `utils/getters.jl`, `utils/print.jl` — shared accessors and `show` formatting.

## Auto-generated structs — do NOT hand-edit

There is **one** generated layer in this repo. PSIP used to vendor a second — an OpenAPI-generator tree under `src/models/generated/open_api_models/`, reached through `APIServer.jl` — and that tree is **gone**. Its transport structs now come from two platform packages, `PowerCoreOpenAPIModels` and `PowerInvestmentsOpenAPIModels` (path deps declared in `[sources]`), aliased `PC` and `PI` in the module file. They are generated in the `PowerOpenAPIModels` monorepo, not here; do not vendor them back.

**Component structs** in `src/models/generated/*.jl` (e.g. `SupplyTechnology.jl`, `StorageTechnology.jl`, `Node.jl`, `Zone.jl`, requirements) — 23 files plus `includes.jl`. Each begins with `#= This file is auto-generated. Do not edit. =#` and `#! format: off`. Produced by the **`StructGeneration` submodule** in `src/utils/generate_structs.jl` — self-contained (own explicit imports: `JSON3`, `JSONSchema`, `Mustache`, `InfrastructureSystems: DataFormatError`; no dependency on PSIP's own types) and **not exported**. Its `generate_invest_structs` reads the JSONSchema spec via `read_json_data`, then renders `STRUCT_TEMPLATE` with Mustache and regenerates `includes.jl`.

Each generated file carries, besides the struct and its accessors/setters, a **`from_openapi(::Type{X}, po, refs)` / `to_openapi(value::X, refs)` pair** targeting the platform `PI.X` transport struct — the shape PowerSystems.jl uses, minus PSY's `Val{:COMPONENT_BASE}` / `Val{:NATURAL_UNITS}` axis, because PSIP has exactly one unit representation and therefore emits two methods per type and takes no `Val`. The generator classifies every descriptor field into one of twelve kinds (`openapi_classify_field`) and both direction drivers throw `DataFormatError` on a kind they were not taught — classification and emission both fail loudly rather than guessing.

Parametric types are **generated, not hand-written** (PSY hand-writes its few; 8 of PSIP's 23 are parametric). `power_systems_type::String` is the single carrier of the type parameter: `from_openapi` resolves `getproperty(PowerSystems, Symbol(po.power_systems_type))`, and `to_openapi` regenerates the string as `string(nameof(T))`. Never set `power_systems_type` to anything but a real PowerSystems type name — a literal that disagrees with the type parameter is drift the old serializer tolerated and this one rejects.

Regenerate from the REPL with the qualified entry point, then run the formatter:

```sh
julia --project=. -e 'using PowerSystemsInvestmentsPortfolios; PowerSystemsInvestmentsPortfolios.StructGeneration.generate_structs("src/descriptors/SiennaInvestSchema.json", "src/models/generated")'
julia --project=scripts/formatter -e 'include("scripts/formatter/formatter_code.jl")'
```

`StructGeneration` is never `include`d or called unqualified. The spec (`src/descriptors/SiennaInvestSchema.json`) is the single source of truth: to change a generated component's fields/defaults/docstring, edit the spec and rerun generation; never patch the output file. Defaults are copied through **verbatim as Julia source**, so a Python literal in the spec (`True`, `False`, `None`) becomes an `UndefVarError` in the generated constructor — write `true`/`false`/`nothing`. New abstract supertypes, hand-written accessors, and dispatch logic belong in the non-generated `models/*.jl` files; new value converters belong in `src/openapi/converters.jl`.

`test/test_openapi_parity.jl` guards descriptor⇄platform-model field parity, and `test/test_openapi_converters.jl` asserts every generated type has both converters and that each parametric `where` bound matches the descriptor's `parametric` key. Run both after any regeneration.

## Main public API

The export list in `src/PowerSystemsInvestmentsPortfolios.jl` is authoritative. `Portfolio` is the
container (the analogue of PSY's `System`); technology types are concrete and **generated**.

## Conventions & gotchas

- Exports are centralized in the module file; generated accessors/setters are exported from the generated `includes.jl`. Add new exports in the right place per include order.
- Use `get_*` accessors, not dot access, in user-facing code (see the `sienna-psy6` skill / global prefs). Note the explicit `# TODO` in the module file warning that some IS re-exports may collide with PowerSystems names — be careful adding re-exports.
- Several existing fields use `Union{Nothing, T}` (e.g. `investment_schedule`, `financial_data`, metadata fields). This predates the prefer-predicate guidance; do not propagate the pattern into new code, and prefer a `Bool` predicate + concrete accessor for new optional values.

## Cross-package coupling

- Upstream: `InfrastructureSystems` (container, internals, time series), `PowerSystems` (base system, parametric technology types), and the two OpenAPI model packages (transport structs). The struct template is PSIP's own, in `src/utils/generate_structs.jl`. Changes to PSY type names ripple into the generated structs' type parameters; changes to the platform models ripple into `to_openapi`'s return types and are caught by `test/test_openapi_parity.jl`.
- Downstream: `PowerSystemsInvestments.jl` consumes `Portfolio` and the technology/requirement structs to build optimization models. Renaming or removing an exported accessor/struct is a breaking change there — consider its impact before editing the API or the spec.

## Running tests, docs, formatter (verified commands)

```sh
# Formatter (run before reporting any task done; self-activates its own env)
julia --project=scripts/formatter -e 'include("scripts/formatter/formatter_code.jl")'

# Full test suite (ReTest runner: runtests.jl includes the test module, which auto-includes
# every test/test_*.jl, then calls run_tests() -> retest())
julia --project=test test/runtests.jl

# Single testset / pattern (ReTest filters by name, not by file)
julia --project=test -e 'using Pkg; Pkg.instantiate()'   # first time / when deps are missing
# then run runtests.jl and rely on ReTest pattern filtering inside run_tests

# Docs
julia --project=docs docs/make.jl
```

Test notes: the runner uses **ReTest** (`run_tests()` calls `retest()`), pulls test data from the `CaseData` artifact in `test/Artifacts.toml`, and runs Aqua checks (unbound args, undefined exports, ambiguities, stale/compat deps) at module load. Test deps live in `test/Project.toml`; always use `--project=test`. Uses `PowerSystemCaseBuilder` — mind shared cached-system state (don't mutate a cached system without `deepcopy`).
