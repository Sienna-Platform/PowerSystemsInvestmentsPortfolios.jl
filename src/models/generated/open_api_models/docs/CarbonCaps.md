# CarbonCaps


## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**`id`** | **`Int64`** | ID for individual component. | [default to nothing]
**`name`** | **`String`** | Name of the component. | [default to nothing]
**`available`** | **`Bool`** | Indicator of whether the component is connected and online (&#x60;true&#x60;) or disconnected, offline, or down (&#x60;false&#x60;). | [default to nothing]
**`target_year`** | **`Int64`** | Year in which this requirement is applied. | [optional] [default to nothing]
**`max_tons_mwh`** | **`Float64`** | Emission limit in terms of rate. Units: Mt/MWh. | [optional] [default to 100000000]
**`max_mtons`** | **`Float64`** | Emission limit in absolute values (million tonnes). Units: Mt. | [optional] [default to nothing]


[[Back to Model list]](../README.md#models) [[Back to API list]](../README.md#api-endpoints) [[Back to README]](../README.md)


