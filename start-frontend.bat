@echo off
title ERP Training Frontend Dev Server
color 0B

echo ===============================================
echo   ERP Training Management System - Frontend
echo ===============================================
echo.

echo [1/3] Checking Node.js installation...
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Node.js is not installed or not in PATH
    echo Please install Node.js from: https://nodejs.org/
    pause
    exit /b 1
)
echo ✅ Node.js is installed

echo.
echo [2/3] Installing dependencies...
npm install
if %errorlevel% neq 0 (
    echo ❌ Failed to install dependencies
    pause
    exit /b 1
)
echo ✅ Dependencies installed

echo.
echo [3/3] Starting development server...
echo.
echo 🚀 Starting frontend on http://localhost:5173
echo 📱 Frontend will automatically open in your browser
echo.
echo Press Ctrl+C to stop the server
echo.

npm run dev

echo.
echo Server stopped.
pause
