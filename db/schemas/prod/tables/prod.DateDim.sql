CREATE TABLE [prod].[DateDim] (
    DateKey INT PRIMARY KEY, -- YYYYMMDD
    FullDate DATE NOT NULL,
    Day INT NOT NULL,
    Month INT NOT NULL,
    MonthName NVARCHAR(20),
    Year INT NOT NULL,
    Quarter INT NOT NULL,
    DayOfWeek INT NOT NULL, -- 1 = Monday
    DayName NVARCHAR(20),
    WeekOfYear INT NOT NULL,
    ISOWeek INT,
    IsWeekend BIT,
    IsLeapYear BIT
);
