---
name: dataviz-review
description: Data visualization review — chart type selection, color accessibility, axis labeling, and dataviz best practices. Use when chart or visualization code is edited.
---

# Data Visualization Review

## Chart Type Selection

| Data Relationship | Recommended Chart | Avoid |
|-------------------|-------------------|-------|
| Comparison (categorical) | Bar chart (vertical or horizontal) | Pie chart for >5 categories |
| Comparison (multi-series) | Grouped bar, small multiples | 3D bars |
| Trend over time | Line chart, area chart | Bar chart for continuous time |
| Part-to-whole | Stacked bar, treemap, waffle | Pie chart for >5 slices |
| Distribution | Histogram, box plot, violin | Bar chart for continuous data |
| Correlation | Scatter plot, bubble chart | Line chart (implies sequence) |
| Ranking | Horizontal bar chart (sorted) | Unsorted vertical bars |
| Geographic | Choropleth, point map | 3D globe for data comparison |

## Color Best Practices

- **Colorblind-safe palettes:** avoid red-green only; use blue-orange, viridis, or cividis
- **Sequential palette:** for ordered data (light → dark, single hue)
- **Diverging palette:** for data with meaningful midpoint (two hues meeting at neutral)
- **Categorical palette:** max 7-8 distinct colors; beyond that, use small multiples
- **Never rely on color alone:** add patterns, labels, shapes, or line styles
- **Consistent mapping:** same color = same meaning across all charts in a dashboard

## Axis and Labeling

- **Always label axes** with units (e.g., "Revenue (USD)", "Time (months)")
- **Y-axis at zero** for bar charts (truncated y-axis exaggerates differences)
- **Y-axis can start above zero** for line charts showing change over time
- **Meaningful tick intervals:** round numbers, not auto-generated noise
- **Direct labeling:** label data series on the chart when feasible (<4 series); avoid legends when possible
- **Number formatting:** use locale-appropriate thousands separator, abbreviate large numbers (1.2M, not 1,200,000)

## Data-Ink Ratio (Tufte)

- Remove chartjunk: unnecessary gridlines, 3D effects, gradients, decorative elements
- Maximize data-ink ratio: every pixel should convey data
- Small multiples over complex overlaid charts (easier to compare)
- No dual y-axes (confusing, easily manipulated) — use two charts instead

## Annotation and Context

- **Title states the insight:** "Sales doubled in Q4" not "Sales by Quarter"
- **Annotate outliers** and key events on the chart
- **Source attribution:** always cite data source
- **Date range:** state the time period covered
- **Baseline/target lines:** add reference lines for goals or averages

## Interaction Design (Web)

- Tooltips for detail-on-demand (show exact values on hover)
- Filter/highlight over zoom for exploration
- Responsive: charts must work on mobile widths (consider aspect ratio)
- Loading states for queries that take time

## Evidence Framework Specifics

- Use appropriate component: `<BarChart>`, `<LineChart>`, `<AreaChart>`, `<ScatterPlot>`, `<DataTable>`
- SQL query drives the data — review query for correct aggregation and grain
- Props: `data={query_name}`, `x="column"`, `y="column"`, `series="group_column"`
- Formatting: `fmt="usd"`, `fmt="pct"`, `fmt="num0"` for number display

## Review Procedure

When invoked:
1. Identify all charts/visualizations in scope
2. Check chart type appropriateness for the data
3. Verify color accessibility and labeling
4. Check for data-ink ratio violations
5. Verify titles state insights, not descriptions
6. Report issues by severity: Blocking (misleading), Warning (suboptimal), Info (enhancement)
