-- =============================================================================
-- init_db.sql — Create a DuckDB view over the local Parquet file
-- =============================================================================
-- DuckDB reads the Parquet directly — no data is copied into the .db file.
-- The .db file holds only this view definition.
-- Parquet file location: /usr/src/app/sources/nyc_taxi/raw/yellow_tripdata_2024-01.parquet
--   (this is where the Evidence container mounts the project volume)
-- =============================================================================

-- Create a clean view with renamed columns and derived fields
-- so all source queries can simply SELECT from yellow_taxi
CREATE VIEW yellow_taxi AS
SELECT
    VendorID                                                        AS vendor_id,
    tpep_pickup_datetime                                            AS pickup_datetime,
    tpep_dropoff_datetime                                           AS dropoff_datetime,
    passenger_count,
    trip_distance,
    RatecodeID                                                      AS rate_code_id,
    store_and_fwd_flag,
    PULocationID                                                    AS pickup_location_id,
    DOLocationID                                                    AS dropoff_location_id,
    payment_type,
    fare_amount,
    extra,
    mta_tax,
    tip_amount,
    tolls_amount,
    improvement_surcharge,
    total_amount,
    congestion_surcharge,
    Airport_fee                                                     AS airport_fee,
    -- Derived columns
    DATE_TRUNC('day',  tpep_pickup_datetime)                       AS pickup_date,
    DATE_TRUNC('hour', tpep_pickup_datetime)                       AS pickup_hour,
    HOUR(tpep_pickup_datetime)                                      AS hour_of_day,
    DAYOFWEEK(tpep_pickup_datetime)                                 AS day_of_week,
    DAYNAME(tpep_pickup_datetime)                                   AS day_name,
    DATEDIFF('minute', tpep_pickup_datetime, tpep_dropoff_datetime) AS trip_duration_min,
    CASE payment_type
        WHEN 1 THEN 'Credit Card'
        WHEN 2 THEN 'Cash'
        WHEN 3 THEN 'No Charge'
        WHEN 4 THEN 'Dispute'
        WHEN 5 THEN 'Unknown'
        WHEN 6 THEN 'Voided Trip'
        ELSE 'Other'
    END                                                             AS payment_type_name,
    CASE VendorID
        WHEN 1 THEN 'Creative Mobile Technologies'
        WHEN 2 THEN 'VeriFone Inc.'
        ELSE 'Unknown'
    END                                                             AS vendor_name
FROM read_parquet('/usr/src/app/sources/nyc_taxi/raw/yellow_tripdata_2024-01.parquet')
-- Basic sanity filters
WHERE tpep_pickup_datetime  >= '2024-01-01'
  AND tpep_pickup_datetime  <  '2024-02-01'
  AND tpep_dropoff_datetime >  tpep_pickup_datetime
  AND trip_distance         >  0
  AND fare_amount           >  0
  AND passenger_count       >  0;

-- Verify the view works
SELECT COUNT(*) AS total_rows FROM yellow_taxi;
