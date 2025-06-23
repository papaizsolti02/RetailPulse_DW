CREATE TABLE [raw].[Users] (
    [UserId]     INT            IDENTITY (1, 1) NOT NULL,
    [Source]     NVARCHAR (255) DEFAULT ('https://randomuser.me/api/') NULL,
    [UserJson]   NVARCHAR (MAX) NOT NULL,
    [InsertedAt] DATETIME       DEFAULT (getdate()) NULL,
    PRIMARY KEY CLUSTERED ([UserId] ASC)
);

