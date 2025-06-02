CREATE TABLE [prod].[ExchangeRatesDim](
	[ExchangeRateId] [int] IDENTITY(1,1) NOT NULL,
	[Country] [nvarchar](100) NOT NULL,
	[Currency] [nvarchar](3) NOT NULL,
	[RateToEUR] [decimal](18, 6) NOT NULL,
	[EffectiveDate] [date] NOT NULL,
	[ExpirationDate] [date] NOT NULL,
	[IsCurrent] [bit] NOT NULL,
PRIMARY KEY CLUSTERED
(
	[ExchangeRateId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [prod].[ExchangeRatesDim] ADD  DEFAULT (getdate()) FOR [EffectiveDate]
GO

ALTER TABLE [prod].[ExchangeRatesDim] ADD  DEFAULT ('9999-12-31') FOR [ExpirationDate]
GO

ALTER TABLE [prod].[ExchangeRatesDim] ADD  DEFAULT ((1)) FOR [IsCurrent]
GO
