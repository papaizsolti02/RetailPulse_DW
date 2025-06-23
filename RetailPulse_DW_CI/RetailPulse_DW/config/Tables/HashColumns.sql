CREATE TABLE [config].[HashColumns] (
    [Id]         INT            IDENTITY (1, 1) NOT NULL,
    [DatasetId]  INT            NOT NULL,
    [ColumnName] NVARCHAR (255) NOT NULL,
    [HashString] NVARCHAR (255) NOT NULL,
    [HashOrder]  INT            NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);

