CREATE TABLE [raw].[Products] (
    [ProductId]   INT             IDENTITY (1, 1) NOT NULL,
    [Name]        NVARCHAR (255)  NOT NULL,
    [Description] NVARCHAR (MAX)  NULL,
    [Color]       NVARCHAR (50)   NULL,
    [Brand]       NVARCHAR (100)  NULL,
    [Category]    NVARCHAR (100)  NULL,
    [Gender]      NVARCHAR (50)   NULL,
    [Price]       DECIMAL (10, 2) NOT NULL,
    [InsertedAt]  DATETIME        DEFAULT (getdate()) NULL,
    PRIMARY KEY CLUSTERED ([ProductId] ASC)
);

