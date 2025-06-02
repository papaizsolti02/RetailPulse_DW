CREATE TABLE [config].[CountryInfo](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[CountryName] [nvarchar](255) NULL,
	[Currency] [nvarchar](10) NULL,
	[CurrencySymbol] [nvarchar](100) NULL,
	[InsertedAt] [datetime] NULL,
PRIMARY KEY CLUSTERED
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [config].[CountryInfo] ADD  DEFAULT (getdate()) FOR [InsertedAt]
GO
