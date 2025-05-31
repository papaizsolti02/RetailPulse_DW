CREATE TABLE [raw].[Users](
	[UserId] [int] IDENTITY(1,1) NOT NULL,
	[Source] [nvarchar](255) NULL,
	[UserJson] [nvarchar](MAX) NOT NULL,
	[InsertedAt] [datetime] NULL,
PRIMARY KEY CLUSTERED
(
	[UserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [raw].[Users] ADD  DEFAULT ('https://randomuser.me/api/') FOR [Source]
GO

ALTER TABLE [raw].[Users] ADD  DEFAULT (getdate()) FOR [InsertedAt]
GO
