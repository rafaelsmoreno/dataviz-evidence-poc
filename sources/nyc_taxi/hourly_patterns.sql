-- Trips by hour of day and day of week — for heatmap
SELECT
    day_of_week,
    day_name,
    hour_of_day,
    COUNT(*)                            AS trips,
    ROUND(AVG(total_amount), 2)        AS avg_fare,
    ROUND(AVG(trip_duration_min), 1)   AS avg_duration_min
FROM yellow_taxi
GROUP BY day_of_week, day_name, hour_of_day
ORDER BY day_of_week, hour_of_day;
