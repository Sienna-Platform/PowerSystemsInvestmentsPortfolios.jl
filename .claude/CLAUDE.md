# PowerSystemsInvestmentsPortfolios.jl — Claude Guide

Platform-wide Sienna conventions (performance, type stability, formatter, environments, code style) live in the `sienna-psy6` skill — invoke it when it is installed. This file is repo-specific and does not restate them.

## Purpose & place in the stack

This is a **data package** — the data-model layer for power-systems capacity-expansion / investment modeling. It defines the `Portfolio` data container and the component/technology data structures that `PowerSystemsInvestments.jl` consumes to build optimization models. It is analogous to `PowerSystems.jl`: it holds, validates, serializes, and parses data; it does **not** build JuMP models. There is therefore no optimization-model layer here.

Dependency facts verified in `Project.toml` (this is the psy6 line — the two Sienna packages still developed on a branch, IS and PSY, are pinned through `[sources]`; everything else resolves from the General registry):

- Builds on **InfrastructureSystems.jl** (`IS4` branch) — `Portfolio`, `PortfolioFinancialData`, and the technology abstract types subtype `IS.InfrastructureSystemsType` / `IS.InfrastructureSystemsComponent`. The container stores an `IS.SystemData` and an `IS.InfrastructureSystemsInternal`. IS also owns the Sienna archive container (`IS.create_sienna_archive` / `IS.extract_sienna_archive`) and the InfraStore time-series store.
- Builds on **PowerSystems.jl** (`psy6` branch) — aliased `const PSY`. The `Portfolio` wraps a base `PSY.System`, generated technology structs are parameterized on PSY types (e.g. `SupplyTechnology{T <: PSY.Generator}`), and PSY is `using`-imported so PSY parametric types resolve by name. `ThermalFuels`, `PrimeMovers`, `StorageTech`, every `PSY.Topology` type (`Topology`, `AggregationTopology`, `Area`, `LoadZone`, `Arc`, `Bus`, `ACBus`, `DCBus`), what constructing them needs (`PerUnit` — the unit module behind `u"CU"`/`u"NU"` — and `ACBusTypes`), and the `CU`/`NU` markers `to_file` takes (`SU` deliberately not, since PSIP has no system-base representation) are re-exported from PSY — the same bindings, so `using` both packages does not clash. `test_portfolio.jl` walks the `Topology` type tree, so a topology type PSY adds later fails the suite until it is re-exported here too.
- Builds on the **platform OpenAPI model packages** (registered, `0.2`, generated from SiennaSchemas 0.2 in the `PowerOpenAPIModels` monorepo): `PowerInvestmentsOpenAPIModels` (`PI` — the investment transport structs **and** `PortfolioDocument` / `read_portfolio_document`; the generic document API — `write_document`, `validate_document`, `add_component!`, `reserve_ids!`, schema-version checks — is defined in `IC` and reachable as `PI.x`), `PowerCoreOpenAPIModels` (`PC` — shared value types: curves, costs, enums, `MinMax`), `InfrastructureCoreOpenAPIModels` (`IC` — `Absent`, `OneOfAPIModel`, `encode`, `SchemaVersionError`), and `InfrastructureTimeSeriesOpenAPIModels` (`PTS`). PSIP does **not** depend on the umbrella `PowerOpenAPIModels` package: since 0.2 the documents live with their domain (`SystemDocument` in `PC`, `PortfolioDocument` in `PI`), and the old `PD` alias is gone. Do not re-add the umbrella, or the Dynamics/Operations packages, as dependencies — they were only ever listed to carry `[sources]` pins.
- Other deps: SQLite/DBInterface/DataFrames (the database parser), JSON/JSON3/JSONSchema/OpenAPI/Mustache (struct generation + serialization), TimeSeries/TimeZones (time series).

## Architecture & `src/` layout

Module file `src/PowerSystemsInvestmentsPortfolios.jl` defines all exports and fixes include order — respect it when adding definitions. Key files:

- `definitions.jl` — module-wide constants/enums.
- `models/technologies.jl` — abstract type tree: `Technology <: IS.InfrastructureSystemsComponent`, with `ResourceTechnology`, `TransmissionTechnology`, `DemandTechnology <: Technology`, plus shared `get_*` accessors on `Technology`.
- `models/regions.jl` — topology is plain `PSY.Topology` (areas, load zones, buses, arcs) living in the base system; the old PSIP-local `RegionTopology`/`Zone`/`Node` types are gone. `models/requirements.jl` (`Requirement`), `models/financial_data/` (`PortfolioFinancialData`, `TechnologyFinancialData`), `models/cost_functions/` (`CapitalCost`, `StorageCapitalCost`).
- `models/generated/` — **auto-generated** concrete technology/requirement/supplemental-attribute structs (see below). `includes.jl` (also generated) `include`s every struct file and exports its accessors/setters.
- `units/` — PSIP's units layer (`natural_unit`, `ConversionUnits`, the unit-aware `get_x(value, units)` / `set_x!(value, val, units)` accessors).
- `investment_schedule.jl` — `InvestmentScheduleResults` (model-output container held by a `Portfolio`).
- `portfolio.jl` — the `Portfolio` mutable struct and its constructors/accessors, `add_technology!` / `add_topology!` (both validate through `_validate_or_skip!` in `validation.jl` unless `skip_validation=true`).
- `time_mapping.jl` — `TimeMapping`, `InvestmentIntervals`, `OperationalPeriods`.
- `openapi/` — the serde layer, see "Serialization" below.
- `db_parser.jl` — submodule `DBParser`; `database_to_portfolio` reads a SiennaGridDB-style SQLite DB into a `Portfolio`.
- `update_system.jl` — `update_system_with_nodal_results!` writes investment results back onto a `PSY.System`.
- `utils/getters.jl`, `utils/print.jl` — shared accessors and `show` formatting.

## Serialization — `to_file` / `from_file`

The design mirrors PowerSystems.jl's psy6 `src/openapi/file_io.jl`: a `Portfolio` becomes a `PI.PortfolioDocument` (`to_openapi(portfolio; ...)`), which is written as JSON beside an InfraStore HDF5 sidecar and the base system, written by PSY's own `to_file`. There is no `to_json`/`from_json` and no `IS.serialize(::Portfolio)` path any more — do not restore them.

Every document is stamped with the `schema_version` it was written with, and the reader refuses — before decoding anything — one with no stamp or from another compatibility line (`IC.SchemaVersionError`). That is upstream behaviour (`write_document` / `read_portfolio_document`); PSIP adds nothing. Files written before 0.2 must be regenerated.

```julia
PSIP.to_file(portfolio, path; base_system_units = CU, force = false, pretty = false)
PSIP.from_file(path; portfolio_kwargs...)
```

`to_file`/`from_file` are PSIP-local functions that shadow PSY's exported ones, and they are **not exported** — always call them qualified (`PSIP.to_file`). Inside PSIP, PSY's are always called as `PSY.to_file`/`PSY.from_file`.

The extension of `path` picks the form on both sides (no content sniffing, no `format` keyword):

| form | members |
|---|---|
| `case` (directory) | `portfolio.json`, `time_series.h5`, `base_system/` (PSY directory form) |
| `case.json` | `case.json`, `case.h5`, `case_base_system.json` + `case_base_system.h5` (PSY `.json` form) |
| `case.snp` (archive) | flat zip of `portfolio.json`, `time_series.h5`, `time_series.h5.sqlite`, `base_system.sns` |

- `.snp` is PSIP's archive extension (`PORTFOLIO_ARCHIVE_EXTENSION`); `.sns` is PSY's. IS zips only the **top level** of the staging directory, so an archive cannot contain a subdirectory — that is why the base system rides as PSY's single-file `.sns` member. The archive keeps InfraStore's `.sqlite` catalog (`write_catalog=true`) and is the only lossless form; its base system is written on `CU` only (PSY's `.sns` rule).
- The document forms write the arrays alone (`IS.serialize_arrays`) and carry the associations in the document's `time_series_associations` table, replayed on read with `IS.import_time_series_association_rows!(store, JSON.json(IC.encode(rows)))` — `IC.encode`, not bare `JSON.json`, or the oneOf rows serialize as `{"value": ...}`.
- **Masking is derived, never recorded (PSY's `HybridSystem` contract).** A `ColocatedSupplyStorageTechnology` owns its `supply_technology` and `storage_technology`: `add_technology!` masks them via `handle_technology_addition!` → `mask_owned_technologies!` (an attached one is moved with `IS.mask_component!`, an unattached one goes straight in with `IS.add_masked_component!`), and removing the colocated technology removes them. Masked technologies drop out of `get_technologies` — so PSI sees the colocated project once — and are reached through `get_subcomponents(colocated)` / `get_masked_technologies` / `is_masked`. The document writes them as ordinary rows (`_plan_components` walks live + masked) with **no mask field**; `from_openapi` attaches every technology live with `_add_technology!` (no hook), loads attributes and memberships, and only then calls `mask_owned_technologies!(portfolio)`. Two constraints: IS cannot attach a supplemental attribute to a masked component (hence masking last on import, and users must attach attributes before adding the owning colocated technology), and a technology can have only one owner. Do not add a mask flag to the schema — that would give one truth two writers.
- `base_system_units` is passed straight to `PSY.to_file(...; units=...)`; the portfolio document itself is always natural units.
- `from_file` forwards only `time_series_read_only` / `time_series_directory` to the base system's `PSY.from_file(path)` (which takes **no type argument** in psy6).

Files in `src/openapi/`, in include order:

- `refs.jl` — `OpenAPIRefs`, the id⇄component registry for one conversion pass, plus the empty `from_openapi` / `to_openapi` generics. **Must precede `models/generated/includes.jl`.** Topology (base system) and portfolio components have two overlapping id spaces, so lookups are typed (`resolve_ref(refs, id, T)`). Existence checks name their family too: `has_component_ref` (technology / requirement / supplemental attribute — what every association row and time-series owner refers to) or `has_topology_ref`. There is deliberately no family-agnostic `has_ref`: an OR over both maps answers `true` for an unregistered portfolio id that a bus or arc happens to share, which once dropped supplemental attributes from the document.
- `cost_conversion.jl` — import-direction hand-written converters (`convert_value_curve`, `convert_cost`, `convert_nested_data`, compound extractors) and the `Absent` helpers (`_NoWireValue`, `_or_default`, `_optional_from_wire`, `_enum_from_po`, ...).
- `export_cost_conversion.jl` — export-direction converters (`convert_cost_to_openapi`, `convert_nested_data_to_openapi`, compound `_minmax_po`/... constructors, `_curve_to_openapi`).
- `sqlite_load.jl` — attaches supplemental attributes from the document's association table.
- `import_document.jl` — `DOCUMENT_PLAN` / `SUPPLEMENTAL_ATTRIBUTE_PLAN` (the dependency-ordered type lists both directions share) and `from_openapi(::Type{Portfolio}, doc, document_path; ...)`.
- `export_document.jl` — `to_openapi(portfolio; base_system_path, time_series_storage_path, write_catalog)`.
- `file_io.jl` — `to_file` / `from_file` and the on-disk layout constants.

Identity is the component's own integer `id`: `from_openapi` sets each component's id with `IS.set_id!` before adding it, so a document id, a container id, and an association row all name the same number.

**The `Absent` contract.** Every optional field of a platform model is `Union{Absent, Nothing, T}` and defaults to `IC.ABSENT`; a field the producer omitted reads back as `IC.Absent`, a JSON `null` as `nothing`. Every import helper must treat both as "no value" (dispatch on `_NoWireValue`), and a field with a descriptor `default` must fall back to it (`_or_default`). The generator emits this; hand-written converters must follow it too. On export, a missing optional value is emitted as `IC.ABSENT` (omitted), **never `nothing`**: the platform schemas mark optional fields as optional, not nullable, so a written `null` fails schema validation when the document is read back. Every export-side optional helper (`_optional_to_wire`, `_*_po_optional`, `_curve_to_openapi`, `_keyed_map_to_openapi`, `_optional_cost_curve_to_openapi`) returns `IC.ABSENT` for a missing value, and the generator wraps nullable scalar fields in `_optional_to_wire`.

## Auto-generated structs — do NOT hand-edit

There is **one** generated layer in this repo. PSIP used to vendor a second — an OpenAPI-generator tree reached through `APIServer.jl` — and that tree is **gone**. The transport structs come from the platform packages above; they are generated in the `PowerOpenAPIModels` monorepo, not here; do not vendor them back.

**Component structs** in `src/models/generated/*.jl` — 18 files plus `includes.jl`. Each begins with `#= This file is auto-generated. Do not edit. =#` and `#! format: off` (the formatter skips them). Produced by the **`StructGeneration` submodule** in `src/utils/generate_structs.jl` — self-contained (own explicit imports; no dependency on PSIP's own types) and **not exported**.

Each generated file carries, besides the struct and its accessors/setters, a **`from_openapi(po::PI.X, refs)` / `to_openapi(value::X, refs)` pair** targeting the platform `PI.X` transport struct — PSY's shape minus its `Val{:COMPONENT_BASE}` / `Val{:NATURAL_UNITS}` axis, because PSIP has exactly one unit representation. The generator classifies every descriptor field into a kind (`openapi_classify_field`) and both drivers throw `DataFormatError` on a kind they were not taught. Wire-shape rules the generator encodes:

- Enums export through `OPENAPI_ENUM_WIRE_TYPES` (`PC.PrimeMovers`, `PC.ThermalFuels`, `PC.StorageTech`); an enum not in that table is a plain `String` on the wire (`conformity`). Import rebuilds through the PSY enum's own string constructor.
- Every `oneOf`/`anyOf` field — curve fields, abstract-cost fields (`PSY.OperationalCost`, `IS.ProductionVariableCostCurve`), capacity bounds — is wrapped in the platform's field-specific `PI.<Struct><PascalCaseField>` type (`openapi_field_wrapper_type`). Import unwraps any of them through a `convert_value_curve` / `convert_cost` method on `IC.OneOfAPIModel`.
- Per-topology capacity bounds export as `PC.MinMaxByKey` (keyed by topology id). **Upstream ambiguity:** `MinMax`'s schema leaves `min`/`max` optional and allows extra properties, so the bound `oneOf` decodes a per-topology map as a `MinMax` with no bounds; `_capacity_bound_value` recognises that shape. The real fix belongs in SiennaSchemas (`MinMax` should require `min`/`max`).
- String-keyed maps (`Dict{String, Int64}` etc.) are the `:keyed_map` kind, not scalars: on the wire each is a field-specific wrapper holding the map in `additional_properties` (`_keyed_map_to_openapi` / `_keyed_map_from_po`).
- Fields with a descriptor `default` import as `_or_default(<absent-safe expr>, default)`.

Parametric types are **generated, not hand-written** (8 of PSIP's 18 are parametric). `power_systems_type::String` is the single carrier of the type parameter: `from_openapi` resolves `getproperty(PowerSystems, Symbol(po.power_systems_type))`, and `to_openapi` regenerates the string as `string(nameof(T))`. Never set `power_systems_type` to anything but a real PowerSystems type name.

Regenerate with the qualified entry point (the generated output is checked in and must match the generator byte-for-byte):

```sh
julia --project=test -e 'using PowerSystemsInvestmentsPortfolios; PowerSystemsInvestmentsPortfolios.StructGeneration.generate_structs("src/descriptors/SiennaInvestSchema.json", "src/models/generated")'
```

`StructGeneration` is never `include`d or called unqualified. The spec (`src/descriptors/SiennaInvestSchema.json`) is the single source of truth: to change a generated component's fields/defaults/docstring, edit the spec and rerun generation; never patch the output file. Defaults are copied through **verbatim as Julia source**, so a Python literal in the spec (`True`, `False`, `None`) becomes an `UndefVarError` — write `true`/`false`/`nothing`. New abstract supertypes, hand-written accessors, and dispatch logic belong in the non-generated `models/*.jl` files; new value converters belong in `src/openapi/cost_conversion.jl` (import) / `export_cost_conversion.jl` (export).

`test/test_openapi_parity.jl` guards the descriptor against the platform models: field names, and field wire types with the expected type derived from the generator's own tables (`OPENAPI_ENUM_WIRE_TYPES`, `openapi_field_wrapper_type`, `openapi_cost_needs_wrapper`) so the test and the generator cannot drift apart. `test/test_serialization.jl`'s "every struct and value variant" testset is the third layer: a wide fixture (the 5-bus portfolio plus every missing document type and the value shapes each can take — nullable fields set and unset, zero and non-zero optional cost curves, every cost container and curve family, per-topology bounds, populated maps, memberships, time series on several owners) round-tripped through all three forms and compared payload by payload. It fails if the fixture stops covering a type. **When adding a field or a value shape, add it to that fixture** — a type present only at its defaults hides exactly the converter bugs that matter. `test/test_openapi_converters.jl` asserts every generated type has both converters and that each parametric `where` bound matches the descriptor. Run both after any regeneration.

## Main public API

The export list in `src/PowerSystemsInvestmentsPortfolios.jl` is authoritative. `Portfolio` is the
container (the analogue of PSY's `System`); technology types are concrete and **generated**.

## Conventions & gotchas

- Exports are centralized in the module file; generated accessors/setters are exported from the generated `includes.jl`.
- **Name shadowing with PSY.** PSIP is `using PowerSystems`, but a generated accessor with the same name as a PSY one (`get_curtailment_cost`, `get_fuel_cost`, `get_fuel`, `get_prime_mover_type`, ...) defines a *new PSIP function* that shadows PSY's rather than extending it. Call PSY/IS accessors on PSY objects qualified (`PSY.get_curtailment_cost(cost)`, `IS.get_fuel_cost(curve)`).
- **No duplicate definitions.** Julia refuses to precompile a module that defines the same method twice, and a duplicate `const` silently takes the last value. When porting code from PSY, check the target file does not already hold it.
- **psy6 units are Unitful.** PSY constructors (`Area`, `LoadZone`, `ACBus`, generators, storage, branches, `TransformerCircuit`) require `input_basis = u"CU"` or `u"NU"` — a Unitful unit, not the `CU`/`NU` marker objects, which now serve only `to_file`'s `units` mode and cost curves' type parameter. `@u_str` only finds those units when the `PerUnit` unit module is **bound by name in the calling module**: the main module gets it from `using PowerSystems`, but a submodule that imports selectively (`DBParser`) needs `import PowerSystems: PerUnit`, or `u"CU"` fails at precompile. `db_parser.jl` passes `u"NU"` for topology (raw DB values) and `u"CU"` where it has already divided by a base power. PSY getters and setters take Unitful units too (`PSY.get_rating(gen, u"MW")`, `set_rating!(gen, x * MW)`); bare floats are rejected.
- Use `get_*` accessors, not dot access, in user-facing code. PO (platform model) structs are the exception — they are accessed with dot notation in the converters.
- Several existing fields use `Union{Nothing, T}` (e.g. `investment_schedule`, `financial_data`). This predates the prefer-predicate guidance; do not propagate the pattern into new code.
- **Known open issue:** `db_parser.jl` still references the removed `RegionTopology`/`Zone`/`Node` types (load-time "undeclared binding" warnings), so the parser's zone/node paths are broken until they are mapped onto PSY topology types. `test/test_parser.jl` has no testsets, so nothing catches it.

## Cross-package coupling

- Upstream: `InfrastructureSystems` (container, internals, time series, archive container), `PowerSystems` (base system, parametric technology types, `to_file`/`from_file` for the base system), and the OpenAPI model packages (transport structs, `PortfolioDocument`). Changes to PSY type names ripple into the generated structs' type parameters; changes to the platform models ripple into `to_openapi`'s return types and are caught by `test/test_openapi_parity.jl`.
- PSY's own `.claude/CLAUDE.md` documents the `.snp` extension as PSIP's; keep the two in agreement.
- Downstream: `PowerSystemsInvestments.jl` consumes `Portfolio` and the technology/requirement structs to build optimization models. Renaming or removing an exported accessor/struct is a breaking change there.

## Running tests, docs, formatter (verified commands)

```sh
# Formatter (run before reporting any task done; self-activates its own env)
julia --project=scripts/formatter -e 'include("scripts/formatter/formatter_code.jl")'

# Full test suite (ReTest runner: runtests.jl includes the test module, which auto-includes
# every test/test_*.jl, then calls run_tests() -> retest())
julia --project=test test/runtests.jl

# One testset (ReTest filters by testset name or regex, not by file)
julia --project=test -e 'using PowerSystemsInvestmentsPortfolios; include("test/PowerSystemsInvestmentsPortfoliosTests.jl"); using ReTest; retest(PowerSystemsInvestmentsPortfoliosTests, "OpenAPI document round-trip")'

# Docs
julia --project=docs docs/make.jl
```

Test notes:

- **ReTest stops the whole run at the first failing testset** — whether from an exception outside a `@test` or an ordinary failed `@test` — so one broken testset hides every testset after it. When the suite stops early, run testsets one by one (`retest(mod, id)` for `id in 1:N`, catching each throw) to get the full failure list. `retest(mod; dry=true)` lists the registered testsets with their ids.
- Top-level testset descriptions must be **unique** across all test files — ReTest silently keeps only the last of a duplicate name.
- The runner pulls test data from the `CaseData` artifact in `test/Artifacts.toml` and runs Aqua checks (unbound args, undefined exports, ambiguities, stale/compat deps) at module load. Test deps live in `test/Project.toml`; always use `--project=test`. Uses `PowerSystemCaseBuilder` — don't mutate a cached system without `deepcopy`.
