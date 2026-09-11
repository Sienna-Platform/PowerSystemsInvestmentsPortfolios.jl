"""
PSIP-owned struct code generator (mirrors PowerSystems.jl's `StructGeneration` fork of
InfrastructureSystems.jl's generator). Self-contained: it emits Julia source as text and
declares its own imports, so it has no dependency on PowerSystemsInvestmentsPortfolios'
own types. `generate_structs`/`generate_invest_structs` are dev-tool entry points, not
part of PSIP's public `get_*`/`set_*` surface — call them module-qualified,
`PowerSystemsInvestmentsPortfolios.StructGeneration.generate_structs(...)`, never exported.
"""
module StructGeneration

import JSON3
import JSONSchema
import Mustache
const MU = Mustache
import InfrastructureSystems: DataFormatError

const STRUCT_TEMPLATE = """
#=
This file is auto-generated. Do not edit.
=#

#! format: off

\"\"\"
    mutable struct {{struct_name}}{{#parametric}}{T <: {{parametric}}}{{/parametric}} <: {{supertype}}
        {{#parameters}}
        {{name}}::{{{data_type}}}
        {{/parameters}}
    end

{{#docstring}}{{{docstring}}}{{/docstring}}

# Arguments
{{#parameters}}
- `{{name}}::{{{data_type}}}`:{{#default}} (default: `{{{default}}}`){{/default}}{{#comment}} {{{comment}}}{{/comment}}{{#valid_range}}, validation range: `{{{valid_range}}}`{{/valid_range}}
{{/parameters}}
\"\"\"
mutable struct {{struct_name}}{{#parametric}}{T <: {{parametric}}}{{/parametric}} <: {{supertype}}
    {{#parameters}}
    {{#comment}}"{{{comment}}}"\n    {{/comment}}{{name}}::{{{data_type}}}
    {{/parameters}}
    {{#inner_constructor_check}}

    function {{struct_name}}({{#parameters}}{{name}}, {{/parameters}})
        ({{#parameters}}{{name}}, {{/parameters}}) = {{inner_constructor_check}}(
            {{#parameters}}
            {{name}},
            {{/parameters}}
        )
        new({{#parameters}}{{name}}, {{/parameters}})
    end
    {{/inner_constructor_check}}
end

{{#needs_positional_constructor}}
function {{constructor_func}}({{#parameters}}{{^internal_default}}{{name}}{{#default}}={{default}}{{/default}}, {{/internal_default}}{{/parameters}}){{{closing_constructor_text}}}
    {{constructor_func}}({{#parameters}}{{^internal_default}}{{name}}, {{/internal_default}}{{/parameters}}{{#parameters}}{{#internal_default}}{{{internal_default}}}, {{/internal_default}}{{/parameters}})
end
{{/needs_positional_constructor}}

function {{constructor_func}}(; {{#parameters}}{{name}}{{#kwarg_value}}{{{kwarg_value}}}{{/kwarg_value}}, {{/parameters}}){{{closing_constructor_text}}}
    {{constructor_func}}({{#parameters}}{{name}}, {{/parameters}})
end

{{#has_null_values}}
# Constructor for demo purposes; non-functional.
function {{constructor_func}}(::Nothing){{{closing_constructor_text}}}
    {{constructor_func}}(;
        {{#parameters}}
        {{^internal_default}}
        {{name}}={{#quotes}}"{{null_value}}"{{/quotes}}{{^quotes}}{{null_value}}{{/quotes}},
        {{/internal_default}}
        {{/parameters}}
    )
end

{{/has_null_values}}
{{#accessors}}
{{#needs_conversion}}
{{#create_docstring}}\"\"\"Get [`{{struct_name}}`](@ref) `{{name}}` as a bare number in the requested `units` (e.g. `SU`, `CU`; domain-provided units such as `MW` are also accepted when the owning domain package has registered a `_strip_units` method for the returned quantity type). Returns a bare number only when such a method is registered; otherwise returns the quantity wrapper. For the unit-bearing value see [`{{accessor}}_unitful`](@ref).\"\"\"{{/create_docstring}}
{{accessor}}(value::{{struct_name}}, units) = InfrastructureSystems._strip_units(get_value(value, Val(:{{name}}), Val({{conversion_unit}}), units))
{{#create_docstring}}\"\"\"Get [`{{struct_name}}`](@ref) `{{name}}` as a unit-bearing quantity in the requested `units` (e.g. `SU`, `CU`, `MW`). For a bare number see [`{{accessor}}`](@ref).\"\"\"{{/create_docstring}}
{{accessor}}_unitful(value::{{struct_name}}, units) = get_value(value, Val(:{{name}}), Val({{conversion_unit}}), units)
InfrastructureSystems.display_units_arg(::typeof({{accessor}}), ::{{units_type_sig}}){{#units_bound}} where {T <: {{units_bound}}}{{/units_bound}} = InfrastructureSystems.{{display_units}}
InfrastructureSystems.display_units_arg(::typeof({{accessor}}_unitful), ::{{units_type_sig}}){{#units_bound}} where {T <: {{units_bound}}}{{/units_bound}} = InfrastructureSystems.{{display_units}}
{{/needs_conversion}}
{{^needs_conversion}}
{{#create_docstring}}\"\"\"Get [`{{struct_name}}`](@ref) `{{name}}`.\"\"\"{{/create_docstring}}
{{accessor}}(value::{{struct_name}}) = value.{{name}}
{{/needs_conversion}}
{{/accessors}}

{{#setters}}
{{#needs_conversion}}
{{#create_docstring}}\"\"\"Set [`{{struct_name}}`](@ref) `{{name}}`.\"\"\"{{/create_docstring}}
{{setter}}(value::{{struct_name}}, val, unit) = value.{{name}} = set_value(value, Val(:{{name}}), val, unit, Val({{conversion_unit}}))
{{/needs_conversion}}
{{^needs_conversion}}
{{#create_docstring}}\"\"\"Set [`{{struct_name}}`](@ref) `{{name}}`.\"\"\"{{/create_docstring}}
{{setter}}(value::{{struct_name}}, val) = value.{{name}} = val
{{/needs_conversion}}
{{/setters}}

{{#custom_code}}
{{{custom_code}}}
{{/custom_code}}

{{#has_openapi}}
{{#has_parametric}}
function from_openapi(po::PI.{{struct_name}}, refs::OpenAPIRefs)
    parameter = getproperty(PowerSystems, Symbol(po.power_systems_type))
    return {{struct_name}}{parameter}(;
        {{#openapi_kwargs}}
        {{name}} = {{{expr}}},
        {{/openapi_kwargs}}
    )
end

function to_openapi(value::{{struct_name}}{T}, refs::OpenAPIRefs) where {T <: {{parametric}}}
    return PI.{{struct_name}}(;
        {{#openapi_export_kwargs}}
        {{name}} = {{{expr}}},
        {{/openapi_export_kwargs}}
    )
end
{{/has_parametric}}

{{^has_parametric}}
function from_openapi(po::PI.{{struct_name}}, refs::OpenAPIRefs)
    return {{struct_name}}(;
        {{#openapi_kwargs}}
        {{name}} = {{{expr}}},
        {{/openapi_kwargs}}
    )
end

function to_openapi(value::{{struct_name}}, refs::OpenAPIRefs)
    return PI.{{struct_name}}(;
        {{#openapi_export_kwargs}}
        {{name}} = {{{expr}}},
        {{/openapi_export_kwargs}}
    )
end
{{/has_parametric}}
{{/has_openapi}}

"""

# ── OpenAPI converter generation ──────────────────────────────────────────────
# Ported from PowerSystems.jl's src/generate_structs.jl. Two differences, both
# structural rather than stylistic:
#
#  * No unit-system axis. PSY emits four methods per type because a PSY document can
#    state values in either of two per-unit bases. PSIP has one representation, so it
#    emits two and takes no `Val`.
#  * Parametric types are generated, not rejected. PSY hand-writes those; PSIP cannot,
#    since 8 of its 23 types are parametric. `power_systems_type` carries the parameter.

const OPENAPI_SKIP_FIELDS = Set(["ext", "internal", "requirements"])

const OPENAPI_SCALAR_TYPES = Set([
    "Float64",
    "Int",
    "Int64",
    "String",
    "Bool",
    "Vector{String}",
    "Dict{String, Int64}",
    "Dict{String, Float64}",
])

const OPENAPI_COMPOUND_MEMBERS = Dict(
    "MinMax" => ("min", "max"),
    "UpDown" => ("up", "down"),
    "InOut" => ("in", "out"),
    "OutageFactors" => ("planned", "forced"),
)

const OPENAPI_COMPOUND_CTORS = Dict(
    "MinMax" => (required="_minmax_po", optional="_minmax_po_optional"),
    "UpDown" => (required="_updown_po", optional="_updown_po_optional"),
    "InOut" => (required="_inout_po", optional="_inout_po_optional"),
    "OutageFactors" =>
        (required="_outagefactors_po", optional="_outagefactors_po_optional"),
)

"""
Import-direction extraction helper per compound alias (`src/openapi/converters.jl`).

One name each, unlike [`OPENAPI_COMPOUND_CTORS`](@ref)'s required/optional pair: absence is
dispatch on `::Nothing` in the helper, so nullability no longer changes the emitted
expression.
"""
const OPENAPI_COMPOUND_EXTRACTORS = Dict(
    "MinMax" => "_minmax_from_po",
    "UpDown" => "_updown_from_po",
    "InOut" => "_inout_from_po",
    "OutageFactors" => "_outagefactors_from_po",
)

# PSY derives this from the descriptor's own struct names. That fails here: PSIP's
# reference fields are typed with the ABSTRACT supertype `Requirement` (a portfolio
# component) and with PowerSystems topology types (`PSY.Topology`, `PSY.Bus`,
# `PSY.AggregationTopology`) that live in the base system, so the set is declared instead.
# Topology references resolve through the same `OpenAPIRefs` registry, which is seeded with
# the base system's topology components alongside the portfolio's own (see document.jl).
# `SupplyTechnology`/`StorageTechnology` are concrete portfolio components a
# `ColocatedSupplyStorageTechnology` co-locates by reference: the struct holds the resolved
# component in memory, but the wire model carries only its integer id (see
# `model_ColocatedSupplyStorageTechnology`). `DOCUMENT_PLAN` registers both before the
# colocated type, so the id resolves in dependency order in either direction.
const OPENAPI_REFERENCE_TYPES = Set([
    "Requirement",
    "PSY.Topology",
    "PSY.Bus",
    "PSY.AggregationTopology",
    "SupplyTechnology",
    "StorageTechnology",
])

const OPENAPI_ENUM_TYPES =
    Set(["PrimeMovers", "ThermalFuels", "StorageTech", "ACBusTypes", "PSY.LoadConformity"])

const OPENAPI_CURVE_TYPES =
    Set(["PSY.ValueCurve", "Union{IS.LinearCurve, IS.PiecewiseIncrementalCurve}"])

# A cost field's declared Julia type must be as narrow as the OpenAPI model's, because the
# PO side has no enum validation on the read path: writing a `ThermalGenerationCost` into a
# field the document types `RenewableGenerationCost` round-trips into a different cost type
# with fields dropped and nothing raised. `test/test_openapi_parity.jl` holds the pairing.
# `PSY.OperationalCost` stays legal only where the PO type is the `GenericOperationCost`
# oneOf, which spans the whole family.
const OPENAPI_COST_TYPES = Set([
    "PSY.OperationalCost",
    "PSY.ThermalGenerationCost",
    "PSY.RenewableGenerationCost",
    "PSY.StorageCost",
    "IS.ProductionVariableCostCurve",
])

const OPENAPI_NESTED_TYPES =
    Set(["TechnologyFinancialData", "CapitalCost", "StorageCapitalCost"])

"""
Split `Union{Nothing, X}` into `(X, true)`; any other type string is `(type, false)`.
"""
function openapi_strip_nullable(data_type::AbstractString)
    m = match(r"^Union\{Nothing,\s*(.+)\}$", data_type)
    if isnothing(m)
        return (String(data_type), false)
    end
    return (String(m.captures[1]), true)
end

"""
Classify one field's role in an OpenAPI converter, returning `(kind, bare, nullable)`
with `kind` one of `:skip`, `:scalar`, `:compound`, `:reference`, `:reference_vector`,
`:enum`, `:enum_vector`, `:enum_dict`, `:enum_compound_dict`, `:curve`, `:cost`,
`:nested`.

Raises `DataFormatError` rather than guessing: a field whose Julia type matches none of
the declared tables is a descriptor change the generator has not been taught about, and
emitting a silently-wrong converter for it would corrupt data at run time.
"""
function openapi_classify_field(struct_name, field)
    name = field["name"]
    if name in OPENAPI_SKIP_FIELDS
        return (:skip, String(field["type"]), false)
    end
    bare, nullable = openapi_strip_nullable(field["type"])
    bare in OPENAPI_SCALAR_TYPES && return (:scalar, bare, nullable)
    haskey(OPENAPI_COMPOUND_MEMBERS, bare) && return (:compound, bare, nullable)
    bare in OPENAPI_REFERENCE_TYPES && return (:reference, bare, nullable)
    bare in OPENAPI_ENUM_TYPES && return (:enum, bare, nullable)
    bare in OPENAPI_CURVE_TYPES && return (:curve, bare, nullable)
    bare in OPENAPI_COST_TYPES && return (:cost, bare, nullable)
    bare in OPENAPI_NESTED_TYPES && return (:nested, bare, nullable)

    inner = match(r"^Vector\{(.+)\}$", bare)
    if !isnothing(inner)
        element = String(inner.captures[1])
        element in OPENAPI_REFERENCE_TYPES && return (:reference_vector, element, nullable)
        element in OPENAPI_ENUM_TYPES && return (:enum_vector, element, nullable)
    end

    dict = match(r"^Dict\{(.+?),\s*(.+)\}$", bare)
    if !isnothing(dict)
        key = String(dict.captures[1])
        value = String(dict.captures[2])
        if key in OPENAPI_ENUM_TYPES
            haskey(OPENAPI_COMPOUND_MEMBERS, value) &&
                return (:enum_compound_dict, (key, value), nullable)
            value in OPENAPI_SCALAR_TYPES && return (:enum_dict, key, nullable)
        end
    end
    # A capacity bound: a single `MinMax`, or a per-topology map of `MinMax` bounds keyed by
    # a base-system topology reference (a value `oneOf`/`anyOf` on the wire). Resolved
    # through the field-specific `AnyOf` wrapper the platform model generates.
    bare == "Union{MinMax, Dict{PSY.Topology, MinMax}}" &&
        return (:union_bound, bare, nullable)

    throw(
        DataFormatError(
            "$struct_name field=$name type=$(field["type"]) has no determinable " *
            "OpenAPI converter kind (not a scalar, compound, reference, enum, curve, " *
            "cost, or nested struct declared in the generator's tables)",
        ),
    )
end

"""
Wrap an import expression that would index into a `nothing` PO field.
"""
function openapi_nullable_wrap(name, body)
    return "(if isnothing(po.$name); nothing; else; $body; end)"
end

# `openapi_classify_field` computes `nullable` for every kind, but only `:compound` and
# `:curve` have a nullable emission (and `:reference` raises its own, more specific error on
# the export side). The kinds listed here would emit code that indexes or converts
# `nothing` — `PRIMEMOVERS_FROM_STRING[nothing]`, `convert_cost(nothing)` — and surface as a
# `MethodError` at load time rather than a generation failure. `:scalar` is deliberately
# absent: `nothing` passes straight through `po.x` and through the PO field's own
# `Union{Nothing, T}`, so a nullable scalar is already correct in both directions.
const OPENAPI_NULLABLE_UNSUPPORTED_KINDS = Set([
    :reference_vector,
    :enum,
    :enum_vector,
    :enum_dict,
    :enum_compound_dict,
    :cost,
    :nested,
])

"""
Raise when a field is nullable and its kind has no nullable emission rule, naming the
driver that would otherwise emit `nothing`-indexing code.
"""
function openapi_check_nullable(struct_name, name, kind, nullable, driver)
    if nullable && kind in OPENAPI_NULLABLE_UNSUPPORTED_KINDS
        throw(
            DataFormatError(
                "$struct_name field=$name kind=$kind is nullable, and $driver has no " *
                "nullable emission for that kind; add the nullable helper to " *
                "src/openapi/converters.jl and teach the driver to call it before " *
                "making this field nullable in the descriptor",
            ),
        )
    end
    return nothing
end

"""
The export-direction accessor call for one field. A field the descriptor marks
`needs_conversion` gets only the units-taking accessor `get_x(value, units)`; a field
without it gets only `get_x(value)`. This must read the same `needs_conversion` key the
accessor generation reads or the emitted call is a `MethodError` at run time.
"""
function openapi_export_getter_call(field)
    name = field["name"]
    if get(field, "needs_conversion", false)
        return "get_$name(value, IS.NU)"
    end
    return "get_$name(value)"
end

"""
Build the `from_openapi` kwargs for one struct, storing them on `item` for the template.
Enums cross the wire as strings and are rebuilt inline with the enum type's own string
constructor (`ThermalFuels(po.fuel)`), so there are no lookup tables to register.
"""
function compute_openapi_converter!(item)
    struct_name = item["struct_name"]
    kwargs = Vector{Dict{String, Any}}()

    for field in item["properties"]
        kind, bare, nullable = openapi_classify_field(struct_name, field)
        kind == :skip && continue
        name = String(field["name"])
        expr = openapi_import_expr(struct_name, name, kind, bare, nullable)
        push!(kwargs, Dict("name" => name, "expr" => expr))
    end

    item["openapi_kwargs"] = kwargs
    return item
end

function openapi_import_expr(struct_name, name, kind, bare, nullable)
    openapi_check_nullable(struct_name, name, kind, nullable, "openapi_import_expr")
    if kind == :scalar
        return "po.$name"
    end
    if kind == :compound
        # No nullable branch: the extractor's ::Nothing method is the guard.
        return "$(OPENAPI_COMPOUND_EXTRACTORS[bare])(po.$name)"
    end
    if kind == :reference
        return "resolve_ref(refs, po.$name, $bare)"
    end
    if kind == :reference_vector
        return "resolve_refs(refs, po.$name, $bare)"
    end
    if kind == :enum
        return "$bare(po.$name)"
    end
    if kind == :enum_vector
        return "[$bare(v) for v in po.$name]"
    end
    if kind == :enum_dict
        return "Dict($bare(k) => v for (k, v) in po.$name)"
    end
    if kind == :enum_compound_dict
        key, value = bare
        extractor = OPENAPI_COMPOUND_EXTRACTORS[value]
        return "Dict($key(k) => $extractor(v) for (k, v) in po.$name)"
    end
    if kind == :curve
        if nullable
            return "_value_curve_optional(po.$name)"
        end
        return "convert_value_curve(po.$name)"
    end
    if kind == :cost
        # `convert_cost` returns one of many cost types and reads an `Any`-typed oneOf
        # wrapper, so the call infers as `Any`. The descriptor states the field's type.
        return "convert_cost(po.$name)::$bare"
    end
    if kind == :nested
        return "convert_nested_data(po.$name)"
    end
    if kind == :union_bound
        return "_capacity_bound_from_po(po.$name, refs)"
    end
    throw(
        DataFormatError(
            "$struct_name field=$name kind=$kind has no emission rule in " *
            "openapi_import_expr; the classifier learned a kind the import driver " *
            "was not taught",
        ),
    )
end

"""
Build the `to_openapi` kwargs for one struct, storing them on `item` for the template.
The mirror of [`compute_openapi_converter!`](@ref): same classification, same single
pass, opposite direction. Enums cross the wire as strings via `string(get_x(value))`, so
there are no lookup tables to register.
"""
function compute_openapi_export_converter!(item)
    struct_name = item["struct_name"]
    kwargs = Vector{Dict{String, Any}}()
    parametric = get(item, "has_parametric", false)

    # `id` is not a descriptor field — it is the object's own identity, now stored in
    # `internal` and read back by `get_id`. It is prepended directly rather than discovered
    # by iterating `item["fields"]`. Reference fields still resolve through `refs`, but an
    # object's own id no longer needs the reflexive registry lookup.
    push!(kwargs, Dict("name" => "id", "expr" => "get_id(value)"))
    for field in item["properties"]
        kind, bare, nullable = openapi_classify_field(struct_name, field)
        kind == :skip && continue
        name = String(field["name"])
        expr = openapi_export_expr(struct_name, field, kind, bare, nullable, parametric)
        push!(kwargs, Dict("name" => name, "expr" => expr))
    end

    item["openapi_export_kwargs"] = kwargs
    return item
end

function openapi_export_expr(struct_name, field, kind, bare, nullable, parametric)
    name = String(field["name"])
    openapi_check_nullable(struct_name, name, kind, nullable, "openapi_export_expr")
    getter = openapi_export_getter_call(field)
    if kind == :scalar
        # Return parametric type for power_systems_type field
        if parametric && name == "power_systems_type"
            return "string(nameof(T))"
        end
        return getter
    end
    if kind == :compound
        ctors = OPENAPI_COMPOUND_CTORS[bare]
        if nullable
            return "$(ctors.optional)($getter)"
        end
        return "$(ctors.required)($getter)"
    end
    if kind == :reference
        if nullable
            throw(
                DataFormatError(
                    "$struct_name field=$name is a nullable reference, and no " *
                    "`_component_id_optional` helper exists in src/openapi/" *
                    "converters.jl for the generator to call; add one there before " *
                    "making a reference field nullable in the descriptor",
                ),
            )
        end
        return "component_id(refs, $getter)"
    end
    if kind == :reference_vector
        return "component_ids(refs, $getter)"
    end
    if kind == :enum
        return "string($getter)"
    end
    if kind == :enum_vector
        return "[string(v) for v in $getter]"
    end
    if kind == :enum_dict
        return "Dict(string(k) => v for (k, v) in $getter)"
    end
    if kind == :enum_compound_dict
        key, value = bare
        ctor = OPENAPI_COMPOUND_CTORS[value].required
        return "Dict(string(k) => $ctor(v) for (k, v) in $getter)"
    end
    if kind == :curve
        if nullable
            return "_value_curve_po_optional($getter)"
        end
        return "convert_value_curve_to_openapi($getter)"
    end
    if kind == :cost
        return "convert_cost_to_openapi($getter)"
    end
    if kind == :nested
        return "convert_nested_data_to_openapi($getter)"
    end
    if kind == :union_bound
        # The platform model names the AnyOf wrapper `<StructName><CamelCasedField>`.
        union_type = struct_name * join(uppercasefirst.(split(name, "_")))
        return "PI.$union_type(_capacity_bound_po_value($getter, refs))"
    end
    throw(
        DataFormatError(
            "$struct_name field=$name kind=$kind has no emission rule in " *
            "openapi_export_expr; the classifier learned a kind the export driver " *
            "was not taught",
        ),
    )
end

function read_json_data(filename::String)
    try
        return JSONSchema.Schema(JSON3.read(filename))
    catch
        throw(DataFormatError("$filename has invalid format"))
    end
end

function generate_invest_structs(directory, data::JSONSchema.Schema; print_results=true)
    struct_names = Vector{String}()
    unique_accessor_functions = Set{String}()
    unique_setter_functions = Set{String}()

    for input in data.data["components"]
        struct_name = input["name"]
        properties = input["properties"]
        item = Dict{String, Any}()
        item["properties"] = properties
        item["has_internal"] = false
        item["has_null_values"] = true
        item["supertype"] = input["supertype"]

        accessors = Vector{Dict}()
        setters = Vector{Dict}()

        item["has_non_default_values"] = false

        item["constructor_func"] = struct_name
        item["struct_name"] = struct_name
        item["closing_constructor_text"] = ""

        # Whether to emit `from_openapi`/`to_openapi` for this struct. Opt-out, because most
        # structs here mirror a schema: a descriptor entry sets `"openapi": false` when the
        # struct is a portfolio-only concept with no counterpart in SiennaSchemas, and so no
        # `PI.<Name>` to convert against. `Zone`/`Node` are that case since the schemas
        # dropped the Regions folder (SiennaSchemas 51f872e) -- they remain real PSIP types,
        # reachable through `RegionTopology` and the DB parser, but they do not ride in an
        # OpenAPI document.
        item["has_openapi"] = get(input, "openapi", true)

        item["has_parametric"] = false
        if haskey(input, "parametric")
            item["parametric"] = input["parametric"]
            item["constructor_func"] *= "{T}"
            item["closing_constructor_text"] = " where T <: $(item["parametric"])"
            item["has_parametric"] = true
        end

        if haskey(input, "docstring")
            item["docstring"] = input["docstring"]
        end

        parameters = Vector{Dict}()
        for values in properties
            param = Dict{String, Any}()

            param["struct_name"] = item["struct_name"]
            param["name"] = values["name"]
            param["data_type"] = values["type"]
            param["comment"] = get(values, "description", "")
            param["exclude_getter"] = get(values, "exclude_getter", false)
            param["conversion_unit"] = get(values, "conversion_unit", "nothing")
            param["needs_conversion"] = get(values, "needs_conversion", false)

            if haskey(param, "valid_range")
                if typeof(param["valid_range"]) == Dict{String, Any}
                    min = param["valid_range"]["min"]
                    max = param["valid_range"]["max"]
                    param["valid_range"] = "($min, $max)"
                elseif typeof(param["valid_range"]) == String
                    param["valid_range"] = param["valid_range"]
                end
            end
            push!(parameters, param)

            # Allow accessor functions to be re-implemented from another module.
            # If this key is defined then the accessor function will not be exported.
            # Example:  get_name is defined in InfrastructureSystems and re-implemented in
            # PowerSystems.
            if haskey(param, "accessor_module")
                accessor_module = param["accessor_module"] * "."
                create_docstring = false
            else
                accessor_module = ""
                create_docstring = true
            end

            accessor_name = accessor_module * "get_" * param["name"]
            setter_name = accessor_module * "set_" * param["name"] * "!"

            conversion_unit = get(param, "conversion_unit", "nothing")
            include_getter = !get(param, "exclude_getter", false)
            if include_getter
                push!(
                    accessors,
                    Dict(
                        "name" => param["name"],
                        "accessor" => accessor_name,
                        "create_docstring" => create_docstring,
                        "needs_conversion" => get(param, "needs_conversion", false),
                        "conversion_unit" => conversion_unit,
                        "display_units" => get(param, "display_units", "NU"),
                        "units_type_sig" => if haskey(item, "parametric")
                            "Type{$(item["struct_name"]){T}}"
                        else
                            "Type{$(item["struct_name"])}"
                        end,
                        "units_bound" => get(item, "parametric", false),
                    ),
                )
            end

            include_setter = !get(param, "exclude_setter", false)
            if include_setter
                push!(
                    setters,
                    Dict(
                        "name" => param["name"],
                        "setter" => setter_name,
                        "data_type" => param["data_type"],
                        "create_docstring" => create_docstring,
                        "needs_conversion" => get(param, "needs_conversion", false),
                        "conversion_unit" => conversion_unit,
                    ),
                )
            end

            if param["name"] != "internal" && accessor_module == ""
                push!(unique_accessor_functions, accessor_name)
                push!(unique_setter_functions, setter_name)
            end

            param["kwarg_value"] = ""
            if !isnothing(get(values, "default", nothing))
                param["default"] = values["default"]
                param["kwarg_value"] = "=" * param["default"]
            elseif !isnothing(get(param, "internal_default", nothing))
                param["kwarg_value"] = "=" * string(param["internal_default"])
                item["has_internal"] = true
                continue
            else
                item["has_non_default_values"] = true
            end

            # This controls whether a demo constructor will be generated.
            if isnothing(get(param, "null_value", nothing)) &&
               isnothing(get(param, "default", nothing))
                item["has_null_values"] = false
            else
                if isnothing(get(param, "null_value", nothing))
                    item["null_value"] = param["default"]
                end
                if param["data_type"] == "String"
                    param["quotes"] = true
                end
            end
        end

        item["parameters"] = parameters
        item["accessors"] = accessors
        item["setters"] = setters

        # If all parameters have defaults then the positional constructor will
        # collide with the kwarg constructor.
        item["needs_positional_constructor"] =
            item["has_internal"] && item["has_non_default_values"]

        compute_openapi_converter!(item)
        compute_openapi_export_converter!(item)

        filename = joinpath(directory, item["struct_name"] * ".jl")

        open(filename, "w") do io
            write(io, strip(MU.render(STRUCT_TEMPLATE, item)))
            write(io, "\n")

            push!(struct_names, item["struct_name"])
        end

        if print_results
            println("Wrote $filename")
        end
    end

    accessors = sort!(collect(unique_accessor_functions))
    setters = sort!(collect(unique_setter_functions))
    filename = joinpath(directory, "includes.jl")
    open(filename, "w") do io
        for name in struct_names
            write(io, "include(\"$name.jl\")\n")
        end
        write(io, "\n")

        for accessor in accessors
            write(io, "export $accessor\n")
        end
        for setter in setters
            write(io, "export $setter\n")
        end
        if print_results
            println("Wrote $filename")
        end
    end
end

function generate_structs(
    input_file::AbstractString,
    output_directory::AbstractString;
    print_results=true,
)
    # Include each generated file.
    if !isdir(output_directory)
        mkdir(output_directory)
    end

    data = read_json_data(input_file)
    generate_invest_structs(output_directory, data; print_results=print_results)
    return
end

end # module StructGeneration
