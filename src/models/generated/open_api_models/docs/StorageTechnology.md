# StorageTechnology


## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**`id`** | **`Int64`** | ID for individual component. | [default to nothing]
**`name`** | **`String`** | Name of the component. | [default to nothing]
**`available`** | **`Bool`** | Indicator of whether the component is connected and online (&#x60;true&#x60;) or disconnected, offline, or down (&#x60;false&#x60;). | [default to nothing]
**`region`** | **`Vector{Int64}`** | Location where the component applies. Can be a zone or node. | [optional] [default to nothing]
**`power_systems_type`** | **`String`** | Corresponding type to be used in PCM modeling. | [default to nothing]
**`min_discharge_fraction`** | **`Float64`** | Minimum discharge as a fraction of total discharge capacity. Units: 1. | [optional] [default to 0.0]
**`prime_mover_type`** | **`String`** | Prime mover for generator. | [optional] [default to "OT"]
**`storage_tech`** | **`String`** | Storage Technology Type. | [default to nothing]
**`capital_costs_energy`** | [**`*ValueCurve`**](ValueCurve.md) |  | [optional] [default to nothing]
**`capital_costs_charge`** | [**`*ValueCurve`**](ValueCurve.md) |  | [optional] [default to nothing]
**`capital_costs_discharge`** | [**`*ValueCurve`**](ValueCurve.md) |  | [optional] [default to nothing]
**`operation_costs`** | [**`*StorageCost`**](StorageCost.md) |  | [optional] [default to nothing]
**`unit_size_discharge`** | **`Float64`** | Used for discrete investment decisions. Size of each unit of discharging capacity being built. Units: MW. | [optional] [default to 0.0]
**`unit_size_charge`** | **`Float64`** | Used for discrete investment decisions. Unit size of charging capacity. Units: MW. | [optional] [default to 0.0]
**`unit_size_energy`** | **`Float64`** | Used for discrete investment decisions. Size of each unit of energy capacity being built. Units: MWh. | [optional] [default to 0.0]
**`capacity_limits_charge`** | [**`*MinMax`**](MinMax.md) |  | [optional] [default to nothing]
**`capacity_limits_discharge`** | [**`*MinMax`**](MinMax.md) |  | [optional] [default to nothing]
**`capacity_limits_energy`** | [**`*MinMax`**](MinMax.md) |  | [optional] [default to nothing]
**`duration_limits`** | [**`*MinMax`**](MinMax.md) |  | [optional] [default to nothing]
**`efficiency`** | [**`*InOut`**](InOut.md) |  | [optional] [default to nothing]
**`losses`** | **`Float64`** | Self-discharge of storage (fraction of energy stored per hour). Units: 1. | [optional] [default to 1.0]
**`lifetime`** | **`Int64`** | Maximum number of years a technology can be active once installed. Units: yr. | [optional] [default to 100]
**`requirements`** | **`Vector{Int64}`** | List of requirement IDs associated with the component. | [optional] [default to nothing]
**`financial_data`** | [**`*TechnologyFinancialData`**](TechnologyFinancialData.md) |  | [default to nothing]


[[Back to Model list]](../README.md#models) [[Back to API list]](../README.md#api-endpoints) [[Back to README]](../README.md)


