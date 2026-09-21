function Base.show(io::IO, ::MIME"text/plain", ist::Union{Technology, Requirement})
    print(io, summary(ist), ":")
    for name in fieldnames(typeof(ist))
        obj = getproperty(ist, name)
        getter_name = Symbol("get_$name")
        if (obj isa InfrastructureSystemsInternal)
            print(io, "\n   ")
            show(io, MIME"text/plain"(), obj.base_value)
            continue
        elseif obj isa IS.InfrastructureSystemsType ||
               obj isa Vector{<:IS.InfrastructureSystemsComponent}
            val = summary(getproperty(ist, name))
        elseif PSY.hasproperty(PowerSystemsInvestmentsPortfolios, getter_name)
            getter_func = PSY.getproperty(PowerSystemsInvestmentsPortfolios, getter_name)
            arg = IS.display_units_arg(getter_func, typeof(ist))
            if ismissing(arg)
                val = getter_func(ist)
            else
                val = getter_func(ist, InfrastructureSystems.NU)
            end
        else
            val = getproperty(ist, name)
        end
        print(io, "\n   ", name, ": ", val)
    end
    print(
        io,
        "\n   ",
        "has_supplemental_attributes",
        ": ",
        string(has_supplemental_attributes(ist)),
    )
    print(io, "\n   ", "has_time_series", ": ", string(has_time_series(ist)))
    return
end

function Base.show(io::IO, ist::Union{Technology, Requirement})
    print(io, IS.strip_module_name(typeof(ist)), "(")
    is_first = true
    for (name, field_type) in zip(fieldnames(typeof(ist)), fieldtypes(typeof(ist)))
        getter_name = Symbol("get_$name")
        if field_type <: InfrastructureSystemsInternal
            continue
        elseif hasproperty(PowerSystemsInvestmentsPortfolios, getter_name)
            getter_func = getproperty(PowerSystemsInvestmentsPortfolios, getter_name)
            val = _show_accessor_value(getter_func, ist)
        else
            val = getproperty(ist, name)
        end
        if is_first
            is_first = false
        else
            print(io, ", ")
        end
        print(io, val)
    end
    print(io, ")")
    return
end

# `getter_func` is deliberately not a type parameter: both callers resolve it through
# `getproperty(PowerSystems, ::Symbol)`, so there is no concrete type to specialize on.
function _show_accessor_value(getter_func::Function, ist::Union{Technology, Requirement}; units = nothing)
    trait_arg = IS.display_units_arg(getter_func, typeof(ist))
    # Fields without a units trait (e.g. `get_name`) aren't unit-convertible at
    # all — an explicit `units` override must not force a units argument onto
    # a getter that doesn't accept one.
    ismissing(trait_arg) && return getter_func(ist)
    arg = if isnothing(units)
        trait_arg
    else
        units
    end
    unitful_func = IS.unitful_variant(getter_func)
    try
        return unitful_func(ist, arg)
    catch err
        # An explicit `units` request that fails is a caller error worth
        # surfacing, not something display should paper over — only the
        # trait's own automatic resolution gets the never-error fallback below.
        isnothing(units) || rethrow()
        err isa ErrorException && occursin("not attached", err.msg) || rethrow()
        # NU can also fail (it may need the system base or a base voltage).
        # Automatic resolution must never error: fall back to the raw stored
        # value, which the CU conversion returns without touching any base.
        # Only swallow the engine's own ErrorExceptions — a MethodError here
        # is a bug.
        try
            return unitful_func(ist, NU)
        catch err2
            err2 isa ErrorException || rethrow()
            return unitful_func(ist, _cu_fallback(trait_arg))
        end
    end
end