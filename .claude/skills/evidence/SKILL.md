---
name: evidence
description: Evidence BI framework reference — SQL-driven pages, chart components, data sources, and project structure. Use when working in an Evidence project.
---

# Evidence Framework Reference

> All rules in this file are verified against official Evidence.dev documentation.
> Do not change access patterns without re-verifying against docs.

---

## Project Structure

```
pages/                        # Filesystem = URL routing
  index.md                    # Root homepage (/)
  dataset-name/               # Subdirectory → sidebar group
    index.md                  # Group landing page (/dataset-name/)
    sub-page.md               # Subpage (/dataset-name/sub-page)
sources/                      # Data source definitions
  my_source/
    connection.yaml           # Connection config
    query.sql                 # Source query → pre-materialized Parquet
partials/                     # Reusable markdown snippets
static/                       # Images and static assets
```

### Sidebar navigation
- Subdirectories auto-create grouped sidebar sections
- `title:` frontmatter = sidebar label and page heading
- `sidebar_position: N` = order within a group (ascending)
- A directory's group name comes from the `title` in its `index.md`

---

## CRITICAL: Input Access Patterns

This is the most common source of page errors. Each component type has a
**different** access pattern. They are NOT interchangeable.

### Quick reference table

| Component | Access in SQL | Access in props/titles | Notes |
|---|---|---|---|
| **Dropdown** (single) | `'${inputs.x.value}'` | `{inputs.x.value}` | `.value` required |
| **Dropdown** (multi) | `IN ${inputs.x.value}` | `{inputs.x.value}` | No quotes around `${}` |
| **ButtonGroup** | `'${inputs.x}'` | `{inputs.x}` | **NO `.value`** |
| **DateRange** | `'${inputs.x.start}'` / `'${inputs.x.end}'` | `{inputs.x.start}` | **NO `.value`** |
| **Slider** | `${inputs.x}` | `{inputs.x}` | **NO `.value`**, no quotes |

### Dropdown (single-select)

```markdown
<Dropdown data={q} name=my_filter value=category_col title="Category"/>

<!-- SQL -->
where category = '${inputs.my_filter.value}'

<!-- Component prop -->
<LineChart y={inputs.my_filter.value}/>

<!-- If/else -->
{#if inputs.my_filter.value === 'foo'}
```

### Dropdown (multi-select, `multiple=true`)

```markdown
<Dropdown data={q} name=multi_filter value=col multiple=true selectAllByDefault=true/>

<!-- SQL — IN clause, NO quotes around ${} -->
where col IN ${inputs.multi_filter.value}

<!-- WRONG — produces "[object Object]" error -->
where col IN '${inputs.multi_filter.value}'   ← extra quotes
where col IN ${inputs.multi_filter}           ← missing .value
```

Multi-select `.value` renders as a SQL tuple: `('A','B','C')`.

### ButtonGroup

```markdown
<ButtonGroup name=metric title="Metric">
    <ButtonGroupItem valueLabel="Trips" value="trips" default/>
    <ButtonGroupItem valueLabel="Revenue" value="revenue"/>
</ButtonGroup>

<!-- SQL -->
where col = '${inputs.metric}'

<!-- Component prop — NO .value -->
<LineChart y={inputs.metric} title="Chart: {inputs.metric}"/>

<!-- If/else — NO .value -->
{#if inputs.metric === 'trips'}
```

### DateRange

```markdown
<DateRange name=dr start=2024-01-01 end=2024-12-31/>

<!-- SQL on DATE/TIMESTAMP column — correct -->
where order_date BETWEEN '${inputs.dr.start}' AND '${inputs.dr.end}'

<!-- SQL on INTEGER year column — MUST cast -->
where year >= YEAR(CAST('${inputs.dr.start}' AS DATE))
  and year <= YEAR(CAST('${inputs.dr.end}' AS DATE))

<!-- WRONG for integer year columns -->
where year >= '${inputs.dr.start}'            ← string vs int
where year >= year('${inputs.dr.start}')      ← year() needs DATE, not string
```

`.start` and `.end` return `YYYY-MM-DD` strings. When filtering an INTEGER
`year` column, you must extract the year with `YEAR(CAST(... AS DATE))`.

### Slider

```markdown
<Slider name=top_n min=5 max=30 defaultValue=15 step=5/>

<!-- SQL — no .value, no quotes (it's a number) -->
limit ${inputs.top_n}
where sales >= ${inputs.top_n}

<!-- Component prop — no .value -->
title="Top {inputs.top_n} items"
```

---

## Source SQL vs Page SQL

| | Source SQL (`sources/name/query.sql`) | Page SQL (` ```sql name ``` `) |
|---|---|---|
| Runs at | `npm run sources` (build/server time) | Browser (DuckDB-WASM, client-side) |
| Output | Evidence Parquet cache | In-memory query over cached Parquet |
| Can reference | Raw files via `read_parquet()`, `read_csv()` | Source results via `source_name.query` or `${other_query}` |
| Can use `inputs.` | **No** | Yes |
| Row limit | Unlimited | Keep small — all rows sent to browser |
| Cross-source JOINs | **No** — each source is isolated | Yes — via page SQL `JOIN` |

**Source SQL must aggregate.** Never return raw 1M+ row tables. Always
`GROUP BY` or `LIMIT`. The entire result is shipped to the browser as Parquet.

### read_parquet() path in source SQL

Use paths **relative to the Evidence working directory**, not container paths:

```sql
-- CORRECT
FROM read_parquet('sources/nyc_taxi/raw/data.parquet')
FROM read_csv('sources/brazil_economy/gdp_usd.csv', auto_detect=true)

-- WRONG — breaks when opened by a different process
FROM read_parquet('/data/raw/data.parquet')          ← absolute container path
FROM read_parquet('/usr/src/app/sources/...')        ← absolute path
```

### Query chaining (page SQL only)

```sql
```sql base_query
select * from source_name.table
```

```sql filtered
select * from ${base_query}
where col = '${inputs.x.value}'
```
```

DuckDB subquery alias is optional. Circular references are blocked by Evidence.
Cross-page query references are **not possible** — use `/queries/` SQL files for shared logic.

---

## DuckDB Browser Dialect Notes

Evidence page queries run in DuckDB-WASM. Avoid:

- `year('2024-01-01')` — `YEAR()` needs a `DATE` type, not a string. Use `YEAR(CAST('...' AS DATE))`
- `USING SAMPLE N ROWS` after `WHERE` — wrong DuckDB syntax. Wrap in subquery:
  ```sql
  FROM (SELECT * FROM t WHERE ...) USING SAMPLE 5000 ROWS
  ```
- Very large result sets — all rows are sent to the browser. Aggregate in SQL.

---

## Components

### Charts — common props

```markdown
<LineChart data={query} x=date_col y=value_col/>
<BarChart  data={query} x=category  y=sales series=group labels=true/>
<AreaChart data={query} x=year y={["col1","col2","col3"]}/>
<ScatterPlot data={query} x=distance y=fare series=payment_type opacity=0.5/>
<Heatmap data={query} x=hour y=day_name value=trips/>
```

- Column name props are **unquoted bare values**: `x=month` not `x="month"`
- Multi-y arrays use quoted strings: `y={["sales","orders"]}`
- Dynamic y from ButtonGroup: `y={inputs.metric}` (no `.value`)
- Dynamic y from Dropdown: `y={inputs.metric.value}`
- `data={query}` always needs curly braces

### Maps

```markdown
<PointMap
    data={locations}
    lat=lat_col
    long=lon_col          ← prop is "long" (4 chars), NOT "lon"
    value=metric_col
    pointName=label_col
    startingLat=40.71
    startingLong=-74.00
    startingZoom=11
    height=500
    tooltipType=hover
/>
```

The `long=` prop takes the **column name** as its value. If your column is
named `lon`, write `long=lon`. If named `longitude`, write `long=longitude`.

### BigValue — aggregation must be in SQL

`agg=` is **not a valid BigValue prop** — it is silently ignored.

```markdown
<!-- WRONG — agg= does nothing -->
<BigValue data={raw_query} value=sales agg=sum/>

<!-- CORRECT — aggregate in SQL first -->
```sql totals
select sum(sales) as total_sales, avg(price) as avg_price
from ${raw_query}
```
<BigValue data={totals} value=total_sales fmt=usd0/>
<BigValue data={totals} value=avg_price fmt=usd2/>
```

### Layout

```markdown
<Grid cols=3> ... </Grid>
<BigLink href="/path">## Title\nDescription</BigLink>
<DataTable data={q} search=true/>
```

---

## Sidebar Grouping (page organisation)

```
pages/
├── index.md                     ← portal page (title = site root label)
├── nyc-taxi/
│   ├── index.md                 ← title: "NYC Yellow Taxi" → group label
│   ├── time-patterns.md         ← sidebar_position: 2
│   └── trip-analysis.md         ← sidebar_position: 3
└── world-energy/
    └── index.md
```

Frontmatter for group `index.md`:
```yaml
---
title: NYC Yellow Taxi    # ← sidebar group label
sidebar_position: 1       # ← group order among all top-level items
---
```

---

## Known Pitfalls — Do Not Repeat

| # | Wrong | Correct | Component |
|---|---|---|---|
| 1 | `{inputs.x.value}` | `{inputs.x}` | ButtonGroup / Slider |
| 2 | `{inputs.x}` | `{inputs.x.value}` | Dropdown (single) |
| 3 | `IN '${inputs.x.value}'` | `IN ${inputs.x.value}` | Dropdown multi |
| 4 | `IN ${inputs.x}` | `IN ${inputs.x.value}` | Dropdown multi |
| 5 | `year >= '${inputs.dr.start}'` | `year >= YEAR(CAST('${inputs.dr.start}' AS DATE))` | DateRange + INT year |
| 6 | `year('${inputs.dr.start}')` | `YEAR(CAST('${inputs.dr.start}' AS DATE))` | DateRange + INT year |
| 7 | `{#if inputs.x.value === ...}` | `{#if inputs.x === ...}` | ButtonGroup |
| 8 | `<BigValue agg=sum/>` | Aggregate in SQL | BigValue |
| 9 | `long=longitude` (when col is `lon`) | `long=lon` | PointMap |
| 10 | `FROM read_parquet('/abs/path')` | `FROM read_parquet('sources/name/file')` | Source SQL |
| 11 | `FROM (SELECT * WHERE ...) USING SAMPLE` | `FROM (subquery) USING SAMPLE N ROWS` | DuckDB WASM |
| 12 | Cross-source refs in source SQL | Join in page SQL instead | Source SQL |
| 13 | `x="month"` (quoted) | `x=month` (bare) | All chart components |
