CREATE TABLE [prod].[DateDim] (
    [DateKey] INT NOT NULL,
    [FullDate] DATE NOT NULL,
    [Day] INT NOT NULL,
    [Month] INT NOT NULL,
    [MonthName] NVARCHAR(20) NULL,
    [Year] INT NOT NULL,
    [Quarter] INT NOT NULL,
    [DayOfWeek] INT NOT NULL,
    [DayName] NVARCHAR(20) NULL,
    [WeekOfYear] INT NOT NULL,
    [ISOWeek] INT NULL,
    [IsWeekend] BIT NULL,
    [IsLeapYear] BIT NULL,
    PRIMARY KEY CLUSTERED ([DateKey] ASC)
);

