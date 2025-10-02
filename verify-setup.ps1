# Quick Setup Verification Script
Write-Host "🔍 Verifying Auth0 Terraform Setup" -ForegroundColor Cyan

$requiredFiles = @{
    "main.tf" = "Terraform main configuration"
    "variables.tf" = "Terraform variables"
    "outputs.tf" = "Terraform outputs"
    ".github/workflows/deploy-auth0.yml" = "GitHub Actions workflow"
    "config/dev.tfvars" = "Development environment variables"
    "config/qa.tfvars" = "Staging environment variables" 
    "config/prod.tfvars" = "Production environment variables"
}

Write-Host "`n📋 File Verification:" -ForegroundColor Yellow
$allFilesExist = $true

foreach ($file in $requiredFiles.GetEnumerator()) {
    if (Test-Path $file.Key) {
        Write-Host "✅ $($file.Value): $($file.Key)" -ForegroundColor Green
    } else {
        Write-Host "❌ $($file.Value): $($file.Key)" -ForegroundColor Red
        $allFilesExist = $false
    }
}

Write-Host "`n📋 Summary:" -ForegroundColor Yellow
if ($allFilesExist) {
    Write-Host "✅ All required files are present!" -ForegroundColor Green
    Write-Host "✅ Your Auth0 Terraform setup is complete." -ForegroundColor Green
} else {
    Write-Host "❌ Some files are missing. Please check the output above." -ForegroundColor Red
}

# Additional checks
Write-Host "`n📋 Additional Information:" -ForegroundColor Yellow
Write-Host "📁 Current Directory: $(Get-Location)" -ForegroundColor Gray
Write-Host "📁 Total Files: $((Get-ChildItem -File).Count)" -ForegroundColor Gray
Write-Host "📁 Total Directories: $((Get-ChildItem -Directory).Count)" -ForegroundColor Gray