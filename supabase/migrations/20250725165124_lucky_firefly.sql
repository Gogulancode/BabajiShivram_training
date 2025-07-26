-- =============================================
-- ERP Training Platform Database Creation
-- =============================================

-- Create Database
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'ERPTrainingDB')
BEGIN
    CREATE DATABASE ERPTrainingDB;
END
GO

USE ERPTrainingDB;
GO

-- Enable JSON support and other features
ALTER DATABASE ERPTrainingDB SET COMPATIBILITY_LEVEL = 160;
GO