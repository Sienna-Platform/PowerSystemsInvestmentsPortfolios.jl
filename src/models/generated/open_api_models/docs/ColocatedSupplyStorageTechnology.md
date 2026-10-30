# ColocatedSupplyStorageTechnology


## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**`id`** | **`Int64`** | ID for individual component. | [default to nothing]
**`name`** | **`String`** | Name of the component. | [default to nothing]
**`available`** | **`Bool`** | Indicator of whether the component is connected and online (&#x60;true&#x60;) or disconnected, offline, or down (&#x60;false&#x60;). | [optional] [default to nothing]
**`power_systems_type`** | **`String`** | Corresponding type to be used in PCM modeling. | [default to nothing]
**`region`** | **`Vector{Int64}`** | Location where the component applies. Can be a zone or node. | [optional] [default to nothing]
**`financial_data`** | [**`*TechnologyFinancialData`**](TechnologyFinancialData.md) |  | [default to nothing]
**`capital_costs_solar`** | [**`*ValueCurve`**](ValueCurve.md) |  | [optional] [default to nothing]
**`operation_costs_solar`** | [**`*RenewableGenerationCost`**](RenewableGenerationCost.md) |  | [optional] [default to nothing]
**`capacity_limits_solar`** | [**`*MinMax`**](MinMax.md) |  | [optional] [default to nothing]
**`lifetime_solar`** | **`Int64`** | Maximum number of years the solar component can be active once installed. Units: yr. | [optional] [default to nothing]
**`capital_costs_wind`** | [**`*ValueCurve`**](ValueCurve.md) |  | [optional] [default to nothing]
**`operation_costs_wind`** | [**`*RenewableGenerationCost`**](RenewableGenerationCost.md) |  | [optional] [default to nothing]
**`capacity_limits_wind`** | [**`*MinMax`**](MinMax.md) |  | [optional] [default to nothing]
**`lifetime_wind`** | **`Int64`** | Maximum number of years the wind component can be active once installed. Units: yr. | [optional] [default to nothing]
**`capital_costs_energy`** | [**`*ValueCurve`**](ValueCurve.md) |  | [optional] [default to nothing]
**`capital_costs_power`** | [**`*ValueCurve`**](ValueCurve.md) |  | [optional] [default to nothing]
**`operation_costs_energy`** | [**`*StorageCost`**](StorageCost.md) |  | [optional] [default to nothing]
**`operation_costs_power`** | [**`*StorageCost`**](StorageCost.md) |  | [optional] [default to nothing]
**`capacity_power_limits`** | [**`*MinMax`**](MinMax.md) |  | [optional] [default to nothing]
**`capacity_energy_limits`** | [**`*MinMax`**](MinMax.md) |  | [optional] [default to nothing]
**`duration_limits`** | [**`*MinMax`**](MinMax.md) |  | [optional] [default to nothing]
**`efficiency_storage`** | [**`*InOut`**](InOut.md) |  | [optional] [default to nothing]
**`losses_storage`** | **`Float64`** | Self-discharge of storage (fraction of stored energy per hour). Units: 1. | [optional] [default to 1.0]
**`lifetime_storage`** | **`Int64`** | Maximum number of years the storage component can be active once installed. Units: yr. | [optional] [default to 100]
**`max_inverter_capacity`** | **`Float64`** | Limit on inverter capacity. Units: MW. | [optional] [default to nothing]
**`min_inverter_capacity`** | **`Float64`** | Minimum inverter capacity. Units: MW. | [optional] [default to nothing]
**`capital_costs_inverter`** | [**`*ValueCurve`**](ValueCurve.md) |  | [default to nothing]
**`operation_costs_inverter`** | [**`*ProductionVariableCostCurve`**](ProductionVariableCostCurve.md) |  | [default to nothing]
**`inverter_efficiency`** | **`Float64`** | Efficiency of AC to DC conversion of inverter. Units: 1. | [default to nothing]
**`inverter_supply_ratio`** | **`Float64`** | Ratio of generation capacity to grid connection capacity. Units: 1. | [default to nothing]
**`requirements`** | **`Vector{Int64}`** | List of requirement IDs associated with the component. | [optional] [default to nothing]


[[Back to Model list]](../README.md#models) [[Back to API list]](../README.md#api-endpoints) [[Back to README]](../README.md)


