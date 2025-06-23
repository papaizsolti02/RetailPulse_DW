CREATE TABLE [prod].[SubTerritoriesDim] (
    [SubTerritoryId] INT IDENTITY (1, 1) NOT NULL,
    [TerritoryId] INT NOT NULL,
    [City] NVARCHAR(100) NOT NULL,
    [StreetName] NVARCHAR(255) NULL,
    [Latitude] DECIMAL(9, 6) NULL,
    [Longitude] DECIMAL(9, 6) NULL,
    [CreatedAt] DATETIME DEFAULT (getdate()) NULL,
    [BUSINESSKEYHASH] VARBINARY(6000) NULL,
    [HASHDATA] VARCHAR(MAX) NULL,
    PRIMARY KEY CLUSTERED ([SubTerritoryId] ASC),
    CONSTRAINT [FK_SubTerritories_Territories] FOREIGN KEY ([TerritoryId]) REFERENCES [prod].[TerritoriesDim] ([TerritoryId])
);

