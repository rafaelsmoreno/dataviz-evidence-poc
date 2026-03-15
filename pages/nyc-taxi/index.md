---
title: NYC Yellow Taxi
sidebar_position: 1
---

```sql kpis
select * from nyc_taxi.overview_kpis
```
```sql daily
select * from nyc_taxi.daily_trips
```
```sql payment
select * from nyc_taxi.payment_breakdown
```

# NYC Yellow Taxi — January 2024

<DateRange
  name=date_filter
  start=2024-01-01
  end=2024-01-31
  title="Filter by date range"
/>

<ButtonGroup name=daily_metric title="Daily chart metric">
    <ButtonGroupItem valueLabel="Trips"       value="trips"       default/>
    <ButtonGroupItem valueLabel="Revenue"     value="revenue"/>
    <ButtonGroupItem valueLabel="Avg Fare"    value="avg_fare"/>
    <ButtonGroupItem valueLabel="Avg Tip %"   value="avg_tip_pct"/>
</ButtonGroup>

```sql daily_filtered
select * from nyc_taxi.daily_trips
where date >= '${inputs.date_filter.start}'
  and date <= '${inputs.date_filter.end}'
order by date
```

```sql kpis_filtered
select
    sum(trips)                      as total_trips,
    round(sum(revenue), 2)         as total_revenue,
    round(avg(avg_fare), 2)        as avg_fare,
    round(avg(avg_tip_pct), 1)     as avg_tip_pct,
    round(avg(avg_distance), 2)    as avg_distance_miles,
    round(avg(avg_duration_min),1) as avg_duration_min
from nyc_taxi.daily_trips
where date >= '${inputs.date_filter.start}'
  and date <= '${inputs.date_filter.end}'
```

---

<Grid cols=4>
<BigValue data={kpis_filtered} value=total_trips       title="Trips"          fmt=num0/>
<BigValue data={kpis_filtered} value=total_revenue     title="Revenue"        fmt=usd0/>
<BigValue data={kpis_filtered} value=avg_fare          title="Avg Fare"       fmt=usd2/>
<BigValue data={kpis_filtered} value=avg_tip_pct       title="Avg Tip %"      fmt=pct1/>
</Grid>

<Grid cols=2>
<BigValue data={kpis_filtered} value=avg_distance_miles title="Avg Distance (mi)" fmt=num2/>
<BigValue data={kpis_filtered} value=avg_duration_min   title="Avg Duration (min)" fmt=num1/>
</Grid>

---

## Daily Trend

<LineChart
  data={daily_filtered}
  x=date
  y={inputs.daily_metric}
  title="Daily {inputs.daily_metric} — {inputs.date_filter.start} to {inputs.date_filter.end}"
  yAxisTitle={inputs.daily_metric}
  markers=true
/>

---

## Payment Methods

<Dropdown
  data={payment}
  name=payment_filter
  value=payment_type_name
  title="Filter payment type"
  multiple=true
  selectAllByDefault=true
/>

```sql payment_filtered
select * from nyc_taxi.payment_breakdown
where payment_type_name in ${inputs.payment_filter.value}
```

<Grid cols=2>
<BarChart
  data={payment_filtered}
  x=payment_type_name
  y=trips
  title="Trips by Payment Type"
  labels=true
/>
<BarChart
  data={payment_filtered}
  x=payment_type_name
  y=avg_fare
  title="Avg Fare by Payment Type"
  labels=true
/>
</Grid>

<DataTable
  data={payment_filtered}
  title="Payment Breakdown"
  search=true
/>
