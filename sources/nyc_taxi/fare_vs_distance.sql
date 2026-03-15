-- 5000-row sample for scatter plot — aggregated in SQL, small result set
SELECT
    ROUND(trip_distance, 1)                                          AS trip_distance,
    ROUND(fare_amount, 2)                                            AS fare_amount,
    ROUND(tip_amount, 2)                                             AS tip_amount,
    ROUND(total_amount, 2)                                           AS total_amount,
    CASE payment_type
        WHEN 1 THEN 'Credit Card' WHEN 2 THEN 'Cash'
        ELSE 'Other'
    END                                                               AS payment_type_name,
    DATEDIFF('minute', tpep_pickup_datetime, tpep_dropoff_datetime)  AS trip_duration_min,
    HOUR(tpep_pickup_datetime)                                        AS hour_of_day
FROM read_parquet('sources/nyc_taxi/raw/yellow_tripdata_2024-01.parquet')
WHERE tpep_pickup_datetime  >= '2024-01-01'
  AND tpep_pickup_datetime  <  '2024-02-01'
  AND tpep_dropoff_datetime >  tpep_pickup_datetime
  AND trip_distance BETWEEN 0.1 AND 30
  AND fare_amount   BETWEEN 1   AND 150
  AND passenger_count > 0
USING SAMPLE 5000 ROWS
