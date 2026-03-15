-- Global energy trends over time (world aggregate)
SELECT
    year,
    COALESCE(coal_share_elec, 0)              AS coal_pct,
    COALESCE(gas_share_elec, 0)               AS gas_pct,
    COALESCE(nuclear_share_elec, 0)           AS nuclear_pct,
    COALESCE(hydro_share_elec, 0)             AS hydro_pct,
    COALESCE(solar_share_elec, 0)             AS solar_pct,
    COALESCE(wind_share_elec, 0)              AS wind_pct,
    COALESCE(renewables_share_elec, 0)        AS renewables_pct,
    COALESCE(fossil_share_elec, 0)            AS fossil_pct,
    COALESCE(low_carbon_share_elec, 0)        AS low_carbon_pct,
    COALESCE(electricity_generation, 0)       AS electricity_twh,
    COALESCE(solar_electricity, 0)            AS solar_twh,
    COALESCE(wind_electricity, 0)             AS wind_twh,
    COALESCE(hydro_electricity, 0)            AS hydro_twh,
    COALESCE(nuclear_electricity, 0)          AS nuclear_twh,
    COALESCE(coal_electricity, 0)             AS coal_twh
FROM read_csv('sources/world_energy/owid-energy-data.csv', auto_detect=true, nullstr='')
WHERE country = 'World'
  AND year >= 1990
ORDER BY year
