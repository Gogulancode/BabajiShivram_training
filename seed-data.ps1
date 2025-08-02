try {
    $response = Invoke-RestMethod -Uri "http://localhost:5001/api/roleaccess/seed-data" -Method POST -Headers @{"Content-Type"="application/json"}
    Write-Host "Success: $($response | ConvertTo-Json)"
} catch {
    Write-Host "Error: $($_.Exception.Message)"
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "Response Body: $responseBody"
    }
}
