CREATE TABLE [prod].[TransactionsFact](
	[TransactionId] [int] IDENTITY(1,1) NOT NULL,
	[TransactionBK] [nvarchar](50) NOT NULL,
	[UserId] [int] NOT NULL,
	[ProductId] [int] NOT NULL,
	[ExchangeRateId] [int] NOT NULL,
	[DateKey] [int] NOT NULL,
	[Currency] [nvarchar](3) NOT NULL,
	[ProductLocalPrice] [decimal](18, 2) NOT NULL,
	[ProductStandardizedPrice] [decimal](18, 2) NOT NULL,
	[CartLocalPrice] [decimal](18, 2) NOT NULL,
	[CartStandardizedPrice] [decimal](18, 2) NOT NULL,
	[InsertedAt] [datetime] NULL,
PRIMARY KEY CLUSTERED
(
	[TransactionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [prod].[TransactionsFact] ADD  DEFAULT (getdate()) FOR [InsertedAt]
GO

ALTER TABLE [prod].[TransactionsFact]  WITH CHECK ADD  CONSTRAINT [FK_TransactionsFact_Date] FOREIGN KEY([DateKey])
REFERENCES [prod].[DateDim] ([DateKey])
GO

ALTER TABLE [prod].[TransactionsFact] CHECK CONSTRAINT [FK_TransactionsFact_Date]
GO

ALTER TABLE [prod].[TransactionsFact]  WITH CHECK ADD  CONSTRAINT [FK_TransactionsFact_ExchangeRate] FOREIGN KEY([ExchangeRateId])
REFERENCES [prod].[ExchangeRatesDim] ([ExchangeRateId])
GO

ALTER TABLE [prod].[TransactionsFact] CHECK CONSTRAINT [FK_TransactionsFact_ExchangeRate]
GO

ALTER TABLE [prod].[TransactionsFact]  WITH CHECK ADD  CONSTRAINT [FK_TransactionsFact_Product] FOREIGN KEY([ProductId])
REFERENCES [prod].[ProductsDim] ([ProductId])
GO

ALTER TABLE [prod].[TransactionsFact] CHECK CONSTRAINT [FK_TransactionsFact_Product]
GO

ALTER TABLE [prod].[TransactionsFact]  WITH CHECK ADD  CONSTRAINT [FK_TransactionsFact_User] FOREIGN KEY([UserId])
REFERENCES [prod].[UsersDim] ([UserId])
GO

ALTER TABLE [prod].[TransactionsFact] CHECK CONSTRAINT [FK_TransactionsFact_User]
GO
