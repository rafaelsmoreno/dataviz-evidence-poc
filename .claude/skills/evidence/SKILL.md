---
name: evidence
description: Evidence BI framework reference — SQL-driven pages, chart components, data sources, and project structure. Use when working in an Evidence project.
---

# Evidence Framework Reference

## Project Structure

```
pages/                        # Markdown pages — filesystem = URL routing
  index.md                    # Root homepage (/), serves as dataset portal
  dataset-name/               # Subdirectory = sidebar group with that name
    index.md                  # Landing page for the group (/dataset-name/)
    sub-page.md               # Subpage (/dataset-name/sub-page)
sources/                      # Data source connections
  my_source/
    connection.yaml           # Connection config
    query.sql                 # Source query — pre-materialized to Parquet
partials/                     # Reusable markdown snippets
static/                       # Static assets (images, etc.)
evidence.plugins.yaml         # Plugin and theme config
```

### Sidebar Navigation
- Subdirectory structure creates grouped sections in the sidebar automatically
- `sidebar_position: N` in frontmatter controls order within a group
- `title` in frontmatter sets the sidebar label and page heading
- Directory group name comes from the `title` in its `index.md`

```markdown
---
title: NYC Yellow Taxi   # ← becomes the sidebar group label
sidebar_position: 1      # ← group order in sidebar
---
```

## Page Authoring

Pages are Markdown files with SQL code blocks:
````markdown
```sql orders
select * from needful_things.orders
where order_date >= '2024-01-01'
```

Total orders: <Value data={orders} column="order_count"/>
````

SQL blocks: ` ```sql query_name ` — the name becomes a referenceable variable.

## CRITICAL: Input `.value` Rules

**This is the most common source of errors.** Every input component stores its
selected value in a `.value` property. Always use `.value` when referencing
inputs in SQL strings or component props.

### Single-select inputs (Dropdown, ButtonGroup)

```markdown
<!-- SQL interpolation — MUST use .value -->
where category = '${inputs.my_dropdown.value}'

<!-- Component prop — MUST use .value -->
<LineChart y={inputs.my_metric.value} />
<BarChart title="Results for {inputs.my_dropdown.value}" />

<!-- If/else conditions — MUST use .value -->
{#if inputs.view_mode.value === 'shares'}
```

### Multi-select Dropdown (`multiple=true`)

```markdown
<!-- SQL IN clause — use .value, NO quotes around ${} -->
where category IN ${inputs.my_multi.value}

<!-- WRONG — produces "[object Object]" error -->
where category IN ${inputs.my_multi}        ← missing .value
where category IN '${inputs.my_multi.value}' ← wrong quotes
```

### DateRange inputs

```markdown
<!-- DateRange uses .start and .end — NOT .value -->
where date >= '${inputs.date_filter.start}'
  and date <= '${inputs.date_filter.end}'
```

### Slider inputs

```markdown
<!-- Slider returns a raw number — no .value needed in SQL -->
where trip_distance <= ${inputs.max_distance}
limit ${inputs.top_n}
```

### Summary table

| Component    | SQL usage                          | Prop usage                  |
|---|---|---|
| Dropdown     | `'${inputs.x.value}'`              | `{inputs.x.value}`          |
| Dropdown multi | `IN ${inputs.x.value}`           | `{inputs.x.value}`          |
| ButtonGroup  | `'${inputs.x.value}'`              | `{inputs.x.value}`          |
| DateRange    | `'${inputs.x.start}'`              | `{inputs.x.start}`          |
| Slider       | `${inputs.x}` (no .value)          | `{inputs.x}`                |

## Built-in Components

### Charts
- `<BarChart data={query} x=category y=value/>` — vertical bars
- `<LineChart data={query} x=date y=value series=group/>` — time series
- `<AreaChart data={query} x=date y={["col1","col2"]}/>` — stacked/filled
- `<ScatterPlot data={query} x=x_col y=y_col series=group opacity=0.5/>` — correlation
- `<Heatmap data={query} x=hour y=day value=trips/>` — 2D heatmap
- `<FunnelChart>` — conversion funnels
- `<Histogram data={query} x=value/>` — distribution

### Maps
- `<PointMap data={query} lat=lat long=lon value=metric pointName=label/>`
  - Requires `lat` and `long` columns with WGS84 decimal degrees
  - `value` column determines point color (scalar or categorical)
  - `startingLat`, `startingLong`, `startingZoom` set initial viewport
  - `tooltipType=hover` or `click`
  - `colorPalette={['#color1','#color2',...]}` for custom scale
- `<BubbleMap>` — sized bubbles on map
- `<AreaMap>` — choropleth (requires GeoJSON)

### Tables & Values
- `<DataTable data={query} search=true/>` — sortable, searchable, paginated
- `<BigValue data={query} value=col fmt=usd0 title="Label" agg=sum/>`
- `<Value data={query} column=col/>` — inline single value

### Inputs (interactive filters)
- `<Dropdown data={query} name=x value=col title="Label"/>`
- `<Dropdown ... multiple=true selectAllByDefault=true/>` — multi-select
- `<DropdownOption value="val" valueLabel="Label"/>` — hardcoded options
- `<ButtonGroup name=x><ButtonGroupItem valueLabel="Label" value="val" default/></ButtonGroup>`
- `<DateRange name=x start=2024-01-01 end=2024-12-31/>`
- `<Slider name=x min=0 max=100 defaultValue=50 step=5/>`
- `<TextInput name=x/>`

### Layout
- `<Grid cols=3>` — responsive grid
- `<BigLink href="/path">## Title\nDescription</BigLink>` — card link
- `<Tabs>` / `<Tab label="Tab 1">` — tabbed content
- `<Alert status="info">` — callout boxes

## Component Props — Common Patterns

```markdown
<!-- Dynamic y axis from ButtonGroup -->
<LineChart data={q} x=date y={inputs.metric.value}/>

<!-- Multi-line chart -->
<LineChart data={q} x=date y={["col1","col2","col3"]}/>

<!-- Conditional chart with if/else -->
{#if inputs.view.value === 'pct'}
<AreaChart data={q} x=year y=share_pct/>
{:else}
<AreaChart data={q} x=year y=absolute_twh/>
{/if}

<!-- BigValue with aggregation -->
<BigValue data={q} value=trips fmt=num0 agg=sum/>
```

## Source SQL vs Page SQL

| | Source SQL (`sources/name/query.sql`) | Page SQL (` ```sql name ``` `) |
|---|---|---|
| Runs at | `npm run sources` (build time) | Browser (DuckDB-WASM, client-side) |
| Input to | Evidence Parquet cache | In-memory query over cached Parquet |
| Can reference | Raw files via `read_parquet()`, `read_csv()` | Source results via `source_name.query_name` or `${other_query}` |
| Can use inputs | No | Yes — `${inputs.x.value}` |
| Row limit | Unlimited (runs in Node) | Keep small — all rows sent to browser |

**Source SQL must aggregate.** Never load raw 1M+ row tables into a source
query — Evidence ships the entire result to the browser as Parquet. Always
`GROUP BY` or `LIMIT` in source queries. Use `USING SAMPLE N ROWS` only for
scatter plots where sampling is intentional.

## DuckDB Source Connection

```yaml
# sources/my_source/connection.yaml
name: my_source
type: duckdb
# No filename = in-memory DuckDB. Reads files via read_parquet()/read_csv().
```

Source queries reference files relative to the Evidence working directory:
```sql
-- sources/my_source/my_query.sql
SELECT * FROM read_parquet('sources/my_source/raw/data.parquet')
WHERE ...
GROUP BY ...
```

Cross-source references in source SQL **do not work** — each source runs
in its own DuckDB instance. Reference other sources only in page SQL.

## Development

- `npm run dev` — hot reload dev server on :3000
- `npm run sources` — re-run all source queries, rebuild Parquet cache
- `npm run build` — static site build
- Page edits hot-reload instantly; source SQL changes require `npm run sources`

## Common Pitfalls — Do Not Repeat

1. **Missing `.value`** — always `inputs.x.value` for Dropdown/ButtonGroup in SQL and props
2. **Multi-select IN clause** — `IN ${inputs.x.value}`, never `IN '${inputs.x.value}'`
3. **Cross-source in source SQL** — source queries cannot reference other sources; join in page SQL or combine in a single source query
4. **Large source result sets** — aggregate in SQL; never ship raw rows to browser
5. **`read_parquet()` path in source SQL** — use path relative to Evidence working dir (`sources/name/raw/file.parquet`), not container-absolute paths
6. **DuckDB view with absolute paths** — views referencing `/data/raw/...` break when opened by a different container/process; use relative paths or in-memory DuckDB with direct `read_parquet()` in each source query
7. **`USING SAMPLE` after `WHERE`** — wrong DuckDB syntax; wrap in subquery: `FROM (SELECT * FROM t WHERE ...) USING SAMPLE N ROWS`
8. **Component casing** — Evidence components use PascalCase (`<BarChart>`, not `<barchart>`)
9. **Sidebar grouping** — use subdirectories under `pages/`; `index.md` in a subdir = group landing page; `sidebar_position` and `title` frontmatter control order and label
