-- Fare vs distance scatter (sampled to 5000 rows for rendering performance)
SELECT
    trip_distance,
    fare_amount,
    tip_amount,
    total_amount,
    payment_type_name,
    trip_duration_min,
    hour_of_day
FROM yellow_taxi
WHERE trip_distance BETWEEN 0.1 AND 30
  AND fare_amount   BETWEEN 1   AND 150
USING SAMPLE 5000 ROWS;
