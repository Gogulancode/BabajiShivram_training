# Test Section Seeding Script
Write-Host "Testing Section Seeding for Module 1..." -ForegroundColor Green

# Start the API in the background
Write-Host "Starting API..." -ForegroundColor Yellow
$apiProcess = Start-Process -FilePath "dotnet" -ArgumentList "run" -PassThru -WindowStyle Hidden

# Wait for API to start
Write-Host "Waiting for API to start..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

try {
    # Test the modules endpoint
    Write-Host "Testing modules endpoint..." -ForegroundColor Yellow
    $modulesResponse = Invoke-RestMethod -Uri "http://localhost:5000/api/modules" -Method GET -Headers @{
        "Accept" = "application/json"
    }
    
    Write-Host "Found $($modulesResponse.Count) modules" -ForegroundColor Green
    
    if ($modulesResponse.Count -gt 0) {
        $module1 = $modulesResponse | Where-Object { $_.erpModuleId -eq "1" }
        if ($module1) {
            Write-Host "Found Module 1: $($module1.title)" -ForegroundColor Green
            
            # Test sections for Module 1
            Write-Host "Testing sections for Module 1..." -ForegroundColor Yellow
            $sectionsResponse = Invoke-RestMethod -Uri "http://localhost:5000/api/sections/module/$($module1.id)" -Method GET -Headers @{
                "Accept" = "application/json"
            }
            
            Write-Host "Found $($sectionsResponse.Count) sections for Module 1" -ForegroundColor Green
            
            if ($sectionsResponse.Count -gt 0) {
                Write-Host "Sample sections:" -ForegroundColor Cyan
                $sectionsResponse | Select-Object -First 5 | ForEach-Object {
                    Write-Host "  - $($_.title) (ERP ID: $($_.erpSectionId))" -ForegroundColor Cyan
                }
            }
        } else {
            Write-Host "Module 1 not found" -ForegroundColor Red
        }
    }
}
catch {
    Write-Host "Error testing API: $($_.Exception.Message)" -ForegroundColor Red
}
finally {
    # Stop the API process
    Write-Host "Stopping API..." -ForegroundColor Yellow
    if ($apiProcess -and !$apiProcess.HasExited) {
        $apiProcess.Kill()
    }
}

Write-Host "Test completed!" -ForegroundColor Green
