-- =============================================
-- Seed Initial Data for ERP Training Platform
-- =============================================

USE ERPTrainingDB;
GO

-- =============================================
-- Seed Roles
-- =============================================

INSERT INTO AspNetRoles (Id, Name, NormalizedName, ConcurrencyStamp)
VALUES 
    (NEWID(), 'Admin', 'ADMIN', NEWID()),
    (NEWID(), 'QA', 'QA', NEWID()),
    (NEWID(), 'User', 'USER', NEWID()),
    (NEWID(), 'Manager', 'MANAGER', NEWID()),
    (NEWID(), 'Supervisor', 'SUPERVISOR', NEWID());

-- =============================================
-- Seed Sample Users (Passwords need to be hashed by the application)
-- =============================================

-- Note: These users will be created by the application's seed data
-- with proper password hashing. This is just the schema preparation.

-- =============================================
-- Seed Sample Modules
-- =============================================

INSERT INTO Modules (Title, Description, Icon, Category, Color, EstimatedTime, Difficulty, Prerequisites, LearningObjectives, IsActive, [Order])
VALUES 
    ('Import Management', 'Learn the fundamentals of import management, documentation, and compliance procedures.', 'Package', 'Trade Operations', 'blue', '2-3 hours', 'Beginner', '[]', '["Understand import documentation requirements", "Learn compliance procedures", "Master import cost calculations"]', 1, 1),
    ('Export Operations', 'Master export procedures, documentation, and international shipping requirements.', 'Truck', 'Trade Operations', 'green', '2-3 hours', 'Intermediate', '["1"]', '["Understand export documentation", "Learn shipping procedures", "Master export regulations"]', 1, 2),
    ('Freight Management', 'Learn freight booking, tracking, and cost optimization strategies.', 'Ship', 'Logistics', 'purple', '1-2 hours', 'Intermediate', '["1", "2"]', '["Master freight booking procedures", "Understand shipping modes", "Learn cost optimization"]', 1, 3),
    ('Inventory Control', 'Optimize inventory levels, tracking, and warehouse management.', 'Archive', 'Operations', 'orange', '1-2 hours', 'Beginner', '[]', '["Learn inventory optimization", "Master stock tracking", "Understand warehouse management"]', 1, 4),
    ('Financial Reports', 'Generate insights through comprehensive reporting and data analysis.', 'BarChart3', 'Finance', 'red', '1-2 hours', 'Advanced', '["1", "2", "3", "4"]', '["Master report generation", "Learn data analysis", "Understand KPI tracking"]', 1, 5),
    ('Customer Management', 'Build and maintain strong customer relationships and communication.', 'Users', 'CRM', 'indigo', '1 hour', 'Beginner', '[]', '["Learn customer communication", "Master relationship building", "Understand service excellence"]', 1, 6);

-- =============================================
-- Seed Sample Sections
-- =============================================

DECLARE @ImportModuleId INT = (SELECT Id FROM Modules WHERE Title = 'Import Management');
DECLARE @ExportModuleId INT = (SELECT Id FROM Modules WHERE Title = 'Export Operations');
DECLARE @FreightModuleId INT = (SELECT Id FROM Modules WHERE Title = 'Freight Management');
DECLARE @InventoryModuleId INT = (SELECT Id FROM Modules WHERE Title = 'Inventory Control');
DECLARE @FinanceModuleId INT = (SELECT Id FROM Modules WHERE Title = 'Financial Reports');
DECLARE @CustomerModuleId INT = (SELECT Id FROM Modules WHERE Title = 'Customer Management');

INSERT INTO Sections (Title, Description, ModuleId, [Order], IsActive)
VALUES 
    -- Import Management Sections
    ('Import Fundamentals', 'Basic concepts and terminology', @ImportModuleId, 1, 1),
    ('Documentation & Compliance', 'Required documents and regulatory compliance', @ImportModuleId, 2, 1),
    ('Customs Procedures', 'Understanding customs clearance processes', @ImportModuleId, 3, 1),
    
    -- Export Operations Sections
    ('Export Basics', 'Fundamental export concepts', @ExportModuleId, 1, 1),
    ('International Regulations', 'Export compliance and international trade rules', @ExportModuleId, 2, 1),
    ('Shipping Documentation', 'Export documentation requirements', @ExportModuleId, 3, 1),
    
    -- Freight Management Sections
    ('Freight Booking', 'Booking and managing freight shipments', @FreightModuleId, 1, 1),
    ('Cost Optimization', 'Strategies for reducing freight costs', @FreightModuleId, 2, 1),
    ('Tracking & Monitoring', 'Shipment tracking and status monitoring', @FreightModuleId, 3, 1),
    
    -- Inventory Control Sections
    ('Stock Management', 'Managing inventory and stock levels', @InventoryModuleId, 1, 1),
    ('Warehouse Operations', 'Warehouse management best practices', @InventoryModuleId, 2, 1),
    ('Inventory Analytics', 'Data-driven inventory decisions', @InventoryModuleId, 3, 1),
    
    -- Financial Reports Sections
    ('Report Generation', 'Creating and customizing reports', @FinanceModuleId, 1, 1),
    ('Data Analysis', 'Analyzing financial data and trends', @FinanceModuleId, 2, 1),
    ('KPI Tracking', 'Key performance indicators and metrics', @FinanceModuleId, 3, 1),
    
    -- Customer Management Sections
    ('Customer Data', 'Managing customer information and profiles', @CustomerModuleId, 1, 1),
    ('Relationship Management', 'Building and maintaining customer relationships', @CustomerModuleId, 2, 1),
    ('Communication Tools', 'Effective customer communication strategies', @CustomerModuleId, 3, 1);

-- =============================================
-- Seed Sample Lessons
-- =============================================

DECLARE @ImportFundamentalsId INT = (SELECT Id FROM Sections WHERE Title = 'Import Fundamentals');
DECLARE @DocumentationComplianceId INT = (SELECT Id FROM Sections WHERE Title = 'Documentation & Compliance');
DECLARE @ExportBasicsId INT = (SELECT Id FROM Sections WHERE Title = 'Export Basics');
DECLARE @FreightBookingId INT = (SELECT Id FROM Sections WHERE Title = 'Freight Booking');

INSERT INTO Lessons (Title, Description, Type, Duration, SectionId, [Order], IsActive, VideoUrl, DocumentContent, HasAssessment)
VALUES 
    -- Import Fundamentals Lessons
    ('Introduction to Import Management', 'Overview of import processes and key stakeholders', 0, '15 min', @ImportFundamentalsId, 1, 1, 'https://www.youtube.com/embed/example', NULL, 0),
    ('Import Terminology', 'Key terms and definitions in import management', 1, '10 min', @ImportFundamentalsId, 2, 1, NULL, '<h3>Import Terminology</h3><p>Key terms and definitions used in import management...</p>', 0),
    ('Import Process Overview', 'Step-by-step import process walkthrough', 2, '20 min', @ImportFundamentalsId, 3, 1, NULL, NULL, 1),
    
    -- Documentation & Compliance Lessons
    ('Required Import Documents', 'Essential documents for import operations', 1, '25 min', @DocumentationComplianceId, 1, 1, NULL, '<h3>Required Documents</h3><p>Essential import documents and their purposes...</p>', 0),
    ('Compliance Procedures', 'Regulatory compliance and best practices', 0, '30 min', @DocumentationComplianceId, 2, 1, 'https://www.youtube.com/embed/compliance', NULL, 1),
    
    -- Export Basics Lessons
    ('Export Fundamentals', 'Basic export procedures and requirements', 0, '20 min', @ExportBasicsId, 1, 1, 'https://www.youtube.com/embed/export-basics', NULL, 0),
    ('Export Documentation', 'Understanding export documentation requirements', 1, '25 min', @ExportBasicsId, 2, 1, NULL, '<h3>Export Documentation</h3><p>Key documents required for export operations...</p>', 1),
    
    -- Freight Booking Lessons
    ('Freight Booking Procedures', 'How to book and manage freight shipments', 0, '25 min', @FreightBookingId, 1, 1, 'https://www.youtube.com/embed/freight-booking', NULL, 0),
    ('Carrier Selection', 'Choosing the right freight carrier', 1, '15 min', @FreightBookingId, 2, 1, NULL, '<h3>Carrier Selection</h3><p>Factors to consider when selecting freight carriers...</p>', 0);

-- =============================================
-- Seed Sample Assessments
-- =============================================

INSERT INTO Assessments (Title, Description, ModuleId, SectionId, PassingScore, TimeLimit, MaxAttempts, IsActive, IsRequired, TriggerType)
VALUES 
    ('Import Management Fundamentals Quiz', 'Test your understanding of basic import concepts and procedures', @ImportModuleId, @ImportFundamentalsId, 70, 30, 3, 1, 1, 0),
    ('Documentation & Compliance Assessment', 'Evaluate your knowledge of import documentation and compliance requirements', @ImportModuleId, @DocumentationComplianceId, 80, 45, 3, 1, 1, 0),
    ('Export Operations Final Exam', 'Comprehensive exam covering all export procedures and international regulations', @ExportModuleId, NULL, 80, 60, 2, 1, 0, 1),
    ('Freight Management Quiz', 'Assessment on freight booking, tracking, and cost optimization', @FreightModuleId, @FreightBookingId, 70, 25, 3, 1, 0, 0);

-- =============================================
-- Seed Sample Questions
-- =============================================

DECLARE @ImportQuizId INT = (SELECT Id FROM Assessments WHERE Title = 'Import Management Fundamentals Quiz');
DECLARE @ComplianceAssessmentId INT = (SELECT Id FROM Assessments WHERE Title = 'Documentation & Compliance Assessment');
DECLARE @ExportExamId INT = (SELECT Id FROM Assessments WHERE Title = 'Export Operations Final Exam');

INSERT INTO Questions (AssessmentId, Type, QuestionText, Options, CorrectAnswers, Explanation, Points, [Order])
VALUES 
    -- Import Management Fundamentals Quiz Questions
    (@ImportQuizId, 0, 'What is the primary purpose of a Bill of Lading in import operations?', 
     '["To calculate customs duties", "To serve as a receipt and contract for transportation", "To determine product quality", "To set the selling price"]', 
     '["To serve as a receipt and contract for transportation"]', 
     'A Bill of Lading serves as a receipt for goods shipped, a contract between the shipper and carrier, and a document of title.', 
     5, 1),
    
    (@ImportQuizId, 2, 'All imported goods must go through customs inspection regardless of their value.', 
     '[]', 
     '["false"]', 
     'Not all goods require physical inspection. Many are cleared through automated systems based on risk assessment.', 
     3, 2),
    
    (@ImportQuizId, 0, 'Which document is required to prove the origin of imported goods?', 
     '["Commercial Invoice", "Certificate of Origin", "Packing List", "Insurance Certificate"]', 
     '["Certificate of Origin"]', 
     'A Certificate of Origin proves where goods were manufactured and may affect duty rates under trade agreements.', 
     5, 3),
    
    (@ImportQuizId, 3, 'What does "CIF" stand for in international trade terms?', 
     '[]', 
     '["Cost, Insurance, and Freight"]', 
     'CIF means the seller pays for cost, insurance, and freight to deliver goods to the destination port.', 
     4, 4),
    
    -- Documentation & Compliance Assessment Questions
    (@ComplianceAssessmentId, 0, 'What is the purpose of an Import License?', 
     '["To track shipment location", "To authorize the import of restricted goods", "To calculate shipping costs", "To determine product quality"]', 
     '["To authorize the import of restricted goods"]', 
     'Import licenses are required for certain restricted or controlled goods to ensure compliance with regulations.', 
     5, 1),
    
    (@ComplianceAssessmentId, 2, 'A Commercial Invoice must always include the country of origin.', 
     '[]', 
     '["true"]', 
     'The country of origin is a mandatory field on commercial invoices for customs clearance purposes.', 
     3, 2),
    
    -- Export Operations Final Exam Questions
    (@ExportExamId, 0, 'Which export document serves as a contract between the exporter and carrier?', 
     '["Export License", "Bill of Lading", "Certificate of Origin", "Commercial Invoice"]', 
     '["Bill of Lading"]', 
     'The Bill of Lading serves as both a receipt and contract for the transportation of goods.', 
     10, 1),
    
    (@ExportExamId, 4, 'Explain the key differences between FOB and CIF terms in export operations.', 
     '[]', 
     '["FOB (Free on Board) means the seller delivers goods to the port and the buyer assumes responsibility from there. CIF (Cost, Insurance, Freight) means the seller pays for shipping and insurance to the destination port."]', 
     'Understanding these terms is crucial for determining responsibility and costs in international trade.', 
     15, 2);

-- =============================================
-- Create Views for Reporting
-- =============================================

-- View for Module Progress Summary
CREATE VIEW vw_ModuleProgressSummary AS
SELECT 
    m.Id AS ModuleId,
    m.Title AS ModuleTitle,
    m.Category,
    m.Difficulty,
    COUNT(DISTINCT s.Id) AS TotalSections,
    COUNT(DISTINCT l.Id) AS TotalLessons,
    COUNT(DISTINCT a.Id) AS TotalAssessments,
    COUNT(DISTINCT ump.UserId) AS EnrolledUsers,
    COUNT(DISTINCT CASE WHEN ump.IsCompleted = 1 THEN ump.UserId END) AS CompletedUsers
FROM Modules m
LEFT JOIN Sections s ON m.Id = s.ModuleId AND s.IsActive = 1
LEFT JOIN Lessons l ON s.Id = l.SectionId AND l.IsActive = 1
LEFT JOIN Assessments a ON m.Id = a.ModuleId AND a.IsActive = 1
LEFT JOIN UserModuleProgress ump ON m.Id = ump.ModuleId
WHERE m.IsActive = 1
GROUP BY m.Id, m.Title, m.Category, m.Difficulty;

-- View for Assessment Performance
CREATE VIEW vw_AssessmentPerformance AS
SELECT 
    a.Id AS AssessmentId,
    a.Title AS AssessmentTitle,
    m.Title AS ModuleTitle,
    s.Title AS SectionTitle,
    a.PassingScore,
    COUNT(DISTINCT aa.UserId) AS TotalAttempts,
    COUNT(DISTINCT CASE WHEN aa.Passed = 1 THEN aa.UserId END) AS PassedUsers,
    AVG(CAST(aa.Score AS FLOAT)) AS AverageScore,
    MAX(aa.Score) AS HighestScore,
    MIN(aa.Score) AS LowestScore
FROM Assessments a
LEFT JOIN Modules m ON a.ModuleId = m.Id
LEFT JOIN Sections s ON a.SectionId = s.Id
LEFT JOIN AssessmentAttempts aa ON a.Id = aa.AssessmentId AND aa.Status = 1 -- Completed
WHERE a.IsActive = 1
GROUP BY a.Id, a.Title, m.Title, s.Title, a.PassingScore;

-- View for User Learning Progress
CREATE VIEW vw_UserLearningProgress AS
SELECT 
    u.Id AS UserId,
    u.FirstName + ' ' + u.LastName AS FullName,
    u.Department,
    COUNT(DISTINCT ump.ModuleId) AS ModulesStarted,
    COUNT(DISTINCT CASE WHEN ump.IsCompleted = 1 THEN ump.ModuleId END) AS ModulesCompleted,
    COUNT(DISTINCT ulp.LessonId) AS LessonsStarted,
    COUNT(DISTINCT CASE WHEN ulp.IsCompleted = 1 THEN ulp.LessonId END) AS LessonsCompleted,
    COUNT(DISTINCT aa.AssessmentId) AS AssessmentsTaken,
    COUNT(DISTINCT CASE WHEN aa.Passed = 1 THEN aa.AssessmentId END) AS AssessmentsPassed
FROM AspNetUsers u
LEFT JOIN UserModuleProgress ump ON u.Id = ump.UserId
LEFT JOIN UserLessonProgress ulp ON u.Id = ulp.UserId
LEFT JOIN AssessmentAttempts aa ON u.Id = aa.UserId AND aa.Status = 1 -- Completed
WHERE u.IsActive = 1
GROUP BY u.Id, u.FirstName, u.LastName, u.Department;

GO

-- =============================================
-- Create Stored Procedures for Common Operations
-- =============================================

-- Procedure to calculate user progress for a module
CREATE PROCEDURE sp_CalculateUserModuleProgress
    @UserId NVARCHAR(450),
    @ModuleId INT
AS
BEGIN
    DECLARE @TotalLessons INT;
    DECLARE @CompletedLessons INT;
    DECLARE @ProgressPercentage INT;
    
    -- Get total lessons in the module
    SELECT @TotalLessons = COUNT(*)
    FROM Lessons l
    INNER JOIN Sections s ON l.SectionId = s.Id
    WHERE s.ModuleId = @ModuleId AND l.IsActive = 1 AND s.IsActive = 1;
    
    -- Get completed lessons by user
    SELECT @CompletedLessons = COUNT(*)
    FROM UserLessonProgress ulp
    INNER JOIN Lessons l ON ulp.LessonId = l.Id
    INNER JOIN Sections s ON l.SectionId = s.Id
    WHERE s.ModuleId = @ModuleId AND ulp.UserId = @UserId AND ulp.IsCompleted = 1;
    
    -- Calculate percentage
    IF @TotalLessons > 0
        SET @ProgressPercentage = (@CompletedLessons * 100) / @TotalLessons;
    ELSE
        SET @ProgressPercentage = 0;
    
    -- Update or insert progress record
    IF EXISTS (SELECT 1 FROM UserModuleProgress WHERE UserId = @UserId AND ModuleId = @ModuleId)
    BEGIN
        UPDATE UserModuleProgress 
        SET CompletionPercentage = @ProgressPercentage,
            IsCompleted = CASE WHEN @ProgressPercentage = 100 THEN 1 ELSE 0 END,
            CompletedAt = CASE WHEN @ProgressPercentage = 100 THEN GETUTCDATE() ELSE NULL END,
            UpdatedAt = GETUTCDATE()
        WHERE UserId = @UserId AND ModuleId = @ModuleId;
    END
    ELSE
    BEGIN
        INSERT INTO UserModuleProgress (UserId, ModuleId, CompletionPercentage, IsCompleted, CompletedAt, StartedAt, UpdatedAt)
        VALUES (@UserId, @ModuleId, @ProgressPercentage, 
                CASE WHEN @ProgressPercentage = 100 THEN 1 ELSE 0 END,
                CASE WHEN @ProgressPercentage = 100 THEN GETUTCDATE() ELSE NULL END,
                GETUTCDATE(), GETUTCDATE());
    END
    
    SELECT @ProgressPercentage AS ProgressPercentage;
END;

GO

-- Procedure to get user dashboard data
CREATE PROCEDURE sp_GetUserDashboard
    @UserId NVARCHAR(450)
AS
BEGIN
    -- User's module progress
    SELECT 
        m.Id,
        m.Title,
        m.Description,
        m.Icon,
        m.Category,
        m.Color,
        m.EstimatedTime,
        m.Difficulty,
        ISNULL(ump.CompletionPercentage, 0) AS Progress,
        ISNULL(ump.IsCompleted, 0) AS IsCompleted
    FROM Modules m
    LEFT JOIN UserModuleProgress ump ON m.Id = ump.ModuleId AND ump.UserId = @UserId
    WHERE m.IsActive = 1
    ORDER BY m.[Order];
    
    -- Recent assessment attempts
    SELECT TOP 5
        a.Title AS AssessmentTitle,
        m.Title AS ModuleTitle,
        aa.Score,
        aa.Passed,
        aa.CompletedAt
    FROM AssessmentAttempts aa
    INNER JOIN Assessments a ON aa.AssessmentId = a.Id
    INNER JOIN Modules m ON a.ModuleId = m.Id
    WHERE aa.UserId = @UserId AND aa.Status = 1 -- Completed
    ORDER BY aa.CompletedAt DESC;
    
    -- Overall statistics
    SELECT 
        COUNT(DISTINCT ump.ModuleId) AS ModulesStarted,
        COUNT(DISTINCT CASE WHEN ump.IsCompleted = 1 THEN ump.ModuleId END) AS ModulesCompleted,
        COUNT(DISTINCT aa.AssessmentId) AS AssessmentsTaken,
        COUNT(DISTINCT CASE WHEN aa.Passed = 1 THEN aa.AssessmentId END) AS AssessmentsPassed
    FROM UserModuleProgress ump
    FULL OUTER JOIN AssessmentAttempts aa ON ump.UserId = aa.UserId AND aa.Status = 1
    WHERE ump.UserId = @UserId OR aa.UserId = @UserId;
END;

GO

PRINT 'ERP Training Platform database schema created successfully!';
PRINT 'Database includes:';
PRINT '- Complete ASP.NET Core Identity tables';
PRINT '- Training platform tables (Modules, Sections, Lessons, Assessments, Questions)';
PRINT '- User progress tracking tables';
PRINT '- Performance indexes';
PRINT '- Sample data for testing';
PRINT '- Reporting views';
PRINT '- Stored procedures for common operations';
PRINT '';
PRINT 'Next steps:';
PRINT '1. Update connection string in appsettings.json';
PRINT '2. Run Entity Framework migrations';
PRINT '3. Start the .NET 8 API application';