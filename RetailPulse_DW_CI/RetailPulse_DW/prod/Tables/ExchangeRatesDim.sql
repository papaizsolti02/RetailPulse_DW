CREATE TABLE [prod].[ExchangeRatesDim] (
    [ExchangeRateId] INT IDENTITY (1, 1) NOT NULL,
    [Country] NVARCHAR(100) NOT NULL,
    [Currency] NVARCHAR(3) NOT NULL,
    [RateToEUR] DECIMAL(18, 6) NOT NULL,
    [EffectiveDate] DATE DEFAULT (getdate()) NOT NULL,
    [ExpirationDate] DATE DEFAULT ('9999-12-31') NOT NULL,
    [IsCurrent] BIT DEFAULT ((1)) NOT NULL,
    PRIMARY KEY CLUSTERED ([ExchangeRateId] ASC)
);
