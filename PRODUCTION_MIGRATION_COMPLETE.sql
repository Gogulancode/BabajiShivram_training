-- ============================================================================
-- PRODUCTION DATABASE MIGRATION SCRIPT
-- Generated: December 2, 2025
-- Target: Support_DB Production Database
-- ============================================================================
-- 
-- INSTRUCTIONS:
-- 1. BACKUP YOUR DATABASE FIRST!
-- 2. Run this script in SQL Server Management Studio
-- 3. Execute in sections if needed (each section is independent with IF checks)
-- 4. Check the output for any errors
--
-- ============================================================================

USE [Support_DB]
GO

PRINT '=============================================='
PRINT 'Starting Production Database Migration'
PRINT '=============================================='
PRINT ''

-- ============================================================================
-- MIGRATION 1: TicketCollaborators Table (20251030100830)
-- ============================================================================
PRINT '>> Migration 1: TicketCollaborators Table'

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TicketCollaborators]') AND type in (N'U'))
BEGIN
    CREATE TABLE [TicketCollaborators] (
        [Id] int NOT NULL IDENTITY(1,1),
        [TicketId] uniqueidentifier NOT NULL,
        [UserId] nvarchar(450) NOT NULL,
        [Role] nvarchar(max) NOT NULL,
        [AddedByUserId] nvarchar(450) NOT NULL,
        [AddedAt] datetime2 NOT NULL,
        CONSTRAINT [PK_TicketCollaborators] PRIMARY KEY ([Id])
    );
    
    CREATE INDEX [IX_TicketCollaborators_AddedByUserId] ON [TicketCollaborators] ([AddedByUserId]);
    CREATE UNIQUE INDEX [IX_TicketCollaborators_TicketId_UserId] ON [TicketCollaborators] ([TicketId], [UserId]);
    CREATE INDEX [IX_TicketCollaborators_UserId] ON [TicketCollaborators] ([UserId]);
    
    -- Add foreign keys if tables exist
    IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[AspNetUsers]'))
    BEGIN
        ALTER TABLE [TicketCollaborators] ADD CONSTRAINT [FK_TicketCollaborators_AspNetUsers_AddedByUserId] 
            FOREIGN KEY ([AddedByUserId]) REFERENCES [AspNetUsers] ([Id]) ON DELETE NO ACTION;
        ALTER TABLE [TicketCollaborators] ADD CONSTRAINT [FK_TicketCollaborators_AspNetUsers_UserId] 
            FOREIGN KEY ([UserId]) REFERENCES [AspNetUsers] ([Id]) ON DELETE NO ACTION;
    END
    
    IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Tickets]'))
    BEGIN
        ALTER TABLE [TicketCollaborators] ADD CONSTRAINT [FK_TicketCollaborators_Tickets_TicketId] 
            FOREIGN KEY ([TicketId]) REFERENCES [Tickets] ([Id]) ON DELETE CASCADE;
    END
    
    PRINT '   [OK] TicketCollaborators table created'
END
ELSE
BEGIN
    PRINT '   [SKIP] TicketCollaborators table already exists'
END

IF NOT EXISTS (SELECT * FROM __EFMigrationsHistory WHERE MigrationId = '20251030100830_AddTicketCollaborators')
BEGIN
    INSERT INTO __EFMigrationsHistory (MigrationId, ProductVersion) VALUES ('20251030100830_AddTicketCollaborators', '9.0.7');
END
GO

-- ============================================================================
-- MIGRATION 2: UserNotifications Table (20251101075532)
-- ============================================================================
PRINT ''
PRINT '>> Migration 2: UserNotifications Table'

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[UserNotifications]') AND type in (N'U'))
BEGIN
    CREATE TABLE [UserNotifications] (
        [Id] int NOT NULL IDENTITY(1,1),
        [UserId] nvarchar(max) NOT NULL,
        [Title] nvarchar(200) NOT NULL,
        [Message] nvarchar(1000) NOT NULL,
        [Type] nvarchar(50) NOT NULL,
        [IsRead] bit NOT NULL DEFAULT 0,
        [CreatedAt] datetime2 NOT NULL DEFAULT GETUTCDATE(),
        [ActionUrl] nvarchar(500) NULL,
        CONSTRAINT [PK_UserNotifications] PRIMARY KEY ([Id])
    );
    PRINT '   [OK] UserNotifications table created'
END
ELSE
BEGIN
    PRINT '   [SKIP] UserNotifications table already exists'
END

IF NOT EXISTS (SELECT * FROM __EFMigrationsHistory WHERE MigrationId = '20251101075532_AddUserNotifications')
BEGIN
    INSERT INTO __EFMigrationsHistory (MigrationId, ProductVersion) VALUES ('20251101075532_AddUserNotifications', '9.0.7');
END
GO

-- ============================================================================
-- MIGRATION 3: Add EscalationTime to SLAs (20251108052321)
-- ============================================================================
PRINT ''
PRINT '>> Migration 3: Add EscalationTime to SLAs'

IF COL_LENGTH('dbo.SLAs', 'EscalationTime') IS NULL
BEGIN
    ALTER TABLE [SLAs] ADD [EscalationTime] int NULL;
    PRINT '   [OK] EscalationTime column added to SLAs'
END
ELSE
BEGIN
    PRINT '   [SKIP] EscalationTime column already exists'
END

IF NOT EXISTS (SELECT * FROM __EFMigrationsHistory WHERE MigrationId = '20251108052321_AddEscalationTimeToSlaPolicy')
BEGIN
    INSERT INTO __EFMigrationsHistory (MigrationId, ProductVersion) VALUES ('20251108052321_AddEscalationTimeToSlaPolicy', '9.0.7');
END
GO

-- ============================================================================
-- MIGRATION 4: SlaEscalationLevels Table (20251108055623)
-- ============================================================================
PRINT ''
PRINT '>> Migration 4: SlaEscalationLevels Table'

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SlaEscalationLevels]') AND type in (N'U'))
BEGIN
    CREATE TABLE [SlaEscalationLevels] (
        [Id] int NOT NULL IDENTITY(1,1),
        [SlaPolicyId] uniqueidentifier NOT NULL,
        [Level] int NOT NULL,
        [TriggerAtMinutes] int NOT NULL,
        [CreatedAt] datetime2 NOT NULL,
        [UpdatedAt] datetime2 NOT NULL,
        CONSTRAINT [PK_SlaEscalationLevels] PRIMARY KEY ([Id])
    );
    
    CREATE UNIQUE INDEX [IX_SlaEscalationLevels_SlaPolicyId_Level] ON [SlaEscalationLevels] ([SlaPolicyId], [Level]);
    
    IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SLAs]'))
    BEGIN
        ALTER TABLE [SlaEscalationLevels] ADD CONSTRAINT [FK_SlaEscalationLevels_SLAs_SlaPolicyId] 
            FOREIGN KEY ([SlaPolicyId]) REFERENCES [SLAs] ([Id]) ON DELETE CASCADE;
    END
    
    PRINT '   [OK] SlaEscalationLevels table created'
END
ELSE
BEGIN
    PRINT '   [SKIP] SlaEscalationLevels table already exists'
END

IF NOT EXISTS (SELECT * FROM __EFMigrationsHistory WHERE MigrationId = '20251108055623_AddSlaEscalationLevels')
BEGIN
    INSERT INTO __EFMigrationsHistory (MigrationId, ProductVersion) VALUES ('20251108055623_AddSlaEscalationLevels', '9.0.7');
END
GO

-- ============================================================================
-- MIGRATION 5: Add Position and IsAgent to AspNetUsers (20251109065409)
-- ============================================================================
PRINT ''
PRINT '>> Migration 5: Add Position and IsAgent to AspNetUsers'

IF COL_LENGTH('dbo.AspNetUsers', 'IsAgent') IS NULL
BEGIN
    ALTER TABLE [AspNetUsers] ADD [IsAgent] bit NOT NULL DEFAULT 0;
    PRINT '   [OK] IsAgent column added to AspNetUsers'
END
ELSE
BEGIN
    PRINT '   [SKIP] IsAgent column already exists'
END

IF COL_LENGTH('dbo.AspNetUsers', 'Position') IS NULL
BEGIN
    ALTER TABLE [AspNetUsers] ADD [Position] nvarchar(max) NULL;
    PRINT '   [OK] Position column added to AspNetUsers'
END
ELSE
BEGIN
    PRINT '   [SKIP] Position column already exists'
END

IF NOT EXISTS (SELECT * FROM __EFMigrationsHistory WHERE MigrationId = '20251109065409_AddPositionAndIsAgentToUser')
BEGIN
    INSERT INTO __EFMigrationsHistory (MigrationId, ProductVersion) VALUES ('20251109065409_AddPositionAndIsAgentToUser', '9.0.7');
END
GO

-- ============================================================================
-- MIGRATION 6: Add CommentId to Attachments (20251112062557)
-- ============================================================================
PRINT ''
PRINT '>> Migration 6: Add CommentId to Attachments'

IF COL_LENGTH('dbo.Attachments', 'CommentId') IS NULL
BEGIN
    ALTER TABLE [Attachments] ADD [CommentId] uniqueidentifier NULL;
    CREATE INDEX [IX_Attachments_CommentId] ON [Attachments] ([CommentId]);
    
    IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TicketComments]'))
    BEGIN
        ALTER TABLE [Attachments] ADD CONSTRAINT [FK_Attachments_TicketComments_CommentId] 
            FOREIGN KEY ([CommentId]) REFERENCES [TicketComments] ([Id]);
    END
    
    PRINT '   [OK] CommentId column added to Attachments'
END
ELSE
BEGIN
    PRINT '   [SKIP] CommentId column already exists'
END

IF NOT EXISTS (SELECT * FROM __EFMigrationsHistory WHERE MigrationId = '20251112062557_AddCommentIdToAttachments')
BEGIN
    INSERT INTO __EFMigrationsHistory (MigrationId, ProductVersion) VALUES ('20251112062557_AddCommentIdToAttachments', '9.0.7');
END
GO

-- ============================================================================
-- MIGRATION 7: Add IsDeleted to TicketCategories (20251118095603)
-- ============================================================================
PRINT ''
PRINT '>> Migration 7: Add IsDeleted to TicketCategories'

IF COL_LENGTH('dbo.TicketCategories', 'IsDeleted') IS NULL
BEGIN
    ALTER TABLE [TicketCategories] ADD [IsDeleted] bit NOT NULL DEFAULT 0;
    PRINT '   [OK] IsDeleted column added to TicketCategories'
END
ELSE
BEGIN
    PRINT '   [SKIP] IsDeleted column already exists'
END

IF NOT EXISTS (SELECT * FROM __EFMigrationsHistory WHERE MigrationId = '20251118095603_AddIsDeletedToTicketCategories')
BEGIN
    INSERT INTO __EFMigrationsHistory (MigrationId, ProductVersion) VALUES ('20251118095603_AddIsDeletedToTicketCategories', '9.0.7');
END
GO

-- ============================================================================
-- MIGRATION 8: Add IsDeleted to TicketSubCategories (20251118105934)
-- ============================================================================
PRINT ''
PRINT '>> Migration 8: Add IsDeleted to TicketSubCategories'

IF COL_LENGTH('dbo.TicketSubCategories', 'IsDeleted') IS NULL
BEGIN
    ALTER TABLE [TicketSubCategories] ADD [IsDeleted] bit NOT NULL DEFAULT 0;
    PRINT '   [OK] IsDeleted column added to TicketSubCategories'
END
ELSE
BEGIN
    PRINT '   [SKIP] IsDeleted column already exists'
END

IF NOT EXISTS (SELECT * FROM __EFMigrationsHistory WHERE MigrationId = '20251118105934_AddIsDeletedToTicketSubCategories')
BEGIN
    INSERT INTO __EFMigrationsHistory (MigrationId, ProductVersion) VALUES ('20251118105934_AddIsDeletedToTicketSubCategories', '9.0.7');
END
GO

-- ============================================================================
-- MIGRATION 9: Add IsDeleted to CustomFields (20251118125237)
-- ============================================================================
PRINT ''
PRINT '>> Migration 9: Add IsDeleted to CustomFields'

IF COL_LENGTH('dbo.CustomFields', 'IsDeleted') IS NULL
BEGIN
    ALTER TABLE [CustomFields] ADD [IsDeleted] bit NOT NULL DEFAULT 0;
    -- Set IsDeleted = 1 for inactive items
    UPDATE [CustomFields] SET [IsDeleted] = 1 WHERE [IsActive] = 0;
    PRINT '   [OK] IsDeleted column added to CustomFields'
END
ELSE
BEGIN
    PRINT '   [SKIP] IsDeleted column already exists'
END

IF NOT EXISTS (SELECT * FROM __EFMigrationsHistory WHERE MigrationId = '20251118125237_AddIsDeletedToCustomFields')
BEGIN
    INSERT INTO __EFMigrationsHistory (MigrationId, ProductVersion) VALUES ('20251118125237_AddIsDeletedToCustomFields', '9.0.7');
END
GO

-- ============================================================================
-- MIGRATION 10: Add IsDeleted to TicketTags (20251118133008)
-- ============================================================================
PRINT ''
PRINT '>> Migration 10: Add IsDeleted to TicketTags'

IF COL_LENGTH('dbo.TicketTags', 'IsDeleted') IS NULL
BEGIN
    ALTER TABLE [TicketTags] ADD [IsDeleted] bit NOT NULL DEFAULT 0;
    PRINT '   [OK] IsDeleted column added to TicketTags'
END
ELSE
BEGIN
    PRINT '   [SKIP] IsDeleted column already exists'
END

IF NOT EXISTS (SELECT * FROM __EFMigrationsHistory WHERE MigrationId = '20251118133008_AddIsDeletedToTicketTags')
BEGIN
    INSERT INTO __EFMigrationsHistory (MigrationId, ProductVersion) VALUES ('20251118133008_AddIsDeletedToTicketTags', '9.0.7');
END
GO

-- ============================================================================
-- MIGRATION 11: Add IsDeleted to TicketPriorities (20251118135249)
-- ============================================================================
PRINT ''
PRINT '>> Migration 11: Add IsDeleted to TicketPriorities'

IF COL_LENGTH('dbo.TicketPriorities', 'IsDeleted') IS NULL
BEGIN
    ALTER TABLE [TicketPriorities] ADD [IsDeleted] bit NOT NULL DEFAULT 0;
    PRINT '   [OK] IsDeleted column added to TicketPriorities'
END
ELSE
BEGIN
    PRINT '   [SKIP] IsDeleted column already exists'
END

IF NOT EXISTS (SELECT * FROM __EFMigrationsHistory WHERE MigrationId = '20251118135249_AddIsDeletedToTicketPriorities')
BEGIN
    INSERT INTO __EFMigrationsHistory (MigrationId, ProductVersion) VALUES ('20251118135249_AddIsDeletedToTicketPriorities', '9.0.7');
END
GO

-- ============================================================================
-- MIGRATION 12: Add Auto-Assignment fields to TicketGroups (20251119120114)
-- ============================================================================
PRINT ''
PRINT '>> Migration 12: Add Auto-Assignment fields to TicketGroups'

IF COL_LENGTH('dbo.TicketGroups', 'AutoAssignmentEnabled') IS NULL
BEGIN
    ALTER TABLE [TicketGroups] ADD [AutoAssignmentEnabled] bit NOT NULL DEFAULT 0;
    PRINT '   [OK] AutoAssignmentEnabled column added to TicketGroups'
END
ELSE
BEGIN
    PRINT '   [SKIP] AutoAssignmentEnabled column already exists'
END

IF COL_LENGTH('dbo.TicketGroups', 'MaxTicketsPerAgent') IS NULL
BEGIN
    ALTER TABLE [TicketGroups] ADD [MaxTicketsPerAgent] int NOT NULL DEFAULT 0;
    PRINT '   [OK] MaxTicketsPerAgent column added to TicketGroups'
END
ELSE
BEGIN
    PRINT '   [SKIP] MaxTicketsPerAgent column already exists'
END

IF NOT EXISTS (SELECT * FROM __EFMigrationsHistory WHERE MigrationId = '20251119120114_AddAutoAssignmentFieldsToTicketGroups')
BEGIN
    INSERT INTO __EFMigrationsHistory (MigrationId, ProductVersion) VALUES ('20251119120114_AddAutoAssignmentFieldsToTicketGroups', '9.0.7');
END
GO

-- ============================================================================
-- MIGRATION 13: Add IsDeleted to TicketGroups (20251119130357)
-- ============================================================================
PRINT ''
PRINT '>> Migration 13: Add IsDeleted to TicketGroups'

IF COL_LENGTH('dbo.TicketGroups', 'IsDeleted') IS NULL
BEGIN
    ALTER TABLE [TicketGroups] ADD [IsDeleted] bit NOT NULL DEFAULT 0;
    PRINT '   [OK] IsDeleted column added to TicketGroups'
END
ELSE
BEGIN
    PRINT '   [SKIP] IsDeleted column already exists'
END

IF NOT EXISTS (SELECT * FROM __EFMigrationsHistory WHERE MigrationId = '20251119130357_AddIsDeletedToTicketGroups')
BEGIN
    INSERT INTO __EFMigrationsHistory (MigrationId, ProductVersion) VALUES ('20251119130357_AddIsDeletedToTicketGroups', '9.0.7');
END
GO

-- ============================================================================
-- MIGRATION 14: Add IsDeleted to TicketStatuses (20251121114646)
-- ============================================================================
PRINT ''
PRINT '>> Migration 14: Add IsDeleted to TicketStatuses'

IF COL_LENGTH('dbo.TicketStatuses', 'IsDeleted') IS NULL
BEGIN
    ALTER TABLE [TicketStatuses] ADD [IsDeleted] bit NOT NULL CONSTRAINT DF_TicketStatuses_IsDeleted DEFAULT(0);
    PRINT '   [OK] IsDeleted column added to TicketStatuses'
END
ELSE
BEGIN
    PRINT '   [SKIP] IsDeleted column already exists'
END

IF NOT EXISTS (SELECT * FROM __EFMigrationsHistory WHERE MigrationId = '20251121114646_AddIsDeletedFlagToTicketStatuses')
BEGIN
    INSERT INTO __EFMigrationsHistory (MigrationId, ProductVersion) VALUES ('20251121114646_AddIsDeletedFlagToTicketStatuses', '9.0.7');
END
GO

-- ============================================================================
-- MIGRATION 15: Add IsDeleted to SlaPolicies/SLAs (20251119123000)
-- ============================================================================
PRINT ''
PRINT '>> Migration 15: Add IsDeleted to SLAs'

IF COL_LENGTH('dbo.SLAs', 'IsDeleted') IS NULL
BEGIN
    ALTER TABLE [SLAs] ADD [IsDeleted] bit NOT NULL DEFAULT 0;
    PRINT '   [OK] IsDeleted column added to SLAs'
END
ELSE
BEGIN
    PRINT '   [SKIP] IsDeleted column already exists'
END

IF NOT EXISTS (SELECT * FROM __EFMigrationsHistory WHERE MigrationId = '20251119123000_AddIsDeletedToSlaPolicies')
BEGIN
    INSERT INTO __EFMigrationsHistory (MigrationId, ProductVersion) VALUES ('20251119123000_AddIsDeletedToSlaPolicies', '9.0.7');
END
GO

-- ============================================================================
-- VERIFICATION: Check all migrations applied
-- ============================================================================
PRINT ''
PRINT '=============================================='
PRINT 'Migration Verification'
PRINT '=============================================='
PRINT ''

SELECT MigrationId, ProductVersion 
FROM __EFMigrationsHistory 
WHERE MigrationId LIKE '202510%' OR MigrationId LIKE '202511%'
ORDER BY MigrationId;

PRINT ''
PRINT '=============================================='
PRINT 'Production Migration Complete!'
PRINT '=============================================='
