CREATE TABLE [raw].[Transactions] (
    [TransactionId] INT IDENTITY (1, 1) NOT NULL,
    [TransactionJson] NVARCHAR(MAX) NULL,
    [InsertedAt] DATETIME DEFAULT (getdate()) NULL
);

