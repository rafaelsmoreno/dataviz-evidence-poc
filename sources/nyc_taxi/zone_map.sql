-- Pickup and dropoff volume per zone with coordinates for map visualisation
-- Joins trip counts from Parquet with zone centroids CSV
WITH trips AS (
    SELECT
        PULocationID                        AS location_id,
        COUNT(*)                            AS pickups,
        ROUND(SUM(total_amount), 2)        AS total_revenue,
        ROUND(AVG(total_amount), 2)        AS avg_fare,
        ROUND(AVG(trip_distance), 2)       AS avg_distance
    FROM read_parquet('sources/nyc_taxi/raw/yellow_tripdata_2024-01.parquet')
    WHERE tpep_pickup_datetime  >= '2024-01-01'
      AND tpep_pickup_datetime  <  '2024-02-01'
      AND tpep_dropoff_datetime >  tpep_pickup_datetime
      AND trip_distance > 0 AND fare_amount > 0 AND passenger_count > 0
    GROUP BY PULocationID
),
dropoffs AS (
    SELECT
        DOLocationID AS location_id,
        COUNT(*)     AS dropoffs
    FROM read_parquet('sources/nyc_taxi/raw/yellow_tripdata_2024-01.parquet')
    WHERE tpep_pickup_datetime  >= '2024-01-01'
      AND tpep_pickup_datetime  <  '2024-02-01'
      AND tpep_dropoff_datetime >  tpep_pickup_datetime
      AND trip_distance > 0 AND fare_amount > 0 AND passenger_count > 0
    GROUP BY DOLocationID
),
zones AS (
    SELECT * FROM read_csv('sources/nyc_taxi/raw/taxi_zone_centroids.csv', auto_detect=true)
)
SELECT
    z.location_id,
    z.zone,
    z.borough,
    z.lat,
    z.lon,
    COALESCE(t.pickups, 0)         AS pickups,
    COALESCE(d.dropoffs, 0)        AS dropoffs,
    COALESCE(t.total_revenue, 0)   AS total_revenue,
    COALESCE(t.avg_fare, 0)        AS avg_fare,
    COALESCE(t.avg_distance, 0)    AS avg_distance
FROM zones z
LEFT JOIN trips    t ON z.location_id = t.location_id
LEFT JOIN dropoffs d ON z.location_id = d.location_id
WHERE z.lat IS NOT NULL AND z.lon IS NOT NULL
ORDER BY pickups DESC
