# ERP Training Management System - Server Startup Script
Write-Host "🚀 Starting ERP Training Management System..." -ForegroundColor Cyan
Write-Host ""

# Get the script directory
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
Set-Location $scriptPath

try {
    # Start Backend API
    Write-Host "[1/2] Starting Backend API Server..." -ForegroundColor Yellow
    $backendPath = Join-Path $scriptPath "backend\ERPTraining.API"
    
    if (Test-Path $backendPath) {
        Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$backendPath'; Write-Host 'Backend API Server' -ForegroundColor Green; dotnet run" -WindowStyle Normal
        Write-Host "✅ Backend API server started" -ForegroundColor Green
    } else {
        Write-Host "❌ Backend path not found: $backendPath" -ForegroundColor Red
    }

    # Wait a moment
    Start-Sleep -Seconds 2

    # Start Frontend
    Write-Host "[2/2] Starting Frontend Development Server..." -ForegroundColor Yellow
    
    if (Test-Path "package.json") {
        Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$scriptPath'; Write-Host 'Frontend Development Server' -ForegroundColor Blue; npm run dev" -WindowStyle Normal
        Write-Host "✅ Frontend development server started" -ForegroundColor Green
    } else {
        Write-Host "❌ package.json not found in root directory" -ForegroundColor Red
    }

    Write-Host ""
    Write-Host "🎉 Server startup complete!" -ForegroundColor Green
    Write-Host ""
    Write-Host "📍 Access your application at:" -ForegroundColor Cyan
    Write-Host "   • Frontend: http://localhost:5173" -ForegroundColor White
    Write-Host "   • Backend API: http://localhost:5000" -ForegroundColor White
    Write-Host "   • API Documentation: http://localhost:5000/swagger" -ForegroundColor White
    Write-Host ""
    Write-Host "💡 Tip: If you see 'Demo Mode Active', the backend isn't running yet." -ForegroundColor Yellow
    Write-Host ""

} catch {
    Write-Host "❌ Error starting servers: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "Press any key to exit..."
Read-Host
