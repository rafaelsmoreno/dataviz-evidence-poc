-- Daily aggregated trip metrics for time-series charts
SELECT
    pickup_date                             AS date,
    COUNT(*)                                AS trips,
    ROUND(SUM(total_amount), 2)            AS revenue,
    ROUND(AVG(total_amount), 2)            AS avg_fare,
    ROUND(AVG(trip_distance), 2)           AS avg_distance,
    ROUND(AVG(trip_duration_min), 1)       AS avg_duration_min,
    ROUND(AVG(tip_amount / NULLIF(fare_amount,0)) * 100, 1) AS avg_tip_pct
FROM yellow_taxi
GROUP BY pickup_date
ORDER BY pickup_date;
