-- Users table (simplified, extend as needed for Identity)
CREATE TABLE Users (
    Id NVARCHAR(450) PRIMARY KEY,
    UserName NVARCHAR(256),
    NormalizedUserName NVARCHAR(256),
    Email NVARCHAR(256),
    NormalizedEmail NVARCHAR(256),
    EmailConfirmed BIT,
    PasswordHash NVARCHAR(MAX),
    SecurityStamp NVARCHAR(MAX),
    ConcurrencyStamp NVARCHAR(MAX),
    PhoneNumber NVARCHAR(20),
    PhoneNumberConfirmed BIT,
    TwoFactorEnabled BIT,
    LockoutEnd DATETIMEOFFSET,
    LockoutEnabled BIT,
    AccessFailedCount INT,
    FirstName NVARCHAR(100),
    LastName NVARCHAR(100),
    Department NVARCHAR(100),
    JoinDate DATETIME,
    Avatar NVARCHAR(512),
    IsActive BIT,
    CreatedAt DATETIME,
    UpdatedAt DATETIME
);

CREATE TABLE Modules (
    Id INT PRIMARY KEY IDENTITY,
    Title NVARCHAR(200),
    Description NVARCHAR(MAX),
    Icon NVARCHAR(100),
    Category NVARCHAR(100),
    Color NVARCHAR(50),
    EstimatedTime NVARCHAR(50),
    Difficulty NVARCHAR(50),
    Prerequisites NVARCHAR(MAX),
    LearningObjectives NVARCHAR(MAX),
    IsActive BIT,
    [Order] INT,
    CreatedAt DATETIME,
    UpdatedAt DATETIME
);

CREATE TABLE Sections (
    Id INT PRIMARY KEY IDENTITY,
    Title NVARCHAR(200),
    Description NVARCHAR(MAX),
    ModuleId INT,
    [Order] INT,
    IsActive BIT,
    CreatedAt DATETIME,
    UpdatedAt DATETIME,
    FOREIGN KEY (ModuleId) REFERENCES Modules(Id)
);

CREATE TABLE Lessons (
    Id INT PRIMARY KEY IDENTITY,
    Title NVARCHAR(200),
    Description NVARCHAR(MAX),
    Type INT,
    Duration NVARCHAR(50),
    SectionId INT,
    [Order] INT,
    IsActive BIT,
    VideoUrl NVARCHAR(512),
    DocumentContent NVARCHAR(MAX),
    ScribeLink NVARCHAR(512),
    InteractiveSteps NVARCHAR(MAX),
    HasAssessment BIT,
    CreatedAt DATETIME,
    UpdatedAt DATETIME,
    FOREIGN KEY (SectionId) REFERENCES Sections(Id)
);

CREATE TABLE Assessments (
    Id INT PRIMARY KEY IDENTITY,
    Title NVARCHAR(200),
    Description NVARCHAR(MAX),
    ModuleId INT,
    SectionId INT NULL,
    LessonId INT NULL,
    PassingScore INT,
    TimeLimit INT,
    MaxAttempts INT,
    IsActive BIT,
    IsRequired BIT,
    TriggerType INT,
    CreatedAt DATETIME,
    UpdatedAt DATETIME,
    FOREIGN KEY (ModuleId) REFERENCES Modules(Id),
    FOREIGN KEY (SectionId) REFERENCES Sections(Id),
    FOREIGN KEY (LessonId) REFERENCES Lessons(Id)
);

CREATE TABLE AssessmentAttempts (
    Id INT PRIMARY KEY IDENTITY,
    UserId NVARCHAR(450),
    AssessmentId INT,
    StartedAt DATETIME,
    CompletedAt DATETIME NULL,
    Score INT,
    TotalPoints INT,
    Passed BIT,
    AttemptNumber INT,
    TimeSpent INT,
    Status INT,
    FOREIGN KEY (UserId) REFERENCES Users(Id),
    FOREIGN KEY (AssessmentId) REFERENCES Assessments(Id)
);

CREATE TABLE Questions (
    Id INT PRIMARY KEY IDENTITY,
    AssessmentId INT,
    Type INT,
    QuestionText NVARCHAR(MAX),
    Options NVARCHAR(MAX),
    CorrectAnswers NVARCHAR(MAX),
    Explanation NVARCHAR(MAX),
    Points INT,
    [Order] INT,
    CreatedAt DATETIME,
    UpdatedAt DATETIME,
    FOREIGN KEY (AssessmentId) REFERENCES Assessments(Id)
);

CREATE TABLE UserAnswers (
    Id INT PRIMARY KEY IDENTITY,
    AssessmentAttemptId INT,
    QuestionId INT,
    SelectedAnswers NVARCHAR(MAX),
    TextAnswer NVARCHAR(MAX),
    IsCorrect BIT,
    PointsEarned INT,
    AnsweredAt DATETIME,
    FOREIGN KEY (AssessmentAttemptId) REFERENCES AssessmentAttempts(Id),
    FOREIGN KEY (QuestionId) REFERENCES Questions(Id)
);

CREATE TABLE UserLessonProgress (
    Id INT PRIMARY KEY IDENTITY,
    UserId NVARCHAR(450),
    LessonId INT,
    IsCompleted BIT,
    CompletedAt DATETIME NULL,
    StartedAt DATETIME,
    TimeSpent INT,
    FOREIGN KEY (UserId) REFERENCES Users(Id),
    FOREIGN KEY (LessonId) REFERENCES Lessons(Id)
);

CREATE TABLE UserModuleProgress (
    Id INT PRIMARY KEY IDENTITY,
    UserId NVARCHAR(450),
    ModuleId INT,
    CompletionPercentage INT,
    IsCompleted BIT,
    CompletedAt DATETIME NULL,
    StartedAt DATETIME,
    UpdatedAt DATETIME,
    FOREIGN KEY (UserId) REFERENCES Users(Id),
    FOREIGN KEY (ModuleId) REFERENCES Modules(Id)
);

CREATE TABLE UploadedContent (
    Id INT PRIMARY KEY IDENTITY,
    Title NVARCHAR(200),
    Description NVARCHAR(MAX),
    Type INT,
    FilePath NVARCHAR(512),
    FileName NVARCHAR(256),
    FileSize BIGINT,
    ContentType NVARCHAR(100),
    ModuleId INT,
    SectionId INT NULL,
    LessonId INT NULL,
    UploadedById NVARCHAR(450),
    Tags NVARCHAR(MAX),
    AccessRoles NVARCHAR(MAX),
    ScribeLink NVARCHAR(512),
    VideoUrl NVARCHAR(512),
    IsActive BIT,
    CreatedAt DATETIME,
    UpdatedAt DATETIME,
    FOREIGN KEY (ModuleId) REFERENCES Modules(Id),
    FOREIGN KEY (SectionId) REFERENCES Sections(Id),
    FOREIGN KEY (LessonId) REFERENCES Lessons(Id),
    FOREIGN KEY (UploadedById) REFERENCES Users(Id)
);
