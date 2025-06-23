CREATE PROCEDURE [stage].[ProcessRawProducts]
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Step 1: Create the stage.Products table if it does not exist
        IF OBJECT_ID('[stage].[Products]', 'U') IS NULL
        BEGIN
            CREATE TABLE [stage].[Products] (
                ProductId INT IDENTITY (1, 1) PRIMARY KEY,
                Name NVARCHAR(255) NOT NULL,
                Description NVARCHAR(MAX) NULL,
                Color NVARCHAR(50) NULL,
                Brand NVARCHAR(100) NULL,
                Category NVARCHAR(100) NULL,
                Gender NVARCHAR(50) NULL,
                Price DECIMAL(10, 2) NOT NULL,
                InsertedAt DATETIME DEFAULT GETDATE(),
                BUSINESSKEYHASH VARBINARY(6000) NULL,
                HASHDATA VARCHAR(MAX) NULL
            );
        END
        ELSE
        BEGIN
            -- Step 2: Truncate existing stage table
            TRUNCATE TABLE [stage].[Products];
        END

        INSERT INTO [stage].[Products] (
			Name,
			Description,
			Color,
			Brand,
			Category,
			Gender,
			Price
		)
		SELECT
			r.[Name],
			r.[Description],
			r.Color,
			r.Brand,
			r.Category,
			r.Gender,
			r.Price
		FROM
			[raw].[Products] r
		WHERE NOT EXISTS (
			SELECT 1
			FROM
				[stage].[Products] s
			WHERE s.Name = r.Name
				AND s.Brand = r.Brand
				AND s.Category = r.Category
				AND s.Color = r.Color
				AND s.Gender = r.Gender
				AND s.Price = r.Price
		);

        -- Step 4: Call hashing stored procedure
        EXEC config.HashTableEntries @DataSourceId = 5;

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