-- Insert dummy users
INSERT INTO Users (Id, UserName, NormalizedUserName, Email, NormalizedEmail, EmailConfirmed, PasswordHash, SecurityStamp, ConcurrencyStamp, PhoneNumber, PhoneNumberConfirmed, TwoFactorEnabled, LockoutEnd, LockoutEnabled, AccessFailedCount, FirstName, LastName, Department, JoinDate, Avatar, IsActive, CreatedAt, UpdatedAt)
VALUES
('1', 'jdoe', 'JDOE', 'jdoe@example.com', 'JDOE@EXAMPLE.COM', 1, 'dummyhash', 'sec1', 'con1', '1234567890', 1, 0, NULL, 0, 0, 'John', 'Doe', 'IT', '2023-01-01', NULL, 1, GETDATE(), GETDATE()),
('2', 'asmith', 'ASMITH', 'asmith@example.com', 'ASMITH@EXAMPLE.COM', 1, 'dummyhash', 'sec2', 'con2', '0987654321', 1, 0, NULL, 0, 0, 'Alice', 'Smith', 'HR', '2023-02-01', NULL, 1, GETDATE(), GETDATE());

-- Insert dummy modules
INSERT INTO Modules (Title, Description, Icon, Category, Color, EstimatedTime, Difficulty, Prerequisites, LearningObjectives, IsActive, [Order], CreatedAt, UpdatedAt)
VALUES
('Import Management', 'Learn about import management processes', 'import-icon', 'Logistics', 'blue', '2h', 'Medium', '', 'Understand import basics', 1, 1, GETDATE(), GETDATE()),
('Compliance', 'Compliance and documentation', 'compliance-icon', 'Legal', 'green', '1.5h', 'Easy', '', 'Understand compliance', 1, 2, GETDATE(), GETDATE());

-- Insert dummy sections
INSERT INTO Sections (Title, Description, ModuleId, [Order], IsActive, CreatedAt, UpdatedAt)
VALUES
('Introduction', 'Intro to import management', 1, 1, 1, GETDATE(), GETDATE()),
('Advanced Topics', 'Deep dive into compliance', 2, 1, 1, GETDATE(), GETDATE());

-- Insert dummy lessons
INSERT INTO Lessons (Title, Description, Type, Duration, SectionId, [Order], IsActive, VideoUrl, DocumentContent, ScribeLink, InteractiveSteps, HasAssessment, CreatedAt, UpdatedAt)
VALUES
('Lesson 1', 'Basics of import', 0, '30m', 1, 1, 1, NULL, 'Content for lesson 1', NULL, '', 1, GETDATE(), GETDATE()),
('Lesson 2', 'Compliance overview', 1, '45m', 2, 1, 1, NULL, 'Content for lesson 2', NULL, '', 1, GETDATE(), GETDATE());

-- Insert dummy assessments
INSERT INTO Assessments (Title, Description, ModuleId, SectionId, LessonId, PassingScore, TimeLimit, MaxAttempts, IsActive, IsRequired, TriggerType, CreatedAt, UpdatedAt)
VALUES
('Assessment 1', 'Test your import knowledge', 1, 1, 1, 70, 30, 3, 1, 1, 0, GETDATE(), GETDATE()),
('Assessment 2', 'Compliance test', 2, 2, 2, 80, 45, 2, 1, 0, 1, GETDATE(), GETDATE());
