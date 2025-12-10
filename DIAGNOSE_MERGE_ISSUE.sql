-- ============================================================================
-- Diagnose Merge Tickets Issue
-- Run this on Support_DB to check table structure
-- ============================================================================

USE [Support_DB]
GO

PRINT '=============================================='
PRINT 'MERGE TICKETS DIAGNOSTIC'
PRINT '=============================================='
PRINT ''

-- 1. Check if MergedTickets table exists
PRINT '>> 1. Checking MergedTickets table...'
IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'MergedTickets')
BEGIN
    PRINT '   [OK] MergedTickets table EXISTS'
    
    -- Show structure
    PRINT ''
    PRINT '   Table columns:'
    SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE, CHARACTER_MAXIMUM_LENGTH
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = 'MergedTickets'
    ORDER BY ORDINAL_POSITION;
    
    -- Show row count
    DECLARE @MergeCount INT = (SELECT COUNT(*) FROM MergedTickets);
    PRINT '   Row count: ' + CAST(@MergeCount AS NVARCHAR);
END
ELSE
BEGIN
    PRINT '   [MISSING] MergedTickets table DOES NOT EXIST!'
    PRINT ''
    PRINT '   Creating MergedTickets table...'
    
    CREATE TABLE MergedTickets (
        Id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
        PrimaryTicketId UNIQUEIDENTIFIER NOT NULL,
        MergedTicketIds NVARCHAR(MAX) NOT NULL,
        MergeReason NVARCHAR(MAX) NULL,
        MergedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        MergedByUserId NVARCHAR(450) NULL
    );
    
    -- Create index on PrimaryTicketId
    CREATE INDEX IX_MergedTickets_PrimaryTicketId ON MergedTickets(PrimaryTicketId);
    
    PRINT '   [OK] MergedTickets table CREATED'
END
GO

-- 2. Check Merged status
PRINT ''
PRINT '>> 2. Checking Merged status...'
IF EXISTS (SELECT 1 FROM TicketStatuses WHERE Name = 'Merged' AND IsActive = 1)
BEGIN
    SELECT Id, Name, IsActive, Color FROM TicketStatuses WHERE Name = 'Merged';
    PRINT '   [OK] Merged status exists'
END
ELSE
BEGIN
    PRINT '   [MISSING] Merged status not found or not active!'
END
GO

-- 3. Check TicketComments table (merge adds comments)
PRINT ''
PRINT '>> 3. Checking TicketComments table...'
IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'TicketComments')
BEGIN
    PRINT '   [OK] TicketComments table EXISTS'
    SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = 'TicketComments'
    ORDER BY ORDINAL_POSITION;
END
ELSE
BEGIN
    PRINT '   [MISSING] TicketComments table DOES NOT EXIST!'
END
GO

-- 4. Check Attachments table (merge moves attachments)
PRINT ''
PRINT '>> 4. Checking Attachments table...'
IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Attachments')
BEGIN
    PRINT '   [OK] Attachments table EXISTS'
END
ELSE
BEGIN
    PRINT '   [MISSING] Attachments table DOES NOT EXIST!'
END
GO

PRINT ''
PRINT '=============================================='
PRINT 'DIAGNOSTIC COMPLETE'
PRINT '=============================================='
PRINT ''
PRINT 'If MergedTickets table was missing, it has been created.'
PRINT 'Try the merge operation again.'
