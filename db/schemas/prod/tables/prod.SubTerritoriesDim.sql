CREATE TABLE [prod].[SubTerritoriesDim](
	[SubTerritoryId] [int] IDENTITY(1,1) NOT NULL,
	[TerritoryId] [int] NOT NULL,
	[City] [nvarchar](100) NOT NULL,
	[StreetName] [nvarchar](255) NULL,
	[Latitude] [decimal](9, 6) NULL,
	[Longitude] [decimal](9, 6) NULL,
	[CreatedAt] [datetime] NULL,
	[BUSINESSKEYHASH] [varbinary](6000) NULL,
	[HASHDATA] [varchar](MAX) NULL,
PRIMARY KEY CLUSTERED
(
	[SubTerritoryId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [prod].[SubTerritoriesDim] ADD  DEFAULT (getdate()) FOR [CreatedAt]
GO

ALTER TABLE [prod].[SubTerritoriesDim]  WITH CHECK ADD  CONSTRAINT [FK_SubTerritories_Territories] FOREIGN KEY([TerritoryId])
REFERENCES [prod].[TerritoriesDim] ([TerritoryId])
GO

ALTER TABLE [prod].[SubTerritoriesDim] CHECK CONSTRAINT [FK_SubTerritories_Territories]
GO
