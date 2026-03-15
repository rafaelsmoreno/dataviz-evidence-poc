---
title: World Energy Mix
sidebar_position: 2
---

```sql global
select * from world_energy.global_trends
```
```sql country_mix
select * from world_energy.country_mix
```
```sql renewables
select * from world_energy.top_renewable_countries
```
```sql timeseries
select * from world_energy.country_time_series
```

# World Energy Mix

> Source: Our World in Data — Energy dataset

---

## Global Electricity Generation Mix

<ButtonGroup name=view_mode title="View">
    <ButtonGroupItem valueLabel="Shares (%)"     value="shares"  default/>
    <ButtonGroupItem valueLabel="Absolute (TWh)" value="absolute"/>
</ButtonGroup>

<DateRange name=year_range title="Year range" start=1990 end=2024/>

```sql global_filtered
select * from ${global}
where year >= YEAR(CAST('${inputs.year_range.start}' AS DATE))
  and year <= YEAR(CAST('${inputs.year_range.end}' AS DATE))
```

{#if inputs.view_mode === 'shares'}
<AreaChart
  data={global_filtered}
  x=year
  y={["renewables_pct","nuclear_pct","fossil_pct"]}
  title="Global Electricity Mix — Share (%)"
  yAxisTitle="Share of generation (%)"
/>
{:else}
<AreaChart
  data={global_filtered}
  x=year
  y={["solar_twh","wind_twh","hydro_twh","nuclear_twh","coal_twh"]}
  title="Global Electricity Generation by Source (TWh)"
  yAxisTitle="TWh"
/>
{/if}

---

## Renewables Rise — Solar & Wind

<LineChart
  data={global_filtered}
  x=year
  y={["solar_pct","wind_pct","hydro_pct"]}
  title="Renewable Sources — Global Share (%)"
  yAxisTitle="%"
  markers=true
/>

---

## Country Comparison — Renewables Transition

<Dropdown
  data={timeseries}
  name=countries
  value=country
  title="Countries"
  multiple=true
  defaultValue={["Brazil","Germany","United States","China","France"]}
/>

<ButtonGroup name=country_metric title="Metric">
    <ButtonGroupItem valueLabel="Renewables %"     value="renewables_pct"    default/>
    <ButtonGroupItem valueLabel="Fossil %"         value="fossil_pct"/>
    <ButtonGroupItem valueLabel="Solar %"          value="solar_pct"/>
    <ButtonGroupItem valueLabel="Wind %"           value="wind_pct"/>
    <ButtonGroupItem valueLabel="Carbon Intensity" value="carbon_intensity"/>
</ButtonGroup>

```sql country_filtered
select * from ${timeseries}
where country in ${inputs.countries.value}
  and year >= YEAR(CAST('${inputs.year_range.start}' AS DATE))
  and year <= YEAR(CAST('${inputs.year_range.end}' AS DATE))
```

<LineChart
  data={country_filtered}
  x=year
  y={inputs.country_metric}
  series=country
  title="{inputs.country_metric} by Country"
  yAxisTitle={inputs.country_metric}
  markers=false
/>

---

## Top Countries by Renewable Share

<Slider name=min_twh title="Min electricity generation (TWh)" min=10 max=500 defaultValue=10 step=10/>

```sql renewables_filtered
select * from ${renewables}
where electricity_twh >= ${inputs.min_twh}
order by renewables_pct desc
```

<BarChart
  data={renewables_filtered}
  x=country
  y=renewables_pct
  title="Renewable Share of Electricity (%) — Latest Year"
  yAxisTitle="%"
  swapXY=true
  labels=true
/>

---

## Current Mix by Country

<Dropdown
  data={country_mix}
  name=selected_country
  value=country
  title="Country"
  defaultValue="Brazil"
/>

```sql selected_mix
select * from ${country_mix}
where country = '${inputs.selected_country.value}'
```

<Grid cols=2>
<BigValue data={selected_mix} value=total_renewables_pct  title="Renewables %"     fmt=num1/>
<BigValue data={selected_mix} value=total_fossil_pct      title="Fossil Fuels %"   fmt=num1/>
<BigValue data={selected_mix} value=nuclear_pct           title="Nuclear %"        fmt=num1/>
<BigValue data={selected_mix} value=electricity_twh       title="Generation (TWh)" fmt=num0/>
</Grid>
