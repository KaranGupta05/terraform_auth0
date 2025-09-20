param(
    [string]$Environment = "dev"
)

$TfvarsFile = "${Environment}.tfvars"

Write-Host "🚀 Deploying Auth0 infrastructure for environment: $Environment" -ForegroundColor Blue

# Check if Terraform is installed
if (!(Get-Command terraform -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Terraform is not installed. Please install Terraform first." -ForegroundColor Red
    Write-Host "   Download from: https://www.terraform.io/downloads.html" -ForegroundColor Yellow
    exit 1
}

# Check if tfvars file exists
if (!(Test-Path $TfvarsFile)) {
    Write-Host "❌ Variables file $TfvarsFile not found." -ForegroundColor Red
    Write-Host "   Please create $TfvarsFile with your Auth0 configuration." -ForegroundColor Yellow
    exit 1
}

# Initialize Terraform if .terraform doesn't exist
if (!(Test-Path ".terraform")) {
    Write-Host "📦 Initializing Terraform..." -ForegroundColor Blue
    terraform init
}

# Validate configuration
Write-Host "✅ Validating Terraform configuration..." -ForegroundColor Blue
terraform validate

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Terraform validation failed" -ForegroundColor Red
    exit 1
}

# Plan deployment
Write-Host "📋 Planning deployment..." -ForegroundColor Blue
terraform plan -var-file="$TfvarsFile"

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Terraform plan failed" -ForegroundColor Red
    exit 1
}

# Ask for confirmation
$confirm = Read-Host "Do you want to proceed with the deployment? (y/N)"
if ($confirm -eq 'y' -or $confirm -eq 'Y') {
    Write-Host "🚀 Applying Terraform configuration..." -ForegroundColor Blue
    terraform apply -var-file="$TfvarsFile" -auto-approve
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "`n✅ Deployment completed successfully!" -ForegroundColor Green
    } else {
        Write-Host "`n❌ Deployment failed" -ForegroundColor Red
    }
} else {
    Write-Host "Deployment cancelled" -ForegroundColor Yellow
}