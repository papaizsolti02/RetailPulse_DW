CREATE TABLE config.Datasets (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Dataset NVARCHAR(100) NOT NULL,
    DatasetSource NVARCHAR(255) NOT NULL,
    SourceRefreshType NVARCHAR(50) NOT NULL,
    LoadTable NVARCHAR(255) NULL,
    ProcessingTable NVARCHAR(255) NULL,
    FinalTable NVARCHAR(255) NULL,
    CreatedAt DATETIME DEFAULT GETDATE()
);