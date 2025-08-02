-- Manual SQL script to insert Operations-Sea role permissions
-- This will directly insert the 25 permissions needed for the Operations-Sea role

DECLARE @OperationsSeaRoleId NVARCHAR(450) = '421d70ba-b799-4b6f-b4bf-41fcda2bb361'

-- Insert the 25 permissions for Operations-Sea role as defined in Role 10 mapping

-- Module 1 permissions (20 sections)
INSERT INTO RoleModuleAccess (RoleId, ModuleId, SectionId, IsActive, ErpRoleId, ErpModuleId, ErpSectionId, CreatedAt, UpdatedAt)
VALUES 
(@OperationsSeaRoleId, 1, 305, 1, '10', '1', '305', GETUTCDATE(), GETUTCDATE()),
(@OperationsSeaRoleId, 1, 307, 1, '10', '1', '307', GETUTCDATE(), GETUTCDATE()),
(@OperationsSeaRoleId, 1, 308, 1, '10', '1', '308', GETUTCDATE(), GETUTCDATE()),
(@OperationsSeaRoleId, 1, 516, 1, '10', '1', '516', GETUTCDATE(), GETUTCDATE()),
(@OperationsSeaRoleId, 1, 517, 1, '10', '1', '517', GETUTCDATE(), GETUTCDATE()),
(@OperationsSeaRoleId, 1, 318, 1, '10', '1', '318', GETUTCDATE(), GETUTCDATE()),
(@OperationsSeaRoleId, 1, 333, 1, '10', '1', '333', GETUTCDATE(), GETUTCDATE()),
(@OperationsSeaRoleId, 1, 304, 1, '10', '1', '304', GETUTCDATE(), GETUTCDATE()),
(@OperationsSeaRoleId, 1, 340, 1, '10', '1', '340', GETUTCDATE(), GETUTCDATE()),
(@OperationsSeaRoleId, 1, 605, 1, '10', '1', '605', GETUTCDATE(), GETUTCDATE()),
(@OperationsSeaRoleId, 1, 360, 1, '10', '1', '360', GETUTCDATE(), GETUTCDATE()),
(@OperationsSeaRoleId, 1, 361, 1, '10', '1', '361', GETUTCDATE(), GETUTCDATE()),
(@OperationsSeaRoleId, 1, 362, 1, '10', '1', '362', GETUTCDATE(), GETUTCDATE()),
(@OperationsSeaRoleId, 1, 363, 1, '10', '1', '363', GETUTCDATE(), GETUTCDATE()),
(@OperationsSeaRoleId, 1, 344, 1, '10', '1', '344', GETUTCDATE(), GETUTCDATE()),
(@OperationsSeaRoleId, 1, 519, 1, '10', '1', '519', GETUTCDATE(), GETUTCDATE()),
(@OperationsSeaRoleId, 1, 521, 1, '10', '1', '521', GETUTCDATE(), GETUTCDATE()),
(@OperationsSeaRoleId, 1, 401, 1, '10', '1', '401', GETUTCDATE(), GETUTCDATE()),
(@OperationsSeaRoleId, 1, 312, 1, '10', '1', '312', GETUTCDATE(), GETUTCDATE()),
(@OperationsSeaRoleId, 1, 311, 1, '10', '1', '311', GETUTCDATE(), GETUTCDATE()),

-- Module 4 permissions (5 sections)
(@OperationsSeaRoleId, 4, 3001, 1, '10', '4', '3001', GETUTCDATE(), GETUTCDATE()),
(@OperationsSeaRoleId, 4, 3021, 1, '10', '4', '3021', GETUTCDATE(), GETUTCDATE()),
(@OperationsSeaRoleId, 4, 3040, 1, '10', '4', '3040', GETUTCDATE(), GETUTCDATE()),
(@OperationsSeaRoleId, 4, 3041, 1, '10', '4', '3041', GETUTCDATE(), GETUTCDATE()),
(@OperationsSeaRoleId, 4, 7001, 1, '10', '4', '7001', GETUTCDATE(), GETUTCDATE())

-- This gives Operations-Sea role access to 25 sections total (20 from Module 1 + 5 from Module 4)
