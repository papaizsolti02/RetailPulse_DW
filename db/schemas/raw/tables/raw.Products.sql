CREATE TABLE [raw].[Products](
	[ProductId] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](255) NOT NULL,
	[Description] [nvarchar](MAX) NULL,
	[Color] [nvarchar](50) NULL,
	[Brand] [nvarchar](100) NULL,
	[Category] [nvarchar](100) NULL,
	[Gender] [nvarchar](50) NULL,
	[Price] [decimal](10, 2) NOT NULL,
	[InsertedAt] [datetime] NULL,
PRIMARY KEY CLUSTERED
(
	[ProductId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [raw].[Products] ADD  DEFAULT (getdate()) FOR [InsertedAt]
GO
