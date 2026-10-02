# Descriptor <-> platform OpenAPI model parity. The descriptor drives PSIP's Julia structs and
# the platform package drives the wire format; a field present in one and absent from the
# other, or carried as a different type, is a silent data-loss bug — so it fails here instead.
#
# Three layers, each catching what the one before cannot:
#   1. field names — every descriptor field exists on the platform model;
#   2. field types — every field's wire type is what the generator emits for its kind, with
#      the expectation derived from the generator's own tables so the two cannot drift;
#   3. round trip — every document and supplemental-attribute type actually survives
#      `to_file`/`from_file`, since a name and a type can both match while the emitted
#      converter still cannot construct the wire struct.

const _PARITY_DESCRIPTOR_FILE =
    joinpath(BASE_DIR, "src", "descriptors", "SiennaInvestSchema.json")
const _PARITY_SKIPPED_FIELDS = Set(["ext", "internal", "requirements"])

@testset "descriptor and PowerInvestmentsOpenAPIModels agree on fields" begin
    descriptor = JSON3.read(_PARITY_DESCRIPTOR_FILE)
    for component in descriptor["components"]
        name = String(component["name"])
        po_type = getproperty(PSIP.PI, Symbol(name))
        po_fields = Set(String(f) for f in fieldnames(po_type))
        descriptor_fields = Set(
            String(p["name"]) for p in component["properties"] if
            !(String(p["name"]) in _PARITY_SKIPPED_FIELDS)
        )
        missing_on_po = setdiff(descriptor_fields, po_fields)

        @test isempty(missing_on_po)
        if !isempty(missing_on_po)
            @error "descriptor fields absent from the OpenAPI model" name missing_on_po
        end
    end
end

"""
The value type a platform-model field carries once its optionality is removed: every optional
field is `Union{Nothing, Absent, T}`, and only `T` describes the wire shape. Errors on a union
that leaves more than one member, which no generated model declares.
"""
function _parity_wire_type(T)
    members =
        filter(t -> t !== Nothing && t !== PSIP.IC.Absent, collect(Base.uniontypes(T)))
    length(members) == 1 ||
        error("test bug: $T has $(length(members)) non-optional members")
    return only(members)
end

"""
Module-free spelling of a type, so `PowerCoreOpenAPIModels.MinMax` compares as `MinMax`.
"""
_parity_type_name(T) = replace(string(T), r"\b[A-Za-z_][A-Za-z0-9_]*\." => "")
_parity_type_name(name::AbstractString) = replace(name, r"\b[A-Za-z_][A-Za-z0-9_]*\." => "")

"""
The module-free wire type name a descriptor field of this classification must carry, derived
from the generator's own tables (`OPENAPI_ENUM_WIRE_TYPES`, `openapi_field_wrapper_type`,
`openapi_cost_needs_wrapper`) so the guard and the emitted converters cannot disagree.
"""
function _parity_expected_type(generation, struct_name, field, kind, bare, stripped_type)
    enum_wire(enum) =
        _parity_type_name(get(generation.OPENAPI_ENUM_WIRE_TYPES, enum, "String"))
    wrapper = generation.openapi_field_wrapper_type(struct_name, field)
    kind === :scalar && return stripped_type == "Int" ? "Int64" : stripped_type
    kind === :compound && return stripped_type
    kind === :reference && return "Int64"
    kind === :reference_vector && return "Vector{Int64}"
    kind === :enum && return enum_wire(bare)
    kind === :enum_vector && return "Vector{$(enum_wire(bare))}"
    kind === :enum_dict && return "Dict{String, $(split(stripped_type, ", ")[2])"
    kind === :enum_compound_dict && return "$(bare[2])ByKey"
    kind === :nested && return bare
    kind in (:keyed_map, :curve, :union_bound) && return wrapper
    if kind === :cost
        generation.openapi_cost_needs_wrapper(bare) && return wrapper
        return _parity_type_name(bare)
    end
    return error("test bug: no expected OpenAPI type for kind=$kind bare=$bare")
end

"""
The shape the wrapper kinds must have beyond their name: a `oneOf` for curves, abstract costs and
capacity bounds (unwrapped by `convert_value_curve`/`convert_cost`/`_capacity_bound_from_po`),
and an `additional_properties` map of the descriptor's value type for a `:keyed_map`.
"""
function _parity_wrapper_shape_ok(generation, kind, bare, wire_type)
    kind in (:curve, :union_bound) && return wire_type <: PSIP.IC.OneOfAPIModel
    if kind === :cost && generation.openapi_cost_needs_wrapper(bare)
        return wire_type <: PSIP.IC.OneOfAPIModel
    end
    if kind === :keyed_map
        hasfield(wire_type, :additional_properties) || return false
        return _parity_type_name(fieldtype(wire_type, :additional_properties)) == bare
    end
    return true
end

@testset "descriptor and PowerInvestmentsOpenAPIModels agree on field types" begin
    descriptor = JSON3.read(_PARITY_DESCRIPTOR_FILE)
    generation = PSIP.StructGeneration
    for component in descriptor["components"]
        name = String(component["name"])
        po_type = getproperty(PSIP.PI, Symbol(name))
        for property in component["properties"]
            field = String(property["name"])
            kind, bare, _ = generation.openapi_classify_field(name, property)
            kind === :skip && continue
            wire_type = _parity_wire_type(fieldtype(po_type, Symbol(field)))
            stripped, _ = generation.openapi_strip_nullable(String(property["type"]))
            expected = _parity_expected_type(generation, name, field, kind, bare, stripped)
            actual = _parity_type_name(wire_type)
            shape_ok = _parity_wrapper_shape_ok(generation, kind, bare, wire_type)
            @test actual == expected
            @test shape_ok
            if actual != expected || !shape_ok
                @error "descriptor and OpenAPI model disagree on a field type" name field kind descriptor_type =
                    String(property["type"]) expected actual shape_ok
            end
        end
    end
end

# ── round trip ──────────────────────────────────────────────────────────────────

"""
The 5-bus portfolio plus every document type it does not already hold, with the optional
`RetirementPotential` maps populated so the `:keyed_map` path carries data rather than `{}`.
"""
function _parity_roundtrip_portfolio()
    portfolio = build_portfolio()
    base = PSIP.get_base_system(portfolio)
    supply = PSIP.get_technology(
        SupplyTechnology{PSY.ThermalStandard},
        portfolio,
        "cheap_thermal",
    )
    storage = first(PSIP.get_technologies(StorageTechnology, portfolio))
    financial_data = PSIP.get_financial_data(supply)
    buses = collect(PSY.get_components(PSY.ACBus, base))

    PSIP.add_technology!(
        portfolio,
        ColocatedSupplyStorageTechnology{PSY.RenewableDispatch}(;
            name="parity_colocated",
            financial_data=financial_data,
            power_systems_type="RenewableDispatch",
            operation_costs_inverter=CostCurve(LinearCurve(0.8)),
            inverter_efficiency=0.96,
            inverter_supply_ratio=1.0,
            capital_costs_inverter=PSIP.CapitalCost(LinearCurve(70.0), 0.0),
            available=true,
            region=PSIP.get_region(supply),
            supply_technology=supply,
            storage_technology=storage,
        ),
    )
    PSIP.add_technology!(
        portfolio,
        NodalHVDCTransportTechnology{PSY.ACBranch}(;
            name="parity_hvdc",
            start_node=buses[1],
            end_node=buses[2],
            financial_data=financial_data,
            power_systems_type="ACBranch",
            available=true,
        ),
    )

    retirement = first(IS.get_supplemental_attributes(RetirementPotential, supply))
    PSIP.set_planned_retirement_year!(retirement, Dict("unit_a" => 2035))
    PSIP.set_build_year!(retirement, Dict("unit_a" => 1990, "unit_b" => 2001))
    return portfolio
end

"""
Every `to_openapi` payload of `T` in `portfolio`, as plain JSON keyed by component name.
"""
function _parity_payloads(portfolio, ::Type{T}) where {T}
    refs = PSIP._build_export_refs(portfolio)
    components = if T <: IS.SupplementalAttribute
        IS.get_supplemental_attributes(T, portfolio.data)
    else
        collect(PSIP._plan_components(portfolio, T))
    end
    return Dict(
        string(IS.get_id(c)) =>
            JSON3.read(JSON3.write(PSIP.IC.encode(PSIP.to_openapi(c, refs))), Dict) for
        c in components
    )
end

@testset "every document type round trips through to_file/from_file" begin
    portfolio = _parity_roundtrip_portfolio()
    plan = vcat(PSIP.DOCUMENT_PLAN, PSIP.SUPPLEMENTAL_ATTRIBUTE_PLAN)

    mktempdir() do dir
        path = joinpath(dir, "parity.json")
        PSIP.to_file(portfolio, path; force=true)
        portfolio2 = PSIP.from_file(path)

        for (T, key) in plan
            before = _parity_payloads(portfolio, T)
            after = _parity_payloads(portfolio2, T)
            # Coverage: a type this portfolio does not hold is not exercised at all.
            @test !isempty(before)
            isempty(before) && @error "round-trip fixture holds no $key"
            @test keys(after) == keys(before)
            for (id, payload) in before
                @test get(after, id, nothing) == payload
                get(after, id, nothing) == payload ||
                    @error "$key id=$id changed across the round trip" payload after =
                        get(after, id, nothing)
            end
        end

        supply = PSIP.get_technology(
            SupplyTechnology{PSY.ThermalStandard},
            portfolio2,
            "cheap_thermal",
        )
        retirements = IS.get_supplemental_attributes(RetirementPotential, supply)
        @test any(
            r -> PSIP.get_build_year(r) == Dict("unit_a" => 1990, "unit_b" => 2001),
            retirements,
        )
    end
end
