# DemandSideTechnology


## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**`id`** | **`Int64`** | ID for individual component. | [default to nothing]
**`name`** | **`String`** | Name of the component. | [default to nothing]
**`available`** | **`Bool`** | Indicator of whether the component is connected and online (&#x60;true&#x60;) or disconnected, offline, or down (&#x60;false&#x60;). | [default to nothing]
**`region`** | **`Vector{Int64}`** | Location where the component applies. Can be a zone or node. | [optional] [default to nothing]
**`power_systems_type`** | **`String`** | Corresponding type to be used in PCM modeling. | [default to nothing]
**`technology_efficiency`** | **`Float64`** | MWh of electricity per unit of output. Ex: MWh per ton of hydrogen for electrolyzers. Units: 1. | [optional] [default to 0.0]
**`price_per_unit`** | [**`*ValueCurve`**](ValueCurve.md) |  | [optional] [default to nothing]
**`min_power`** | **`Float64`** | Minimum operation of demandside unit as a fraction of peak demand. Units: 1. | [optional] [default to 0.0]
**`peak_demand_mw`** | **`Float64`** | Peak demand value in MW. Units: MW. | [optional] [default to 0.0]
**`max_demand_delay`** | **`Float64`** | Maximum number of hours that demand can be deferred or delayed (hours). Units: h. | [optional] [default to nothing]
**`max_demand_advance`** | **`Float64`** | Maximum number of hours that demand can be scheduled in advance of the original schedule (hours). Units: h. | [optional] [default to nothing]
**`demand_energy_efficiency`** | **`Float64`** | Energy efficiency associated with time shifting demand. Represents energy losses due to time shifting. Units: 1. | [optional] [default to nothing]
**`shift_variable_cost`** | [**`*ValueCurve`**](ValueCurve.md) |  | [optional] [default to nothing]
**`curtailment_cost`** | [**`*ValueCurve`**](ValueCurve.md) |  | [optional] [default to nothing]
**`max_demand_curtailment`** | **`Float64`** | Maximum fraction of demand that can be curtailed. Units: 1. | [optional] [default to nothing]
**`requirements`** | **`Vector{Int64}`** | List of requirement IDs associated with the component. | [optional] [default to nothing]


[[Back to Model list]](../README.md#models) [[Back to API list]](../README.md#api-endpoints) [[Back to README]](../README.md)


