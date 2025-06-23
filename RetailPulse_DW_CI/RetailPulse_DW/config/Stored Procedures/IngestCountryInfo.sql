CREATE PROCEDURE [config].[IngestCountryInfo]
    @CountryName NVARCHAR(255),
    @Currency NVARCHAR(10),
    @CurrencySymbol NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    IF OBJECT_ID('[config].[CountryInfo]', 'U') IS NULL
    BEGIN
        CREATE TABLE [config].[CountryInfo]
		(
			Id INT IDENTITY(1,1) PRIMARY KEY,
			CountryName NVARCHAR(255),
			Currency NVARCHAR(10),
			CurrencySymbol NVARCHAR(10),
			InsertedAt DATETIME DEFAULT GETDATE()
		);
    END

    -- Insert or ignore if already exists (optional logic depending on uniqueness)
    INSERT INTO [config].[CountryInfo] (
		CountryName,
		Currency,
		CurrencySymbol
	)
	VALUES (
		@CountryName,
		@Currency,
		@CurrencySymbol
	)
END
