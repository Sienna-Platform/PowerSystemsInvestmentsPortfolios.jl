# USD and MMBtu come from InfrastructureSystems, which defines them for CostCurve and FuelCurve.
using InfrastructureSystems.CommodityUnits: USD, MMBtu

# Energy, with SI prefixes (kWh, MWh, GWh, ...); Unitful itself spells energy as W*hr
@unit Wh "Wh" WattHour 1u"W" * u"hr" true

# Emissions units
@unit tonne "tonne" tonne 1e3u"kg" false
@unit Mt "Mt" Mt 1e6 * tonne false

const MW = u"MW"
