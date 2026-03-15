#!/bin/sh
# Fetch Brazil economic indicators from World Bank API and save as CSV
# Uses only mawk-compatible awk (no gawk extensions)

set -e

OUT_DIR="/data/brazil_economy"
mkdir -p "$OUT_DIR"


fetch_indicator() {
    CODE="$1"
    NAME="$2"
    OUT="$OUT_DIR/$NAME.csv"
    if [ -f "$OUT" ] && [ -s "$OUT" ]; then
        echo "[init] $NAME already exists — skipping."
        return
    fi
    echo "[init] Fetching $NAME ($CODE) ..."
    curl -s "https://api.worldbank.org/v2/country/BR/indicator/$CODE?format=json&per_page=60&mrv=60" \
        | awk -f /scripts/parse_wb.awk | sort -t, -k1,1n > "$OUT"
    ROWS=$(wc -l < "$OUT")
    echo "[init] Saved $OUT ($ROWS rows)"
}

fetch_indicator "NY.GDP.MKTP.CD"  "gdp_usd"
fetch_indicator "NY.GDP.PCAP.CD"  "gdp_per_capita"
fetch_indicator "FP.CPI.TOTL.ZG"  "inflation"
fetch_indicator "SL.UEM.TOTL.ZS"  "unemployment"
fetch_indicator "PA.NUS.FCRF"     "usd_brl"
fetch_indicator "NE.EXP.GNFS.CD"  "exports"
fetch_indicator "NE.IMP.GNFS.CD"  "imports"

echo "[init] Brazil economy data ready."
