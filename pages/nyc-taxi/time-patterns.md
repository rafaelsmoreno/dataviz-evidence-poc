---
title: Time Patterns
sidebar_position: 2
---

```sql hourly
select * from nyc_taxi.hourly_patterns
```
```sql daily
select * from nyc_taxi.daily_trips
```

# Time Patterns

<Grid cols=2>
<Dropdown name=vendor_filter title="Vendor" defaultValue="All">
    <DropdownOption value="All"                              valueLabel="All Vendors"/>
    <DropdownOption value="Creative Mobile Technologies"     valueLabel="Creative Mobile"/>
    <DropdownOption value="VeriFone Inc."                    valueLabel="VeriFone"/>
</Dropdown>

<ButtonGroup name=heatmap_metric title="Heatmap metric">
    <ButtonGroupItem valueLabel="Trips"        value="trips"           default/>
    <ButtonGroupItem valueLabel="Avg Fare"     value="avg_fare"/>
    <ButtonGroupItem valueLabel="Avg Duration" value="avg_duration_min"/>
</ButtonGroup>
</Grid>

---

## Trip Volume Heatmap — Day × Hour

<Heatmap
  data={hourly}
  x=hour_of_day
  y=day_name
  value={inputs.heatmap_metric.value}
  title="Heatmap: {inputs.heatmap_metric.value} by Day & Hour"
  xAxisTitle="Hour of Day (0–23)"
  yAxisTitle="Day of Week"
/>

---

## Avg Fare by Hour of Day

```sql avg_by_hour
select
    hour_of_day,
    sum(trips)                        as trips,
    round(avg(avg_fare), 2)          as avg_fare,
    round(avg(avg_duration_min), 1)  as avg_duration_min
from ${hourly}
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
  markers=true
/>

---

## Peak Hours — Top 5 Busiest

```sql peak_hours
select
    hour_of_day,
    sum(trips) as trips,
    round(avg(avg_fare),2) as avg_fare
from ${hourly}
group by hour_of_day
order by trips desc
limit 5
```

<DataTable data={peak_hours} title="Top 5 Busiest Hours"/>

---

## Daily Duration & Distance Trend

<DateRange name=trend_dates start=2024-01-01 end=2024-01-31 title="Date range"/>

```sql daily_filtered
select * from nyc_taxi.daily_trips
where date >= '${inputs.trend_dates.start}'
  and date <= '${inputs.trend_dates.end}'
```

<LineChart
  data={daily_filtered}
  x=date
  y={["avg_duration_min","avg_distance"]}
  title="Avg Trip Duration (min) & Distance (mi) by Day"
  yAxisTitle="Value"
  markers=true
/>
