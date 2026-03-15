# Next Session Kickstart — Evidence-POC

## Context

Evidence.dev POC running at http://localhost:3777 (port 3777, registered in ~/projects/ports.yml).
All work is on branch `feature/nyc-taxi-duckdb-scaffold`. No PR opened yet.
Read `.claude/session-state.md` for full context before doing anything.

---

## Immediate actions at session start

### 1. Check if zone map centroid CSV exists
```bash
ls Evidence-POC/sources/nyc_taxi/raw/
```
If `taxi_zone_centroids.csv` is MISSING (likely), generate it:
```bash
cd Evidence-POC && docker compose down && docker compose up -d
docker logs duckdb_init -f   # watch for "Saved .../taxi_zone_centroids.csv"
```
Then restart Evidence to rebuild sources:
```bash
docker compose restart evidence
docker logs evidence_dev -f   # watch for "Starting dev server"
```

### 2. Verify all pages render without red errors
Open each page and confirm no red error boxes:
- http://localhost:3777 (portal)
- http://localhost:3777/nyc-taxi (overview)
- http://localhost:3777/nyc-taxi/time-patterns
- http://localhost:3777/nyc-taxi/trip-analysis
- http://localhost:3777/nyc-taxi/map  ← needs centroid CSV
- http://localhost:3777/world-energy
- http://localhost:3777/brazil-economy

If any page is still broken, check the browser console error message and
cross-reference `.claude/skills/evidence/SKILL.md` pitfall table before touching code.

### 3. Open the PR
```bash
cd Evidence-POC
gh pr create --title "feat(poc): Evidence + DuckDB + NYC Taxi + World Energy + Brazil Economy dashboards" \
  --body "Full Evidence.dev POC with three datasets, interactive filters, zone map, and correct input access patterns."
```

---

## Remaining work (prioritised)

### P1 — Verify zone map works end-to-end
The `nyc-taxi/map.md` PointMap page has never been seen working.
After generating `taxi_zone_centroids.csv` and rebuilding sources, open the map page
and confirm points render on the NYC map. If it errors, check the `zone_map` source
SQL and the centroids CSV content.

### P2 — Evidence session complete → decide next tool
The user wants to move to a "more flexible BI-as-code tool" next.
Candidates discussed: **Metabase** or **Lightdash**.
Create a new repo: `<tool-name>-POC` following the same pattern.
Metabase: self-hosted via Docker, SQL-driven, live queries, row-level security, write-back.
Lightdash: dbt-native, semantic layer, full drill-through.

### P3 — Platform scaling phases (separate context, AI-dev-Platform repo)
A 5-phase plan was written this session. Phase 1 is highest priority:
Replace per-repo `pre-commit` hooks with `git config --global core.hooksPath`.
Full plan in the session handoff block from the previous session conversation.

---

## Key technical facts to remember

- **ButtonGroup** → `{inputs.x}` (NO `.value` anywhere)
- **Dropdown** → `{inputs.x.value}` (always `.value`)
- **DateRange + INT year** → `YEAR(CAST('${inputs.dr.start}' AS DATE))`
- **BigValue** → aggregate in SQL first; `agg=` prop is invalid
- **Source SQL paths** → relative: `sources/name/raw/file.parquet` (never absolute)
- **Evidence dev server** → hot-reloads page edits; source SQL changes need `npm run sources`
