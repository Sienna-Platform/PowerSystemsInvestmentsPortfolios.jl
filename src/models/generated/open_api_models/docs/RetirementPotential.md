# RetirementPotential


## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**`id`** | **`Int64`** | ID for individual component. | [default to nothing]
**`eligible_generators`** | **`Vector{String}`** | Names of individual generation units mapped to a technology that are eligible for retirement. | [optional] [default to nothing]
**`planned_retirement_year`** | **`Dict{String, Int64}`** | Optional dictionary to indicate the year in which the forced/planned retirement will occur. | [optional] [default to nothing]
**`build_year`** | **`Dict{String, Int64}`** | Optional dictionary to indicate the year in which existing generators in the base system were built. | [optional] [default to nothing]


[[Back to Model list]](../README.md#models) [[Back to API list]](../README.md#api-endpoints) [[Back to README]](../README.md)


