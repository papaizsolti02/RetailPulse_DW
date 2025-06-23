CREATE PROCEDURE [raw].[IngestRawUsers]
    @UserJson NVARCHAR(MAX),
    @Source NVARCHAR(255) = 'https://randomuser.me/api/'
AS
BEGIN
    SET NOCOUNT ON;

    IF OBJECT_ID('[raw].[Users]', 'U') IS NULL
    BEGIN
        CREATE TABLE [raw].[Users]
        (
            [UserId] INT IDENTITY (1, 1) PRIMARY KEY,
            [Source] NVARCHAR(255) NULL DEFAULT 'https://randomuser.me/api/',
            [UserJson] NVARCHAR(MAX) NOT NULL,
			[InsertedAt] DATETIME DEFAULT GETDATE()
        );

    END

    INSERT INTO [raw].[Users] (UserJson, Source)
    VALUES (@UserJson, @Source);
END
