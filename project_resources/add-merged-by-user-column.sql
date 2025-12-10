-- Add MergedByUserId column to MergedTickets table
-- This column tracks which user performed the merge operation

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('MergedTickets') AND name = 'MergedByUserId')
BEGIN
    ALTER TABLE MergedTickets ADD MergedByUserId NVARCHAR(450) NULL;
    PRINT 'Added MergedByUserId column to MergedTickets table';
END
ELSE
BEGIN
    PRINT 'MergedByUserId column already exists';
END
GO

-- Add index for faster lookups
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_MergedTickets_MergedByUserId' AND object_id = OBJECT_ID('MergedTickets'))
BEGIN
    CREATE INDEX IX_MergedTickets_MergedByUserId ON MergedTickets(MergedByUserId);
    PRINT 'Created index on MergedByUserId';
END
GO
