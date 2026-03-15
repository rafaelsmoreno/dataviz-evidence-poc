---
name: evidence
description: Evidence BI framework reference — SQL-driven pages, chart components, data sources, and project structure. Use when working in an Evidence project.
---

# Evidence Framework Reference

## Project Structure

```
pages/                   # Markdown pages with embedded SQL
  index.md               # Homepage
  my-report.md           # Report pages
sources/                 # Data source connections
  my_source/
    connection.yaml      # Connection config
components/              # Custom Svelte components
evidence.plugins.yaml    # Plugin and theme config
```

## Page Authoring

Pages are Markdown files with SQL code blocks:
````markdown
```sql orders
select * from orders
where order_date >= '2024-01-01'
```

Total orders: <Value data={orders} column="order_count"/>
````

SQL blocks: ` ```sql query_name ` — the name becomes a referenceable variable.

## Built-in Components

### Charts
- `<BarChart data={query} x="category" y="value"/>` — vertical bars
- `<LineChart data={query} x="date" y="value" series="group"/>` — time series
- `<AreaChart>` — filled line chart
- `<ScatterPlot data={query} x="x_col" y="y_col"/>` — correlation
- `<Histogram data={query} x="value" binCount={20}/>` — distribution
- `<BoxPlot>` — statistical distribution
- `<FunnelChart>` — conversion funnels

### Tables
- `<DataTable data={query}/>` — sortable, searchable, paginated
- `<DataTable data={query} search={true} rows={20}/>` — with options

### Values
- `<Value data={query} column="col"/>` — inline single value
- `<BigValue data={query} value="revenue" fmt="usd"/>` — KPI display
- `<Delta data={query} column="change" fmt="pct"/>` — change indicator

### Inputs (interactive filters)
- `<Dropdown data={query} name="selected" value="col"/>`
- `<TextInput name="search_term"/>`
- `<DateRange name="date_filter"/>`
- `<ButtonGroup data={query} name="category" value="col"/>`

### Layout
- `<Grid cols={3}>` — responsive grid
- `<Tabs>` / `<Tab label="Tab 1">` — tabbed content
- `<Alert status="info">` — callout boxes
- `<Details title="Click to expand">` — collapsible sections

## Component Props

Common props across charts:
- `data` — query result reference
- `x`, `y` — column names for axes
- `series` — column for grouping/coloring
- `title`, `subtitle` — chart titles
- `xAxisTitle`, `yAxisTitle` — axis labels
- `fmt` — number format (`usd`, `pct`, `num0`, `num2`)
- `chartAreaHeight` — pixel height

## Templating

```markdown
{#each query as row}
  - {row.name}: {row.value}
{/each}

{#if query[0].count > 100}
  High volume!
{/if}
```

## Data Sources

Configure in `sources/<name>/connection.yaml`:
- DuckDB (default, local)
- PostgreSQL, MySQL
- BigQuery, Snowflake, Databricks
- CSV files (place in `sources/`)

## Development

- `npm run dev` — hot reload dev server on :3000
- `npm run build` — static site build
- `npm run preview` — preview production build
- Source changes trigger query re-run automatically

## Deployment

- Evidence Cloud (managed hosting)
- Netlify / Vercel (static export)
- Any static hosting (output in `build/`)

## Common Pitfalls

- Query naming conflicts: two SQL blocks with the same name on one page
- Large datasets: paginate or aggregate in SQL, don't load 100K+ rows to frontend
- Missing source config: check `sources/` directory and `connection.yaml` format
- Component casing: Evidence components use PascalCase (`<BarChart>`, not `<barchart>`)
