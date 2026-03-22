# Kickstart Prompt — dataviz-evidence-poc

Last updated: 2026-03-22
Maintained by `scripts/update_kickstart.py` — do not edit manually.

---

## Paste this at the start of the next session:

```
Repo: dataviz-evidence-poc — continuing from previous session.

## Last completed (2026-03-22)
Evidence.dev POC with 3 datasets (NYC Taxi, World Energy, Brazil Economy). All pages implemented. Zone map centroid CSV generation pending.

## Repo: dataviz-evidence-poc
## Date: 2026-03-22

## Current branch
master

## Open PRs
  (none)

## Last 3 commits
  2ec508b chore(claude): create .claude/CLAUDE.md (M4 consolidation) (#3)
  d8549f1 Merge pull request #2 from rafaelsmoreno/feature/nyc-taxi-duckdb-scaffold
  3b3fa8a docs: rewrite README with project overview, stack, usage, and patterns

## Start here: P1: Verify zone map works end-to-end (taxi_zone_centroids.csv). P2: Open PR for feature/nyc-taxi-duckdb-scaffold branch. P3: Decide next BI-as-code tool (Metabase or Lightdash).

- Check centroid CSV: ls Evidence-POC/sources/nyc_taxi/raw/ — if missing, run docker compose up to generate
- Verify all 7 pages render without red errors at http://localhost:3777
- Open PR for feat/nyc-taxi-duckdb-scaffold when map page confirmed working

## Persistent context
- Repo uses master (not main) as default branch
- ButtonGroup: {inputs.x} (NO .value). Dropdown: {inputs.x.value}. DateRange+INT year: YEAR(CAST(...)). BigValue: aggregate in SQL first.
- Port 3777 registered in ~/projects/ports.yml
- Evidence dev server hot-reloads page edits; source SQL changes need npm run sources

## Blockers / Watch out
taxi_zone_centroids.csv likely missing — must regenerate via docker compose
Do not ask about optional parameters. Start working.
```
