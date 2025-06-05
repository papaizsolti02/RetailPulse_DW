CREATE TABLE [prod].[ProductsDim](
	[ProductId] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](255) NOT NULL,
	[Description] [nvarchar](MAX) NULL,
	[Color] [nvarchar](50) NULL,
	[Brand] [nvarchar](100) NULL,
	[Category] [nvarchar](100) NULL,
	[Gender] [nvarchar](50) NULL,
	[Price] [decimal](10, 2) NOT NULL,
	[BUSINESSKEYHASH] [varbinary](6000) NULL,
	[HASHDATA] [varchar](MAX) NULL,
	[EffectiveDate] [datetime] NOT NULL,
	[ExpirationDate] [datetime] NOT NULL,
	[IsCurrent] [bit] NOT NULL,
PRIMARY KEY CLUSTERED
(
	[ProductId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [prod].[ProductsDim] ADD  DEFAULT (getdate()) FOR [EffectiveDate]
GO

ALTER TABLE [prod].[ProductsDim] ADD  DEFAULT ('9999-12-31') FOR [ExpirationDate]
GO

ALTER TABLE [prod].[ProductsDim] ADD  DEFAULT ((1)) FOR [IsCurrent]
GO
