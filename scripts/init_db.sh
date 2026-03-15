#!/bin/sh
# =============================================================================
# init_db.sh — Download all raw data files for Evidence-POC
# =============================================================================

set -e

download() {
    DEST="$1"; URL="$2"; LABEL="$3"
    mkdir -p "$(dirname $DEST)"
    if [ -f "$DEST" ]; then
        echo "[init] $LABEL already exists ($(du -h $DEST | cut -f1)) — skipping."
    else
        echo "[init] Downloading $LABEL ..."
        curl -L --progress-bar -o "$DEST" "$URL"
        echo "[init] Done: $DEST ($(du -h $DEST | cut -f1))"
    fi
}

# NYC Yellow Taxi Jan 2024
download \
    "/data/nyc_taxi/raw/yellow_tripdata_2024-01.parquet" \
    "https://d37ci6vzurychx.cloudfront.net/trip-data/yellow_tripdata_2024-01.parquet" \
    "NYC Yellow Taxi Jan 2024"

# NYC Taxi Zone centroids — extract from TLC shapefile using DuckDB spatial
CENTROIDS="/data/nyc_taxi/raw/taxi_zone_centroids.csv"
if [ -f "$CENTROIDS" ]; then
    echo "[init] Zone centroids already exist — skipping."
else
    echo "[init] Extracting NYC taxi zone centroids from shapefile..."
    curl -s -L -o /tmp/taxi_zones.zip "https://d37ci6vzurychx.cloudfront.net/misc/taxi_zones.zip"
    unzip -q /tmp/taxi_zones.zip -d /tmp/taxi_zones
    /duckdb -csv -c "
        INSTALL spatial; LOAD spatial;
        COPY (
            SELECT
                LocationID    AS location_id,
                zone,
                borough,
                ST_X(ST_Transform(ST_Centroid(geom), 'EPSG:2263', 'EPSG:4326')) AS lat,
                ST_Y(ST_Transform(ST_Centroid(geom), 'EPSG:2263', 'EPSG:4326')) AS lon
            FROM ST_Read('/tmp/taxi_zones/taxi_zones/taxi_zones.shp')
            ORDER BY LocationID
        ) TO '$CENTROIDS' (HEADER, DELIMITER ',')
    " 2>/dev/null
    rm -rf /tmp/taxi_zones /tmp/taxi_zones.zip
    echo "[init] Saved $CENTROIDS ($(wc -l < $CENTROIDS) zones)"
fi

# Our World in Data — Energy
download \
    "/data/world_energy/owid-energy-data.csv" \
    "https://raw.githubusercontent.com/owid/energy-data/master/owid-energy-data.csv" \
    "OWID Energy CSV"

# Brazil economy indicators from World Bank API
sh /scripts/fetch_brazil_data.sh

echo "[init] All data files ready."
