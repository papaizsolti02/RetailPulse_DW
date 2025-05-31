CREATE PROCEDURE prod.UpsertUsersDim
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Materialize the CTE as a temp table
        IF OBJECT_ID('tempdb..#UsersWithProdTerritory') IS NOT NULL
            DROP TABLE #UsersWithProdTerritory;

        SELECT
            su.*,
            td.TerritoryId AS ProdTerritoryId
        INTO #UsersWithProdTerritory
        FROM
            stage.Users su
        INNER JOIN stage.Territories st
            ON su.TerritoryId = st.TerritoryId
        INNER JOIN prod.TerritoriesDim td
            ON st.Country = td.Country
            AND st.State = td.State;

        UPDATE d
        SET
            d.ExpirationDate = s.InsertedAt,
            d.IsCurrent = 0
        FROM prod.UsersDim d
        INNER JOIN #UsersWithProdTerritory s
			ON d.BUSINESSKEYHASH = s.BUSINESSKEYHASH
        WHERE
            d.IsCurrent = 1
            AND ISNULL(d.Email, '') <> ISNULL(s.Email, '');

        INSERT INTO prod.UsersDim (
            Source,
			Gender,
			FullName,
			FirstName,
			LastName,
			Email,
			TerritoryId,
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
            s.ProdTerritoryId,
            s.BUSINESSKEYHASH,
            s.HASHDATA,
            s.InsertedAt AS EffectiveDate,
            '9999-12-31' AS ExpirationDate,
            1 AS IsCurrent
        FROM #UsersWithProdTerritory s
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
