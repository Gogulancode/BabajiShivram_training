# Test Role Access API

## Quick Test Script

### Step 1: Start the API
Open PowerShell and run:
```powershell
cd "d:\BabajiShivram_training\backend\ERPTraining.API"
dotnet run
```

### Step 2: Seed the Role Data
In another PowerShell window, run:
```powershell
# Seed the data
$seedUrl = "https://localhost:7001/api/roleaccess/seed-data"
try {
    $response = Invoke-RestMethod -Uri $seedUrl -Method POST -ContentType "application/json" -SkipCertificateCheck
    Write-Host "Seed Response: $($response | ConvertTo-Json -Depth 3)"
} catch {
    Write-Host "Error seeding data: $_"
    Write-Host "Status Code: $($_.Exception.Response.StatusCode)"
}
```

### Step 3: Verify Role 10 Data
```powershell
# Check Role 10 (Operations-Sea) permissions
$role10Url = "https://localhost:7001/api/roleaccess/role/10"
try {
    $response = Invoke-RestMethod -Uri $role10Url -Method GET -ContentType "application/json" -SkipCertificateCheck
    Write-Host "Role 10 Data: $($response | ConvertTo-Json -Depth 3)"
    Write-Host "Number of sections for Role 10: $($response.Count)"
} catch {
    Write-Host "Error getting Role 10 data: $_"
}
```

### Step 4: Check All Roles Summary
```powershell
# Get all roles with access summary
$rolesUrl = "https://localhost:7001/api/roleaccess/roles-summary"
try {
    $response = Invoke-RestMethod -Uri $rolesUrl -Method GET -ContentType "application/json" -SkipCertificateCheck
    Write-Host "All Roles Summary: $($response | ConvertTo-Json -Depth 3)"
} catch {
    Write-Host "Error getting roles summary: $_"
}
```

### Step 5: Test All Available Endpoints
```powershell
# Test all role access endpoints
$baseUrl = "https://localhost:7001/api/roleaccess"
$endpoints = @(
    "",                          # Get all role access
    "/role/1",                   # Role 1 (Admin)
    "/role/10",                  # Role 10 (Operations)
    "/role/100",                 # Role 100 (Super Admin)
    "/roles-summary",            # All roles summary
    "/test-roles"                # Test roles endpoint
)

foreach ($endpoint in $endpoints) {
    $url = $baseUrl + $endpoint
    Write-Host "`n=== Testing: $url ==="
    try {
        $response = Invoke-RestMethod -Uri $url -Method GET -ContentType "application/json" -SkipCertificateCheck
        Write-Host "Success: $($response | ConvertTo-Json -Depth 2 | Out-String -Width 1000)"
    } catch {
        Write-Host "Error: $_"
    }
}
```

## Expected Results
- **Role 1**: 70 sections 
- **Role 10**: 25 sections
- **Role 100**: 126 sections

## If Data is Missing
If any role shows 0 permissions, run the seed command again or check:
1. Database connection
2. Entity Framework migrations
3. Service registration in Program.cs
