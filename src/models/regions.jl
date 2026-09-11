# Topology — areas, load zones, buses, arcs — is attached directly to the portfolio as
# PowerSystems components (see `TOPOLOGY_TYPES` / `DOCUMENT_PLAN` in `openapi/document.jl`),
# replacing the former PSIP-local `RegionTopology` (`Zone`/`Node`) abstractions. These PSY
# types carry their own accessors; the portfolio only needs an `id` accessor consistent with
# the one it uses for its own generated components.
get_id(val::PSY.Topology) = IS.get_id(val)
