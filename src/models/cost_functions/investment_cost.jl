"""
Abstract supertype for all investment cost representations.

Concrete subtypes:

  - [`CapitalCost`](@ref)
"""
abstract type InvestmentCost <: DeviceParameter end

IS.serialize(val::InvestmentCost) = IS.serialize_struct(val)
IS.deserialize(T::Type{<:InvestmentCost}, val::Dict) = IS.deserialize_struct(T, val)
