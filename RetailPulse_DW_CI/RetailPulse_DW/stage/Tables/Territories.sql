﻿CREATE TABLE [stage].[Territories] (
    [TerritoryId]     INT              IDENTITY (1, 1) NOT NULL,
    [Country]         NVARCHAR (100)   NOT NULL,
    [State]           NVARCHAR (100)   NOT NULL,
    [CreatedAt]       DATETIME         DEFAULT (getdate()) NULL,
    [BUSINESSKEYHASH] VARBINARY (6000) NULL,
    [HASHDATA]        VARCHAR (MAX)    NULL,
    PRIMARY KEY CLUSTERED ([TerritoryId] ASC)
);

