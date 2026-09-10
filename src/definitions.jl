const MinMax = NamedTuple{(:min, :max), Tuple{Float64, Float64}}
const InOut = NamedTuple{(:in, :out), Tuple{Float64, Float64}}
const UpDown = NamedTuple{(:up, :down), Tuple{Float64, Float64}}
const OutageFactors = NamedTuple{(:planned, :forced), Tuple{Float64, Float64}}

# The validation descriptor the adopted-store SystemData is built with on import. Must match the
# one the normal Portfolio path uses (`PSY._create_system_data_from_kwargs`) so an imported
# portfolio validates identically to a freshly-built one.
const PORTFOLIO_STRUCT_DESCRIPTOR_FILE = PowerSystems.POWER_SYSTEM_STRUCT_DESCRIPTOR_FILE
