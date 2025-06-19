CREATE TABLE [raw].[Transactions](
	[TransactionId] [int] IDENTITY(1,1) NOT NULL,
	[TransactionJson] [nvarchar](MAX) NULL,
	[InsertedAt] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [raw].[Transactions] ADD  DEFAULT (getdate()) FOR [InsertedAt]
GO
