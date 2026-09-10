# Ported from PowerSystems.jl's src/openapi/refs.jl. PSY's version also carries the
# document's unit system and base power; PSIP has one unit representation and no
# system base, so both fields are absent.

function from_openapi end
function to_openapi end

"""
Bidirectional id<->component resolution context for one OpenAPI conversion pass.

Fields:

  - `by_topology_id::Dict{Int, Any}`: Id → base-system topology component (buses, areas,
    load zones, arcs). Seeded from the portfolio's base `PSY.System`.
  - `by_component_id::Dict{Int, Any}`: Id → portfolio component (requirements,
    technologies), populated by `setindex!` as each is converted.
  - `id_by_component::IdDict{Any, Int}`: Component → id, the reverse of both forward maps,
    keyed by object identity (globally unique, so a single map suffices).
  - `deferred_refs::Vector{Function}`: import-only queue of component→component reference
    resolutions a converter could not complete on its first pass (forward or same-type refs),
    drained by [`resolve_deferred_refs!`](@ref). Empty on export.

PSY's `OpenAPIRefs` carries `base_power` and a time-series `store` besides these; PSIP needs
neither — it has one unit representation and no system base, and threads the import store through
a `_with_import_store` scoped value rather than the refs object.

Topology lives in the base `PSY.System` and portfolio components in `portfolio.data`; those
are two independent `InfrastructureSystems` id counters, so their integer ids overlap (both
start at 1). The forward direction is therefore split into two maps and every read names the
family it wants — through the referenced field's declared type — so an id shared by a
topology component and a portfolio component resolves unambiguously to the right one.

Populated in dependency order as components are converted (topology seeded up front, then
requirements before the technologies that reference them, etc.) An id or a component that
has not been registered yet is malformed input, not an absence to tolerate: the typed
[`resolve_ref`](@ref) and [`component_id`](@ref) error loudly naming what was missing rather
than returning `nothing`. Use [`has_ref`](@ref) / [`has_component_id`](@ref) first when
absence is itself a valid outcome to branch on.
"""
struct OpenAPIRefs
    by_topology_id::Dict{Int, Any}
    by_component_id::Dict{Int, Any}
    id_by_component::IdDict{Any, Int}
    deferred_refs::Vector{Function}
end

OpenAPIRefs() =
    OpenAPIRefs(Dict{Int, Any}(), Dict{Int, Any}(), IdDict{Any, Int}(), Function[])

# The forward map for a family. Topology (from the base `PSY.System`) and portfolio
# components (from `portfolio.data`) share an integer id space, so which map applies is
# decided by whether the value/target is a `PSY.Topology`.
_forward_map(refs::OpenAPIRefs, is_topology::Bool) =
    is_topology ? refs.by_topology_id : refs.by_component_id

function Base.setindex!(refs::OpenAPIRefs, component, id::Integer)
    key = Int(id)
    map = _forward_map(refs, component isa PSY.Topology)
    if haskey(map, key)
        error(
            "OpenAPIRefs: duplicate id $key — already registered as " *
            "$(summary(map[key])), cannot register $(summary(component))",
        )
    end
    map[key] = component
    refs.id_by_component[component] = key
    return component
end

# Typed forward lookup, dispatched to the right family map by whether `T <: PSY.Topology`.
function _resolve(refs::OpenAPIRefs, id::Integer, is_topology::Bool)
    key = Int(id)
    map = _forward_map(refs, is_topology)
    if !haskey(map, key)
        error(
            "OpenAPIRefs: unresolved $(is_topology ? "topology" : "component") id $key — " *
            "no component registered under it; expected every referenced component to be " *
            "converted earlier, in dependency order",
        )
    end
    return map[key]
end

function Base.getindex(refs::OpenAPIRefs, ::Integer)
    error(
        "OpenAPIRefs: ambiguous untyped id lookup — topology and portfolio-component ids " *
        "occupy two overlapping id spaces; use the typed resolve_ref(refs, id, T) form",
    )
end

has_ref(refs::OpenAPIRefs, id::Integer) =
    haskey(refs.by_topology_id, Int(id)) || haskey(refs.by_component_id, Int(id))

"""
Resolve an **optional** component reference from a document.

`nothing` in means `nothing` out: a schema-optional reference the document omits is an
absent relationship, not a malformed one. A reference that *is* stated still goes
through the typed lookup and so still errors when it names an unregistered id.
"""
resolve_ref(::OpenAPIRefs, ::Nothing) = nothing
resolve_ref(refs::OpenAPIRefs, id::Integer) = refs[id]

"""
Resolve a reference whose type the descriptor already states, asserting it on the way out.

The forward maps hold `Any`, so the assert costs one type check and turns a document that
points a `Requirement` field at a topology id (or vice-versa) into a failure here, naming
the type, rather than something deeper and less legible. The stated type also selects which
family map (topology vs portfolio component) the id is resolved against.
"""
resolve_ref(::OpenAPIRefs, ::Nothing, ::Type) = nothing
resolve_ref(refs::OpenAPIRefs, id::Integer, ::Type{T}) where {T} =
    _resolve(refs, id, T <: PSY.Topology)::T


"""
Resolve a list of references whose element type the descriptor states.

Builds the `Vector{T}` the field already declares, so an omitted list is `T[]` rather than
an `Any[]` that has to be re-typed on assignment.
"""
resolve_refs(::OpenAPIRefs, ::Nothing, ::Type{T}) where {T} = T[]
resolve_refs(refs::OpenAPIRefs, ids, ::Type{T}) where {T} =
    T[_resolve(refs, id, T <: PSY.Topology)::T for id in ids]

function component_id(refs::OpenAPIRefs, component)
    if !haskey(refs.id_by_component, component)
        error(
            "OpenAPIRefs: component $(summary(component)) has no registered id — it " *
            "was never passed through setindex!",
        )
    end
    return refs.id_by_component[component]
end

component_ids(refs::OpenAPIRefs, components) =
    Int[component_id(refs, c) for c in components]

has_component_id(refs::OpenAPIRefs, component) = haskey(refs.id_by_component, component)

"""
Defer a component→component reference a `from_openapi` converter cannot resolve on its own
first pass: either a genuine forward reference (the referenced type converts later in
`DOCUMENT_PLAN`) or a same-type reference (the referenced component is of the SAME type,
converted earlier or later within that type's own document-key pass, so no `DOCUMENT_PLAN`
reordering could express it — a cascading `HydroReservoir` chain is the motivating case).

A converter facing either one constructs its component with that field left at its own
empty/`nothing` default, then calls `defer_ref!(refs, f)` with a zero-argument `f` that
performs the resolution (typically closing over the constructed component, `refs`, and the
raw ids still to resolve) via a mutating setter. `f` runs later, from
[`resolve_deferred_refs!`](@ref), once every component in the document is registered — a raw
id still unresolvable then is genuinely absent from the document and errors from `refs`'s own
`getindex`, not from here.
"""
defer_ref!(refs::OpenAPIRefs, f) = push!(refs.deferred_refs, f)

"""
Run every reference resolution queued by [`defer_ref!`](@ref), in the order queued, then clear
the queue. Called once, after every component in the document has converted and registered —
see `from_openapi(::Type{System}, doc)` in `import_document.jl`.
"""
function resolve_deferred_refs!(refs::OpenAPIRefs)
    for f in refs.deferred_refs
        f()
    end
    empty!(refs.deferred_refs)
    return nothing
end