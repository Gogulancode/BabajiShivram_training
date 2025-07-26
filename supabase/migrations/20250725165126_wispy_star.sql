-- =============================================
-- Create Tables for ERP Training Platform
-- =============================================

USE ERPTrainingDB;
GO

-- =============================================
-- Identity Tables (ASP.NET Core Identity)
-- =============================================

-- AspNetRoles
CREATE TABLE AspNetRoles (
    Id NVARCHAR(450) NOT NULL PRIMARY KEY,
    Name NVARCHAR(256) NULL,
    NormalizedName NVARCHAR(256) NULL,
    ConcurrencyStamp NVARCHAR(MAX) NULL
);

-- AspNetUsers
CREATE TABLE AspNetUsers (
    Id NVARCHAR(450) NOT NULL PRIMARY KEY,
    UserName NVARCHAR(256) NULL,
    NormalizedUserName NVARCHAR(256) NULL,
    Email NVARCHAR(256) NULL,
    NormalizedEmail NVARCHAR(256) NULL,
    EmailConfirmed BIT NOT NULL,
    PasswordHash NVARCHAR(MAX) NULL,
    SecurityStamp NVARCHAR(MAX) NULL,
    ConcurrencyStamp NVARCHAR(MAX) NULL,
    PhoneNumber NVARCHAR(MAX) NULL,
    PhoneNumberConfirmed BIT NOT NULL,
    TwoFactorEnabled BIT NOT NULL,
    LockoutEnd DATETIMEOFFSET(7) NULL,
    LockoutEnabled BIT NOT NULL,
    AccessFailedCount INT NOT NULL,
    
    -- Custom User Properties
    FirstName NVARCHAR(100) NOT NULL DEFAULT '',
    LastName NVARCHAR(100) NOT NULL DEFAULT '',
    Department NVARCHAR(100) NOT NULL DEFAULT '',
    JoinDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    Avatar NVARCHAR(500) NULL,
    IsActive BIT NOT NULL DEFAULT 1,
    CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    UpdatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE()
);

-- AspNetUserRoles
CREATE TABLE AspNetUserRoles (
    UserId NVARCHAR(450) NOT NULL,
    RoleId NVARCHAR(450) NOT NULL,
    PRIMARY KEY (UserId, RoleId),
    FOREIGN KEY (UserId) REFERENCES AspNetUsers(Id) ON DELETE CASCADE,
    FOREIGN KEY (RoleId) REFERENCES AspNetRoles(Id) ON DELETE CASCADE
);

-- AspNetUserClaims
CREATE TABLE AspNetUserClaims (
    Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    UserId NVARCHAR(450) NOT NULL,
    ClaimType NVARCHAR(MAX) NULL,
    ClaimValue NVARCHAR(MAX) NULL,
    FOREIGN KEY (UserId) REFERENCES AspNetUsers(Id) ON DELETE CASCADE
);

-- AspNetUserLogins
CREATE TABLE AspNetUserLogins (
    LoginProvider NVARCHAR(450) NOT NULL,
    ProviderKey NVARCHAR(450) NOT NULL,
    ProviderDisplayName NVARCHAR(MAX) NULL,
    UserId NVARCHAR(450) NOT NULL,
    PRIMARY KEY (LoginProvider, ProviderKey),
    FOREIGN KEY (UserId) REFERENCES AspNetUsers(Id) ON DELETE CASCADE
);

-- AspNetUserTokens
CREATE TABLE AspNetUserTokens (
    UserId NVARCHAR(450) NOT NULL,
    LoginProvider NVARCHAR(450) NOT NULL,
    Name NVARCHAR(450) NOT NULL,
    Value NVARCHAR(MAX) NULL,
    PRIMARY KEY (UserId, LoginProvider, Name),
    FOREIGN KEY (UserId) REFERENCES AspNetUsers(Id) ON DELETE CASCADE
);

-- AspNetRoleClaims
CREATE TABLE AspNetRoleClaims (
    Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    RoleId NVARCHAR(450) NOT NULL,
    ClaimType NVARCHAR(MAX) NULL,
    ClaimValue NVARCHAR(MAX) NULL,
    FOREIGN KEY (RoleId) REFERENCES AspNetRoles(Id) ON DELETE CASCADE
);

-- =============================================
-- Training Platform Tables
-- =============================================

-- Modules Table
CREATE TABLE Modules (
    Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Title NVARCHAR(200) NOT NULL,
    Description NVARCHAR(1000) NOT NULL,
    Icon NVARCHAR(50) NOT NULL DEFAULT 'BookOpen',
    Category NVARCHAR(100) NOT NULL,
    Color NVARCHAR(20) NOT NULL DEFAULT 'blue',
    EstimatedTime NVARCHAR(50) NOT NULL,
    Difficulty NVARCHAR(20) NOT NULL,
    Prerequisites NVARCHAR(MAX) NOT NULL DEFAULT '[]', -- JSON array
    LearningObjectives NVARCHAR(MAX) NOT NULL DEFAULT '[]', -- JSON array
    IsActive BIT NOT NULL DEFAULT 1,
    [Order] INT NOT NULL DEFAULT 0,
    CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    UpdatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE()
);

-- Sections Table
CREATE TABLE Sections (
    Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Title NVARCHAR(200) NOT NULL,
    Description NVARCHAR(1000) NOT NULL,
    ModuleId INT NOT NULL,
    [Order] INT NOT NULL DEFAULT 0,
    IsActive BIT NOT NULL DEFAULT 1,
    CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    UpdatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    FOREIGN KEY (ModuleId) REFERENCES Modules(Id) ON DELETE CASCADE
);

-- Lessons Table
CREATE TABLE Lessons (
    Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Title NVARCHAR(200) NOT NULL,
    Description NVARCHAR(1000) NOT NULL,
    Type INT NOT NULL, -- 0=Video, 1=Document, 2=Interactive, 3=Quiz
    Duration NVARCHAR(20) NOT NULL,
    SectionId INT NOT NULL,
    [Order] INT NOT NULL DEFAULT 0,
    IsActive BIT NOT NULL DEFAULT 1,
    VideoUrl NVARCHAR(500) NULL,
    DocumentContent NVARCHAR(MAX) NULL,
    ScribeLink NVARCHAR(500) NULL,
    InteractiveSteps NVARCHAR(MAX) NOT NULL DEFAULT '[]', -- JSON array
    HasAssessment BIT NOT NULL DEFAULT 0,
    CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    UpdatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    FOREIGN KEY (SectionId) REFERENCES Sections(Id) ON DELETE CASCADE
);

-- Assessments Table
CREATE TABLE Assessments (
    Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Title NVARCHAR(200) NOT NULL,
    Description NVARCHAR(1000) NOT NULL,
    ModuleId INT NOT NULL,
    SectionId INT NULL,
    LessonId INT NULL,
    PassingScore INT NOT NULL,
    TimeLimit INT NOT NULL, -- in minutes
    MaxAttempts INT NOT NULL DEFAULT 3,
    IsActive BIT NOT NULL DEFAULT 1,
    IsRequired BIT NOT NULL DEFAULT 0,
    TriggerType INT NOT NULL DEFAULT 0, -- 0=SectionCompletion, 1=ModuleCompletion, 2=LessonCompletion
    CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    UpdatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    FOREIGN KEY (ModuleId) REFERENCES Modules(Id) ON DELETE CASCADE,
    FOREIGN KEY (SectionId) REFERENCES Sections(Id) ON DELETE SET NULL,
    FOREIGN KEY (LessonId) REFERENCES Lessons(Id) ON DELETE SET NULL
);

-- Questions Table
CREATE TABLE Questions (
    Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    AssessmentId INT NOT NULL,
    Type INT NOT NULL, -- 0=MultipleChoice, 1=SingleChoice, 2=TrueFalse, 3=ShortAnswer, 4=Essay
    QuestionText NVARCHAR(2000) NOT NULL,
    Options NVARCHAR(MAX) NOT NULL DEFAULT '[]', -- JSON array
    CorrectAnswers NVARCHAR(MAX) NOT NULL DEFAULT '[]', -- JSON array
    Explanation NVARCHAR(1000) NULL,
    Points INT NOT NULL DEFAULT 1,
    [Order] INT NOT NULL DEFAULT 0,
    CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    UpdatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    FOREIGN KEY (AssessmentId) REFERENCES Assessments(Id) ON DELETE CASCADE
);

-- Assessment Attempts Table
CREATE TABLE AssessmentAttempts (
    Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    UserId NVARCHAR(450) NOT NULL,
    AssessmentId INT NOT NULL,
    StartedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    CompletedAt DATETIME2 NULL,
    Score INT NOT NULL DEFAULT 0,
    TotalPoints INT NOT NULL DEFAULT 0,
    Passed BIT NOT NULL DEFAULT 0,
    AttemptNumber INT NOT NULL DEFAULT 1,
    TimeSpent INT NOT NULL DEFAULT 0, -- in seconds
    Status INT NOT NULL DEFAULT 0, -- 0=InProgress, 1=Completed, 2=Abandoned, 3=TimeExpired
    FOREIGN KEY (UserId) REFERENCES AspNetUsers(Id) ON DELETE CASCADE,
    FOREIGN KEY (AssessmentId) REFERENCES Assessments(Id) ON DELETE CASCADE
);

-- User Answers Table
CREATE TABLE UserAnswers (
    Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    AssessmentAttemptId INT NOT NULL,
    QuestionId INT NOT NULL,
    SelectedAnswers NVARCHAR(MAX) NOT NULL DEFAULT '[]', -- JSON array
    TextAnswer NVARCHAR(MAX) NULL,
    IsCorrect BIT NOT NULL DEFAULT 0,
    PointsEarned INT NOT NULL DEFAULT 0,
    AnsweredAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    FOREIGN KEY (AssessmentAttemptId) REFERENCES AssessmentAttempts(Id) ON DELETE CASCADE,
    FOREIGN KEY (QuestionId) REFERENCES Questions(Id) ON DELETE NO ACTION
);

-- User Module Progress Table
CREATE TABLE UserModuleProgress (
    Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    UserId NVARCHAR(450) NOT NULL,
    ModuleId INT NOT NULL,
    CompletionPercentage INT NOT NULL DEFAULT 0,
    IsCompleted BIT NOT NULL DEFAULT 0,
    CompletedAt DATETIME2 NULL,
    StartedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    UpdatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    FOREIGN KEY (UserId) REFERENCES AspNetUsers(Id) ON DELETE CASCADE,
    FOREIGN KEY (ModuleId) REFERENCES Modules(Id) ON DELETE CASCADE,
    UNIQUE(UserId, ModuleId)
);

-- User Lesson Progress Table
CREATE TABLE UserLessonProgress (
    Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    UserId NVARCHAR(450) NOT NULL,
    LessonId INT NOT NULL,
    IsCompleted BIT NOT NULL DEFAULT 0,
    CompletedAt DATETIME2 NULL,
    StartedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    TimeSpent INT NOT NULL DEFAULT 0, -- in seconds
    FOREIGN KEY (UserId) REFERENCES AspNetUsers(Id) ON DELETE CASCADE,
    FOREIGN KEY (LessonId) REFERENCES Lessons(Id) ON DELETE CASCADE,
    UNIQUE(UserId, LessonId)
);

-- Uploaded Content Table
CREATE TABLE UploadedContents (
    Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Title NVARCHAR(200) NOT NULL,
    Description NVARCHAR(1000) NOT NULL,
    Type INT NOT NULL, -- 0=Document, 1=Video, 2=Image, 3=Interactive
    FilePath NVARCHAR(500) NOT NULL,
    FileName NVARCHAR(255) NOT NULL,
    FileSize BIGINT NOT NULL DEFAULT 0,
    ContentType NVARCHAR(100) NOT NULL,
    ModuleId INT NOT NULL,
    SectionId INT NULL,
    LessonId INT NULL,
    UploadedById NVARCHAR(450) NOT NULL,
    Tags NVARCHAR(MAX) NOT NULL DEFAULT '[]', -- JSON array
    AccessRoles NVARCHAR(MAX) NOT NULL DEFAULT '[]', -- JSON array
    ScribeLink NVARCHAR(500) NULL,
    VideoUrl NVARCHAR(500) NULL,
    IsActive BIT NOT NULL DEFAULT 1,
    CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    UpdatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    FOREIGN KEY (ModuleId) REFERENCES Modules(Id) ON DELETE CASCADE,
    FOREIGN KEY (SectionId) REFERENCES Sections(Id) ON DELETE SET NULL,
    FOREIGN KEY (LessonId) REFERENCES Lessons(Id) ON DELETE SET NULL,
    FOREIGN KEY (UploadedById) REFERENCES AspNetUsers(Id) ON DELETE NO ACTION
);

GO