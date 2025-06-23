CREATE PROCEDURE [prod].[GenerateDateDim]
    @StartDate DATE,
    @EndDate DATE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @CurrentDate DATE = @StartDate;

    WHILE @CurrentDate <= @EndDate
    BEGIN
        INSERT INTO prod.DateDim (
            DateKey, FullDate, Day, Month, MonthName, Year, Quarter,
            DayOfWeek, DayName, WeekOfYear, ISOWeek, IsWeekend, IsLeapYear
        )
        SELECT
            CONVERT(INT, FORMAT(@CurrentDate, 'yyyyMMdd')),
            @CurrentDate,
            DAY(@CurrentDate),
            MONTH(@CurrentDate),
            DATENAME(MONTH, @CurrentDate),
            YEAR(@CurrentDate),
            DATEPART(QUARTER, @CurrentDate),
            DATEPART(WEEKDAY, @CurrentDate),
            DATENAME(WEEKDAY, @CurrentDate),
            DATEPART(WEEK, @CurrentDate),
            DATEPART(ISO_WEEK, @CurrentDate),
            CASE WHEN DATEPART(WEEKDAY, @CurrentDate) IN (1, 7) THEN 1 ELSE 0 END,
            CASE WHEN (YEAR(@CurrentDate) % 4 = 0 AND YEAR(@CurrentDate) % 100 <> 0) OR (YEAR(@CurrentDate) % 400 = 0) THEN 1 ELSE 0 END;

        SET @CurrentDate = DATEADD(DAY, 1, @CurrentDate);
    END
END;