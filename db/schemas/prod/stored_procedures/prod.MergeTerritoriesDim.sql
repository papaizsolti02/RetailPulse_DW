CREATE PROCEDURE [prod].[MergeTerritoriesDim]
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        MERGE INTO prod.TerritoriesDim AS target
        USING (
            SELECT
                Country,
                State,
                BUSINESSKEYHASH,
                HASHDATA
            FROM
                stage.Territories
        ) AS source
        ON target.BUSINESSKEYHASH = source.BUSINESSKEYHASH

        WHEN NOT MATCHED BY TARGET THEN
            INSERT (
                Country,
                State,
                CreatedAt,
                BUSINESSKEYHASH,
                HASHDATA
            )
            VALUES (
                source.Country,
                source.State,
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
