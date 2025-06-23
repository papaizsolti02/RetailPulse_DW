
CREATE PROCEDURE [prod].[UpsertUsersDim]
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Materialize the CTE as a temp table
        IF OBJECT_ID('tempdb..#UsersWithProdTerritory') IS NOT NULL
            DROP TABLE #UsersWithProdSubTerritory;

        SELECT 
            su.*,
            std.SubTerritoryId AS ProdSubTerritoryId
        INTO #UsersWithProdSubTerritory
        FROM 
            stage.Users su
        INNER JOIN stage.SubTerritories st
            ON su.SubTerritoryId = st.SubTerritoryId
		INNER JOIN prod.SubTerritoriesDim std
			ON st.City = std.City
			AND st.StreetName = std.StreetName
			AND st.Latitude = std.Latitude
			AND st.Longitude = std.Longitude
		
		-- Step 1: Expire old records where Email has changed
        UPDATE d
        SET 
            d.ExpirationDate = s.InsertedAt,
            d.IsCurrent = 0
        FROM prod.UsersDim d
        INNER JOIN #UsersWithProdSubTerritory s 
			ON d.BUSINESSKEYHASH = s.BUSINESSKEYHASH
        WHERE 
            d.IsCurrent = 1
            AND ISNULL(d.Email, '') <> ISNULL(s.Email, '');

        -- Step 2: Insert new or changed records
        INSERT INTO prod.UsersDim (
            Source, 
			Gender,
			FullName,
			FirstName,
			LastName,
			Email,
			SubTerritoryId,
            BUSINESSKEYHASH,
			HASHDATA,
            EffectiveDate,
			ExpirationDate,
			IsCurrent
        )
        SELECT 
            s.Source,
            s.Gender,
            s.FullName,
            s.FirstName,
            s.LastName,
            s.Email,
            s.ProdSubTerritoryId,
            s.BUSINESSKEYHASH,
            s.HASHDATA,
            s.InsertedAt AS EffectiveDate,
            '9999-12-31' AS ExpirationDate,
            1 AS IsCurrent
        FROM #UsersWithProdSubTerritory s
        LEFT JOIN prod.UsersDim d
            ON s.BUSINESSKEYHASH = d.BUSINESSKEYHASH 
			AND d.IsCurrent = 1
        WHERE 
            d.UserId IS NULL 
			OR ISNULL(d.Email, '') <> ISNULL(s.Email, '');

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
