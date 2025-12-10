-- ============================================================================
-- MergedTickets Table Migration
-- Run this on Support_DB to enable ticket merge functionality
-- ============================================================================

USE [Support_DB]
GO

PRINT '>> Creating MergedTickets table for ticket merge functionality'

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[MergedTickets]') AND type in (N'U'))
BEGIN
    CREATE TABLE [MergedTickets] (
        [Id] uniqueidentifier NOT NULL,
        [PrimaryTicketId] uniqueidentifier NOT NULL,
        [MergedTicketIds] nvarchar(max) NOT NULL,
        [MergeReason] nvarchar(1000) NULL,
        [MergedAt] datetime2 NOT NULL,
        [MergedByUserId] nvarchar(450) NOT NULL,
        CONSTRAINT [PK_MergedTickets] PRIMARY KEY ([Id])
    );
    
    CREATE INDEX [IX_MergedTickets_PrimaryTicketId] ON [MergedTickets] ([PrimaryTicketId]);
    CREATE INDEX [IX_MergedTickets_MergedByUserId] ON [MergedTickets] ([MergedByUserId]);
    
    -- Add foreign key to Tickets table
    IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Tickets]'))
    BEGIN
        ALTER TABLE [MergedTickets] ADD CONSTRAINT [FK_MergedTickets_Tickets_PrimaryTicketId] 
            FOREIGN KEY ([PrimaryTicketId]) REFERENCES [Tickets] ([Id]) ON DELETE CASCADE;
    END
    
    PRINT '   [OK] MergedTickets table created'
END
ELSE
BEGIN
    PRINT '   [SKIP] MergedTickets table already exists'
END
GO

-- Also ensure "Merged" status exists in TicketStatuses
PRINT ''
PRINT '>> Ensuring Merged status exists in TicketStatuses'

IF NOT EXISTS (SELECT 1 FROM TicketStatuses WHERE Name = 'Merged')
BEGIN
    DECLARE @MaxId INT = (SELECT ISNULL(MAX(Id), 0) FROM TicketStatuses);
    IF @MaxId < 1009 SET @MaxId = 1009;
    
    INSERT INTO TicketStatuses (Id, Name, Description, IsActive, IsDefault, DisplayOrder, IsDeleted)
    VALUES (@MaxId + 1, 'Merged', 'Ticket has been merged into another ticket', 1, 0, 99, 0);
    
    PRINT '   [OK] Merged status added to TicketStatuses'
END
ELSE
BEGIN
    PRINT '   [SKIP] Merged status already exists'
END
GO

PRINT ''
PRINT '=============================================='
PRINT 'MergedTickets Migration Complete!'
PRINT '=============================================='
