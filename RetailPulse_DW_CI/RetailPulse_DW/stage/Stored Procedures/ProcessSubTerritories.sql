CREATE PROCEDURE [stage].[ProcessSubTerritories]
    @IsSuccess BIT OUTPUT,
    @ErrorMessage NVARCHAR(MAX) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Insert distinct subterritories
        INSERT INTO stage.SubTerritories (
            TerritoryId, City, StreetName, Latitude, Longitude
        )
        SELECT DISTINCT
            t.TerritoryId,
            pu.City,
            pu.StreetName,
            pu.Latitude,
            pu.Longitude
        FROM #ParsedUsers pu
        INNER JOIN stage.Territories t
            ON pu.Country = t.Country AND pu.State = t.State
        WHERE NOT EXISTS (
            SELECT 1
            FROM stage.SubTerritories st
            WHERE st.TerritoryId = t.TerritoryId
              AND st.City = pu.City
              AND ISNULL(st.StreetName, '') = ISNULL(pu.StreetName, '')
              AND ISNULL(st.Latitude, 0) = ISNULL(pu.Latitude, 0)
              AND ISNULL(st.Longitude, 0) = ISNULL(pu.Longitude, 0)
        );

		EXEC config.HashTableEntries @DataSourceId = 3;

		EXEC [prod].[MergeSubTerritoriesDim];

        SET @IsSuccess = 1;
        SET @ErrorMessage = NULL;
    END TRY
    BEGIN CATCH
        SET @IsSuccess = 0;
        SET @ErrorMessage = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;