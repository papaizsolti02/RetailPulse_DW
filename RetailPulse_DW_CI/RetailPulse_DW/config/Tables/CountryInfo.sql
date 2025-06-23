CREATE TABLE [config].[CountryInfo] (
    [Id]             INT            IDENTITY (1, 1) NOT NULL,
    [CountryName]    NVARCHAR (255) NULL,
    [Currency]       NVARCHAR (10)  NULL,
    [CurrencySymbol] NVARCHAR (100) NULL,
    [InsertedAt]     DATETIME       DEFAULT (getdate()) NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);

