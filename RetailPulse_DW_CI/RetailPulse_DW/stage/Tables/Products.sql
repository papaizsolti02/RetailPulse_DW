CREATE TABLE [stage].[Products] (
    [ProductId] INT IDENTITY (1, 1) NOT NULL,
    [Name] NVARCHAR(255) NOT NULL,
    [Description] NVARCHAR(MAX) NULL,
    [Color] NVARCHAR(50) NULL,
    [Brand] NVARCHAR(100) NULL,
    [Category] NVARCHAR(100) NULL,
    [Gender] NVARCHAR(50) NULL,
    [Price] DECIMAL(10, 2) NOT NULL,
    [InsertedAt] DATETIME DEFAULT (getdate()) NULL,
    [BUSINESSKEYHASH] VARBINARY(6000) NULL,
    [HASHDATA] VARCHAR(MAX) NULL,
    PRIMARY KEY CLUSTERED ([ProductId] ASC)
);

