-- Brazil macro indicators joined from World Bank CSV files
SELECT
    g.year::INT                                  AS year,
    ROUND(g.value / 1e9, 1)                     AS gdp_billion_usd,
    ROUND(gp.value, 0)                           AS gdp_per_capita_usd,
    ROUND(i.value, 2)                            AS inflation_pct,
    ROUND(u.value, 2)                            AS unemployment_pct,
    ROUND(f.value, 4)                            AS usd_brl_rate,
    ROUND(ex.value / 1e9, 1)                    AS exports_billion_usd,
    ROUND(im.value / 1e9, 1)                    AS imports_billion_usd,
    ROUND((ex.value - im.value) / 1e9, 1)       AS trade_balance_billion_usd
FROM read_csv('sources/brazil_economy/gdp_usd.csv', auto_detect=true)          g
LEFT JOIN read_csv('sources/brazil_economy/gdp_per_capita.csv', auto_detect=true)  gp ON g.year = gp.year
LEFT JOIN read_csv('sources/brazil_economy/inflation.csv', auto_detect=true)       i  ON g.year = i.year
LEFT JOIN read_csv('sources/brazil_economy/unemployment.csv', auto_detect=true)    u  ON g.year = u.year
LEFT JOIN read_csv('sources/brazil_economy/usd_brl.csv', auto_detect=true)         f  ON g.year = f.year
LEFT JOIN read_csv('sources/brazil_economy/exports.csv', auto_detect=true)         ex ON g.year = ex.year
LEFT JOIN read_csv('sources/brazil_economy/imports.csv', auto_detect=true)         im ON g.year = im.year
ORDER BY year
