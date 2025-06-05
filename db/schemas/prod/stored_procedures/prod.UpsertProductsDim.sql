CREATE PROCEDURE [prod].[UpsertProductsDim]
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE p
        SET
            ExpirationDate = GETDATE(),
            IsCurrent = 0
        FROM prod.ProductsDim p
        INNER JOIN stage.Products s
            ON p.BUSINESSKEYHASH = s.BUSINESSKEYHASH AND p.Price <> s.Price
        WHERE p.IsCurrent = 1;

        INSERT INTO prod.ProductsDim (
            Name,
            Description,
            Color,
            Brand,
            Category,
            Gender,
            Price,
            BUSINESSKEYHASH,
            HASHDATA,
			EffectiveDate
        )
        SELECT
            s.Name,
            s.Description,
            s.Color,
            s.Brand,
            s.Category,
            s.Gender,
            s.Price,
            s.BUSINESSKEYHASH,
            s.HASHDATA,
			InsertedAt
        FROM stage.Products s
		WHERE NOT EXISTS (
            SELECT 1
            FROM prod.ProductsDim p
            WHERE
                p.BUSINESSKEYHASH = s.BUSINESSKEYHASH
                AND p.IsCurrent = 1
        );

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        DECLARE @ErrorMessage NVARCHAR(MAX) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;
GO
