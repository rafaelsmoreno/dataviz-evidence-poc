-- Trip distance distribution in 0.5-mile buckets (up to 20 miles)
SELECT
    ROUND(FLOOR(trip_distance / 0.5) * 0.5, 1) AS distance_bucket_miles,
    COUNT(*)                                     AS trips,
    ROUND(AVG(total_amount), 2)                 AS avg_fare,
    ROUND(AVG(tip_amount), 2)                   AS avg_tip
FROM yellow_taxi
WHERE trip_distance <= 20
GROUP BY distance_bucket_miles
ORDER BY distance_bucket_miles;
