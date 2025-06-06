CREATE VIEW [utils].[GetTerritoryCurrencies] AS
SELECT DISTINCT
    td.Country [Country],
    ci.Currency [Currency]
FROM
    prod.TerritoriesDim td
INNER JOIN config.CountryInfo ci
	ON td.Country = ci.CountryName;
GO
