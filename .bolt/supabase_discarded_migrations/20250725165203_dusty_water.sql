-- =============================================
-- Create Indexes for Performance
-- =============================================

USE ERPTrainingDB;
GO

-- Identity Indexes
CREATE UNIQUE INDEX IX_AspNetRoles_NormalizedName ON AspNetRoles (NormalizedName) WHERE NormalizedName IS NOT NULL;
CREATE INDEX IX_AspNetRoleClaims_RoleId ON AspNetRoleClaims (RoleId);
CREATE INDEX IX_AspNetUserClaims_UserId ON AspNetUserClaims (UserId);
CREATE INDEX IX_AspNetUserLogins_UserId ON AspNetUserLogins (UserId);
CREATE INDEX IX_AspNetUserRoles_RoleId ON AspNetUserRoles (RoleId);
CREATE UNIQUE INDEX IX_AspNetUsers_NormalizedEmail ON AspNetUsers (NormalizedEmail) WHERE NormalizedEmail IS NOT NULL;
CREATE UNIQUE INDEX IX_AspNetUsers_NormalizedUserName ON AspNetUsers (NormalizedUserName) WHERE NormalizedUserName IS NOT NULL;

-- Training Platform Indexes
CREATE INDEX IX_Modules_Order ON Modules ([Order]);
CREATE INDEX IX_Modules_IsActive ON Modules (IsActive);
CREATE INDEX IX_Modules_Category ON Modules (Category);

CREATE INDEX IX_Sections_ModuleId_Order ON Sections (ModuleId, [Order]);
CREATE INDEX IX_Sections_IsActive ON Sections (IsActive);

CREATE INDEX IX_Lessons_SectionId_Order ON Lessons (SectionId, [Order]);
CREATE INDEX IX_Lessons_IsActive ON Lessons (IsActive);
CREATE INDEX IX_Lessons_Type ON Lessons (Type);

CREATE INDEX IX_Assessments_ModuleId ON Assessments (ModuleId);
CREATE INDEX IX_Assessments_SectionId ON Assessments (SectionId);
CREATE INDEX IX_Assessments_IsActive ON Assessments (IsActive);
CREATE INDEX IX_Assessments_TriggerType ON Assessments (TriggerType);

CREATE INDEX IX_Questions_AssessmentId_Order ON Questions (AssessmentId, [Order]);
CREATE INDEX IX_Questions_Type ON Questions (Type);

CREATE INDEX IX_AssessmentAttempts_UserId ON AssessmentAttempts (UserId);
CREATE INDEX IX_AssessmentAttempts_AssessmentId ON AssessmentAttempts (AssessmentId);
CREATE INDEX IX_AssessmentAttempts_Status ON AssessmentAttempts (Status);
CREATE INDEX IX_AssessmentAttempts_StartedAt ON AssessmentAttempts (StartedAt);

CREATE INDEX IX_UserAnswers_AssessmentAttemptId ON UserAnswers (AssessmentAttemptId);
CREATE INDEX IX_UserAnswers_QuestionId ON UserAnswers (QuestionId);

CREATE INDEX IX_UserModuleProgress_UserId ON UserModuleProgress (UserId);
CREATE INDEX IX_UserModuleProgress_ModuleId ON UserModuleProgress (ModuleId);
CREATE INDEX IX_UserModuleProgress_IsCompleted ON UserModuleProgress (IsCompleted);

CREATE INDEX IX_UserLessonProgress_UserId ON UserLessonProgress (UserId);
CREATE INDEX IX_UserLessonProgress_LessonId ON UserLessonProgress (LessonId);
CREATE INDEX IX_UserLessonProgress_IsCompleted ON UserLessonProgress (IsCompleted);

CREATE INDEX IX_UploadedContents_ModuleId ON UploadedContents (ModuleId);
CREATE INDEX IX_UploadedContents_SectionId ON UploadedContents (SectionId);
CREATE INDEX IX_UploadedContents_UploadedById ON UploadedContents (UploadedById);
CREATE INDEX IX_UploadedContents_Type ON UploadedContents (Type);
CREATE INDEX IX_UploadedContents_IsActive ON UploadedContents (IsActive);
CREATE INDEX IX_UploadedContents_CreatedAt ON UploadedContents (CreatedAt);

GO