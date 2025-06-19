CREATE PROCEDURE [stage].[ProcessRawUsers]
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @TerritorySuccess BIT, @TerritoryError NVARCHAR(MAX);
    DECLARE @SubTerritorySuccess BIT, @SubTerritoryError NVARCHAR(MAX);

    BEGIN TRY
        BEGIN TRANSACTION;

		TRUNCATE TABLE [stage].[Users];

        IF OBJECT_ID('tempdb..#ParsedUsers') IS NOT NULL DROP TABLE #ParsedUsers;

        CREATE TABLE #ParsedUsers (
            Source NVARCHAR(255),
            Gender CHAR(1),
            FullName NVARCHAR(255),
            FirstName NVARCHAR(100),
            LastName NVARCHAR(100),
            Email NVARCHAR(320),
            Country NVARCHAR(100),
            State NVARCHAR(100),
            City NVARCHAR(100),
            StreetName NVARCHAR(255),
            Latitude DECIMAL(9,6) NULL,
            Longitude DECIMAL(9,6) NULL,
            InsertedAt DATETIME
        );

        INSERT INTO #ParsedUsers (
            Source, Gender, FullName, FirstName, LastName, Email,
            Country, State, City, StreetName, Latitude, Longitude, InsertedAt
        )
        SELECT
            u.Source,
            CASE LOWER(JSON_VALUE(u.UserJson, '$.gender'))
                WHEN 'male' THEN 'M'
                WHEN 'female' THEN 'F'
                ELSE NULL
            END,
            JSON_VALUE(u.UserJson, '$.name.first') + ' ' + JSON_VALUE(u.UserJson, '$.name.last'),
            JSON_VALUE(u.UserJson, '$.name.first'),
            JSON_VALUE(u.UserJson, '$.name.last'),
            JSON_VALUE(u.UserJson, '$.email'),
            JSON_VALUE(u.UserJson, '$.location.country'),
            JSON_VALUE(u.UserJson, '$.location.state'),
            JSON_VALUE(u.UserJson, '$.location.city'),
            JSON_VALUE(u.UserJson, '$.location.street.name'),
            TRY_CAST(JSON_VALUE(u.UserJson, '$.location.coordinates.latitude') AS DECIMAL(9,6)),
            TRY_CAST(JSON_VALUE(u.UserJson, '$.location.coordinates.longitude') AS DECIMAL(9,6)),
            u.InsertedAt
        FROM raw.Users u
        WHERE
            ISNULL(JSON_VALUE(u.UserJson, '$.name.first'), '') COLLATE Latin1_General_BIN NOT LIKE '%[^ -~]%' AND
            ISNULL(JSON_VALUE(u.UserJson, '$.name.last'), '') COLLATE Latin1_General_BIN NOT LIKE '%[^ -~]%' AND
            ISNULL(JSON_VALUE(u.UserJson, '$.location.city'), '') COLLATE Latin1_General_BIN NOT LIKE '%[^ -~]%' AND
            ISNULL(JSON_VALUE(u.UserJson, '$.location.state'), '') COLLATE Latin1_General_BIN NOT LIKE '%[^ -~]%';

		DELETE FROM stage.SubTerritories;
		DELETE FROM stage.Territories;


        -- Process Territories
        EXEC [stage].[ProcessTerritories]
            @IsSuccess = @TerritorySuccess OUTPUT,
            @ErrorMessage = @TerritoryError OUTPUT;

        IF @TerritorySuccess = 0
        BEGIN
            RAISERROR(@TerritoryError, 16, 1);
        END

        -- Process SubTerritories
        EXEC [stage].[ProcessSubTerritories]
            @IsSuccess = @SubTerritorySuccess OUTPUT,
            @ErrorMessage = @SubTerritoryError OUTPUT;

        IF @SubTerritorySuccess = 0
        BEGIN
            RAISERROR(@SubTerritoryError, 16, 1);
        END

        -- Final user load
        INSERT INTO stage.Users (
            Source, Gender, FullName, FirstName, LastName, Email, InsertedAt, SubTerritoryId
        )
        SELECT
            pu.Source,
            pu.Gender,
            pu.FullName,
            pu.FirstName,
            pu.LastName,
            pu.Email,
            pu.InsertedAt,
            st.SubTerritoryId
        FROM #ParsedUsers pu
        INNER JOIN stage.Territories t
            ON pu.Country = t.Country AND pu.State = t.State
        INNER JOIN stage.SubTerritories st
            ON t.TerritoryId = st.TerritoryId
           AND st.City = pu.City
           AND ISNULL(st.StreetName, '') = ISNULL(pu.StreetName, '')
           AND ISNULL(st.Latitude, 0) = ISNULL(pu.Latitude, 0)
           AND ISNULL(st.Longitude, 0) = ISNULL(pu.Longitude, 0);

        EXEC config.HashTableEntries @DataSourceId = 1;

		EXEC prod.UpsertUsersDim;

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
