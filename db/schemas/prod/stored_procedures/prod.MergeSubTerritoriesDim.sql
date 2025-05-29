CREATE PROCEDURE [prod].[MergeSubTerritoriesDim]
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        MERGE INTO prod.SubTerritoriesDim AS target
        USING (
            SELECT
                b.TerritoryId,
                a.City,
                a.StreetName,
                a.Latitude,
                a.Longitude,
                a.CreatedAt,
                a.BUSINESSKEYHASH,
                a.HASHDATA
            FROM
                stage.SubTerritories a
            INNER JOIN stage.Territories t
                ON a.TerritoryId = t.TerritoryId
            INNER JOIN prod.TerritoriesDim b
                ON t.BUSINESSKEYHASH = b.BUSINESSKEYHASH
        ) AS source
        ON target.BUSINESSKEYHASH = source.BUSINESSKEYHASH

        WHEN NOT MATCHED BY TARGET THEN
            INSERT (
                TerritoryId,
                City,
                StreetName,
                Latitude,
                Longitude,
                CreatedAt,
                BUSINESSKEYHASH,
                HASHDATA
            )
            VALUES (
                source.TerritoryId,
                source.City,
                source.StreetName,
                source.Latitude,
                source.Longitude,
                GETDATE(),
                source.BUSINESSKEYHASH,
                source.HASHDATA
            );

        -- No update on match, no delete
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;
GO
