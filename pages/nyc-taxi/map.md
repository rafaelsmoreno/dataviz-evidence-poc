---
title: Zone Map
sidebar_position: 4
---

```sql zones
select * from nyc_taxi.zone_map
```

# Zone Map

> January 2024 — 2.7M trips plotted across 263 taxi zones

---

<Grid cols=3>
<ButtonGroup name=map_metric title="Color by">
    <ButtonGroupItem valueLabel="Pickups"      value="pickups"       default/>
    <ButtonGroupItem valueLabel="Dropoffs"     value="dropoffs"/>
    <ButtonGroupItem valueLabel="Avg Fare"     value="avg_fare"/>
    <ButtonGroupItem valueLabel="Revenue"      value="total_revenue"/>
</ButtonGroup>

<Dropdown name=borough_filter title="Borough" defaultValue="All">
    <DropdownOption value="All"           valueLabel="All Boroughs"/>
    <DropdownOption value="Manhattan"     valueLabel="Manhattan"/>
    <DropdownOption value="Queens"        valueLabel="Queens"/>
    <DropdownOption value="Brooklyn"      valueLabel="Brooklyn"/>
    <DropdownOption value="Bronx"         valueLabel="Bronx"/>
    <DropdownOption value="Staten Island" valueLabel="Staten Island"/>
    <DropdownOption value="EWR"           valueLabel="Newark Airport"/>
</Dropdown>

<Slider name=min_pickups title="Min pickups" min=0 max=5000 defaultValue=0 step=100/>
</Grid>

```sql zones_filtered
select * from ${zones}
where (borough = '${inputs.borough_filter.value}' or '${inputs.borough_filter.value}' = 'All')
  and pickups >= ${inputs.min_pickups}
```

<PointMap
    data={zones_filtered}
    lat=lat
    long=lon
    value={inputs.map_metric}
    pointName=zone
    title="NYC Taxi Zones — {inputs.map_metric} (Jan 2024)"
    startingLat=40.7128
    startingLong=-74.006
    startingZoom=11
    height=600
    tooltipType=hover
    tooltip={[
        {id: 'zone',          showColumnName: false, valueClass: 'text-lg font-semibold'},
        {id: 'borough',       showColumnName: false, valueClass: 'text-sm text-gray-500'},
        {id: 'pickups',       fmt: 'num0'},
        {id: 'dropoffs',      fmt: 'num0'},
        {id: 'avg_fare',      fmt: 'usd2'},
        {id: 'total_revenue', fmt: 'usd0'}
    ]}
    colorPalette={['#ffffcc','#fed976','#fd8d3c','#e31a1c','#800026']}
/>

---

## Zone Detail

```sql top_zones
select * from ${zones_filtered}
where pickups > 0
order by pickups desc
limit 20
```

<DataTable
    data={top_zones}
    title="Top Zones by {inputs.map_metric}"
    search=true
/>

---

```sql zone_totals
select
    sum(pickups)       as total_pickups,
    sum(dropoffs)      as total_dropoffs,
    avg(avg_fare)      as avg_fare,
    sum(total_revenue) as total_revenue
from ${zones_filtered}
```

<Grid cols=4>
<BigValue data={zone_totals} value=total_pickups  title="Total Pickups"  fmt=num0/>
<BigValue data={zone_totals} value=total_dropoffs title="Total Dropoffs" fmt=num0/>
<BigValue data={zone_totals} value=avg_fare       title="Avg Fare"       fmt=usd2/>
<BigValue data={zone_totals} value=total_revenue  title="Total Revenue"  fmt=usd0/>
</Grid>
