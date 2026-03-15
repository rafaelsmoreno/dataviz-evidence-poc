-- Payment type breakdown
SELECT
    payment_type_name,
    COUNT(*)                            AS trips,
    ROUND(SUM(total_amount), 2)        AS total_revenue,
    ROUND(AVG(total_amount), 2)        AS avg_fare,
    ROUND(AVG(tip_amount), 2)          AS avg_tip,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 1) AS pct_of_trips
FROM yellow_taxi
GROUP BY payment_type_name
ORDER BY trips DESC;
