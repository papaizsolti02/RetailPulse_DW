CREATE PROCEDURE [stage].[ProcessTerritories]
    @IsSuccess BIT OUTPUT,
    @ErrorMessage NVARCHAR(MAX) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Insert distinct values from #ParsedUsers
        INSERT INTO stage.Territories (Country, State)
        SELECT DISTINCT
            pu.Country,
            pu.State
        FROM #ParsedUsers pu
        WHERE NOT EXISTS (
            SELECT 1
            FROM stage.Territories t
            WHERE t.Country = pu.Country AND t.State = pu.State
        );

		EXEC config.HashTableEntries @DataSourceId = 2;

		EXEC [prod].[MergeTerritoriesDim];

        SET @IsSuccess = 1;
        SET @ErrorMessage = NULL;
    END TRY
    BEGIN CATCH
        SET @IsSuccess = 0;
        SET @ErrorMessage = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;