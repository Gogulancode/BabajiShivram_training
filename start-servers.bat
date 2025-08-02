@echo off
echo Starting ERP Training Management System...
echo.

echo [1/2] Starting Backend API Server...
cd /d "%~dp0backend\ERPTraining.API"
start "Backend API" cmd /k "dotnet run"

echo [2/2] Starting Frontend Development Server...
cd /d "%~dp0"
start "Frontend Dev" cmd /k "npm run dev"

echo.
echo ✅ Both servers are starting...
echo.
echo Backend API will be available at: http://localhost:5000
echo Frontend will be available at: http://localhost:5173
echo.
echo Press any key to exit this window...
pause > nul
