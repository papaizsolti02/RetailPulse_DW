CREATE   PROCEDURE config.HashTableEntries
    @DataSourceID INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        
        DECLARE @sqlHashData NVARCHAR(MAX);
        DECLARE @HashString NVARCHAR(MAX);

        -- Get the target processing table from the Datasets config
        DECLARE @TableAndSchema NVARCHAR(MAX) = (SELECT d.ProcessingTable FROM config.Datasets d WHERE d.Id = @DataSourceID)

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
            UPDATE ' + @TableAndSchema + '
            SET HASHDATA = UPPER(CONCAT(' + @HashString + '));

            UPDATE ' + @TableAndSchema + '
            SET BUSINESSKEYHASH = HASHBYTES(''SHA2_512'', HASHDATA);
        ';

        -- Execute the dynamic SQL
        EXEC sp_executesql @sqlHashData;

    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        RAISERROR('Error in config.HashTableEntries: %s', @ErrorSeverity, @ErrorState, @ErrorMessage);
    END CATCH
END;
