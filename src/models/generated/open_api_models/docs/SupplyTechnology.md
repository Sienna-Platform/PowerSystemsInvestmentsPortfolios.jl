# SupplyTechnology


## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**`id`** | **`Int64`** | ID for individual component. | [default to nothing]
**`name`** | **`String`** | Name of the component. | [default to nothing]
**`available`** | **`Bool`** | Indicator of whether the component is connected and online (&#x60;true&#x60;) or disconnected, offline, or down (&#x60;false&#x60;). | [optional] [default to nothing]
**`power_systems_type`** | **`String`** | Corresponding type to be used in PCM modeling. | [default to nothing]
**`region`** | **`Vector{Int64}`** | Location where the component applies. Can be a zone or node. | [optional] [default to nothing]
**`prime_mover_type`** | **`String`** | Prime mover for generator. | [optional] [default to "OT"]
**`fuel`** | **`Vector{String}`** | Fuel type according to IEA. | [optional] [default to nothing]
**`co2`** | **`Dict{String, Float64}`** | Carbon intensity of fuel. Units: t/MMBtu. | [optional] [default to nothing]
**`cofire_start_limits`** | [**`Dict{String, MinMax}`**](MinMax.md) | Minimum and maximum blending level of each fuel during start-up process for multi-fuel generator. Units: 1. | [optional] [default to nothing]
**`cofire_level_limits`** | [**`Dict{String, MinMax}`**](MinMax.md) | Minimum and maximum blending level of each fuel during normal generation process for multi-fuel generator. Units: 1. | [optional] [default to nothing]
**`capital_costs`** | [**`*ValueCurve`**](ValueCurve.md) |  | [optional] [default to nothing]
**`operation_costs`** | [**`*GenericOperationCost`**](GenericOperationCost.md) |  | [optional] [default to nothing]
**`unit_size`** | **`Float64`** | Used for discrete investment decisions. Size of each unit being built. Units: MW. | [optional] [default to 0.0]
**`capacity_limits`** | [**`*MinMax`**](MinMax.md) |  | [optional] [default to nothing]
**`outage_factor`** | **`Float64`** | Derating factor to account for planned or forced outages of a technology. Fraction of hours in a year where technology is unavailable. Units: 1. | [optional] [default to 1.0]
**`min_generation_fraction`** | **`Float64`** | Minimum generation as a fraction of total capacity. Units: 1. | [optional] [default to 0.0]
**`ramp_limits`** | [**`*UpDown`**](UpDown.md) |  | [optional] [default to nothing]
**`time_limits`** | [**`*UpDown`**](UpDown.md) |  | [optional] [default to nothing]
**`start_fuel_mmbtu_per_mw`** | **`Float64`** | Startup fuel use per MW of nameplate capacity of each generator. Units: MMBtu/MW. | [optional] [default to 0.0]
**`lifetime`** | **`Int64`** | Maximum number of years a technology can be active once installed. Units: yr. | [optional] [default to 100]
**`requirements`** | **`Vector{Int64}`** | List of requirement IDs associated with the component. | [optional] [default to nothing]
**`financial_data`** | [**`*TechnologyFinancialData`**](TechnologyFinancialData.md) |  | [default to nothing]


[[Back to Model list]](../README.md#models) [[Back to API list]](../README.md#api-endpoints) [[Back to README]](../README.md)


