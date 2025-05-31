CREATE TABLE [stage].[Users](
	[UserId] [int] IDENTITY(1,1) NOT NULL,
	[Source] [nvarchar](255) NULL,
	[Gender] [char](1) NOT NULL,
	[FullName] [nvarchar](255) NOT NULL,
	[FirstName] [nvarchar](100) NOT NULL,
	[LastName] [nvarchar](100) NOT NULL,
	[Email] [nvarchar](320) NOT NULL,
	[InsertedAt] [datetime] NOT NULL,
	[TerritoryId] [int] NOT NULL,
	[BUSINESSKEYHASH] [varbinary](6000) NULL,
	[HASHDATA] [varchar](MAX) NULL,
PRIMARY KEY CLUSTERED
(
	[UserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [stage].[Users] ADD  DEFAULT ('UNKNOWN') FOR [Source]
GO

ALTER TABLE [stage].[Users] ADD  DEFAULT (getdate()) FOR [InsertedAt]
GO

ALTER TABLE [stage].[Users]  WITH CHECK ADD  CONSTRAINT [FK_StageUsers_Territories] FOREIGN KEY([TerritoryId])
REFERENCES [stage].[Territories] ([TerritoryId])
GO

ALTER TABLE [stage].[Users] CHECK CONSTRAINT [FK_StageUsers_Territories]
GO
