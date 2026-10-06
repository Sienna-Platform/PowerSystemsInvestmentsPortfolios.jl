# Topology — areas, load zones, buses, arcs — is attached directly to the portfolio's base
# system as PowerSystems components (seeded into each OpenAPI conversion pass by
# `_register_base_system_topology!` in `openapi/import_document.jl`), replacing the former
# PSIP-local `RegionTopology` (`Zone`/`Node`) abstractions. These PSY
# types carry their own accessors; the portfolio only needs an `id` accessor consistent with
# the one it uses for its own generated components.
get_id(val::PSY.Topology) = IS.get_id(val)
