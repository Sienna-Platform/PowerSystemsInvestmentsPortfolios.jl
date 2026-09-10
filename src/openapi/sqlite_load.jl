# Hand-written (not generated): the loader that carries the document's supplemental
# attribute, plant, combined-cycle, and requirement association rows into IS. Called by
# `from_openapi(::Type{Portfolio}, doc)` in `src/openapi/import_document.jl`. Time series are
# not loaded here — the sidecar store is adopted whole.
#
# Reuses import_document.jl's per-type attribute conversion (the 2-arg
# `from_openapi(po, refs)` methods), attach dispatch (`_attach_attribute!`), and
# requirement-membership dispatch (`_attach_requirement_membership!`); this file is `include`d into
# the same `PowerSystems` module.

"""
Group indices for (plant_id, entity_id) pairs. `PortfolioDocument` carries no plant-family
association tables (they were dropped from the Investments schema — PSIP has no plant or
combined-cycle attribute types), so there are no group indices: this is always empty. Kept as a
seam so `_attach_attribute!` can stay group-index-aware if a plant-family type is ever added.
"""
_group_index_by_pair(::PD.PortfolioDocument) = Dict{Tuple{Int, Int}, Vector{Int}}()

"""
Loud error naming `id` when the document's declared `attribute_type` is absent or does
not match `nameof(typeof(resolved))`.
"""
function _check_resolved_type_matches(resolved, declared_type, id)
    isnothing(declared_type) && error(
        "load_supplemental_attribute_associations!: association referencing id=$id has " *
        "no attribute_type",
    )
    actual = string(nameof(typeof(resolved)))
    declared_type == actual || error(
        "load_supplemental_attribute_associations!: id=$id declares attribute_type=" *
        "\"$declared_type\" but resolved to a $actual",
    )
    return nothing
end

"""
$(TYPEDSIGNATURES)

Attach every row of `doc.supplemental_attribute_associations` and `doc.requirement_associations`
into `portfolio`.

One PSY attribute object per `attribute_id`, memoized in `converted`: the first time an
`attribute_id` is seen, its document id is set onto the built object with `IS.set_id!`
before it is ever attached — mirroring how a component is set to its document id before
`add_component!` in `import_document.jl`. Components and supplemental attributes share one
id stream, so an attribute's document id can never collide with a component's. The object is
then registered into `refs` under that id, so `refs[id]` covers supplemental attributes the
way it already covers components.

Every attach goes through [`_attach_attribute!`](@ref) (`import_document.jl`), which writes
an association row only for pairs the store does not already hold. A plant-family attribute's
group numbers for a given entity come from the matching
`plant_associations`/`combined_cycle_associations` rows (there is always at least one — see
[`_group_index_by_pair`](@ref)); every other attribute passes `nothing`.

Errors, naming the id, when: an association's `entity_id`/`attribute_id`/`requirement_id` does
not resolve, or an attribute's `attribute_type` is absent or does not match what the id
actually resolved to. No silent skip.
"""
function load_supplemental_attribute_associations!(
    portfolio::Portfolio,
    refs::OpenAPIRefs,
    doc::PD.PortfolioDocument,
)
    attribute_rows = Dict{Int, Any}(
        Int(getproperty(attr, :id)) => attr for attr in doc.supplemental_attributes
    )
    converted = Dict{Int, SupplementalAttribute}()
    group_index_by_pair = _group_index_by_pair(doc)
    # One store read for the whole table instead of a probe per row; rows written below are
    # folded back in so a document that repeats a pair still attaches rather than re-adds.
    stored_pairs = Set{Tuple{Int, Int}}(
        (Int(row.component_id), Int(row.attribute_id)) for
        row in IS.list_supplemental_attribute_association_rows(portfolio.data)
    )
    IS.begin_association_batch(portfolio.data) do
        for assoc in doc.supplemental_attribute_associations
            attribute_id = Int(assoc.attribute_id)
            component_id = Int(assoc.component_id)
            has_ref(refs, component_id) || error(
                "load_supplemental_attribute_associations!: association references " *
                "unresolved component_id=$component_id (attribute_id=$attribute_id)",
            )
            haskey(attribute_rows, attribute_id) || error(
                "load_supplemental_attribute_associations!: association references " *
                "unresolved attribute_id=$attribute_id (component_id=$component_id)",
            )
            attribute = get!(converted, attribute_id) do
                built = from_openapi(attribute_rows[attribute_id], refs)
                _check_resolved_type_matches(built, assoc.attribute_type, attribute_id)
                IS.set_id!(built, attribute_id)
                refs[attribute_id] = built
                return built
            end
            group_indices = get(group_index_by_pair, (attribute_id, component_id), nothing)
            _attach_attribute!(
                portfolio,
                stored_pairs,
                _resolve(refs, component_id, false),
                attribute,
                group_indices,
            )
        end
    end
    return nothing
end
