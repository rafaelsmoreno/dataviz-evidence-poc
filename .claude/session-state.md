# Session State — Evidence-POC
## Last updated: 2026-03-15T21:30:00-03:00

---

## Goal

Proof-of-concept Evidence.dev BI-as-code project demonstrating:
1. Evidence connected to DuckDB reading raw Parquet/CSV files
2. Three fully interactive dashboards across three datasets
3. Good navigation structure, no chart errors
4. Foundation to evaluate Evidence before deciding on a more flexible BI-as-code tool

---

## Instructions

- Evidence running on port **3777** (not 3000 — registered in `~/projects/ports.yml`)
- Do not commit raw data files (Parquet, CSV) — they are gitignored and downloaded at runtime by `init_db.sh`
- All work is on branch `feature/nyc-taxi-duckdb-scaffold` — no PR opened yet
- Dev workflow: `docker compose up` from the project root starts everything

---

## Discoveries — Technical Facts

### Evidence input access patterns (verified against official docs)
| Component | SQL | Props/titles |
|---|---|---|
| Dropdown single | `'${inputs.x.value}'` | `{inputs.x.value}` |
| Dropdown multi | `IN ${inputs.x.value}` (no quotes) | `{inputs.x.value}` |
| ButtonGroup | `'${inputs.x}'` (no `.value`) | `{inputs.x}` |
| DateRange | `'${inputs.x.start}'` / `'${inputs.x.end}'` | no `.value` |
| Slider | `${inputs.x}` (no `.value`, no quotes) | `{inputs.x}` |

### DateRange + INTEGER year column
```sql
-- CORRECT
where year >= YEAR(CAST('${inputs.dr.start}' AS DATE))
-- WRONG — binder error
where year >= year('${inputs.dr.start}')
```

### BigValue — `agg=` is NOT a valid prop. Aggregate in SQL first.

### PointMap — longitude prop is `long=` (4 chars), value is column name (can be `lon`)

### Source SQL — paths must be relative to Evidence working dir
```sql
FROM read_parquet('sources/nyc_taxi/raw/yellow_tripdata_2024-01.parquet')
-- NOT /data/raw/... or /usr/src/app/...
```

### DuckDB in-memory architecture
- `connection.yaml` has no `filename:` → in-memory DuckDB
- Each source query does `read_parquet()` or `read_csv()` directly
- This avoids the cross-container path problem with `.db` files
- `NODE_OPTIONS=--max-old-space-size=4096` is set in compose.yaml to handle 2.7M row scans

### Docker compose architecture
- `duckdb-init` service: downloads raw data files, runs DuckDB spatial for zone centroids
- `evidence` service: `npm run sources` → `npm run dev`
- `duckdb-init` uses `datacatering/duckdb:v1.2.0` image (has `curl`, `awk`, `unzip`, DuckDB CLI + spatial)
- Evidence runs on `node:20-slim`

### Zone centroids extraction
`init_db.sh` downloads `taxi_zones.zip`, runs DuckDB spatial to extract centroids as
`sources/nyc_taxi/raw/taxi_zone_centroids.csv`. This requires a fresh `docker compose down && up`
to generate — it was NOT generated in this session (`.parquet` exists, centroids CSV does NOT).

---

## Accomplished

### Infrastructure
- [x] Docker Compose with two services: `duckdb-init` + `evidence`
- [x] Port 3777 (registered in `~/projects/ports.yml`)
- [x] `init_db.sh` downloads NYC Taxi Parquet, OWID Energy CSV, Brazil World Bank CSVs
- [x] `fetch_brazil_data.sh` + `parse_wb.awk` fetch World Bank API → CSV (mawk-compatible)
- [x] `init_db.sh` also extracts taxi zone centroids via DuckDB spatial extension
- [x] `.gitignore` excludes all raw data files

### Data sources
- [x] `nyc_taxi` source: 8 SQL queries over Jan 2024 Yellow Taxi Parquet (2.7M rows)
  - `overview_kpis`, `daily_trips`, `hourly_patterns`, `payment_breakdown`
  - `top_pickup_zones`, `distance_distribution`, `fare_vs_distance`, `vendor_comparison`
  - `zone_map` — joins trip counts with taxi zone centroids for PointMap
- [x] `world_energy` source: 4 SQL queries over OWID Energy CSV
  - `global_trends`, `country_mix`, `top_renewable_countries`, `country_time_series`
- [x] `brazil_economy` source: 1 SQL query joining 7 World Bank CSV indicators
  - `macro_indicators` — GDP, per capita, inflation, unemployment, USD/BRL, exports, imports

### Dashboard pages (all in subdirectory structure)
- [x] `pages/index.md` — portal with BigLink cards to each dataset
- [x] `pages/nyc-taxi/index.md` — overview KPIs, daily trend, payment breakdown
- [x] `pages/nyc-taxi/time-patterns.md` — heatmap, avg fare by hour, daily trends
- [x] `pages/nyc-taxi/trip-analysis.md` — distance dist, scatter, top zones, vendors
- [x] `pages/nyc-taxi/map.md` — PointMap of 263 taxi zones (needs centroid CSV)
- [x] `pages/world-energy/index.md` — global mix, country comparison, renewables ranking
- [x] `pages/brazil-economy/index.md` — GDP, USD/BRL, inflation, unemployment, trade

### Interactivity on all pages
- [x] DateRange, ButtonGroup, Dropdown (single + multi), Slider used throughout
- [x] All 16 input access bugs fixed (ButtonGroup `.value`, DateRange+INT year, BigValue agg=)

### Platform governance
- [x] `pre-commit-branch-guard.sh` installed in AI-dev-Context and AI-dev-Practices
- [x] `make setup` target in both repos
- [x] Global hook path analysis done (Phase 1 of scaling plan)
- [x] `~/projects/ports.yml` created as central port registry
- [x] `AI-dev-Practices/CLAUDE.md` updated with port allocation rule
- [x] `AI-dev-Context/skills/docker-review.md` updated with port pre-flight section
- [x] All PRs merged: AI-dev-Context #6, AI-dev-Practices #8, AI-dev-Platform #134
- [x] Evidence skill (`SKILL.md`) fully rewritten with verified doc-grounded rules

---

## In Progress / Pending

### Zone Map page (blocked until centroids CSV is generated)
- `sources/nyc_taxi/raw/taxi_zone_centroids.csv` does NOT exist yet
- It will be created on the next `docker compose down && docker compose up`
  (the `init_db.sh` spatial extraction block will run since the file is absent)
- After it exists, `npm run sources` must re-run to rebuild `zone_map.parquet`
- The map page will show errors until this is done

### PR not opened yet
- All work is on `feature/nyc-taxi-duckdb-scaffold`
- No PR opened — do this at session start if desired

### Evidence page errors — possibly still present
- All 16 known bugs were fixed and committed
- The dev server hot-reloads page changes but **source query changes require `npm run sources`**
- If charts are still broken, restart the Evidence container: `docker compose restart evidence`

### Platform scaling plan (separate from this POC)
5 phases documented in a handoff block from earlier in this session.
Start with Phase 1: `git config --global core.hooksPath` in AI-dev-Platform.

---

## Relevant files / directories

### Evidence-POC repo (branch: `feature/nyc-taxi-duckdb-scaffold`)
```
compose.yaml                          # Two-service stack: duckdb-init + evidence
scripts/init_db.sh                    # Downloads all raw data + extracts zone centroids
scripts/fetch_brazil_data.sh          # World Bank API → CSV (7 indicators)
scripts/parse_wb.awk                  # mawk-compatible JSON→CSV parser for World Bank
sources/nyc_taxi/                     # 8 source SQL files + connection.yaml
sources/world_energy/                 # 4 source SQL files + connection.yaml
sources/brazil_economy/               # 1 source SQL file + connection.yaml
sources/nyc_taxi/raw/                 # Runtime-downloaded data (gitignored)
  yellow_tripdata_2024-01.parquet     # EXISTS
  taxi_zone_centroids.csv             # MISSING — generated on next compose up
pages/index.md                        # Portal
pages/nyc-taxi/                       # 4 pages: index, time-patterns, trip-analysis, map
pages/world-energy/index.md
pages/brazil-economy/index.md
.claude/skills/evidence/SKILL.md     # Fully updated Evidence reference skill
```

### Other repos touched
```
~/projects/ports.yml                                    # Central port registry
AI-dev-Context/skills/docker-review.md                  # Port pre-flight section added
AI-dev-Practices/CLAUDE.md                              # Port allocation rule added
AI-dev-Practices/scripts/pre-commit-branch-guard.sh     # Branch guard hook
AI-dev-Platform/docs/lifecycle-triggers.yml             # before_code_changes updated
AI-dev-Platform/docs/issue-report-direct-commit-to-main-missing-hook-propagation.md
```

---

## Next session kickstart prompt

See `NEXT_SESSION.md` in this directory.
