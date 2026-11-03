# USD and MMBtu come from InfrastructureSystems, which defines them for CostCurve and FuelCurve.
using InfrastructureSystems.CommodityUnits: USD, MMBtu

# Emissions units
@unit tonne "tonne" tonne 1e3u"kg" false
@unit Mt "Mt" Mt 1e6 * tonne false

# Re-export common Unitful units for power systems
const MW = u"MW"
const kV = u"kV"
const OHMS = u"Ω"
const SIEMENS = u"S"
