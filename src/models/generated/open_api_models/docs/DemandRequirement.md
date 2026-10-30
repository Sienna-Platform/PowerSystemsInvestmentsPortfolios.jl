# DemandRequirement


## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**`id`** | **`Int64`** | ID for individual component. | [default to nothing]
**`name`** | **`String`** | Name of the component. | [default to nothing]
**`available`** | **`Bool`** | Indicator of whether the component is connected and online (&#x60;true&#x60;) or disconnected, offline, or down (&#x60;false&#x60;). | [optional] [default to true]
**`power_systems_type`** | **`String`** | Corresponding type to be used in PCM modeling. | [default to nothing]
**`conformity`** | **`String`** | Indicator of how the demand requirement should conform to the load profile of existing technologies in the system. Should only be used for new demand requirements. | [optional] [default to "UNDEFINED"]
**`growth_rate`** | **`Float64`** | The annual growth rate of the demand requirement, used to scale present-day loads into future projections. Should only be used for conforming loads. Units: 1. | [optional] [default to 0.0]
**`new_demand_mw`** | **`Float64`** | The value of the peak demand to be used for new DemandRequirements. Units: MW. | [optional] [default to 0.0]
**`new_construction_year`** | **`Int64`** | The year in which the new demand requirement will be installed. Should only be used for new demand requirements. | [optional] [default to 2020]
**`region`** | **`Vector{Int64}`** | Location where the component applies. Can be a zone or node. | [optional] [default to nothing]
**`value_of_lost_load`** | **`Float64`** | Value of unserved load. Units: USD/MWh. | [default to nothing]
**`unserved_demand_curve`** | [**`*ValueCurve`**](ValueCurve.md) |  | [optional] [default to nothing]
**`requirements`** | **`Vector{Int64}`** | List of requirement IDs associated with the component. | [optional] [default to nothing]


[[Back to Model list]](../README.md#models) [[Back to API list]](../README.md#api-endpoints) [[Back to README]](../README.md)


