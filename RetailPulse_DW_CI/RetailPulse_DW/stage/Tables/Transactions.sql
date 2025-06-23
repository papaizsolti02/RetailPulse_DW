CREATE TABLE [stage].[Transactions] (
    [TransactionId]            INT             IDENTITY (1, 1) NOT NULL,
    [TransactionBK]            NVARCHAR (50)   NULL,
    [UserId]                   INT             NULL,
    [Currency]                 NVARCHAR (3)    NULL,
    [ProductId]                INT             NULL,
    [ProductLocalPrice]        DECIMAL (18, 2) NULL,
    [ProductStandardizedPrice] DECIMAL (18, 2) NULL,
    [CartLocalPrice]           DECIMAL (18, 2) NULL,
    [CartStandardizedPrice]    DECIMAL (18, 2) NULL,
    [ExchangeRateId]           INT             NULL,
    [DateKey]                  INT             NULL,
    [InsertedAt]               DATETIME        DEFAULT (getdate()) NULL,
    PRIMARY KEY CLUSTERED ([TransactionId] ASC),
    CONSTRAINT [FK_StageTransactions_DateKey] FOREIGN KEY ([DateKey]) REFERENCES [prod].[DateDim] ([DateKey]),
    CONSTRAINT [FK_StageTransactions_ExchangeRateId] FOREIGN KEY ([ExchangeRateId]) REFERENCES [prod].[ExchangeRatesDim] ([ExchangeRateId]),
    CONSTRAINT [FK_StageTransactions_ProductId] FOREIGN KEY ([ProductId]) REFERENCES [prod].[ProductsDim] ([ProductId]),
    CONSTRAINT [FK_StageTransactions_UserId] FOREIGN KEY ([UserId]) REFERENCES [prod].[UsersDim] ([UserId])
);

