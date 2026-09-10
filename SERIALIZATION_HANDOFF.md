# PSIP Serialization Port — Handoff Notes

Port of PowerSystems.jl (PSY, branch `jd/serialization_refactor`) document-based serialization
into PSIP: `to_openapi`/`from_openapi` + `to_file`/`from_file`.

## Status: precompiles & loads into a usable state

The package now precompiles and loads cleanly. All four serialization entry points are defined:
`to_file`, `from_file`, `to_openapi`, `from_openapi`.

Verify with:

```bash
julia --project -e 'using PowerSystemsInvestmentsPortfolios'
```

## Changes made (minimal, precompile-only)

1. **`src/PowerSystemsInvestmentsPortfolios.jl`** — added module aliases used in signatures /
   top-level:
   ```julia
   import PowerOpenAPIModels
   import InfrastructureCoreOpenAPIModels
   import InfrastructureTimeSeriesOpenAPIModels
   const PD = PowerOpenAPIModels
   const PO = PowerOpenAPIModels
   const IC = InfrastructureCoreOpenAPIModels
   const PTS = InfrastructureTimeSeriesOpenAPIModels
   ```
   (Existing: `PC = PowerCoreOpenAPIModels`, `PI = PowerInvestmentsOpenAPIModels`.)

2. **`src/PowerSystemsInvestmentsPortfolios.jl`** — moved `using DocStringExtensions` above the
   `openapi/*` includes. It was at L212, after files that use `$(TYPEDSIGNATURES)` in docstrings
   (evaluated at include time).

3. **`src/openapi/file_io.jl`** — defined `const SIENNA_ARCHIVE_EXTENSION = ".sn"` locally (value
   from the file's own header comment) and repointed all `IS.SIENNA_ARCHIVE_EXTENSION` references
   to it. This IS4 rev exports **no** archive support.

4. **`src/openapi/export_document.jl`** — base_system path now stored as a portable **relative**
   path. Added `_base_system_relpath(path) = joinpath(BASE_SYSTEM_DIRECTORY, basename(String(path)))`
   (mirrors `_sidecar_basename` but keeps the subdirectory segment) and changed the export to
   `base_system_file = _base_system_relpath(base_system_path)` → stores `"base_system/base_system.json"`
   instead of an absolute path. Read-side companion still TODO (see below).

5. **`src/PowerSystemsInvestmentsPortfolios.jl`** — moved `include("openapi/cost_conversion.jl")`
   and `include("openapi/export_cost_conversion.jl")` to **after** `include("portfolio.jl")`.
   `export_cost_conversion.jl` carries a method signature typed on PSIP's `PortfolioFinancialData`
   (defined in `portfolio.jl`), which must exist before the annotation is evaluated at include time.

### Why these were the only precompile blockers

Precompile executes top-level code + method **signatures** (not function bodies). So blockers
were undefined module aliases (`PD`/`PO`/`IC`/`PTS`), the full-name annotation
`InfrastructureTimeSeriesOpenAPIModels.TimeSeriesFeatureValue` (`import_document.jl:466`), and
top-level docstring interpolations. Undefined helpers referenced **only inside function bodies**
do not block precompile — they are the tomorrow work below.

## Review findings (oracle, reconciled — 2026-09-10)

The port precompiles but **round-trip does not run**: precompile only checks signatures, so a
whole broken API surface survived. These are *written-and-wrong*, not WIP-missing. Top blockers
spot-verified directly.

### Blockers — the `OpenAPIRefs` migration was only half-applied
The struct was rebuilt with split maps (`by_topology_id` / `by_component_id`, no `by_id`, no
`base_power`/`store`), but many consumers still call the old single-map PSY API:
- `refs.jl:75-80,93,104` — typed `resolve_ref(refs,id[,T])` routes through `getindex`, which now
  **always errors**. `resolve_refs` (plural, L115) correctly uses `_resolve`. Fix: singular
  `resolve_ref(refs,id,::Type{T})` → `_resolve(refs, id, T<:PSY.Topology)::T`; drop/rework the
  untyped 2-arg form.
- `sqlite_load.jl:125,140` — `refs[id]` reads hit the dead `getindex`. Fix: use `_resolve`.
- `import_document.jl:320` — `OpenAPIRefs(base_power; store=store)` → `MethodError`. Fix:
  `OpenAPIRefs()` (store is already threaded via `_with_import_store` at L322).
- `refs.jl:147,154-159` — `defer_ref!`/`resolve_deferred_refs!` use a non-existent `deferred_refs`
  field; `from_openapi` calls the latter every import (`import_document.jl:333`) → `FieldError`.
  Fix: add the field, or delete the deferral API + the L333 call.
- `export_document.jl:431-436` — `_reserve_ids!` reads `refs.by_id` (gone). Fix: reserve from
  `refs.by_component_id` only (topology ids live in the base system's separate counter).

### Blockers — construction & base-system path
- `portfolio.jl:213-232` — `Portfolio(data, aggregation)` injects
  `financial_data=PortfolioFinancialData(base_year, ...)` from **undefined variables** →
  `UndefVarError`. This is exactly the ctor `_portfolio_with_sidecar` calls. Fix: drop the bogus
  `financial_data=...` (mirror PSY `System(data, base_power)`).
- `import_document.jl:329` — `add_component!(portfolio, component)` has no method (only
  `add_technology!`/`add_requirement!`/`add_topology!` exist). Fix: add a type-dispatching
  `add_component!`.
- `import_document.jl:311` — unqualified `from_file(system_path)` calls PSIP's own reader on a
  **PSY.System** document. Fix: `PSY.from_file(system_path)`.
- `import_document.jl:312` — `set_base_system!(portfolio, nothing)` → `MethodError` when no base
  system named. Fix: `isnothing(system) || set_base_system!(portfolio, system)`.
- `file_io.jl:336` — reading any `.json` evaluates `IS.is_sienna_archive` (undefined in this IS4)
  before the `.json` branch → `UndefVarError` on the normal read path. Fix: test `.json`/dir forms
  first; gate the archive behind `isdefined(IS, :is_sienna_archive)`.
- `file_io.jl:399` — `_resolve_sidecar(doc::PD.SystemDocument, ...)` never matches the
  `PD.PortfolioDocument` passed at L380 → `MethodError`. Fix: retype to `PD.PortfolioDocument`.

### Blockers/High — financial_data & symmetry (silent data loss)
- `cost_conversion.jl:291-298` (import) & `export_cost_conversion.jl:262-269` (export):
  `PortfolioFinancialData` conversion is wrong **both** directions — reads/writes a `tax_rate`
  neither the wire type nor the PSIP struct has, and **drops `interest_rate`**. PSIP struct ctor
  is positional (not `@kwdef`). Correct field set both sides:
  `base_year, discount_rate, inflation_rate, interest_rate`.
  (`TechnologyFinancialData.tax_rate` is legitimate — only the *Portfolio* one is wrong.)
- `export_document.jl:394` — `investment_schedule = get_investment_schedule(portfolio)` passes an
  object where the doc field requires `Nothing`/`AbstractDict`. Fix:
  `isnothing(sched) ? nothing : IS.serialize(sched)`.
- `export_document.jl:393` — `convert_nested_data_to_openapi(get_financial_data(...))` errors when
  financial_data is `nothing`. Fix: add `convert_nested_data_to_openapi(::Nothing) = nothing`.
- `import_document.jl:297-337` — `financial_data` and `investment_schedule` are **never imported**
  (and there's no `set_financial_data!`). Fix: read both back + add the setter.
- Requirements membership is handled **twice**: inline on tech wire objects (authoritative) AND a
  separate `requirements_associations` table (`export_document.jl:341-356,407` +
  `sqlite_load.jl:129-141`, whose `_attach_requirements_membership!` → `add_service!` is undefined).
  Fix: keep the inline representation, delete the association table path.

### Cluster 3 financial_data / investment_schedule — RESOLVED (A6, A13, A14, A16)
- **A6** (`cost_conversion.jl:291`): `convert_nested_data(::PI.PortfolioFinancialData)` now uses the
  **positional** ctor `PortfolioFinancialData(base_year, discount_rate, inflation_rate, interest_rate)`
  (the struct has no `@kwdef`). Export side (`export_cost_conversion.jl`) already correct.
- **A13 export** (`export_document.jl:397`): guards `nothing` and passes `.results` (a `Dict`) →
  matches wire `Union{Nothing, Dict{String,Any}}`.
- **A13 import** (`import_document.jl:_resolve_investment_schedule`): fixed the undefined
  `InvestmentScheduleResult` (singular) → `InvestmentScheduleResults`, used its **positional** ctor,
  and returns `nothing` when the document has no schedule; call site now guards
  `isnothing(schedule) || set_investment_schedule!(...)`.
- **A14**: `convert_nested_data_to_openapi(::Nothing) = nothing` present.
- **A16**: import reads both `financial_data` and `investment_schedule` back;
  `set_financial_data!(::Portfolio, …)` exists. Now unblocked by the A6/A13 fixes.
Verified: full stack precompiles; both financial_data directions round-trip
(interest_rate/base_year preserved); `InvestmentScheduleResults(Dict)` ctor works; `::Nothing`
guard holds. **All of clusters 1–3 are now resolved** — next step is an end-to-end
`to_file`→`from_file` round-trip test (see process note below).

### A15 — RESOLVED (Option B: association table is the single canonical encoding)
Requirement↔member membership is now represented ONLY by the document-level
`requirements_associations` table; the inline `requirements` wire field was dropped. Spanned
three repos:
- **SiennaSchemas** (`jp/inv_fix`): removed the `requirements` property from the 7 technology
  schemas + `DemandRequirement.json`; regenerated bundled dist specs (`bundle_specs.py`).
- **PowerOpenAPIModels** (`jp/investment_updates`): `make generate` regenerated the PI wire
  models — `requirements` dropped from all 8 tech structs. (`portfolio_document.jl` +
  `test/validate.jl` changes there are your pre-existing branch work adding the
  `add_requirement_association!` builder + `requirements_membership` cache, not from this regen.)
- **PSIP**:
  - `generate_structs.jl`: added `"requirements"` to `OPENAPI_SKIP_FIELDS` and regenerated the 8
    generated tech files. In-memory struct field + `get/set_requirements!` **kept**; only the two
    wire-converter lines dropped (`resolve_refs` on import, `component_ids` on export).
  - Export (`export_document.jl`): `_export_requirements_associations!` now routes rows through
    `PD.add_requirement_association!(doc, …)` (inherits dedup + membership cache) instead of raw
    `append!`.
  - Import: deleted the broken `sqlite_load.jl` requirements loop and the undefined-`add_service!`
    `_attach_requirements_membership!` block; added `load_requirements_associations!` — a
    post-component-pass reconstruction that folds the table into per-entity `set_requirements!`
    (using cluster-1 `_resolve`, not the ambiguous `getindex`), wired into `from_openapi`.
  Verified: full stack precompiles; wire field gone from `PI.SupplyTechnology`;
  `add_requirement_association!` available; `load_requirements_associations!` defined and the old
  membership helper removed. Full `to_file`→`from_file` behavioral round-trip is deferred until
  A6/A13/A14/A16 land (they still block a clean `to_openapi`/`from_openapi`).

### A10 — RESOLVED (IS pinned to archive-capable commit)
`is_sienna_archive` / `SIENNA_ARCHIVE_EXTENSION` / `create_sienna_archive` / `extract_sienna_archive`
were absent because the IS4 pin was an orphaned (rebased-away) commit. Pinned IS to
`5776a49b329eb6f27027b7ba51302dfaa76eea0b` in `Project.toml [sources]` — the newest IS4 commit
with full `.sn` archive support that is **before** two breaking changes near the branch tip:
  - `3b9653e` renames IS unit markers `DU`/`DeviceBaseUnit` → `CU`/`ComponentBaseUnit` (no shims);
    PSY `jd/serialization_refactor` still uses `DU`/`DeviceBaseUnit`, so any commit at/after this
    breaks PSY at precompile.
  - `559a192` (branch HEAD) bumps to OpenAPI 1.x; all 8 local `PowerOpenAPIModels` packages + PSY
    pin OpenAPI 0.2, so HEAD would force an ecosystem-wide OpenAPI migration.
`5776a49` stays on OpenAPI 0.2 and bumped InfraStore 0.11→0.12 (registry). `file_io.jl` now uses
`IS.is_sienna_archive` and `IS.SIENNA_ARCHIVE_EXTENSION` (local `.snp` shim removed). Verified:
package precompiles; `is_sienna_archive` resolves. **Cluster 2's last blocker (A10) is closed** —
remaining cluster 2 items A7/A8/A9/A11/A12 still pending.
NOTE for future: moving to IS4 HEAD later is a dedicated task (OpenAPI 0.2→1 across the OpenAPI
model repos + PSY, plus DU→CU rename in PSY + PSIP).

### Handoff corrections (were stated wrong above)
- `_resolve_base_system` **is already implemented** (`import_document.jl:339`) — the earlier
  "read-side companion still needed" note below is obsolete; only its *consumer* (A8) is broken.
- SystemData is built with the **6-arg** IS4 form (`import_document.jl:412`), matching PSY exactly —
  earlier "7-arg" was a miscount.
- `SIENNA_ARCHIVE_EXTENSION` is currently `".snp"` in code but every doc/comment says `.sn` — pick
  `.sn`.

## Remaining round-trip work

### Import path build-out (`src/openapi/import_document.jl`)
Body-only helpers still undefined:
- `_reserve_ids!`
- `_merge_doc_ext!`
- `_check_no_unconverted_component_types`
- `_check_resolved_type_matches`
- `_unwrap_oneof` (port from PSY `import_handwritten.jl:942-943`)
- `DOCUMENT_PLAN_KEYS`
- `load_supplemental_attribute_associations!`
- `_with_import_store`
- `resolve_deferred_refs!`
- `_EMITTED_ASSOCIATION_IDS_KEY`

Design decisions (already confirmed):
- Simplify `_attach_attribute!` to drop group indices (`_push_group_index!` won't exist).
- Build `SystemData` via the 7-arg IS4 form (mirror PSIP's `deserialize(::Type{IS.SystemData})`).
- Portfolio inner ctor (`portfolio.jl:61`) with a fresh `IS.InfrastructureSystemsInternal()`.
- Requirements membership is **inline** on technology wire objects
  (`resolve_refs(refs, po.requirements, Requirement)`) — no separate association loader on import.

### Export gaps (`src/openapi/export_document.jl`)
- `to_openapi` currently **drops** `financial_data` and `investment_schedule` — add both.
- Add a `financial_data` converter: wire `PI.PortfolioFinancialData`
  (id / discount_rate / inflation_rate / interest_rate / base_year) →
  PSIP `PortfolioFinancialData(base_year, discount_rate, inflation_rate, interest_rate)`.
- Define `_export_ext!`, `_reserve_ids!`, `_EMITTED_ASSOCIATION_IDS_KEY`.
- Store `base_system_file` as portable relative path `base_system/base_system.json`. **DONE** — see
  `_base_system_relpath` in `export_document.jl`. Read-side companion still needed:

  ```julia
  function _resolve_base_system(doc::PD.PortfolioDocument, dir::AbstractString)
      named = PD.get_base_system_file(doc)          # accessor confirmed
      named === nothing && return nothing
      path = joinpath(dir, named)
      isfile(path) || throw(IS.DataFormatError(
          "the document names base_system_file=\"$named\" but $path does not exist"))
      return path
  end
  ```

  Then wire into `_from_file_document` alongside the existing sidecar resolve:

  ```julia
  return from_openapi(
      Portfolio, doc;
      base_system_path = _resolve_base_system(doc, isempty(dir) ? "." : dir),
      time_series_storage_path = _resolve_sidecar(doc, isempty(dir) ? "." : dir),
      system_kwargs...,
  )
  ```

### Shared
- Define `get_data_source(::Portfolio)` in `src/portfolio.jl` (needed by export L390 + import).

### File I/O (`src/openapi/file_io.jl`)
- `_from_file_document` must resolve both sidecars (base_system + time_series) relative to the
  document dir.
- Wire `from_openapi(Portfolio, doc; base_system_path, time_series_storage_path, portfolio_kwargs...)`.
- `IS.is_sienna_archive` (L336) and the whole `.sn` archive path are unavailable in this IS4 —
  either stub, gate, or wait for upstream IS archive support. Confirm the `.sn` extension
  value/behavior once that lands.

### PSY cruft to remove
- The mistyped `from_openapi(::Type{System}, doc::PD.SystemDocument)` and other System-oriented
  signatures carried over from PSY.

## Open concern (needs a decision)
`_to_file_sienna` hardcodes `base_system_units = NU` (`file_io.jl:~322`) while the `.sn` archive
is meant to be lossless.

## Notes
- 3 pre-existing `DBParser` warnings (undeclared `Zone`/`Node`/`RegionTopology` bindings) appear
  during precompile — unrelated to these changes.

## Reference files
- `src/PowerSystemsInvestmentsPortfolios.jl` — imports/aliases; include order (`import_document.jl`,
  `export_document.jl`, `file_io.jl`).
- `src/openapi/import_document.jl` — import path; `DOCUMENT_PLAN`; `_attach_attribute!`;
  `_ts_feature_value` (L466).
- `src/openapi/export_document.jl` — `to_openapi`; export helpers.
- `src/openapi/file_io.jl` — `to_file`/`from_file`; sidecar resolution; `SIENNA_ARCHIVE_EXTENSION`.
- `src/portfolio.jl` — Portfolio ctor (L61); accessors; `PortfolioFinancialData` (L44); add
  `get_data_source`.
- PSY originals (branch `jd/serialization_refactor`) for helper ports:
  `import_handwritten.jl:942-943`, `sqlite_load.jl`, `export_document.jl:130-134,703,765`.
