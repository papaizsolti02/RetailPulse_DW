CREATE PROCEDURE [stage].[ProcessRawTransactions]
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        TRUNCATE TABLE [stage].[Transactions];

        DECLARE
            @TransactionId INT,
            @TransactionJson NVARCHAR(MAX),
            @InsertedAt DATETIME,
            @UserEmail NVARCHAR(320),
            @TransactionDate DATE,
            @Country NVARCHAR(100),
            @Cart NVARCHAR(MAX),

            @ProductName NVARCHAR(255),
            @ProductLocalPrice DECIMAL(18,2),
            @UserId INT,
            @ProductId INT,
            @CurrencyCode NVARCHAR(10),
            @ExchangeRateToEUR DECIMAL(18,6),
            @ExchangeRateId INT,
            @DateKey INT,

            @CartLocalTotal DECIMAL(18,2),
            @CartStandardizedTotal DECIMAL(18,2),

            @TransactionBK NVARCHAR(50),
            @TransactionDateStr NVARCHAR(8),
            @NextSequence INT = NULL;

        DECLARE TransactionCursor CURSOR FOR
            SELECT TransactionId, TransactionJson, InsertedAt
            FROM raw.Transactions
            ORDER BY InsertedAt;

        OPEN TransactionCursor;
        FETCH NEXT FROM TransactionCursor INTO @TransactionId, @TransactionJson, @InsertedAt;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            SET @CartLocalTotal = 0;
            SET @CartStandardizedTotal = 0;

            SET @UserEmail = JSON_VALUE(@TransactionJson, '$.UserEmail');
            SET @TransactionDate = TRY_CAST(JSON_VALUE(@TransactionJson, '$.Date') AS DATE);
            SET @Cart = JSON_QUERY(@TransactionJson, '$.Cart');

            IF @UserEmail IS NULL OR @TransactionDate IS NULL
            BEGIN
                FETCH NEXT FROM TransactionCursor INTO @TransactionId, @TransactionJson, @InsertedAt;
                CONTINUE;
            END

            SELECT @Country = JSON_VALUE(TransactionJson, '$.Country')
            FROM raw.Transactions
            WHERE TransactionId = @TransactionId;

            SELECT @UserId = UserId
            FROM prod.UsersDim
            WHERE Email COLLATE SQL_Latin1_General_CP1_CI_AS = @UserEmail COLLATE SQL_Latin1_General_CP1_CI_AS
              AND IsCurrent = 1;

            IF @UserId IS NULL
            BEGIN
                FETCH NEXT FROM TransactionCursor INTO @TransactionId, @TransactionJson, @InsertedAt;
                CONTINUE;
            END

            SELECT @CurrencyCode = Currency
            FROM config.CountryInfo
            WHERE CountryName = @Country;

            IF @CurrencyCode IS NULL
            BEGIN
                FETCH NEXT FROM TransactionCursor INTO @TransactionId, @TransactionJson, @InsertedAt;
                CONTINUE;
            END

            -- Get latest exchange rate info
            SELECT TOP 1
                @ExchangeRateToEUR = RateToEUR,
                @ExchangeRateId = ExchangeRateId
            FROM prod.ExchangeRatesDim
            WHERE Currency = @CurrencyCode AND IsCurrent = 1;

            IF @ExchangeRateToEUR IS NULL OR @ExchangeRateToEUR = 0
            BEGIN
                FETCH NEXT FROM TransactionCursor INTO @TransactionId, @TransactionJson, @InsertedAt;
                CONTINUE;
            END

            -- Get DateKey
            SELECT @DateKey = DateKey
            FROM prod.DateDim
            WHERE FullDate = @TransactionDate;

            IF @DateKey IS NULL
            BEGIN
                FETCH NEXT FROM TransactionCursor INTO @TransactionId, @TransactionJson, @InsertedAt;
                CONTINUE;
            END

            SET @TransactionDateStr = FORMAT(@TransactionDate, 'yyyyMMdd');

            IF @NextSequence IS NULL OR @TransactionDateStr <> LEFT(@TransactionBK, 11)
            BEGIN
                SELECT @NextSequence = ISNULL(MAX(CAST(RIGHT(TransactionBK, 5) AS INT)), 0)
                FROM stage.Transactions
                WHERE TransactionBK LIKE CONCAT('ORD', @TransactionDateStr, '%');

                SET @NextSequence += 1;
            END
            ELSE
            BEGIN
                SET @NextSequence += 1;
            END

            SET @TransactionBK = CONCAT('ORD', @TransactionDateStr, '-', RIGHT('00000' + CAST(@NextSequence AS NVARCHAR(5)), 5));

            DECLARE @CartItems TABLE (
                ProductName NVARCHAR(255),
                ProductLocalPrice DECIMAL(18,2)
            );

            INSERT INTO @CartItems(ProductName, ProductLocalPrice)
            SELECT
                cart_key_value.[key],
                TRY_CAST(cart_key_value.[value] AS DECIMAL(18,2))
            FROM (SELECT @TransactionJson AS TransactionJson) AS r
            CROSS APPLY OPENJSON(r.TransactionJson, '$.Cart') AS cart_item
            CROSS APPLY OPENJSON(cart_item.value) AS cart_key_value;

            DECLARE CartCursor CURSOR FOR
                SELECT ProductName, ProductLocalPrice FROM @CartItems;

            OPEN CartCursor;
            FETCH NEXT FROM CartCursor INTO @ProductName, @ProductLocalPrice;

            WHILE @@FETCH_STATUS = 0
            BEGIN
                SELECT @ProductId = ProductId
                FROM prod.ProductsDim
                WHERE Name = @ProductName AND IsCurrent = 1;

                IF @ProductId IS NULL
                BEGIN
                    FETCH NEXT FROM CartCursor INTO @ProductName, @ProductLocalPrice;
                    CONTINUE;
                END

                DECLARE @ProductStandardizedPrice DECIMAL(18,2) = ROUND(ISNULL(@ProductLocalPrice,0) * NULLIF(@ExchangeRateToEUR,0), 2);

                SET @CartLocalTotal += ISNULL(@ProductLocalPrice, 0);
                SET @CartStandardizedTotal += @ProductStandardizedPrice;

                INSERT INTO stage.Transactions (
                    TransactionBK,
                    UserId,
                    Currency,
                    ProductId,
                    ProductLocalPrice,
                    ProductStandardizedPrice,
                    CartLocalPrice,
                    CartStandardizedPrice,
                    ExchangeRateId,
                    DateKey,
                    InsertedAt
                )
                VALUES (
                    @TransactionBK,
                    @UserId,
                    @CurrencyCode,
                    @ProductId,
                    @ProductLocalPrice,
                    @ProductStandardizedPrice,
                    0,
                    0,
                    @ExchangeRateId,
                    @DateKey,
                    @InsertedAt
                );

                FETCH NEXT FROM CartCursor INTO @ProductName, @ProductLocalPrice;
            END

            CLOSE CartCursor;
            DEALLOCATE CartCursor;

            UPDATE stage.Transactions
            SET CartLocalPrice = @CartLocalTotal,
                CartStandardizedPrice = @CartStandardizedTotal
            WHERE TransactionBK = @TransactionBK;

            FETCH NEXT FROM TransactionCursor INTO @TransactionId, @TransactionJson, @InsertedAt;
        END

        CLOSE TransactionCursor;
        DEALLOCATE TransactionCursor;

    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('Error in stage.ProcessRawTransactions: %s', 16, 1, @ErrorMessage);
    END CATCH;
END;
GO
