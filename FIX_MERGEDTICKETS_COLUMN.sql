-- ============================================================================
-- Fix MergedTickets table - Add missing MergedByUserId column
-- Run this on Support_DB
-- ============================================================================

USE [Support_DB]
GO

PRINT '>> Checking MergedTickets table columns...'

SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'MergedTickets'
ORDER BY ORDINAL_POSITION;
GO

-- Check if MergedByUserId column exists
IF NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = 'MergedTickets' AND COLUMN_NAME = 'MergedByUserId'
)
BEGIN
    PRINT ''
    PRINT '>> Adding missing MergedByUserId column...'
    
    ALTER TABLE MergedTickets 
    ADD MergedByUserId NVARCHAR(450) NULL;
    
    PRINT '   [OK] MergedByUserId column added'
END
ELSE
BEGIN
    PRINT ''
    PRINT '   [OK] MergedByUserId column already exists'
END
GO

-- Verify final structure
PRINT ''
PRINT '>> Final MergedTickets structure:'
SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'MergedTickets'
ORDER BY ORDINAL_POSITION;
GO

PRINT ''
PRINT '=============================================='
PRINT 'Fix Complete - Try merge again'
PRINT '=============================================='
