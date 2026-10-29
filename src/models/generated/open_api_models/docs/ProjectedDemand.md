# ProjectedDemand


## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**`id`** | **`Int64`** |  | [optional] [default to nothing]
**`name`** | **`String`** |  | [default to nothing]
**`available`** | **`Bool`** |  | [default to true]
**`power_systems_type`** | **`String`** |  | [default to nothing]
**`region`** | **`Vector{Int64}`** |  | [optional] [default to nothing]
**`peak_demand_mw`** | **`Float64`** |  | [optional] [default to 0.0]
**`construction_year`** | **`Int64`** |  | [optional] [default to 2020]
**`growth_rate`** | **`Float64`** |  | [optional] [default to 0.0]
**`conformity`** | **`String`** |  | [optional] [default to "UNDEFINED"]
**`max_demand_curtailment`** | **`Float64`** |  | [optional] [default to 0.0]
**`curtailment_cost`** | [**`*ValueCurve`**](ValueCurve.md) |  | [optional] [default to nothing]
**`value_of_lost_load`** | **`Float64`** |  | [optional] [default to 1e8]
**`flexible_fraction`** | **`Float64`** |  | [optional] [default to 0.0]
**`max_demand_delay`** | **`Float64`** |  | [optional] [default to 0.0]
**`max_demand_advance`** | **`Float64`** |  | [optional] [default to 0.0]
**`shift_efficiency`** | **`Float64`** |  | [optional] [default to 1.0]
**`shift_cost`** | [**`*ValueCurve`**](ValueCurve.md) |  | [optional] [default to nothing]
**`requirements`** | **`Vector{Int64}`** |  | [optional] [default to nothing]


[[Back to Model list]](../README.md#models) [[Back to API list]](../README.md#api-endpoints) [[Back to README]](../README.md)


