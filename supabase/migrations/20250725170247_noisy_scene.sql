-- ERP Training Platform - SQLite Database Schema
-- Complete database schema for the training platform

-- Enable foreign key constraints
PRAGMA foreign_keys = ON;

-- ============================================================================
-- USERS AND AUTHENTICATION TABLES
-- ============================================================================

-- AspNetRoles table
CREATE TABLE IF NOT EXISTS AspNetRoles (
    Id TEXT NOT NULL PRIMARY KEY,
    Name TEXT,
    NormalizedName TEXT,
    ConcurrencyStamp TEXT
);

-- AspNetUsers table
CREATE TABLE IF NOT EXISTS AspNetUsers (
    Id TEXT NOT NULL PRIMARY KEY,
    UserName TEXT,
    NormalizedUserName TEXT,
    Email TEXT,
    NormalizedEmail TEXT,
    EmailConfirmed INTEGER NOT NULL DEFAULT 0,
    PasswordHash TEXT,
    SecurityStamp TEXT,
    ConcurrencyStamp TEXT,
    PhoneNumber TEXT,
    PhoneNumberConfirmed INTEGER NOT NULL DEFAULT 0,
    TwoFactorEnabled INTEGER NOT NULL DEFAULT 0,
    LockoutEnd TEXT,
    LockoutEnabled INTEGER NOT NULL DEFAULT 0,
    AccessFailedCount INTEGER NOT NULL DEFAULT 0,
    FirstName TEXT NOT NULL DEFAULT '',
    LastName TEXT NOT NULL DEFAULT '',
    Department TEXT NOT NULL DEFAULT '',
    JoinDate TEXT NOT NULL DEFAULT (datetime('now')),
    Avatar TEXT,
    IsActive INTEGER NOT NULL DEFAULT 1,
    CreatedAt TEXT NOT NULL DEFAULT (datetime('now')),
    UpdatedAt TEXT NOT NULL DEFAULT (datetime('now'))
);

-- AspNetUserRoles table
CREATE TABLE IF NOT EXISTS AspNetUserRoles (
    UserId TEXT NOT NULL,
    RoleId TEXT NOT NULL,
    PRIMARY KEY (UserId, RoleId),
    FOREIGN KEY (UserId) REFERENCES AspNetUsers(Id) ON DELETE CASCADE,
    FOREIGN KEY (RoleId) REFERENCES AspNetRoles(Id) ON DELETE CASCADE
);

-- AspNetUserClaims table
CREATE TABLE IF NOT EXISTS AspNetUserClaims (
    Id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    UserId TEXT NOT NULL,
    ClaimType TEXT,
    ClaimValue TEXT,
    FOREIGN KEY (UserId) REFERENCES AspNetUsers(Id) ON DELETE CASCADE
);

-- AspNetUserLogins table
CREATE TABLE IF NOT EXISTS AspNetUserLogins (
    LoginProvider TEXT NOT NULL,
    ProviderKey TEXT NOT NULL,
    ProviderDisplayName TEXT,
    UserId TEXT NOT NULL,
    PRIMARY KEY (LoginProvider, ProviderKey),
    FOREIGN KEY (UserId) REFERENCES AspNetUsers(Id) ON DELETE CASCADE
);

-- AspNetUserTokens table
CREATE TABLE IF NOT EXISTS AspNetUserTokens (
    UserId TEXT NOT NULL,
    LoginProvider TEXT NOT NULL,
    Name TEXT NOT NULL,
    Value TEXT,
    PRIMARY KEY (UserId, LoginProvider, Name),
    FOREIGN KEY (UserId) REFERENCES AspNetUsers(Id) ON DELETE CASCADE
);

-- AspNetRoleClaims table
CREATE TABLE IF NOT EXISTS AspNetRoleClaims (
    Id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    RoleId TEXT NOT NULL,
    ClaimType TEXT,
    ClaimValue TEXT,
    FOREIGN KEY (RoleId) REFERENCES AspNetRoles(Id) ON DELETE CASCADE
);

-- ============================================================================
-- TRAINING PLATFORM CORE TABLES
-- ============================================================================

-- Modules table
CREATE TABLE IF NOT EXISTS Modules (
    Id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    Title TEXT NOT NULL,
    Description TEXT NOT NULL,
    Icon TEXT NOT NULL DEFAULT 'BookOpen',
    Category TEXT NOT NULL,
    Color TEXT NOT NULL DEFAULT 'blue',
    EstimatedTime TEXT NOT NULL DEFAULT '1 hour',
    Difficulty TEXT NOT NULL DEFAULT 'Beginner',
    Prerequisites TEXT NOT NULL DEFAULT '[]', -- JSON array
    LearningObjectives TEXT NOT NULL DEFAULT '[]', -- JSON array
    IsActive INTEGER NOT NULL DEFAULT 1,
    [Order] INTEGER NOT NULL DEFAULT 0,
    CreatedAt TEXT NOT NULL DEFAULT (datetime('now')),
    UpdatedAt TEXT NOT NULL DEFAULT (datetime('now'))
);

-- Sections table
CREATE TABLE IF NOT EXISTS Sections (
    Id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    Title TEXT NOT NULL,
    Description TEXT NOT NULL,
    ModuleId INTEGER NOT NULL,
    [Order] INTEGER NOT NULL DEFAULT 0,
    IsActive INTEGER NOT NULL DEFAULT 1,
    CreatedAt TEXT NOT NULL DEFAULT (datetime('now')),
    UpdatedAt TEXT NOT NULL DEFAULT (datetime('now')),
    FOREIGN KEY (ModuleId) REFERENCES Modules(Id) ON DELETE CASCADE
);

-- Lessons table
CREATE TABLE IF NOT EXISTS Lessons (
    Id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    Title TEXT NOT NULL,
    Description TEXT NOT NULL,
    Type INTEGER NOT NULL DEFAULT 0, -- 0=Video, 1=Document, 2=Interactive, 3=Quiz
    Duration TEXT NOT NULL DEFAULT '10 min',
    SectionId INTEGER NOT NULL,
    [Order] INTEGER NOT NULL DEFAULT 0,
    IsActive INTEGER NOT NULL DEFAULT 1,
    VideoUrl TEXT,
    DocumentContent TEXT,
    ScribeLink TEXT,
    InteractiveSteps TEXT NOT NULL DEFAULT '[]', -- JSON array
    HasAssessment INTEGER NOT NULL DEFAULT 0,
    CreatedAt TEXT NOT NULL DEFAULT (datetime('now')),
    UpdatedAt TEXT NOT NULL DEFAULT (datetime('now')),
    FOREIGN KEY (SectionId) REFERENCES Sections(Id) ON DELETE CASCADE
);

-- Assessments table
CREATE TABLE IF NOT EXISTS Assessments (
    Id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    Title TEXT NOT NULL,
    Description TEXT NOT NULL,
    ModuleId INTEGER NOT NULL,
    SectionId INTEGER,
    LessonId INTEGER,
    PassingScore INTEGER NOT NULL DEFAULT 70,
    TimeLimit INTEGER NOT NULL DEFAULT 30, -- in minutes
    MaxAttempts INTEGER NOT NULL DEFAULT 3,
    IsActive INTEGER NOT NULL DEFAULT 1,
    IsRequired INTEGER NOT NULL DEFAULT 0,
    TriggerType INTEGER NOT NULL DEFAULT 0, -- 0=SectionCompletion, 1=ModuleCompletion, 2=LessonCompletion
    CreatedAt TEXT NOT NULL DEFAULT (datetime('now')),
    UpdatedAt TEXT NOT NULL DEFAULT (datetime('now')),
    FOREIGN KEY (ModuleId) REFERENCES Modules(Id) ON DELETE CASCADE,
    FOREIGN KEY (SectionId) REFERENCES Sections(Id) ON DELETE SET NULL,
    FOREIGN KEY (LessonId) REFERENCES Lessons(Id) ON DELETE SET NULL
);

-- Questions table
CREATE TABLE IF NOT EXISTS Questions (
    Id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    AssessmentId INTEGER NOT NULL,
    Type INTEGER NOT NULL DEFAULT 0, -- 0=MultipleChoice, 1=SingleChoice, 2=TrueFalse, 3=ShortAnswer, 4=Essay
    QuestionText TEXT NOT NULL,
    Options TEXT NOT NULL DEFAULT '[]', -- JSON array
    CorrectAnswers TEXT NOT NULL DEFAULT '[]', -- JSON array
    Explanation TEXT,
    Points INTEGER NOT NULL DEFAULT 5,
    [Order] INTEGER NOT NULL DEFAULT 0,
    CreatedAt TEXT NOT NULL DEFAULT (datetime('now')),
    UpdatedAt TEXT NOT NULL DEFAULT (datetime('now')),
    FOREIGN KEY (AssessmentId) REFERENCES Assessments(Id) ON DELETE CASCADE
);

-- AssessmentAttempts table
CREATE TABLE IF NOT EXISTS AssessmentAttempts (
    Id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    UserId TEXT NOT NULL,
    AssessmentId INTEGER NOT NULL,
    StartedAt TEXT NOT NULL DEFAULT (datetime('now')),
    CompletedAt TEXT,
    Score INTEGER NOT NULL DEFAULT 0,
    TotalPoints INTEGER NOT NULL DEFAULT 0,
    Passed INTEGER NOT NULL DEFAULT 0,
    AttemptNumber INTEGER NOT NULL DEFAULT 1,
    TimeSpent INTEGER NOT NULL DEFAULT 0, -- in seconds
    Status INTEGER NOT NULL DEFAULT 0, -- 0=InProgress, 1=Completed, 2=Abandoned, 3=TimeExpired
    FOREIGN KEY (UserId) REFERENCES AspNetUsers(Id) ON DELETE CASCADE,
    FOREIGN KEY (AssessmentId) REFERENCES Assessments(Id) ON DELETE CASCADE
);

-- UserAnswers table
CREATE TABLE IF NOT EXISTS UserAnswers (
    Id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    AssessmentAttemptId INTEGER NOT NULL,
    QuestionId INTEGER NOT NULL,
    SelectedAnswers TEXT NOT NULL DEFAULT '[]', -- JSON array
    TextAnswer TEXT,
    IsCorrect INTEGER NOT NULL DEFAULT 0,
    PointsEarned INTEGER NOT NULL DEFAULT 0,
    AnsweredAt TEXT NOT NULL DEFAULT (datetime('now')),
    FOREIGN KEY (AssessmentAttemptId) REFERENCES AssessmentAttempts(Id) ON DELETE CASCADE,
    FOREIGN KEY (QuestionId) REFERENCES Questions(Id) ON DELETE RESTRICT
);

-- UserModuleProgress table
CREATE TABLE IF NOT EXISTS UserModuleProgress (
    Id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    UserId TEXT NOT NULL,
    ModuleId INTEGER NOT NULL,
    CompletionPercentage INTEGER NOT NULL DEFAULT 0,
    IsCompleted INTEGER NOT NULL DEFAULT 0,
    CompletedAt TEXT,
    StartedAt TEXT NOT NULL DEFAULT (datetime('now')),
    UpdatedAt TEXT NOT NULL DEFAULT (datetime('now')),
    FOREIGN KEY (UserId) REFERENCES AspNetUsers(Id) ON DELETE CASCADE,
    FOREIGN KEY (ModuleId) REFERENCES Modules(Id) ON DELETE CASCADE,
    UNIQUE(UserId, ModuleId)
);

-- UserLessonProgress table
CREATE TABLE IF NOT EXISTS UserLessonProgress (
    Id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    UserId TEXT NOT NULL,
    LessonId INTEGER NOT NULL,
    IsCompleted INTEGER NOT NULL DEFAULT 0,
    CompletedAt TEXT,
    StartedAt TEXT NOT NULL DEFAULT (datetime('now')),
    TimeSpent INTEGER NOT NULL DEFAULT 0, -- in seconds
    FOREIGN KEY (UserId) REFERENCES AspNetUsers(Id) ON DELETE CASCADE,
    FOREIGN KEY (LessonId) REFERENCES Lessons(Id) ON DELETE CASCADE,
    UNIQUE(UserId, LessonId)
);

-- UploadedContents table
CREATE TABLE IF NOT EXISTS UploadedContents (
    Id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    Title TEXT NOT NULL,
    Description TEXT NOT NULL,
    Type INTEGER NOT NULL DEFAULT 0, -- 0=Document, 1=Video, 2=Image, 3=Interactive
    FilePath TEXT NOT NULL,
    FileName TEXT NOT NULL,
    FileSize INTEGER NOT NULL DEFAULT 0,
    ContentType TEXT NOT NULL DEFAULT 'application/octet-stream',
    ModuleId INTEGER NOT NULL,
    SectionId INTEGER,
    LessonId INTEGER,
    UploadedById TEXT NOT NULL,
    Tags TEXT NOT NULL DEFAULT '[]', -- JSON array
    AccessRoles TEXT NOT NULL DEFAULT '[]', -- JSON array
    ScribeLink TEXT,
    VideoUrl TEXT,
    IsActive INTEGER NOT NULL DEFAULT 1,
    CreatedAt TEXT NOT NULL DEFAULT (datetime('now')),
    UpdatedAt TEXT NOT NULL DEFAULT (datetime('now')),
    FOREIGN KEY (ModuleId) REFERENCES Modules(Id) ON DELETE CASCADE,
    FOREIGN KEY (SectionId) REFERENCES Sections(Id) ON DELETE SET NULL,
    FOREIGN KEY (LessonId) REFERENCES Lessons(Id) ON DELETE SET NULL,
    FOREIGN KEY (UploadedById) REFERENCES AspNetUsers(Id) ON DELETE RESTRICT
);

-- ============================================================================
-- INDEXES FOR PERFORMANCE
-- ============================================================================

-- User indexes
CREATE INDEX IF NOT EXISTS IX_AspNetUsers_NormalizedUserName ON AspNetUsers(NormalizedUserName);
CREATE INDEX IF NOT EXISTS IX_AspNetUsers_NormalizedEmail ON AspNetUsers(NormalizedEmail);
CREATE INDEX IF NOT EXISTS IX_AspNetUsers_IsActive ON AspNetUsers(IsActive);

-- Module indexes
CREATE INDEX IF NOT EXISTS IX_Modules_Order ON Modules([Order]);
CREATE INDEX IF NOT EXISTS IX_Modules_IsActive ON Modules(IsActive);
CREATE INDEX IF NOT EXISTS IX_Modules_Category ON Modules(Category);

-- Section indexes
CREATE INDEX IF NOT EXISTS IX_Sections_ModuleId_Order ON Sections(ModuleId, [Order]);
CREATE INDEX IF NOT EXISTS IX_Sections_IsActive ON Sections(IsActive);

-- Lesson indexes
CREATE INDEX IF NOT EXISTS IX_Lessons_SectionId_Order ON Lessons(SectionId, [Order]);
CREATE INDEX IF NOT EXISTS IX_Lessons_Type ON Lessons(Type);
CREATE INDEX IF NOT EXISTS IX_Lessons_IsActive ON Lessons(IsActive);

-- Assessment indexes
CREATE INDEX IF NOT EXISTS IX_Assessments_ModuleId ON Assessments(ModuleId);
CREATE INDEX IF NOT EXISTS IX_Assessments_SectionId ON Assessments(SectionId);
CREATE INDEX IF NOT EXISTS IX_Assessments_IsActive ON Assessments(IsActive);

-- Question indexes
CREATE INDEX IF NOT EXISTS IX_Questions_AssessmentId_Order ON Questions(AssessmentId, [Order]);
CREATE INDEX IF NOT EXISTS IX_Questions_Type ON Questions(Type);

-- Progress indexes
CREATE INDEX IF NOT EXISTS IX_UserModuleProgress_UserId_ModuleId ON UserModuleProgress(UserId, ModuleId);
CREATE INDEX IF NOT EXISTS IX_UserLessonProgress_UserId_LessonId ON UserLessonProgress(UserId, LessonId);

-- Assessment attempt indexes
CREATE INDEX IF NOT EXISTS IX_AssessmentAttempts_UserId ON AssessmentAttempts(UserId);
CREATE INDEX IF NOT EXISTS IX_AssessmentAttempts_AssessmentId ON AssessmentAttempts(AssessmentId);
CREATE INDEX IF NOT EXISTS IX_AssessmentAttempts_Status ON AssessmentAttempts(Status);

-- User answer indexes
CREATE INDEX IF NOT EXISTS IX_UserAnswers_AssessmentAttemptId ON UserAnswers(AssessmentAttemptId);
CREATE INDEX IF NOT EXISTS IX_UserAnswers_QuestionId ON UserAnswers(QuestionId);

-- Content indexes
CREATE INDEX IF NOT EXISTS IX_UploadedContents_ModuleId ON UploadedContents(ModuleId);
CREATE INDEX IF NOT EXISTS IX_UploadedContents_UploadedById ON UploadedContents(UploadedById);
CREATE INDEX IF NOT EXISTS IX_UploadedContents_IsActive ON UploadedContents(IsActive);