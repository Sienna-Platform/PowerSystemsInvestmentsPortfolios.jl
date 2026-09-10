# The type ordering both conversion directions share. References resolve by id, and
# `OpenAPIRefs` errors on an unregistered one, so a type must appear after everything
# it points at: requirements have no references, technologies point at them, supplemental
# attributes reference nothing.
#
# `Zone`/`Node` are absent deliberately: the schemas dropped the Regions folder
# (SiennaSchemas 51f872e), so neither has a `PI.` counterpart to convert against and neither
# can ride in a document. They remain real portfolio types, reached through `RegionTopology`
# and the DB parser; `TopologyMapping` is how the schemas now express region membership.
const DOCUMENT_PLAN = [
    (CarbonCaps, "CarbonCaps"),
    (CarbonTax, "CarbonTax"),
    (CapacityReserveMargin, "CapacityReserveMargin"),
    (EnergyShareRequirements, "EnergyShareRequirements"),
    (HourlyMatching, "HourlyMatching"),
    (MinimumCapacityRequirements, "MinimumCapacityRequirements"),
    (MaximumCapacityRequirements, "MaximumCapacityRequirements"),
    (SupplyTechnology, "SupplyTechnology"),
    (StorageTechnology, "StorageTechnology"),
    (ColocatedSupplyStorageTechnology, "ColocatedSupplyStorageTechnology"),
    (DemandRequirement, "DemandRequirement"),
    (DemandSideTechnology, "DemandSideTechnology"),
    (AggregateTransportTechnology, "AggregateTransportTechnology"),
    (NodalACTransportTechnology, "NodalACTransportTechnology"),
    (NodalHVDCTransportTechnology, "NodalHVDCTransportTechnology"),
]

# The schemas merged the aggregate retirement/retrofit attributes into the plain ones
# (SiennaSchemas d26fc75), which now carry the cost and fraction fields the aggregate
# variants held, so there is one of each here rather than two.
const SUPPLEMENTAL_ATTRIBUTE_PLAN = [
    (RetirementPotential, "RetirementPotential"),
    (RetrofitPotential, "RetrofitPotential"),
    (ExistingDevices, "ExistingDevices"),
    (TopologyMapping, "TopologyMapping"),
]

function _build_export_refs(portfolio::Portfolio)
    refs = OpenAPIRefs()
    # Zone/Node carry no `PI.` counterpart (`openapi: false`) and never ride in the
    # document, but other components still reference them by id (`region`/`region_ids`),
    # so they must be registered here even though DOCUMENT_PLAN skips them.
    for component in IS.get_components(RegionTopology, portfolio.data)
        refs[get_id(component)] = component
    end
    for (psip_type, _key) in DOCUMENT_PLAN
        for component in IS.get_components(psip_type, portfolio.data)
            refs[get_id(component)] = component
        end
    end
    return refs
end
