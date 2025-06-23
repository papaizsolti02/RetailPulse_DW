CREATE TABLE [prod].[TransactionsFact] (
    [TransactionId]            INT             IDENTITY (1, 1) NOT NULL,
    [TransactionBK]            NVARCHAR (50)   NOT NULL,
    [UserId]                   INT             NOT NULL,
    [ProductId]                INT             NOT NULL,
    [ExchangeRateId]           INT             NOT NULL,
    [DateKey]                  INT             NOT NULL,
    [Currency]                 NVARCHAR (3)    NOT NULL,
    [ProductLocalPrice]        DECIMAL (18, 2) NOT NULL,
    [ProductStandardizedPrice] DECIMAL (18, 2) NOT NULL,
    [CartLocalPrice]           DECIMAL (18, 2) NOT NULL,
    [CartStandardizedPrice]    DECIMAL (18, 2) NOT NULL,
    [InsertedAt]               DATETIME        DEFAULT (getdate()) NULL,
    PRIMARY KEY CLUSTERED ([TransactionId] ASC),
    CONSTRAINT [FK_TransactionsFact_Date] FOREIGN KEY ([DateKey]) REFERENCES [prod].[DateDim] ([DateKey]),
    CONSTRAINT [FK_TransactionsFact_ExchangeRate] FOREIGN KEY ([ExchangeRateId]) REFERENCES [prod].[ExchangeRatesDim] ([ExchangeRateId]),
    CONSTRAINT [FK_TransactionsFact_Product] FOREIGN KEY ([ProductId]) REFERENCES [prod].[ProductsDim] ([ProductId]),
    CONSTRAINT [FK_TransactionsFact_User] FOREIGN KEY ([UserId]) REFERENCES [prod].[UsersDim] ([UserId])
);

