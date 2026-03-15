#!/bin/bash
# =============================================================================
# init_db.sh — Bootstrap DuckDB with NYC Taxi data from S3 Parquet files
# =============================================================================
# This script runs inside the duckdb-init container.
# It downloads one month of Yellow Taxi data (Jan 2024) directly from
# the NYC TLC S3 bucket and persists it to a DuckDB file that Evidence
# mounts as its data source.
# =============================================================================

set -euo pipefail

DB_PATH="/data/nyc_taxi.db"
PARQUET_URL="https://d37ci6vzurychx.cloudfront.net/trip-data/yellow_tripdata_2024-01.parquet"

echo "[init_db] Starting DuckDB initialization..."

if [ -f "$DB_PATH" ]; then
  echo "[init_db] Database already exists at $DB_PATH — skipping download."
  exit 0
fi

echo "[init_db] Creating DuckDB at $DB_PATH ..."

duckdb "$DB_PATH" <<'SQL'
-- Install and load the httpfs extension so we can read from S3/HTTPS
INSTALL httpfs;
LOAD httpfs;

-- Pull Jan 2024 Yellow Taxi directly from the TLC CloudFront distribution
-- ~3M rows, ~50MB Parquet — fast enough for a POC
CREATE TABLE yellow_taxi AS
SELECT
    VendorID                                AS vendor_id,
    tpep_pickup_datetime                    AS pickup_datetime,
    tpep_dropoff_datetime                   AS dropoff_datetime,
    passenger_count,
    trip_distance,
    RatecodeID                              AS rate_code_id,
    store_and_fwd_flag,
    PULocationID                            AS pickup_location_id,
    DOLocationID                            AS dropoff_location_id,
    payment_type,
    fare_amount,
    extra,
    mta_tax,
    tip_amount,
    tolls_amount,
    improvement_surcharge,
    total_amount,
    congestion_surcharge,
    Airport_fee                             AS airport_fee,
    -- Derived columns for easier querying in dashboards
    DATE_TRUNC('day',  tpep_pickup_datetime) AS pickup_date,
    DATE_TRUNC('hour', tpep_pickup_datetime) AS pickup_hour,
    HOUR(tpep_pickup_datetime)               AS hour_of_day,
    DAYOFWEEK(tpep_pickup_datetime)          AS day_of_week,
    DAYNAME(tpep_pickup_datetime)            AS day_name,
    DATEDIFF('minute', tpep_pickup_datetime, tpep_dropoff_datetime) AS trip_duration_min,
    CASE payment_type
        WHEN 1 THEN 'Credit Card'
        WHEN 2 THEN 'Cash'
        WHEN 3 THEN 'No Charge'
        WHEN 4 THEN 'Dispute'
        WHEN 5 THEN 'Unknown'
        WHEN 6 THEN 'Voided Trip'
        ELSE 'Other'
    END AS payment_type_name,
    CASE vendor_id
        WHEN 1 THEN 'Creative Mobile Technologies'
        WHEN 2 THEN 'VeriFone Inc.'
        ELSE 'Unknown'
    END AS vendor_name
FROM read_parquet('https://d37ci6vzurychx.cloudfront.net/trip-data/yellow_tripdata_2024-01.parquet')
-- Basic sanity filters: exclude test rows and obvious data errors
WHERE tpep_pickup_datetime  >= '2024-01-01'
  AND tpep_pickup_datetime  <  '2024-02-01'
  AND tpep_dropoff_datetime >  tpep_pickup_datetime
  AND trip_distance         >  0
  AND fare_amount           >  0
  AND passenger_count       >  0;

-- Confirm row count
SELECT COUNT(*) AS total_rows FROM yellow_taxi;
SQL

echo "[init_db] Done. Database ready at $DB_PATH"
