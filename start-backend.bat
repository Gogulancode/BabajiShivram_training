@echo off
title ERP Training API Server
color 0A

echo ===============================================
echo    ERP Training Management System - API Server
echo ===============================================
echo.

cd /d "%~dp0backend\ERPTraining.API"

echo [1/3] Checking .NET installation...
dotnet --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ .NET is not installed or not in PATH
    echo Please install .NET 8.0 or later from: https://dotnet.microsoft.com/download
    pause
    exit /b 1
)
echo ✅ .NET is installed

echo.
echo [2/3] Restoring NuGet packages...
dotnet restore
if %errorlevel% neq 0 (
    echo ❌ Failed to restore packages
    pause
    exit /b 1
)
echo ✅ Packages restored

echo.
echo [3/3] Starting API server...
echo.
echo 🚀 Starting server on http://localhost:5000
echo 📚 API Documentation: http://localhost:5000/swagger
echo.
echo Press Ctrl+C to stop the server
echo.

dotnet run --urls "http://localhost:5000"

echo.
echo Server stopped.
pause
