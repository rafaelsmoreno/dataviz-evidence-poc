-- Per-country time series 1990–present for key countries
-- Used for multi-country comparison line charts
SELECT
    country,
    year,
    COALESCE(renewables_share_elec, 0)  AS renewables_pct,
    COALESCE(solar_share_elec, 0)       AS solar_pct,
    COALESCE(wind_share_elec, 0)        AS wind_pct,
    COALESCE(fossil_share_elec, 0)      AS fossil_pct,
    COALESCE(electricity_generation, 0) AS electricity_twh,
    COALESCE(carbon_intensity_elec, 0)  AS carbon_intensity
FROM read_csv('sources/world_energy/owid-energy-data.csv', auto_detect=true, nullstr='')
WHERE country IN (
    'Brazil','United States','Germany','China',
    'France','India','United Kingdom','Australia'
)
  AND year >= 1990
ORDER BY country, year
