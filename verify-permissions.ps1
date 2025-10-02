$token = $null

# Get Auth0 credentials from terraform.tfvars
$tfvars = Get-Content "terraform.tfvars" | Where-Object { $_ -match '^auth0_' }
$auth0Config = @{}
$tfvars | ForEach-Object {
    if ($_ -match '^auth0_(\w+)\s*=\s*"([^"]+)"') {
        $auth0Config[$matches[1]] = $matches[2]
    }
}

# Get access token
$tokenRequest = @{
    Method  = "POST"
    Uri     = "https://$($auth0Config.domain)/oauth/token"
    Body    = @{
        client_id     = $auth0Config.client_id
        client_secret = $auth0Config.client_secret
        audience      = "https://$($auth0Config.domain)/api/v2/"
        grant_type    = "client_credentials"
    } | ConvertTo-Json
    Headers = @{
        "Content-Type" = "application/json"
    }
}

try {
    $tokenResponse = Invoke-RestMethod @tokenRequest
    $token = $tokenResponse.access_token
    Write-Host "✅ Successfully obtained access token" -ForegroundColor Green
} catch {
    Write-Host "❌ Failed to get access token: $_" -ForegroundColor Red
    exit 1
}

# Check permissions
$headers = @{
    "Authorization" = "Bearer $token"
}

$response = Invoke-RestMethod -Uri "https://$($auth0Config.domain)/api/v2/client-grants" -Headers $headers -Method Get

Write-Host "`nChecking permissions for client ID: $($auth0Config.client_id)" -ForegroundColor Cyan

$requiredScopes = @(
    "read:roles",
    "create:roles",
    "delete:roles",
    "update:roles",
    "read:role_members",
    "update:role_members",
    "read:actions",
    "create:actions",
    "update:actions",
    "delete:actions"
)

$clientGrant = $response | Where-Object { $_.client_id -eq $auth0Config.client_id }

if ($clientGrant) {
    Write-Host "`nCurrent permissions:" -ForegroundColor Yellow
    $clientGrant.scope | ForEach-Object {
        Write-Host "  • $_" -ForegroundColor Gray
    }

    Write-Host "`nMissing permissions:" -ForegroundColor Yellow
    $missingScopes = $requiredScopes | Where-Object { $clientGrant.scope -notcontains $_ }
    if ($missingScopes) {
        $missingScopes | ForEach-Object {
            Write-Host "  • $_" -ForegroundColor Red
        }
    } else {
        Write-Host "  ✅ None - All required permissions are granted" -ForegroundColor Green
    }
} else {
    Write-Host "❌ No permissions found for this client ID" -ForegroundColor Red
}