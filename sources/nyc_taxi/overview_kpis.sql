SELECT
    COUNT(*)                                                          AS total_trips,
    ROUND(SUM(total_amount), 2)                                      AS total_revenue,
    ROUND(AVG(total_amount), 2)                                      AS avg_fare,
    ROUND(AVG(trip_distance), 2)                                     AS avg_distance_miles,
    ROUND(AVG(trip_duration_min), 1)                                 AS avg_duration_min,
    ROUND(AVG(tip_amount / NULLIF(fare_amount,0)) * 100, 1)         AS avg_tip_pct,
    ROUND(SUM(tip_amount), 2)                                        AS total_tips,
    COUNT(DISTINCT pickup_date)                                      AS days_in_dataset
FROM (
    SELECT
        total_amount, trip_distance,
        DATEDIFF('minute', tpep_pickup_datetime, tpep_dropoff_datetime) AS trip_duration_min,
        tip_amount, fare_amount,
        DATE_TRUNC('day', tpep_pickup_datetime) AS pickup_date
    FROM read_parquet('sources/nyc_taxi/raw/yellow_tripdata_2024-01.parquet')
    WHERE tpep_pickup_datetime  >= '2024-01-01'
      AND tpep_pickup_datetime  <  '2024-02-01'
      AND tpep_dropoff_datetime >  tpep_pickup_datetime
      AND trip_distance > 0 AND fare_amount > 0 AND passenger_count > 0
)
