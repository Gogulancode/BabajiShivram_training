# ============================================================================
# PRODUCTION BUILD & PACKAGE SCRIPT
# One-click script to build and package everything for production deployment
# ============================================================================
# Usage: .\build-production.ps1
# Output: Creates a ready-to-deploy package in .\production-release\
# ============================================================================

$ErrorActionPreference = "Continue"
$startTime = Get-Date

Write-Host ""
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "  PRODUCTION BUILD SCRIPT" -ForegroundColor Cyan
Write-Host "  $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Gray
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""

# Configuration
$projectRoot = $PSScriptRoot
if (-not $projectRoot) { $projectRoot = Get-Location }
$releaseFolder = Join-Path $projectRoot "production-release"
$backendProject = Join-Path $projectRoot "backend\ERPTraining.API"
$frontendDist = Join-Path $projectRoot "dist"
$productionConfig = Join-Path $projectRoot "production-config"

# Step 1: Clean previous release
Write-Host "[1/5] Cleaning previous release folder..." -ForegroundColor Yellow
if (Test-Path $releaseFolder) {
    Remove-Item -Recurse -Force $releaseFolder
}
New-Item -ItemType Directory -Path $releaseFolder | Out-Null
Write-Host "      Done!" -ForegroundColor Green

# Step 2: Build Frontend
Write-Host ""
Write-Host "[2/5] Building Frontend (Vite + React)..." -ForegroundColor Yellow
Push-Location $projectRoot
try {
    $env:ErrorActionPreference = "Continue"
    & npm run build:production 2>&1 | ForEach-Object { 
        if ($_ -match "built in|modules transformed") { 
            Write-Host "      $_" -ForegroundColor Gray 
        }
    }
    $env:ErrorActionPreference = "Stop"
    
    if (-not (Test-Path $frontendDist)) {
        throw "Frontend build failed - dist folder not created!"
    }
    Write-Host "      Done! Output: dist/" -ForegroundColor Green
} finally {
    Pop-Location
}

# Step 3: Build Backend
Write-Host ""
Write-Host "[3/5] Building Backend (.NET 8)..." -ForegroundColor Yellow
$backendOutput = Join-Path $releaseFolder "api"
dotnet publish $backendProject -c Release -o $backendOutput --verbosity quiet
if ($LASTEXITCODE -ne 0) {
    throw "Backend build failed!"
}
Write-Host "      Done! Output: production-release/api/" -ForegroundColor Green

# Step 4: Copy Frontend to wwwroot
Write-Host ""
Write-Host "[4/5] Copying Frontend to Backend wwwroot..." -ForegroundColor Yellow
$wwwroot = Join-Path $backendOutput "wwwroot"
if (Test-Path $wwwroot) {
    Remove-Item -Recurse -Force $wwwroot
}
Copy-Item -Recurse $frontendDist $wwwroot
Write-Host "      Done!" -ForegroundColor Green

# Step 5: Copy Production Config (but don't overwrite appsettings.Production.json if using secrets)
Write-Host ""
Write-Host "[5/5] Applying Production Configuration..." -ForegroundColor Yellow

# Copy Web.config from production-config if it exists
$webConfigSource = Join-Path $productionConfig "Web.config"
$webConfigDest = Join-Path $backendOutput "Web.config"
if (Test-Path $webConfigSource) {
    Copy-Item $webConfigSource $webConfigDest -Force
    Write-Host "      Web.config applied" -ForegroundColor Green
}

# Copy appsettings.Production.json from production-config
$appSettingsSource = Join-Path $productionConfig "appsettings.Production.json"
$appSettingsDest = Join-Path $backendOutput "appsettings.Production.json"
if (Test-Path $appSettingsSource) {
    Copy-Item $appSettingsSource $appSettingsDest -Force
    Write-Host "      appsettings.Production.json applied" -ForegroundColor Green
}

# Create logs folder
$logsFolder = Join-Path $backendOutput "logs"
if (-not (Test-Path $logsFolder)) {
    New-Item -ItemType Directory -Path $logsFolder | Out-Null
    Write-Host "      logs/ folder created" -ForegroundColor Green
}

# Create Data folder for uploads
$dataFolder = Join-Path $backendOutput "Data"
if (-not (Test-Path $dataFolder)) {
    New-Item -ItemType Directory -Path $dataFolder | Out-Null
    Write-Host "      Data/ folder created" -ForegroundColor Green
}

# Calculate build time
$endTime = Get-Date
$duration = $endTime - $startTime

Write-Host ""
Write-Host "=============================================" -ForegroundColor Green
Write-Host "  BUILD SUCCESSFUL!" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green
Write-Host ""
Write-Host "  Output:     $releaseFolder\api\" -ForegroundColor White
Write-Host "  Build Time: $($duration.TotalSeconds.ToString('F1')) seconds" -ForegroundColor Gray
Write-Host ""
Write-Host "  DEPLOYMENT INSTRUCTIONS:" -ForegroundColor Yellow
Write-Host "  -------------------------" -ForegroundColor Yellow
Write-Host "  1. Copy 'production-release\api\*' to D:\SupportApp\api\" -ForegroundColor White
Write-Host "  2. Copy 'production-release\api\wwwroot\*' to D:\SupportApp\frontend\ (if separate)" -ForegroundColor White
Write-Host "  3. Restart IIS Application Pool" -ForegroundColor White
Write-Host ""
Write-Host "  Or use xcopy/robocopy:" -ForegroundColor Gray
Write-Host "  robocopy `"$releaseFolder\api`" `"\\SERVER\D$\SupportApp\api`" /MIR /XF appsettings.Development.json" -ForegroundColor DarkGray
Write-Host ""

# Show what was built
Write-Host "  Package Contents:" -ForegroundColor Cyan
$apiFiles = Get-ChildItem $backendOutput -File | Measure-Object -Property Length -Sum
$wwwrootFiles = Get-ChildItem $wwwroot -Recurse -File | Measure-Object -Property Length -Sum
Write-Host "  - API:      $($apiFiles.Count) files ($([math]::Round($apiFiles.Sum/1MB, 2)) MB)" -ForegroundColor Gray
Write-Host "  - Frontend: $($wwwrootFiles.Count) files ($([math]::Round($wwwrootFiles.Sum/1MB, 2)) MB)" -ForegroundColor Gray
Write-Host ""
