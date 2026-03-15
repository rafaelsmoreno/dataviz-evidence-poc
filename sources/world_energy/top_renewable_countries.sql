-- Top 20 countries by renewable share of electricity (latest year, min 10 TWh)
SELECT
    country,
    year,
    ROUND(renewables_share_elec, 1)   AS renewables_pct,
    ROUND(solar_share_elec, 1)        AS solar_pct,
    ROUND(wind_share_elec, 1)         AS wind_pct,
    ROUND(hydro_share_elec, 1)        AS hydro_pct,
    ROUND(electricity_generation, 0)  AS electricity_twh
FROM read_csv('sources/world_energy/owid-energy-data.csv', auto_detect=true, nullstr='')
WHERE iso_code IS NOT NULL
  AND iso_code NOT LIKE 'OWID_%'
  AND length(iso_code) = 3
  AND year = (
      SELECT MAX(year)
      FROM read_csv('sources/world_energy/owid-energy-data.csv', auto_detect=true, nullstr='')
      WHERE iso_code IS NOT NULL AND iso_code NOT LIKE 'OWID_%'
        AND renewables_share_elec IS NOT NULL
  )
  AND electricity_generation >= 10
  AND renewables_share_elec IS NOT NULL
ORDER BY renewables_pct DESC
LIMIT 20
