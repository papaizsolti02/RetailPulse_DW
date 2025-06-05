CREATE PROCEDURE [raw].[IngestRawProducts]
    @Name NVARCHAR(255),
    @Description NVARCHAR(MAX),
    @Color NVARCHAR(50),
    @Brand NVARCHAR(100),
    @Category NVARCHAR(100),
    @Gender NVARCHAR(50),
    @Price DECIMAL(10, 2)
AS
BEGIN
    SET NOCOUNT ON;

    IF OBJECT_ID('[raw].[Products]', 'U') IS NULL
    BEGIN
        CREATE TABLE [raw].[Products] (
            ProductId INT IDENTITY(1,1) PRIMARY KEY,
            Name NVARCHAR(255) NOT NULL,
            Description NVARCHAR(MAX) NULL,
            Color NVARCHAR(50) NULL,
            Brand NVARCHAR(100) NULL,
            Category NVARCHAR(100) NULL,
            Gender NVARCHAR(50) NULL,
            Price DECIMAL(10, 2) NOT NULL,
            InsertedAt DATETIME DEFAULT GETDATE()
        );
    END

    INSERT INTO [raw].[Products] (Name, Description, Color, Brand, Category, Gender, Price)
    VALUES (@Name, @Description, @Color, @Brand, @Category, @Gender, @Price);
END
GO
