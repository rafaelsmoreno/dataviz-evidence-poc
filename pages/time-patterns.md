---
title: Time Patterns
---

```sql hourly
select * from nyc_taxi.hourly_patterns
```

```sql daily
select * from nyc_taxi.daily_trips
```

# Time Patterns

## Hourly Heatmap — Trips by Day & Hour

<Heatmap
  data={hourly}
  x=hour_of_day
  y=day_name
  value=trips
  title="Trip Volume by Day of Week & Hour"
  xAxisTitle="Hour of Day"
  yAxisTitle="Day of Week"
/>

---

## Average Fare by Hour of Day

```sql avg_by_hour
select
    hour_of_day,
    count(*)                       as trips,
    round(avg(total_amount), 2)   as avg_fare,
    round(avg(trip_duration_min),1) as avg_duration_min
from nyc_taxi.hourly_patterns
group by hour_of_day
order by hour_of_day
```

<LineChart
  data={avg_by_hour}
  x=hour_of_day
  y=avg_fare
  title="Average Fare by Hour of Day"
  xAxisTitle="Hour"
  yAxisTitle="Avg Fare (USD)"
/>

---

## Daily Trend — Avg Duration & Distance

<LineChart
  data={daily}
  x=date
  y={["avg_duration_min", "avg_distance"]}
  title="Avg Trip Duration & Distance by Day"
  yAxisTitle="Value"
/>

---

> [← Overview](/index) | [Trip Analysis →](/trip-analysis)
