---
title: Trip Analysis
---

```sql dist
select * from nyc_taxi.distance_distribution
```
```sql scatter
select * from nyc_taxi.fare_vs_distance
```
```sql zones
select * from nyc_taxi.top_pickup_zones
```
```sql vendors
select * from nyc_taxi.vendor_comparison
```

# Trip Analysis

---

## Distance Distribution

<Slider
  name=max_distance
  title="Max trip distance (miles)"
  min=1
  max=20
  defaultValue=20
  step=1
/>

```sql dist_filtered
select * from ${dist}
where distance_bucket_miles <= ${inputs.max_distance}
```

<Grid cols=2>
<BarChart
  data={dist_filtered}
  x=distance_bucket_miles
  y=trips
  title="Trip Count by Distance (0.5 mi buckets)"
  xAxisTitle="Distance (miles)"
  yAxisTitle="Trips"
/>
<BarChart
  data={dist_filtered}
  x=distance_bucket_miles
  y=avg_fare
  title="Avg Fare by Distance"
  xAxisTitle="Distance (miles)"
  yAxisTitle="Avg Fare (USD)"
/>
</Grid>

---

## Fare vs Distance

<Grid cols=2>
<Dropdown name=payment_scatter title="Payment type" defaultValue="All">
    <DropdownOption value="All"          valueLabel="All"/>
    <DropdownOption value="Credit Card"  valueLabel="Credit Card"/>
    <DropdownOption value="Cash"         valueLabel="Cash"/>
    <DropdownOption value="Other"        valueLabel="Other"/>
</Dropdown>

<Slider
  name=max_fare
  title="Max fare (USD)"
  min=5
  max=150
  defaultValue=100
  step=5
/>
</Grid>

```sql scatter_filtered
select * from ${scatter}
where (payment_type_name = '${inputs.payment_scatter}' or '${inputs.payment_scatter}' = 'All')
  and fare_amount <= ${inputs.max_fare}
```

<ScatterPlot
  data={scatter_filtered}
  x=trip_distance
  y=fare_amount
  series=payment_type_name
  title="Fare vs Distance (5,000-row sample)"
  xAxisTitle="Distance (miles)"
  yAxisTitle="Fare (USD)"
  opacity=0.5
/>

---

## Top Pickup Zones

<Slider
  name=top_n
  title="Show top N zones"
  min=5
  max=30
  defaultValue=15
  step=5
/>

```sql zones_filtered
select * from ${zones}
limit ${inputs.top_n}
```

<BarChart
  data={zones_filtered}
  x=pickup_location_id
  y=trips
  title="Top {inputs.top_n} Pickup Zones"
  xAxisTitle="Zone ID"
  yAxisTitle="Trips"
  labels=true
/>

<DataTable
  data={zones_filtered}
  title="Top Pickup Zones"
  search=true
/>

---

## Vendor Comparison

<DataTable
  data={vendors}
  title="Vendor Performance"
/>

<Grid cols=2>
<BarChart
  data={vendors}
  x=vendor_name
  y=trips
  title="Trips by Vendor"
  labels=true
/>
<BarChart
  data={vendors}
  x=vendor_name
  y=avg_tip_pct
  title="Avg Tip % by Vendor"
  labels=true
/>
</Grid>

---

> [← Overview](/) | [← Time Patterns](/time-patterns)
