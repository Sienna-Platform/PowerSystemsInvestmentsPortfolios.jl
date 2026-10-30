# GenericOperationCost



## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**value** | This is a oneOf model. The value must be exactly one of the following types: HydroGenerationCost, RenewableGenerationCost, ThermalGenerationCost | Fixed and variable O&amp;M costs for a technology. Units: USD/MWh. | [optional] 

The discriminator field is `cost_type` with the following mapping:
 - `HYDRO_GEN`: `HydroGenerationCost`
 - `RENEWABLE`: `RenewableGenerationCost`
 - `THERMAL`: `ThermalGenerationCost`



[[Back to Model list]](../README.md#models) [[Back to API list]](../README.md#api-endpoints) [[Back to README]](../README.md)


