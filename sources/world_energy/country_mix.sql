-- Energy mix by country for the latest available year
-- Returns share of each source in total electricity generation
SELECT
    country,
    year,
    COALESCE(coal_share_elec, 0)              AS coal_pct,
    COALESCE(gas_share_elec, 0)               AS gas_pct,
    COALESCE(oil_share_elec, 0)               AS oil_pct,
    COALESCE(nuclear_share_elec, 0)           AS nuclear_pct,
    COALESCE(hydro_share_elec, 0)             AS hydro_pct,
    COALESCE(solar_share_elec, 0)             AS solar_pct,
    COALESCE(wind_share_elec, 0)              AS wind_pct,
    COALESCE(other_renewables_share_elec, 0)  AS other_renewables_pct,
    COALESCE(renewables_share_elec, 0)        AS total_renewables_pct,
    COALESCE(fossil_share_elec, 0)            AS total_fossil_pct,
    COALESCE(low_carbon_share_elec, 0)        AS low_carbon_pct,
    COALESCE(electricity_generation, 0)       AS electricity_twh,
    COALESCE(population, 0)                   AS population
FROM read_csv('sources/world_energy/owid-energy-data.csv', auto_detect=true, nullstr='')
WHERE iso_code IS NOT NULL
  AND iso_code NOT LIKE 'OWID_%'
  AND length(iso_code) = 3
  AND year = (
      SELECT MAX(year)
      FROM read_csv('sources/world_energy/owid-energy-data.csv', auto_detect=true, nullstr='')
      WHERE iso_code IS NOT NULL AND iso_code NOT LIKE 'OWID_%'
        AND electricity_generation IS NOT NULL
  )
  AND electricity_generation > 0
ORDER BY electricity_twh DESC
