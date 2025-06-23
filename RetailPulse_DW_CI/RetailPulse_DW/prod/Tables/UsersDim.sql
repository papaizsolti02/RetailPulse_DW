CREATE TABLE [prod].[UsersDim] (
    [UserId] INT IDENTITY (1, 1) NOT NULL,
    [Source] NVARCHAR(255) NULL,
    [Gender] CHAR(1) NOT NULL,
    [FullName] NVARCHAR(255) NOT NULL,
    [FirstName] NVARCHAR(100) NOT NULL,
    [LastName] NVARCHAR(100) NOT NULL,
    [Email] NVARCHAR(320) NOT NULL,
    [SubTerritoryId] INT NOT NULL,
    [BUSINESSKEYHASH] VARBINARY(6000) NULL,
    [HASHDATA] VARCHAR(MAX) NULL,
    [EffectiveDate] DATETIME NOT NULL,
    [ExpirationDate] DATETIME DEFAULT ('9999-12-31') NOT NULL,
    [IsCurrent] BIT DEFAULT ((1)) NOT NULL,
    PRIMARY KEY CLUSTERED ([UserId] ASC),
    CONSTRAINT [FK_UsersDim_SubTerritories] FOREIGN KEY ([SubTerritoryId]) REFERENCES [prod].[SubTerritoriesDim] ([SubTerritoryId])
);

