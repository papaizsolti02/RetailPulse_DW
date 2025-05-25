CREATE OR ALTER PROCEDURE config.HashTableEntries
    @DataSourceID INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        DECLARE @TableAndSchema NVARCHAR(MAX);
        DECLARE @sqlHashData NVARCHAR(MAX);
        DECLARE @HashString NVARCHAR(MAX);

        -- Get the target processing table from the Datasets config
        SELECT @TableAndSchema = d.ProcessingTable
        FROM config.Datasets d
        WHERE d.Id = @DataSourceID;

        IF @TableAndSchema IS NULL
        BEGIN
            RAISERROR('No processing table found for DataSourceID %d.', 16, 1, @DataSourceID);
            RETURN;
        END;

        -- Construct the hash string from the HashColumns config
        WITH HC AS (
            SELECT TOP 100 PERCENT HashString
            FROM config.HashColumns
            WHERE DatasetId = @DataSourceID
            ORDER BY HashOrder, Id
        )
        SELECT @HashString = STRING_AGG(HashString, ', ''|'' , ')
        FROM HC;

        IF @HashString IS NULL
        BEGIN
            RAISERROR('No hash columns found for DataSourceID %d.', 16, 1, @DataSourceID);
            RETURN;
        END

        -- Prepare dynamic SQL
        SET @sqlHashData = '
            UPDATE ' + QUOTENAME(@TableAndSchema) + '
            SET HASHDATA = UPPER(CONCAT(' + @HashString + '));

            UPDATE ' + QUOTENAME(@TableAndSchema) + '
            SET ROWHASH = CONVERT(VARCHAR(128), HASHBYTES(''SHA2_512'', HASHDATA), 2);
        ';

        -- Execute the dynamic SQL
        EXEC sp_executesql @sqlHashData;

        PRINT 'Row hash generation completed successfully for DataSourceID ' + CAST(@DataSourceID AS NVARCHAR);

    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        RAISERROR('Error in config.GenerateRowHashes: %s', @ErrorSeverity, @ErrorState, @ErrorMessage);
    END CATCH
END;
GO
