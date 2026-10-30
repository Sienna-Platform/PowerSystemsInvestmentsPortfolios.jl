# NodalACTransportTechnology


## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**`id`** | **`Int64`** | ID for individual component. | [default to nothing]
**`name`** | **`String`** | Name of the component. | [default to nothing]
**`available`** | **`Bool`** | Indicator of whether the component is connected and online (&#x60;true&#x60;) or disconnected, offline, or down (&#x60;false&#x60;). | [default to nothing]
**`power_systems_type`** | **`String`** | Corresponding type to be used in PCM modeling. | [default to nothing]
**`start_node`** | **`Int64`** | Start node for transport technology. | [default to nothing]
**`end_node`** | **`Int64`** | End node for transport technology. | [default to nothing]
**`capacity_limits`** | [**`*MinMax`**](MinMax.md) |  | [optional] [default to nothing]
**`capital_costs`** | [**`*ValueCurve`**](ValueCurve.md) |  | [optional] [default to nothing]
**`resistance`** | **`Float64`** | Technology resistance in Ohms. Units: ohm. | [optional] [default to 0.0]
**`voltage`** | **`Float64`** | Voltage rating of transmission line. Units: kV. | [optional] [default to 0.0]
**`unit_size`** | **`Float64`** | Used for integer investment decisions. Represents the rating capacity of individual new lines. Units: MW. | [optional] [default to 0.0]
**`reactance`** | **`Float64`** | Series reactance for a line. Units: ohm. | [optional] [default to 0.0]
**`requirements`** | **`Vector{Int64}`** | List of requirement IDs associated with the component. | [optional] [default to nothing]
**`financial_data`** | [**`*TechnologyFinancialData`**](TechnologyFinancialData.md) |  | [default to nothing]


[[Back to Model list]](../README.md#models) [[Back to API list]](../README.md#api-endpoints) [[Back to README]](../README.md)


