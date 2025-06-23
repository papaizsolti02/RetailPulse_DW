CREATE   PROCEDURE prod.InsertTransactionsFact
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- If the table does not exist, create it
        IF NOT EXISTS (
            SELECT 1
            FROM INFORMATION_SCHEMA.TABLES
            WHERE TABLE_SCHEMA = 'prod' AND TABLE_NAME = 'TransactionsFact'
        )
        BEGIN
            EXEC('
                CREATE TABLE prod.TransactionsFact (
                    TransactionId INT IDENTITY(1,1) PRIMARY KEY,
                    TransactionBK NVARCHAR(50) NOT NULL,
                    UserId INT NOT NULL,
                    ProductId INT NOT NULL,
                    ExchangeRateId INT NOT NULL,
                    DateKey INT NOT NULL,
                    Currency NVARCHAR(3) NOT NULL,
                    ProductLocalPrice DECIMAL(18, 2) NOT NULL,
                    ProductStandardizedPrice DECIMAL(18, 2) NOT NULL,
                    CartLocalPrice DECIMAL(18, 2) NOT NULL,
                    CartStandardizedPrice DECIMAL(18, 2) NOT NULL,
                    InsertedAt DATETIME DEFAULT GETDATE(),

                    CONSTRAINT FK_TransactionsFact_User FOREIGN KEY (UserId) REFERENCES prod.UsersDim(UserId),
                    CONSTRAINT FK_TransactionsFact_Product FOREIGN KEY (ProductId) REFERENCES prod.ProductsDim(ProductId),
                    CONSTRAINT FK_TransactionsFact_ExchangeRate FOREIGN KEY (ExchangeRateId) REFERENCES prod.ExchangeRatesDim(ExchangeRateId),
                    CONSTRAINT FK_TransactionsFact_Date FOREIGN KEY (DateKey) REFERENCES prod.DateDim(DateKey)
                );
            ');
        END

        -- Insert data into prod.TransactionsFact
        INSERT INTO prod.TransactionsFact (
            TransactionBK,
            UserId,
            ProductId,
            ExchangeRateId,
            DateKey,
            Currency,
            ProductLocalPrice,
            ProductStandardizedPrice,
            CartLocalPrice,
            CartStandardizedPrice,
            InsertedAt
        )
        SELECT
            TransactionBK,
            UserId,
            ProductId,
            ExchangeRateId,
            DateKey,
            Currency,
            ProductLocalPrice,
            ProductStandardizedPrice,
            CartLocalPrice,
            CartStandardizedPrice,
            InsertedAt
        FROM stage.Transactions;

    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('Error in InsertTransactionsFact: %s', 16, 1, @ErrorMessage);
    END CATCH
END;