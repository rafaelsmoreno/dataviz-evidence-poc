-- Top 30 pickup locations by volume
SELECT
    pickup_location_id,
    COUNT(*)                            AS trips,
    ROUND(SUM(total_amount), 2)        AS total_revenue,
    ROUND(AVG(total_amount), 2)        AS avg_fare,
    ROUND(AVG(trip_distance), 2)       AS avg_distance
FROM yellow_taxi
GROUP BY pickup_location_id
ORDER BY trips DESC
LIMIT 30;
