-- Vendor performance comparison
SELECT
    vendor_name,
    COUNT(*)                                        AS trips,
    ROUND(AVG(total_amount), 2)                    AS avg_fare,
    ROUND(AVG(trip_distance), 2)                   AS avg_distance,
    ROUND(AVG(trip_duration_min), 1)               AS avg_duration_min,
    ROUND(AVG(tip_amount / NULLIF(fare_amount,0)) * 100, 1) AS avg_tip_pct,
    ROUND(SUM(total_amount), 2)                    AS total_revenue
FROM yellow_taxi
GROUP BY vendor_name
ORDER BY trips DESC;
