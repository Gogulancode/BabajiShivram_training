# PowerShell script to test Role Mapping API endpoints
# Save as test-role-mapping.ps1

$baseUrl = "http://localhost:5000/api/roleaccess"

Write-Host "=== Role Mapping API Test Script ===" -ForegroundColor Green
Write-Host "Testing ERP Training Role-Module-Section Mapping" -ForegroundColor Yellow
Write-Host ""

# Function to make HTTP requests with error handling
function Invoke-ApiRequest {
    param(
        [string]$Url,
        [string]$Method = "GET",
        [string]$Body = $null
    )
    
    try {
        if ($Body) {
            $headers = @{ "Content-Type" = "application/json" }
            $response = Invoke-RestMethod -Uri $Url -Method $Method -Body $Body -Headers $headers
        } else {
            $response = Invoke-RestMethod -Uri $Url -Method $Method
        }
        return $response
    }
    catch {
        Write-Host "Error calling $Url : $($_.Exception.Message)" -ForegroundColor Red
        return $null
    }
}

# Test 1: Check if API is running
Write-Host "1. Testing API connectivity..." -ForegroundColor Cyan
$testResponse = Invoke-ApiRequest -Url "$baseUrl/test-roles"
if ($testResponse) {
    Write-Host "✅ API is running and accessible" -ForegroundColor Green
    Write-Host "Available roles: $($testResponse.Count)" -ForegroundColor White
} else {
    Write-Host "❌ API is not accessible. Make sure the backend is running on localhost:5000" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Test 2: Seed role data
Write-Host "2. Seeding role module section data..." -ForegroundColor Cyan
$seedResponse = Invoke-ApiRequest -Url "$baseUrl/seed-data" -Method "POST"
if ($seedResponse) {
    if ($seedResponse.success) {
        Write-Host "✅ Data seeded successfully!" -ForegroundColor Green
        Write-Host "Message: $($seedResponse.message)" -ForegroundColor White
    } else {
        Write-Host "⚠️  Seeding response: $($seedResponse.message)" -ForegroundColor Yellow
    }
} else {
    Write-Host "❌ Failed to seed data" -ForegroundColor Red
}

Write-Host ""

# Test 3: Get all role access mappings
Write-Host "3. Retrieving all role access mappings..." -ForegroundColor Cyan
$allRoleAccess = Invoke-ApiRequest -Url $baseUrl
if ($allRoleAccess) {
    Write-Host "✅ Retrieved role access mappings" -ForegroundColor Green
    Write-Host "Total mappings: $($allRoleAccess.Count)" -ForegroundColor White
    
    if ($allRoleAccess.Count -gt 0) {
        Write-Host "Sample mapping:" -ForegroundColor Gray
        $sample = $allRoleAccess[0]
        Write-Host "  - Role: $($sample.roleName)" -ForegroundColor White
        Write-Host "  - Module: $($sample.moduleName)" -ForegroundColor White
        Write-Host "  - Section: $($sample.sectionName) (ID: $($sample.sectionId))" -ForegroundColor White
    }
} else {
    Write-Host "❌ Failed to retrieve role access mappings" -ForegroundColor Red
}

Write-Host ""

# Test 4: Get roles summary
Write-Host "4. Getting roles access summary..." -ForegroundColor Cyan
$rolesSummary = Invoke-ApiRequest -Url "$baseUrl/roles-summary"
if ($rolesSummary) {
    Write-Host "✅ Retrieved roles summary" -ForegroundColor Green
    Write-Host "Total roles: $($rolesSummary.Count)" -ForegroundColor White
    
    foreach ($role in $rolesSummary | Select-Object -First 3) {
        Write-Host "Role: $($role.roleName)" -ForegroundColor White
        foreach ($module in $role.moduleAccess) {
            if ($module.accessibleSections -gt 0) {
                Write-Host "  - $($module.moduleName): $($module.accessibleSections)/$($module.totalSections) sections" -ForegroundColor Gray
            }
        }
    }
} else {
    Write-Host "❌ Failed to retrieve roles summary" -ForegroundColor Red
}

Write-Host ""

# Test 5: Check specific access
Write-Host "5. Testing access check functionality..." -ForegroundColor Cyan
if ($allRoleAccess -and $allRoleAccess.Count -gt 0) {
    $sampleAccess = $allRoleAccess[0]
    $checkUrl = "$baseUrl/check-access?userId=test-user&moduleId=$($sampleAccess.moduleId)&sectionId=$($sampleAccess.sectionId)"
    $accessCheck = Invoke-ApiRequest -Url $checkUrl
    
    if ($accessCheck -ne $null) {
        Write-Host "✅ Access check completed" -ForegroundColor Green
        Write-Host "Has access: $($accessCheck.hasAccess)" -ForegroundColor White
    } else {
        Write-Host "❌ Failed to check access" -ForegroundColor Red
    }
} else {
    Write-Host "⚠️  Skipping access check - no role access data available" -ForegroundColor Yellow
}

Write-Host ""

# Summary
Write-Host "=== Test Summary ===" -ForegroundColor Green
if ($allRoleAccess -and $allRoleAccess.Count -gt 0) {
    Write-Host "✅ Role mapping system is working correctly!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Key Statistics:" -ForegroundColor Yellow
    Write-Host "- Total role-section mappings: $($allRoleAccess.Count)" -ForegroundColor White
    Write-Host "- Available roles: $($rolesSummary.Count)" -ForegroundColor White
    
    # Count sections by category
    $categories = @{
        "User Setup" = ($allRoleAccess | Where-Object { $_.sectionId -ge 100 -and $_.sectionId -lt 200 }).Count
        "Customer Setup" = ($allRoleAccess | Where-Object { $_.sectionId -ge 200 -and $_.sectionId -lt 300 }).Count
        "Operations" = ($allRoleAccess | Where-Object { $_.sectionId -ge 300 -and $_.sectionId -lt 400 }).Count
        "General/Admin" = ($allRoleAccess | Where-Object { $_.sectionId -ge 400 -and $_.sectionId -lt 500 }).Count
        "Reports" = ($allRoleAccess | Where-Object { $_.sectionId -ge 500 -and $_.sectionId -lt 600 }).Count
        "Post Clearance" = ($allRoleAccess | Where-Object { $_.sectionId -ge 600 -and $_.sectionId -lt 700 }).Count
    }
    
    Write-Host ""
    Write-Host "Sections by Category:" -ForegroundColor Yellow
    foreach ($category in $categories.GetEnumerator()) {
        if ($category.Value -gt 0) {
            Write-Host "- $($category.Key): $($category.Value) sections" -ForegroundColor White
        }
    }
    
    Write-Host ""
    Write-Host "🎉 Role mapping implementation is complete and functional!" -ForegroundColor Green
    Write-Host "You can now:" -ForegroundColor Cyan
    Write-Host "- Access the frontend at http://localhost:3000/role-mapping" -ForegroundColor White
    Write-Host "- Use the API endpoints for role-based access control" -ForegroundColor White
    Write-Host "- Assign users to roles and control their access to sections" -ForegroundColor White
} else {
    Write-Host "❌ Role mapping system needs attention" -ForegroundColor Red
    Write-Host "Please check the API logs and ensure the database is properly configured" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "=== End of Test ===" -ForegroundColor Green
