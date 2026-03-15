SELECT
    CASE payment_type
        WHEN 1 THEN 'Credit Card' WHEN 2 THEN 'Cash'
        WHEN 3 THEN 'No Charge'  WHEN 4 THEN 'Dispute'
        WHEN 5 THEN 'Unknown'    WHEN 6 THEN 'Voided Trip'
        ELSE 'Other'
    END                                                               AS payment_type_name,
    COUNT(*)                                                          AS trips,
    ROUND(SUM(total_amount), 2)                                      AS total_revenue,
    ROUND(AVG(total_amount), 2)                                      AS avg_fare,
    ROUND(AVG(tip_amount), 2)                                        AS avg_tip,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 1)              AS pct_of_trips
FROM read_parquet('sources/nyc_taxi/raw/yellow_tripdata_2024-01.parquet')
WHERE tpep_pickup_datetime  >= '2024-01-01'
  AND tpep_pickup_datetime  <  '2024-02-01'
  AND tpep_dropoff_datetime >  tpep_pickup_datetime
  AND trip_distance > 0 AND fare_amount > 0 AND passenger_count > 0
GROUP BY payment_type
ORDER BY trips DESC
