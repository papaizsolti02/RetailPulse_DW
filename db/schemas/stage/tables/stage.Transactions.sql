CREATE TABLE [stage].[Transactions](
	[TransactionId] [int] IDENTITY(1,1) NOT NULL,
	[TransactionBK] [nvarchar](50) NULL,
	[UserId] [int] NULL,
	[Currency] [nvarchar](3) NULL,
	[ProductId] [int] NULL,
	[ProductLocalPrice] [decimal](18, 2) NULL,
	[ProductStandardizedPrice] [decimal](18, 2) NULL,
	[CartLocalPrice] [decimal](18, 2) NULL,
	[CartStandardizedPrice] [decimal](18, 2) NULL,
	[ExchangeRateId] [int] NULL,
	[DateKey] [int] NULL,
	[InsertedAt] [datetime] NULL,
PRIMARY KEY CLUSTERED
(
	[TransactionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [stage].[Transactions] ADD  DEFAULT (getdate()) FOR [InsertedAt]
GO

ALTER TABLE [stage].[Transactions]  WITH CHECK ADD  CONSTRAINT [FK_StageTransactions_DateKey] FOREIGN KEY([DateKey])
REFERENCES [prod].[DateDim] ([DateKey])
GO

ALTER TABLE [stage].[Transactions] CHECK CONSTRAINT [FK_StageTransactions_DateKey]
GO

ALTER TABLE [stage].[Transactions]  WITH CHECK ADD  CONSTRAINT [FK_StageTransactions_ExchangeRateId] FOREIGN KEY([ExchangeRateId])
REFERENCES [prod].[ExchangeRatesDim] ([ExchangeRateId])
GO

ALTER TABLE [stage].[Transactions] CHECK CONSTRAINT [FK_StageTransactions_ExchangeRateId]
GO

ALTER TABLE [stage].[Transactions]  WITH CHECK ADD  CONSTRAINT [FK_StageTransactions_ProductId] FOREIGN KEY([ProductId])
REFERENCES [prod].[ProductsDim] ([ProductId])
GO

ALTER TABLE [stage].[Transactions] CHECK CONSTRAINT [FK_StageTransactions_ProductId]
GO

ALTER TABLE [stage].[Transactions]  WITH CHECK ADD  CONSTRAINT [FK_StageTransactions_UserId] FOREIGN KEY([UserId])
REFERENCES [prod].[UsersDim] ([UserId])
GO

ALTER TABLE [stage].[Transactions] CHECK CONSTRAINT [FK_StageTransactions_UserId]
GO
