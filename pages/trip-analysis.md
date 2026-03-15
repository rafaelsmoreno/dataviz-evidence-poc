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

## Distance Distribution

<BarChart
  data={dist}
  x=distance_bucket_miles
  y=trips
  title="Trip Count by Distance Bucket (0.5 mi)"
  xAxisTitle="Distance (miles)"
  yAxisTitle="Trips"
/>

<BarChart
  data={dist}
  x=distance_bucket_miles
  y=avg_fare
  title="Average Fare by Distance Bucket"
  xAxisTitle="Distance (miles)"
  yAxisTitle="Avg Fare (USD)"
/>

---

## Fare vs Distance (5,000-row sample)

<ScatterPlot
  data={scatter}
  x=trip_distance
  y=fare_amount
  series=payment_type_name
  title="Fare vs Trip Distance"
  xAxisTitle="Distance (miles)"
  yAxisTitle="Fare (USD)"
  opacity=0.4
/>

---

## Top 30 Pickup Zones

<BarChart
  data={zones}
  x=pickup_location_id
  y=trips
  title="Top Pickup Zones by Trip Volume"
  xAxisTitle="Location ID"
  yAxisTitle="Trips"
/>

<DataTable
  data={zones}
  title="Top 30 Pickup Zones"
/>

---

## Vendor Comparison

<Grid cols=2>

<BarChart
  data={vendors}
  x=vendor_name
  y=trips
  title="Trips by Vendor"
/>

<BarChart
  data={vendors}
  x=vendor_name
  y=avg_fare
  title="Avg Fare by Vendor"
/>

</Grid>

<DataTable data={vendors} title="Vendor Performance" />

---

> [← Overview](/index) | [← Time Patterns](/time-patterns)
