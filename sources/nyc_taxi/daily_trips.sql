SELECT
    DATE_TRUNC('day', tpep_pickup_datetime)                          AS date,
    COUNT(*)                                                          AS trips,
    ROUND(SUM(total_amount), 2)                                      AS revenue,
    ROUND(AVG(total_amount), 2)                                      AS avg_fare,
    ROUND(AVG(trip_distance), 2)                                     AS avg_distance,
    ROUND(AVG(DATEDIFF('minute', tpep_pickup_datetime, tpep_dropoff_datetime)), 1) AS avg_duration_min,
    ROUND(AVG(tip_amount / NULLIF(fare_amount,0)) * 100, 1)         AS avg_tip_pct
FROM read_parquet('sources/nyc_taxi/raw/yellow_tripdata_2024-01.parquet')
WHERE tpep_pickup_datetime  >= '2024-01-01'
  AND tpep_pickup_datetime  <  '2024-02-01'
  AND tpep_dropoff_datetime >  tpep_pickup_datetime
  AND trip_distance > 0 AND fare_amount > 0 AND passenger_count > 0
GROUP BY DATE_TRUNC('day', tpep_pickup_datetime)
ORDER BY 1
