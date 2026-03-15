# Evidence.dev POC

A proof-of-concept BI-as-code project built with [Evidence.dev](https://evidence.dev) and DuckDB,
evaluating Evidence as a candidate for a SQL-driven, version-controlled analytics platform.

Three fully interactive dashboards, built entirely in Markdown + SQL. No drag-and-drop. No GUI.
Everything is code, everything is in git.

---

## Dashboards

| Dataset | Pages | Source |
|---|---|---|
| **NYC Yellow Taxi** | Overview, Time Patterns, Trip Analysis, Zone Map | TLC Jan 2024 Parquet (2.7M rows) |
| **World Energy Mix** | Global trends, Country comparison, Renewables ranking | Our World in Data CSV |
| **Brazil Economy** | GDP, inflation, FX, trade (2000–2025) | World Bank Open Data API |

### NYC Yellow Taxi
- KPI overview: total trips, revenue, avg fare, avg distance
- Daily trip volume trend for January 2024
- Hourly heatmap (trips by hour × day of week)
- Fare vs. distance scatter plot (sampled)
- Top pickup zones ranked by volume
- Vendor comparison
- **PointMap** of all 263 taxi zones — filterable by borough, colorable by pickups / dropoffs / revenue

### World Energy Mix
- Global primary energy consumption by source (1965–present)
- Country-level energy mix comparison
- Top renewable energy countries ranked by share

### Brazil Economy
- GDP (total and per capita), inflation, unemployment, USD/BRL rate
- Exports, imports, trade balance — all from World Bank API
- Full time-series from 2000 to 2025 with DateRange filter

---

## Stack

```
Evidence.dev  →  Markdown + SQL pages compiled to a static site
DuckDB        →  In-memory query engine (no persistent .db file)
Docker Compose → Two-service stack: data init + Evidence dev server
```

All raw data is downloaded at container start by `scripts/init_db.sh`. Nothing is committed to git.

---

## How to Run

```bash
docker compose up
```

Open **http://localhost:3777**.

That's it. The `duckdb-init` service downloads all raw data files on first run (skips if already present).
The `evidence` service waits for it to finish, then runs `npm run sources` and starts the dev server.

**First run** takes ~2–3 min (downloads ~60 MB of raw data).
**Subsequent runs** start in ~30 sec (data already present, sources rebuild from cache).

---

## Project Structure

```
pages/
  index.md                      # Portal — links to all datasets
  nyc-taxi/
    index.md                    # Overview KPIs + daily trend
    time-patterns.md            # Heatmap + hourly charts
    trip-analysis.md            # Distance, fare, zones, vendors
    map.md                      # PointMap of 263 taxi zones
  world-energy/
    index.md                    # Global mix + country comparison
  brazil-economy/
    index.md                    # Macro indicators 2000–2025

sources/
  nyc_taxi/                     # 9 DuckDB source queries (pre-aggregated)
  world_energy/                 # 4 DuckDB source queries
  brazil_economy/               # 1 DuckDB source query (joins 7 CSVs)

scripts/
  init_db.sh                    # Downloads all raw data + extracts zone centroids
  fetch_brazil_data.sh          # World Bank API → CSV (7 indicators)
  parse_wb.awk                  # mawk-compatible JSON→CSV parser
```

---

## Architecture Notes

**In-memory DuckDB** — `connection.yaml` has no `filename:`, so each source query runs
`read_parquet()` or `read_csv()` directly over the raw files. No persistent `.db` file,
no cross-container path issues.

**Source SQL vs Page SQL** — source queries run at build time and produce pre-aggregated
Parquet files shipped to the browser. Page SQL runs client-side in DuckDB-WASM over those
Parquet files. Interactive filters (`inputs.*`) only work in page SQL.

**Zone centroids** — extracted from the NYC TLC shapefile via DuckDB spatial extension
(`LOAD spatial; ST_X(ST_Centroid(geom))`). Stored as `taxi_zone_centroids.csv` (gitignored,
generated at runtime).

---

## Key Evidence Patterns Learned

These were discovered/verified against official docs during this POC and are captured in
`.claude/skills/evidence/SKILL.md`:

| Component | SQL access | Prop access |
|---|---|---|
| `Dropdown` (single) | `'${inputs.x.value}'` | `{inputs.x.value}` |
| `Dropdown` (multi) | `IN ${inputs.x.value}` | `{inputs.x.value}` |
| `ButtonGroup` | `'${inputs.x}'` | `{inputs.x}` — **no `.value`** |
| `DateRange` | `'${inputs.x.start}'` | `{inputs.x.start}` — **no `.value`** |
| `Slider` | `${inputs.x}` | `{inputs.x}` — **no `.value`**, no quotes |

`DateRange` with an INTEGER year column requires `YEAR(CAST('${inputs.x.start}' AS DATE))` —
not `year('...')` (binder error) and not a bare string comparison (type mismatch).

`BigValue` has no `agg=` prop. Aggregate in SQL first.

`PointMap` longitude prop is `long=` (4 chars), not `lon=`.
