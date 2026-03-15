SELECT
    CASE VendorID
        WHEN 1 THEN 'Creative Mobile Technologies'
        WHEN 2 THEN 'VeriFone Inc.'
        ELSE 'Unknown'
    END                                                               AS vendor_name,
    COUNT(*)                                                          AS trips,
    ROUND(AVG(total_amount), 2)                                      AS avg_fare,
    ROUND(AVG(trip_distance), 2)                                     AS avg_distance,
    ROUND(AVG(DATEDIFF('minute', tpep_pickup_datetime, tpep_dropoff_datetime)), 1) AS avg_duration_min,
    ROUND(AVG(tip_amount / NULLIF(fare_amount,0)) * 100, 1)         AS avg_tip_pct,
    ROUND(SUM(total_amount), 2)                                      AS total_revenue
FROM read_parquet('sources/nyc_taxi/raw/yellow_tripdata_2024-01.parquet')
WHERE tpep_pickup_datetime  >= '2024-01-01'
  AND tpep_pickup_datetime  <  '2024-02-01'
  AND tpep_dropoff_datetime >  tpep_pickup_datetime
  AND trip_distance > 0 AND fare_amount > 0 AND passenger_count > 0
GROUP BY VendorID
ORDER BY trips DESC
