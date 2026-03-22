@.claude/NEXT_SESSION.md

# dataviz-evidence-poc — Agent Instructions

## Start Here

Read `.claude/session-state.md` for current state.
If `KICKSTART.md` exists at repo root, read it first.

Universal engineering rules live in `~/projects/CLAUDE.md` — not repeated here.

---

## What This Repo Is

Proof-of-concept Evidence.dev BI-as-code project. Three fully interactive dashboards
backed by DuckDB reading raw Parquet/CSV files. Evaluates Evidence.dev as a BI toolchain.

## Stack

- **Framework:** Evidence.dev
- **DB:** DuckDB (reads Parquet/CSV at runtime via `init_db.sh`)
- **Dev:** `docker compose up` from project root
- **Port:** 3777 (registered in `~/projects/ports.yml` — do not change without updating registry)

## Key Technical Facts

- Evidence running on port **3777** (not 3000)
- Raw data files (Parquet, CSV) are gitignored — downloaded at runtime by `init_db.sh`
- Default branch is `master` (not `main`)

## Dev workflow

```bash
docker compose up    # start Evidence dev server at localhost:3777
```

## Git Notes

- SSH not configured — use HTTPS for all git operations
- Default branch: `master`
