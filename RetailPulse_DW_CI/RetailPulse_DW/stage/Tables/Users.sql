CREATE TABLE [stage].[Users] (
    [UserId] INT IDENTITY (1, 1) NOT NULL,
    [Source] NVARCHAR(255) DEFAULT ('UNKNOWN') NULL,
    [Gender] CHAR(1) NOT NULL,
    [FullName] NVARCHAR(255) NOT NULL,
    [FirstName] NVARCHAR(100) NOT NULL,
    [LastName] NVARCHAR(100) NOT NULL,
    [Email] NVARCHAR(320) NOT NULL,
    [InsertedAt] DATETIME DEFAULT (getdate()) NOT NULL,
    [SubTerritoryId] INT NOT NULL,
    [BUSINESSKEYHASH] VARBINARY(6000) NULL,
    [HASHDATA] VARCHAR(MAX) NULL,
    PRIMARY KEY CLUSTERED ([UserId] ASC),
    CONSTRAINT [FK_StageUsers_SubTerritories] FOREIGN KEY ([SubTerritoryId]) REFERENCES [stage].[SubTerritories] ([SubTerritoryId])
);

