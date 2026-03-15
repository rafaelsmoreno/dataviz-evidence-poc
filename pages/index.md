---
title: NYC Taxi Dashboard
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

<Grid cols=4>

<BigValue
  data={kpis}
  value=total_trips
  title="Total Trips"
  fmt=num0
/>

<BigValue
  data={kpis}
  value=total_revenue
  title="Total Revenue"
  fmt=usd0
/>

<BigValue
  data={kpis}
  value=avg_fare
  title="Avg Fare"
  fmt=usd2
/>

<BigValue
  data={kpis}
  value=avg_tip_pct
  title="Avg Tip %"
  fmt=pct1
/>

</Grid>

<Grid cols=3>

<BigValue
  data={kpis}
  value=avg_distance_miles
  title="Avg Distance (mi)"
  fmt=num2
/>

<BigValue
  data={kpis}
  value=avg_duration_min
  title="Avg Duration (min)"
  fmt=num1
/>

<BigValue
  data={kpis}
  value=total_tips
  title="Total Tips"
  fmt=usd0
/>

</Grid>

---

## Daily Trip Volume & Revenue

<LineChart
  data={daily}
  x=date
  y=trips
  title="Daily Trips"
  yAxisTitle="Trips"
/>

<LineChart
  data={daily}
  x=date
  y=revenue
  title="Daily Revenue"
  yAxisTitle="Revenue (USD)"
  fmt=usd0
/>

---

## Payment Methods

<Grid cols=2>

<BarChart
  data={payment}
  x=payment_type_name
  y=trips
  title="Trips by Payment Type"
  yAxisTitle="Trips"
/>

<BarChart
  data={payment}
  x=payment_type_name
  y=avg_fare
  title="Avg Fare by Payment Type"
  yAxisTitle="Avg Fare (USD)"
/>

</Grid>

<DataTable data={payment} title="Payment Type Breakdown" />

---

> **Data source:** NYC TLC Yellow Taxi Trip Records, January 2024
> [Explore Time Patterns →](/time-patterns) | [Trip Analysis →](/trip-analysis)
