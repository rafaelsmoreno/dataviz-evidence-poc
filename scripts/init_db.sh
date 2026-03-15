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

# Our World in Data — Energy
download \
    "/data/world_energy/owid-energy-data.csv" \
    "https://raw.githubusercontent.com/owid/energy-data/master/owid-energy-data.csv" \
    "OWID Energy CSV"

# Brazil economy indicators from World Bank API
sh /scripts/fetch_brazil_data.sh

echo "[init] All data files ready."
