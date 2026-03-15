SELECT
    ROUND(FLOOR(trip_distance / 0.5) * 0.5, 1) AS distance_bucket_miles,
    COUNT(*)                                     AS trips,
    ROUND(AVG(total_amount), 2)                 AS avg_fare,
    ROUND(AVG(tip_amount), 2)                   AS avg_tip
FROM read_parquet('sources/nyc_taxi/raw/yellow_tripdata_2024-01.parquet')
WHERE tpep_pickup_datetime  >= '2024-01-01'
  AND tpep_pickup_datetime  <  '2024-02-01'
  AND tpep_dropoff_datetime >  tpep_pickup_datetime
  AND trip_distance > 0 AND trip_distance <= 20
  AND fare_amount > 0 AND passenger_count > 0
GROUP BY distance_bucket_miles
ORDER BY distance_bucket_miles
