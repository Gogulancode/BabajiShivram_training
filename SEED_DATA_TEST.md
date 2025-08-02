# Role Mapping Data Seeding Test

## Test the seeding endpoint

### 1. Start the API
```bash
cd "d:\BabajiShivram_training\backend\ERPTraining.API"
dotnet run
```

### 2. Seed the data using curl or Postman
```bash
curl -X POST "https://localhost:7001/api/roleaccess/seed-data" -H "Content-Type: application/json"
```

Or using PowerShell:
```powershell
Invoke-RestMethod -Uri "https://localhost:7001/api/roleaccess/seed-data" -Method POST -ContentType "application/json"
```

### 3. Verify the data
```bash
curl -X GET "https://localhost:7001/api/roleaccess/role/10" -H "Content-Type: application/json"
```

## Expected Response
The role 10 should return 25 sections across modules 1 and 4.

## Troubleshooting
1. Check if database is created and connected
2. Verify the connection string in appsettings.json
3. Check if migrations are applied
4. Verify that the seeding service is properly registered

## Frontend Issues
If the frontend still shows 0 permissions after seeding:
1. Check if the frontend is calling the correct API endpoints
2. Verify CORS settings in the API
3. Check browser console for errors
4. Ensure the frontend is reading from the correct data source
