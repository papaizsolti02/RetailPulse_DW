CREATE PROCEDURE [raw].[IngestRawTransactions]
    @TransactionJson NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    IF OBJECT_ID('[raw].[Transactions]', 'U') IS NULL
    BEGIN
		CREATE TABLE [raw].[Transactions] (
			[TransactionId] INT IDENTITY(1,1),
			[TransactionJson] NVARCHAR(MAX),
			[InsertedAt] DATETIME DEFAULT GETDATE()
		);
    END

    INSERT INTO [raw].[Transactions] (TransactionJson)
    VALUES (@TransactionJson);
END
