CREATE PROCEDURE [prod].[UpsertExchangeRate]
    @Country NVARCHAR(255),
    @Currency NVARCHAR(10),
    @RateToEUR DECIMAL(18, 6)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Today DATE = CAST(GETDATE() AS DATE);

    -- Deactivate previous rows for this currency
    UPDATE prod.ExchangeRatesDim
    SET
		IsCurrent = 0,
        ExpirationDate = @Today
    WHERE
		Country = @Country
		AND Currency = @Currency
		AND IsCurrent = 1;

    INSERT INTO prod.ExchangeRatesDim
	(
        Country,
		Currency,
		RateToEUR
    )
    VALUES (
        @Country,
		@Currency,
		@RateToEUR
    );
END