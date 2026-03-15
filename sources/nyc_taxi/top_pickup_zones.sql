SELECT
    PULocationID                        AS pickup_location_id,
    COUNT(*)                            AS trips,
    ROUND(SUM(total_amount), 2)        AS total_revenue,
    ROUND(AVG(total_amount), 2)        AS avg_fare,
    ROUND(AVG(trip_distance), 2)       AS avg_distance
FROM read_parquet('sources/nyc_taxi/raw/yellow_tripdata_2024-01.parquet')
WHERE tpep_pickup_datetime  >= '2024-01-01'
  AND tpep_pickup_datetime  <  '2024-02-01'
  AND tpep_dropoff_datetime >  tpep_pickup_datetime
  AND trip_distance > 0 AND fare_amount > 0 AND passenger_count > 0
GROUP BY PULocationID
ORDER BY trips DESC
LIMIT 30
