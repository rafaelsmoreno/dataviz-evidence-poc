SELECT
    DAYOFWEEK(tpep_pickup_datetime)   AS day_of_week,
    DAYNAME(tpep_pickup_datetime)     AS day_name,
    HOUR(tpep_pickup_datetime)        AS hour_of_day,
    COUNT(*)                          AS trips,
    ROUND(AVG(total_amount), 2)      AS avg_fare,
    ROUND(AVG(DATEDIFF('minute', tpep_pickup_datetime, tpep_dropoff_datetime)), 1) AS avg_duration_min
FROM read_parquet('sources/nyc_taxi/raw/yellow_tripdata_2024-01.parquet')
WHERE tpep_pickup_datetime  >= '2024-01-01'
  AND tpep_pickup_datetime  <  '2024-02-01'
  AND tpep_dropoff_datetime >  tpep_pickup_datetime
  AND trip_distance > 0 AND fare_amount > 0 AND passenger_count > 0
GROUP BY 1, 2, 3
ORDER BY 1, 3
