import DataFrames
import Dates
import TimeSeries

function verify_time_series(port::Portfolio, num_initial_times, num_time_series, len)
    total_time_series = 0
    all_time_series = get_time_series_multiple(port)
    for time_series in all_time_series
        if length(time_series) != len
            @error "length doesn't match" length(time_series) len
            return false
        end
        total_time_series += 1
    end

    if num_time_series != total_time_series
        @error "num_time_series doesn't match" num_time_series total_time_series
        return false
    end

    return true
end

@testset "Test single time_series addition" begin
    technology_name = "wind"
    name = "capacity_factors"

    port = build_portfolio()

    #Clear existing timeseries
    PSIP.clear_time_series!(port)
    @test verify_time_series(port, 0, 0, 24)

    local_path = @__DIR__
    data = CSV.read(joinpath(local_path, "data_utils/ts_data.csv"), DataFrame)
    wind_ts_vec = data[!, "Wind"] ./ 451.0

    timestamps = collect(
        DateTime("1/1/2024  0:00:00", "d/m/y  H:M:S"):Hour(1):DateTime(
            "1/1/2024  23:00:00",
            "d/m/y  H:M:S",
        ),
    )
    data = wind_ts_vec[1:24]
    ts = SingleTimeSeries(; data=TimeArray(timestamps, data), name=name)

    technology = get_technology(SupplyTechnology{RenewableDispatch}, port, technology_name)
    PSIP.add_time_series!(
        port,
        technology,
        ts;
        features=Dict("year" => "2024", "rep_day" => 1),
    )

    ta = get_data(ts)
    @test verify_time_series(port, 1, 1, 24)
    time_series = collect(get_time_series_multiple(port))[1]
    @test TimeSeries.timestamp(get_data(time_series)) == TimeSeries.timestamp(ta)
    @test TimeSeries.values(get_data(time_series)) == TimeSeries.values(ta)
end
