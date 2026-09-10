# Descriptor <-> platform OpenAPI model field parity. The descriptor drives PSIP's
# Julia structs and the platform package drives the wire format; a field present in
# one and absent from the other is a silent data-loss bug, so it fails here instead.
@testset "descriptor and PowerInvestmentsOpenAPIModels agree on fields" begin
    descriptor =
        JSON3.read(joinpath(BASE_DIR, "src", "descriptors", "SiennaInvestSchema.json"))
    skipped = Set(["ext", "internal", "requirements"])
    for component in descriptor["components"]
        name = String(component["name"])
        po_type = getproperty(PSIP.PI, Symbol(name))
        po_fields = Set(String(f) for f in fieldnames(po_type))
        descriptor_fields = Set(
            String(p["name"]) for
            p in component["properties"] if !(String(p["name"]) in skipped)
        )
        missing_on_po = setdiff(descriptor_fields, po_fields)
        @test isempty(missing_on_po)
        if !isempty(missing_on_po)
            @error "descriptor fields absent from the OpenAPI model" name missing_on_po
        end
    end
end

# Matching names are not enough. The OpenAPI read path does no discriminator validation:
# `OpenAPI.from_json(PC.RenewableGenerationCost, thermal_json)` succeeds, and the value
# comes back as a *different* cost type with fields dropped and nothing raised. So a
# descriptor field whose declared Julia type is wider than the PO's is silent data loss,
# and a `:cost` field pointed at a PO type outside the family `src/openapi/converters.jl`
# emits cannot be read back at all. Both are type drift, and this is where they fail.
const OPENAPI_PARITY_COST_PO_TYPES = Dict(
    # `GenericOperationCost` is the oneOf spanning the whole cost family, so and only so
    # may the descriptor stay at the abstract `PSY.OperationalCost`.
    "PSY.OperationalCost" => "GenericOperationCost",
    "PSY.ThermalGenerationCost" => "ThermalGenerationCost",
    "PSY.RenewableGenerationCost" => "RenewableGenerationCost",
    "PSY.StorageCost" => "StorageCost",
    "IS.ProductionVariableCostCurve" => "ProductionVariableCostCurve",
)

const OPENAPI_PARITY_REFERENCE_PO_TYPE = "Int64"

"""
The OpenAPI model type a descriptor field of this classification must carry. Driven by the
generator's own `openapi_classify_field` so the guard and the emitted converters cannot
disagree about what a field is.
"""
function openapi_parity_expected_po_type(kind, bare, stripped_type)
    if kind === :scalar
        # The descriptor writes `Int`; the OpenAPI generator writes `Int64`.
        stripped_type == "Int" && return "Int64"
        return stripped_type
    end
    kind === :compound && return stripped_type
    kind === :reference && return OPENAPI_PARITY_REFERENCE_PO_TYPE
    kind === :reference_vector && return "Vector{$OPENAPI_PARITY_REFERENCE_PO_TYPE}"
    # Enums cross the wire as strings, in scalar, vector and dict-key position alike.
    kind === :enum && return "String"
    kind === :enum_vector && return replace(stripped_type, bare => "String")
    kind === :enum_dict && return replace(stripped_type, bare => "String")
    kind === :enum_compound_dict && return replace(stripped_type, bare[1] => "String")
    kind === :curve && return "ValueCurve"
    kind === :cost && return OPENAPI_PARITY_COST_PO_TYPES[bare]
    kind === :nested && return bare
    return error(
        "test bug: no expected OpenAPI type for classification kind=$kind bare=$bare",
    )
end

# The platform model's `_property_types_*` map holds Julia `Type`s (usually wrapped in
# `Union{Nothing, T}`), while the expected side is a module-free type string. Normalize the
# actual type to the same string form: drop the nullable wrapper and every module qualifier.
_parity_strip_nothing(t) = (t isa Union && Nothing <: t) ? Base.nonnothingtype(t) : t
_parity_module_strip(s::AbstractString) = replace(s, r"\b[A-Za-z_][A-Za-z0-9_]*\." => "")

@testset "descriptor and PowerInvestmentsOpenAPIModels agree on field types" begin
    descriptor =
        JSON3.read(joinpath(BASE_DIR, "src", "descriptors", "SiennaInvestSchema.json"))
    generation = PSIP.StructGeneration
    for component in descriptor["components"]
        name = String(component["name"])
        po_type = getproperty(PSIP.PI, Symbol(name))
        po_types = getproperty(PSIP.PI, Symbol("_property_types_$name"))
        for property in component["properties"]
            field = String(property["name"])
            kind, bare, _ = generation.openapi_classify_field(name, property)
            kind === :skip && continue
            actual_type = _parity_strip_nothing(po_types[Symbol(field)])
            # A capacity-bound union maps to a field-specific `AnyOf` wrapper whose exact
            # generated name is not worth pinning; assert it is one rather than a concrete
            # type.
            if kind === :union_bound
                @test occursin("AnyOfAPIModel", string(supertype(actual_type)))
                continue
            end
            stripped, _ = generation.openapi_strip_nullable(String(property["type"]))
            expected = openapi_parity_expected_po_type(kind, bare, stripped)
            actual = _parity_module_strip(string(actual_type))
            @test actual == expected
            if actual != expected
                @error "descriptor and OpenAPI model disagree on a field type" name field kind descriptor_type =
                    String(property["type"]) expected actual
            end
        end
    end
end
