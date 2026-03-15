---
title: Brazil Economy
sidebar_position: 3
---

```sql macro
select * from brazil_economy.macro_indicators
```

# Brazil Economy — World Bank Indicators

> Source: World Bank Open Data API | Updated at dashboard build time

---

## Key Indicators — Latest Year

```sql latest
select * from ${macro} order by year desc limit 1
```

<Grid cols=4>
<BigValue data={latest} value=gdp_billion_usd      title="GDP (USD bn)"        fmt=num1/>
<BigValue data={latest} value=gdp_per_capita_usd   title="GDP per Capita"      fmt=usd0/>
<BigValue data={latest} value=inflation_pct        title="Inflation %"         fmt=pct1/>
<BigValue data={latest} value=usd_brl_rate         title="USD/BRL Rate"        fmt=num4/>
</Grid>

<Grid cols=3>
<BigValue data={latest} value=unemployment_pct          title="Unemployment %"       fmt=pct1/>
<BigValue data={latest} value=exports_billion_usd       title="Exports (USD bn)"     fmt=num1/>
<BigValue data={latest} value=trade_balance_billion_usd title="Trade Balance (USD bn)" fmt=num1/>
</Grid>

---

## Historical Trends

<DateRange name=year_range title="Year range" start=2000 end=2025/>

<ButtonGroup name=gdp_view title="GDP view">
    <ButtonGroupItem valueLabel="Total GDP (USD bn)" value="gdp_billion_usd"    default/>
    <ButtonGroupItem valueLabel="GDP per Capita"     value="gdp_per_capita_usd"/>
</ButtonGroup>

```sql macro_filtered
select * from ${macro}
where year >= YEAR(CAST('${inputs.year_range.start}' AS DATE))
  and year <= YEAR(CAST('${inputs.year_range.end}' AS DATE))
```

<LineChart
  data={macro_filtered}
  x=year
  y={inputs.gdp_view}
  title="Brazil GDP — {inputs.gdp_view}"
  yAxisTitle="USD"
  markers=true
/>

---

## USD/BRL Exchange Rate

<LineChart
  data={macro_filtered}
  x=year
  y=usd_brl_rate
  title="USD/BRL Official Exchange Rate"
  yAxisTitle="BRL per 1 USD"
  markers=true
/>

---

## Inflation & Unemployment

<LineChart
  data={macro_filtered}
  x=year
  y={["inflation_pct","unemployment_pct"]}
  title="Inflation & Unemployment Rate (%)"
  yAxisTitle="%"
  markers=true
/>

---

## Trade — Exports vs Imports

<BarChart
  data={macro_filtered}
  x=year
  y={["exports_billion_usd","imports_billion_usd"]}
  title="Brazil Trade — Exports vs Imports (USD bn)"
  yAxisTitle="USD Billion"
  type=grouped
/>

<LineChart
  data={macro_filtered}
  x=year
  y=trade_balance_billion_usd
  title="Trade Balance (USD bn)"
  yAxisTitle="USD Billion"
  markers=true
/>

---

## Full Data Table

<DataTable
  data={macro_filtered}
  title="Brazil Economic Indicators"
  search=true
/>
