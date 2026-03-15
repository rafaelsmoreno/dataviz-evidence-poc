-- Key Performance Indicators for the Overview dashboard
SELECT
    COUNT(*)                                        AS total_trips,
    ROUND(SUM(total_amount), 2)                    AS total_revenue,
    ROUND(AVG(total_amount), 2)                    AS avg_fare,
    ROUND(AVG(trip_distance), 2)                   AS avg_distance_miles,
    ROUND(AVG(trip_duration_min), 1)               AS avg_duration_min,
    ROUND(AVG(tip_amount / NULLIF(fare_amount,0)) * 100, 1) AS avg_tip_pct,
    ROUND(SUM(tip_amount), 2)                      AS total_tips,
    COUNT(DISTINCT pickup_date)                    AS days_in_dataset
FROM yellow_taxi;
