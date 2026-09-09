# `IS.serialize` reaches each component through `IS.serialize(::IS.SystemData)`, which hands
# it no portfolio, but `to_openapi` needs the document's id registry. The registry for one
# `IS.serialize(::Portfolio)` call therefore lives in task-local storage for its duration:
# task-scoped so two portfolios serialized on different threads cannot see each other's
# registry, re-entrant, and unwound on throw without an explicit `finally`.
const _EXPORT_REFS_KEY = :psip_openapi_export_refs

function _active_export_refs()
    storage = task_local_storage()
    if !haskey(storage, _EXPORT_REFS_KEY)
        error(
            "no active OpenAPI export registry: a PSIP component resolves its references " *
            "by document id, which only a Portfolio can supply, so a component cannot be " *
            "serialized on its own. Serialize the owning portfolio instead — " *
            "`to_json(portfolio, filename)` or `to_json(portfolio)`.",
        )
    end
    return storage[_EXPORT_REFS_KEY]
end
function IS.serialize(portfolio::T) where {T <: Portfolio}
    refs = _build_export_refs(portfolio)
    return task_local_storage(_EXPORT_REFS_KEY, refs) do
        data = Dict{String, Any}()
        data["data_format_version"] = DATA_FORMAT_VERSION
        for field in fieldnames(T)
            # Exclude time_series_directory because the portfolio may get deserialized on a
            # different portfolio. `aggregation` is written below instead, in a form that
            # does not depend on the writing session's module scope.
            if !(field in [:time_series_directory, :base_system, :aggregation])
                data[string(field)] = serialize(getfield(portfolio, field))
            end
        end
        data["aggregation"] = _serialize_type_name(get_aggregation(portfolio))
        return data
    end
end
function IS.serialize(schedule::InvestmentScheduleResults)
    start_dates = Vector{String}()
    end_dates = Vector{String}()
    capacity_data = Vector{Vector{Dict{String, Any}}}()
    for (period, investments) in schedule.results
        push!(start_dates, string(period[1]))
        push!(end_dates, string(period[2]))

        installation_list = Vector{Dict{String, Any}}()
        for (technology, capacity) in investments
            installation = Dict{String, Any}(
                "technology" => string(nameof(technology[1])),
                "parameter" => string(nameof((only(technology[1].parameters)))),
                "name" => technology[2],
                "installations" => capacity,
            )
            push!(installation_list, installation)
        end
        push!(capacity_data, installation_list)
    end
    return Dict{String, Any}(
        "start_dates" => start_dates,
        "end_dates" => end_dates,
        "results" => capacity_data,
    )
end
"""
Rendering goes through `OpenAPI.to_json` rather than `JSON3.write` because only the former
unwraps the `oneOf` wrappers and stamps their discriminators.
"""
function _serialize_openapi(component)
    # Rejected on write as well as on read: a type absent from the plans would otherwise
    # be emitted happily and then refused by `deserialize_components!`, producing a
    # document that cannot be read back. `Base.typename(...).wrapper` is the plan key for
    # a parametric type, matching what `_group_by_serialized_type` resolves to.
    _openapi_wire_type(Base.typename(typeof(component)).wrapper)
    po = to_openapi(component, _active_export_refs())
    data = JSON3.read(OpenAPI.to_json(po), Dict{String, Any})
    add_serialization_metadata!(data, typeof(component))
    return data
end
IS.serialize(value::Technology) = _serialize_openapi(value)
IS.serialize(value::Requirement) = _serialize_openapi(value)

# PSIP's supplemental attributes subtype `IS.SupplementalAttribute` directly, with no PSIP
# supertype of their own, so dispatching on the abstract type would pirate every other
# package's attributes. One method per declared type instead, driven by the same plan the
# deserialize side reads.
for (attribute_type, _key) in SUPPLEMENTAL_ATTRIBUTE_PLAN
    @eval IS.serialize(value::$attribute_type) = _serialize_openapi(value)
end
"""
Add type information to the dictionary that can be used to deserialize the value.

A parametric component's type parameter is not recorded here: it travels in the payload's
own `power_systems_type` field, which `from_openapi` reads.
"""
function add_serialization_metadata!(data::Dict, ::Type{T}) where {T}
    data[METADATA_KEY] = Dict{String, Any}(
        TYPE_KEY => string(nameof(T)),
        MODULE_KEY => string(parentmodule(T)),
    )
    return
end
"""
Write a `Type`-valued field, such as `Portfolio.aggregation`, in the `"Module.Type"` form
[`_deserialize_type_name`](@ref) requires.

Emitted explicitly rather than left to the generic `serialize` path: `IS` has no
`serialize(::Type)` method, so the raw `DataType` would reach JSON3, which stringifies it
through `show` — and `show` resolves a type name against `Base.active_module()`. A writer
with `using PowerSystems` in scope would then emit the bare `"ACBus"` and a writer with
`import PowerSystems as PSY` the qualified `"PowerSystems.ACBus"`, making the document
depend on the writing session's scope and unreadable in the first case.
"""
_serialize_type_name(T::Type) = string(parentmodule(T), '.', nameof(T))
function _build_export_refs(portfolio::Portfolio)
    refs = OpenAPIRefs()
    _register_base_system_topology!(refs, portfolio.base_system)
    for (psip_type, _key) in DOCUMENT_PLAN
        for component in IS.get_components(psip_type, portfolio.data)
            refs[get_id(component)] = component
        end
    end
    return refs
end
