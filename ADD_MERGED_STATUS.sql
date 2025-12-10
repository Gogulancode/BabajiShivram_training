-- ============================================================================
-- Add Merged Status to TicketStatuses (Complete Schema)
-- Run this on Support_DB
-- ============================================================================

USE [Support_DB]
GO

PRINT '>> Checking TicketStatuses table structure'

-- First, let's see what columns exist
SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'TicketStatuses'
ORDER BY ORDINAL_POSITION;
GO

-- Show existing statuses
PRINT ''
PRINT '>> Current statuses in database:'
SELECT Id, Name, IsActive, IsDefault, WorkflowOrder FROM TicketStatuses ORDER BY Id;
GO

PRINT ''
PRINT '>> Adding Merged status if not exists'

-- Check if Merged status exists
IF NOT EXISTS (SELECT 1 FROM TicketStatuses WHERE Name = 'Merged')
BEGIN
    -- Get max ID and workflow order
    DECLARE @MaxId INT = (SELECT ISNULL(MAX(Id), 0) FROM TicketStatuses);
    DECLARE @MaxOrder INT = (SELECT ISNULL(MAX(WorkflowOrder), 0) FROM TicketStatuses);
    SET @MaxId = @MaxId + 1;
    SET @MaxOrder = @MaxOrder + 1;
    
    -- Enable IDENTITY_INSERT if Id is an identity column
    SET IDENTITY_INSERT TicketStatuses ON;
    
    -- Insert with all columns based on TicketStatus entity
    INSERT INTO TicketStatuses (
        Id, 
        Name, 
        WorkflowOrder, 
        IsActive, 
        IsDeleted, 
        Color, 
        IsDefault, 
        IsClosedStatus, 
        AllowedTransitions, 
        CreatedAt, 
        UpdatedAt
    )
    VALUES (
        @MaxId,              -- Id
        'Merged',            -- Name
        @MaxOrder,           -- WorkflowOrder (last in order)
        1,                   -- IsActive = true
        0,                   -- IsDeleted = false
        '#9333EA',           -- Color (purple for merged)
        0,                   -- IsDefault = false
        1,                   -- IsClosedStatus = true (merged tickets are considered closed)
        NULL,                -- AllowedTransitions (no transitions from merged)
        GETUTCDATE(),        -- CreatedAt
        GETUTCDATE()         -- UpdatedAt
    );
    
    SET IDENTITY_INSERT TicketStatuses OFF;
    
    PRINT '   [OK] Merged status added with ID: ' + CAST(@MaxId AS NVARCHAR);
END
ELSE
BEGIN
    SELECT Id, Name, IsActive, WorkflowOrder, Color FROM TicketStatuses WHERE Name = 'Merged';
    PRINT '   [SKIP] Merged status already exists'
END
GO

-- Verify the result
PRINT ''
PRINT '>> Final statuses in database:'
SELECT Id, Name, IsActive, IsDefault, WorkflowOrder, Color FROM TicketStatuses ORDER BY WorkflowOrder;
GO

PRINT ''
PRINT '=============================================='
PRINT 'Migration Complete!'
PRINT '=============================================='
PRINT ''
PRINT 'NEXT STEPS:'
PRINT '1. Copy the new Merged status ID from the output above'
PRINT '2. Test merge tickets feature in the application'
PRINT '=============================================='
