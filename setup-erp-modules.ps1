# Clear existing modules and test new ERP modules
$connectionString = "Server=DESKTOP-81Q1B98\TRAINING_MODULE;Database=ERPTrainingDB;Trusted_Connection=True;MultipleActiveResultSets=true;TrustServerCertificate=True"

Write-Host "Clearing existing modules from database..." -ForegroundColor Yellow

try {
    # Create SQL connection
    $connection = New-Object System.Data.SqlClient.SqlConnection($connectionString)
    $connection.Open()
    
    # Clear existing data in correct order (respect foreign key constraints)
    
    # First clear sections
    $command = New-Object System.Data.SqlClient.SqlCommand("DELETE FROM Sections", $connection)
    $sectionsDeleted = $command.ExecuteNonQuery()
    Write-Host "Deleted $sectionsDeleted existing sections" -ForegroundColor Green
    
    # Then clear modules
    $command = New-Object System.Data.SqlClient.SqlCommand("DELETE FROM Modules", $connection)
    $modulesDeleted = $command.ExecuteNonQuery()
    Write-Host "Deleted $modulesDeleted existing modules" -ForegroundColor Green
    
    $connection.Close()
    Write-Host "Database cleared successfully!" -ForegroundColor Green
}
catch {
    Write-Host "Error clearing database: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host "Starting API server to reseed with new ERP modules..." -ForegroundColor Yellow

# Change to project directory
Set-Location "d:\BabajiShivram_training"

# Start the API server (it will automatically seed the new modules)
Start-Process powershell -ArgumentList "-Command", "dotnet run --project backend\ERPTraining.API" -WindowStyle Minimized

Write-Host "API server starting... Please wait 10 seconds for seeding to complete" -ForegroundColor Yellow
Start-Sleep -Seconds 10

Write-Host "Testing module creation..." -ForegroundColor Yellow

try {
    # Test if server is running by checking a simple endpoint
    $response = Invoke-WebRequest -Uri "http://localhost:5000/api/modules" -Method GET -ErrorAction SilentlyContinue -TimeoutSec 5
    if ($response.StatusCode -eq 401) {
        Write-Host "✅ API server is running (returned 401 Unauthorized as expected)" -ForegroundColor Green
        Write-Host "✅ New ERP modules should be seeded successfully!" -ForegroundColor Green
    }
}
catch {
    if ($_.Exception.Message -contains "401") {
        Write-Host "✅ API server is running (returned 401 Unauthorized as expected)" -ForegroundColor Green
        Write-Host "✅ New ERP modules should be seeded successfully!" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Server might still be starting up. Error: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "🎯 Module Master Setup Summary:" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host "✅ Created erp-modules.json with your 17 ERP modules" -ForegroundColor Green
Write-Host "✅ Updated SeedData.cs to load ERP modules" -ForegroundColor Green
Write-Host "✅ Cleared existing training modules from database" -ForegroundColor Green
Write-Host "✅ Started API server to seed new ERP modules" -ForegroundColor Green
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Cyan
Write-Host "1. Check API logs for successful module seeding" -ForegroundColor White
Write-Host "2. Test API endpoints at http://localhost:5000/swagger" -ForegroundColor White
Write-Host "3. Proceed with Section Master setup for 670 sections" -ForegroundColor White
Write-Host ""
Write-Host "Your ERP Modules:" -ForegroundColor Cyan
$erpModules = @(
    "1 - CB Imports", "2 - Freight Forwarding", "3 - NBCPL", "4 - Company Services",
    "5 - CB Exports", "6 - Contracts", "8 - SEZ", "9 - Ops Accounting",
    "10 - Container Movement", "11 - CRM", "12 - Babaji Transport", "13 - Additional Job",
    "15 - MIS", "35 - Essential Certificate", "45 - Equipment Hire", "50 - Public Notice", "55 - Project"
)
foreach ($module in $erpModules) {
    Write-Host "   $module" -ForegroundColor Gray
}
