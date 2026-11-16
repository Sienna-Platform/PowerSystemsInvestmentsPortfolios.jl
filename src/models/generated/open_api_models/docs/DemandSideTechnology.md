# DemandSideTechnology


## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**`id`** | **`Int64`** |  | [optional] [default to nothing]
**`name`** | **`String`** |  | [default to nothing]
**`available`** | **`Bool`** |  | [default to nothing]
**`power_systems_type`** | **`String`** |  | [default to nothing]
**`region`** | **`Vector{Int64}`** |  | [optional] [default to nothing]
**`capacity_limits`** | [**`*MinMax`**](MinMax.md) |  | [optional] [default to nothing]
**`unit_size`** | **`Float64`** |  | [optional] [default to 0.0]
**`capital_costs`** | [**`*ValueCurve`**](ValueCurve.md) |  | [optional] [default to nothing]
**`operation_costs`** | [**`*LoadCost`**](LoadCost.md) |  | [optional] [default to nothing]
**`min_power`** | **`Float64`** |  | [optional] [default to 0.0]
**`ramp_limits`** | [**`*UpDown`**](UpDown.md) |  | [optional] [default to nothing]
**`technology_efficiency`** | **`Float64`** |  | [optional] [default to 1.0]
**`price_per_unit`** | [**`*ValueCurve`**](ValueCurve.md) |  | [optional] [default to nothing]
**`lifetime`** | **`Int64`** |  | [optional] [default to 100]
**`financial_data`** | [**`*TechnologyFinancialData`**](TechnologyFinancialData.md) |  | [optional] [default to nothing]
**`requirements`** | **`Vector{Int64}`** |  | [optional] [default to nothing]


[[Back to Model list]](../README.md#models) [[Back to API list]](../README.md#api-endpoints) [[Back to README]](../README.md)


