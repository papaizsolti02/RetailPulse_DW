CREATE TABLE [prod].[UsersDim](
	[UserId] [int] IDENTITY(1,1) NOT NULL,
	[Source] [nvarchar](255) NULL,
	[Gender] [char](1) NOT NULL,
	[FullName] [nvarchar](255) NOT NULL,
	[FirstName] [nvarchar](100) NOT NULL,
	[LastName] [nvarchar](100) NOT NULL,
	[Email] [nvarchar](320) NOT NULL,
	[SubTerritoryId] [int] NOT NULL,
	[BUSINESSKEYHASH] [varbinary](6000) NULL,
	[HASHDATA] [varchar](MAX) NULL,
	[EffectiveDate] [datetime] NOT NULL,
	[ExpirationDate] [datetime] NOT NULL,
	[IsCurrent] [bit] NOT NULL,
PRIMARY KEY CLUSTERED
(
	[UserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [prod].[UsersDim] ADD  DEFAULT ('9999-12-31') FOR [ExpirationDate]
GO

ALTER TABLE [prod].[UsersDim] ADD  DEFAULT ((1)) FOR [IsCurrent]
GO

ALTER TABLE [prod].[UsersDim]  WITH CHECK ADD  CONSTRAINT [FK_UsersDim_SubTerritories] FOREIGN KEY([SubTerritoryId])
REFERENCES [prod].[SubTerritoriesDim] ([SubTerritoryId])
GO

ALTER TABLE [prod].[UsersDim] CHECK CONSTRAINT [FK_UsersDim_SubTerritories]
GO
