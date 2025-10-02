# End-to-End Deployment Setup Script
# This script helps you set up and test the GitHub Actions deployment pipeline

param(
    [switch]$SetupEnvironments = $false,
    [switch]$TestLocalDeploy = $false,
    [switch]$CommitAndPush = $false,
    [string]$Environment = "dev"
)

Write-Host "🚀 Auth0 Terraform - End-to-End Deployment Setup" -ForegroundColor Blue
Write-Host "Repository: KaranGupta05/terrform_auth0" -ForegroundColor Cyan

# Add GitHub CLI to PATH
if (Test-Path "C:\Program Files\GitHub CLI\gh.exe") {
    $env:PATH += ";C:\Program Files\GitHub CLI"
    $ghPath = "C:\Program Files\GitHub CLI\gh.exe"
} else {
    $ghPath = "gh"
}

function Write-Step {
    param([string]$Message, [string]$Color = "Yellow")
    Write-Host "`n📋 $Message" -ForegroundColor $Color
}

function Write-Success {
    param([string]$Message)
    Write-Host "✅ $Message" -ForegroundColor Green
}

function Write-Error {
    param([string]$Message)
    Write-Host "❌ $Message" -ForegroundColor Red
}

# Step 1: Setup GitHub Environments
if ($SetupEnvironments) {
    Write-Step "Setting up GitHub Environments"
    
    try {
        # Check GitHub CLI authentication
        & $ghPath auth status 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) {
            Write-Success "GitHub CLI is authenticated"
            
            # Create environments
            $environments = @("development", "staging", "production")
            foreach ($env in $environments) {
                Write-Host "Creating environment: $env" -ForegroundColor Cyan
                & $ghPath api repos/vnyrjkmr/auth0-terraform-deployment/environments/$env -X PUT | Out-Null
                if ($LASTEXITCODE -eq 0) {
                    Write-Success "Environment '$env' created"
                } else {
                    Write-Error "Failed to create environment '$env'"
                }
            }
            
            # Set up environment secrets for Auth0
            Write-Host "`nSetting up Auth0 environment secrets..." -ForegroundColor Cyan
            
            # Map environments to their corresponding tfvars files
            $envMapping = @{
                "development" = "dev"
                "staging" = "qa" 
                "production" = "prod"
            }
            
            foreach ($env in $environments) {
                $tfvarsFile = "config/$($envMapping[$env]).tfvars"
                
                if (Test-Path $tfvarsFile) {
                    Write-Host "Reading Auth0 credentials from $tfvarsFile" -ForegroundColor Cyan
                    
                    # Read the tfvars file and extract Auth0 credentials
                    $content = Get-Content $tfvarsFile -Raw
                    
                    # Extract values using regex
                    if ($content -match 'auth0_domain\s*=\s*"([^"]*)"') {
                        $auth0Domain = $matches[1]
                    }
                    if ($content -match 'auth0_client_id\s*=\s*"([^"]*)"') {
                        $auth0ClientId = $matches[1]
                    }
                    if ($content -match 'auth0_client_secret\s*=\s*"([^"]*)"') {
                        $auth0ClientSecret = $matches[1]
                    }
                    
                    if ($auth0Domain -and $auth0ClientId -and $auth0ClientSecret) {
                        # Set environment secrets using GitHub CLI
                        Write-Host "  Setting AUTH0_DOMAIN for $env..." -ForegroundColor Gray
                        Write-Output $auth0Domain | & $ghPath secret set AUTH0_DOMAIN --env $env 2>$null
                        
                        Write-Host "  Setting AUTH0_CLIENT_ID for $env..." -ForegroundColor Gray
                        Write-Output $auth0ClientId | & $ghPath secret set AUTH0_CLIENT_ID --env $env 2>$null
                        
                        Write-Host "  Setting AUTH0_CLIENT_SECRET for $env..." -ForegroundColor Gray
                        Write-Output $auth0ClientSecret | & $ghPath secret set AUTH0_CLIENT_SECRET --env $env 2>$null
                        
                        Write-Success "Auth0 secrets configured for $env environment"
                    } else {
                        Write-Error "Could not extract Auth0 credentials from $tfvarsFile"
                    }
                } else {
                    Write-Error "Configuration file $tfvarsFile not found"
                }
            }
        } else {
            Write-Error "GitHub CLI not authenticated. Run: gh auth login"
            return
        }
    } catch {
        Write-Error "Failed to setup environments: $_"
    }
}

# Step 2: Validate current setup
Write-Step "Validating Current Setup"

# Check required files
$requiredFiles = @{
    ".github/workflows/deploy-auth0.yml" = "GitHub Actions workflow"
    "config/dev.tfvars" = "Development environment variables"
    "config/qa.tfvars" = "Staging environment variables"
    "config/prod.tfvars" = "Production environment variables"
    "main.tf" = "Terraform main configuration"
    "variables.tf" = "Terraform variables"
}

$allFilesExist = $true
foreach ($file in $requiredFiles.GetEnumerator()) {
    if (Test-Path $file.Key) {
        Write-Success "$($file.Value) found: $($file.Key)"
    } else {
        Write-Error "$($file.Value) missing: $($file.Key)"
        $allFilesExist = $false
    }
}

if (-not $allFilesExist) {
    Write-Error "Some required files are missing. Please ensure all files are present."
    return
}

# Step 3: Test Local Deployment
if ($TestLocalDeploy) {
    Write-Step "Testing Local Terraform Deployment"
    
    # Check if terraform.tfvars exists with credentials
    if (-not (Test-Path "terraform.tfvars")) {
        Write-Error "terraform.tfvars not found. Please create it with your Auth0 credentials."
        Write-Host "Required format:" -ForegroundColor Yellow
        Write-Host 'auth0_domain = "your-domain.us.auth0.com"' -ForegroundColor Gray
        Write-Host 'auth0_client_id = "your-client-id"' -ForegroundColor Gray
        Write-Host 'auth0_client_secret = "your-client-secret"' -ForegroundColor Gray
        return
    }
    
    try {
        # Initialize Terraform
        Write-Host "Initializing Terraform..." -ForegroundColor Cyan
        terraform init
        
        if ($LASTEXITCODE -eq 0) {
            Write-Success "Terraform initialized successfully"
            
            # Validate configuration
            Write-Host "Validating Terraform configuration..." -ForegroundColor Cyan
            terraform validate
            
            if ($LASTEXITCODE -eq 0) {
                Write-Success "Terraform configuration is valid"
                
                # Run plan
                Write-Host "Running Terraform plan for $Environment environment..." -ForegroundColor Cyan
                terraform plan -var-file="$Environment.tfvars"
                
                if ($LASTEXITCODE -eq 0) {
                    Write-Success "Terraform plan completed successfully"
                } else {
                    Write-Error "Terraform plan failed"
                }
            } else {
                Write-Error "Terraform validation failed"
            }
        } else {
            Write-Error "Terraform initialization failed"
        }
    } catch {
        Write-Error "Local deployment test failed: $_"
    }
}

# Step 4: Commit and Push Changes
if ($CommitAndPush) {
    Write-Step "Committing and Pushing Changes to GitHub"
    
    try {
        # Check if there are changes to commit
        $gitStatus = git status --porcelain
        if ($gitStatus) {
            Write-Host "Changes detected:" -ForegroundColor Cyan
            git status --short
            
            # Add all changes
            git add .
            
            # Commit with descriptive message
            $commitMessage = "feat: implement comprehensive GitHub Actions deployment pipeline

- Add multi-environment support (development/staging/production)
- Implement branching strategy-based deployment logic
- Add automatic release tagging for production deployments  
- Include comprehensive validation and approval gates
- Support feature branches, hotfixes, and release branches"

            git commit -m "$commitMessage"
            
            if ($LASTEXITCODE -eq 0) {
                Write-Success "Changes committed successfully"
                
                # Push to main branch
                Write-Host "Pushing to main branch..." -ForegroundColor Cyan
                git push origin main
                
                if ($LASTEXITCODE -eq 0) {
                    Write-Success "Changes pushed to GitHub successfully"
                } else {
                    Write-Error "Failed to push changes to GitHub"
                }
            } else {
                Write-Error "Failed to commit changes"
            }
        } else {
            Write-Host "No changes to commit" -ForegroundColor Yellow
        }
    } catch {
        Write-Error "Failed to commit and push changes: $_"
    }
}

# Step 5: Next Steps Instructions
Write-Step "Next Steps for End-to-End Testing" "Green"

Write-Host "1. 🔐 Set up GitHub Repository Secrets:" -ForegroundColor White
Write-Host "   Go to: https://github.com/vnyrjkmr/auth0-terraform-deployment/settings/secrets/actions" -ForegroundColor Cyan
Write-Host "   Add these secrets:" -ForegroundColor White
Write-Host "   • AUTH0_DOMAIN" -ForegroundColor Gray
Write-Host "   • AUTH0_CLIENT_ID" -ForegroundColor Gray
Write-Host "   • AUTH0_CLIENT_SECRET" -ForegroundColor Gray

Write-Host "`n2. 🌍 Configure GitHub Environments:" -ForegroundColor White
Write-Host "   Go to: https://github.com/vnyrjkmr/auth0-terraform-deployment/settings/environments" -ForegroundColor Cyan
Write-Host "   • development: No restrictions" -ForegroundColor Gray
Write-Host "   • staging: Require 1 reviewer, 5-minute wait" -ForegroundColor Gray  
Write-Host "   • production: Require 2 reviewers, 15-minute wait" -ForegroundColor Gray

Write-Host "`n3. 🧪 Test the Deployment Flow:" -ForegroundColor White
Write-Host "   Feature Branch → Development:" -ForegroundColor Cyan
Write-Host "   git checkout -b feature/test-deployment" -ForegroundColor Gray
Write-Host "   git push origin feature/test-deployment" -ForegroundColor Gray
Write-Host "   # Creates PR → Shows plan only" -ForegroundColor Green

Write-Host "`n   Development Deployment:" -ForegroundColor Cyan
Write-Host "   git checkout development" -ForegroundColor Gray
Write-Host "   git merge feature/test-deployment" -ForegroundColor Gray
Write-Host "   git push origin development" -ForegroundColor Gray
Write-Host "   # Deploys to development tenant automatically" -ForegroundColor Green

Write-Host "`n   Staging Deployment:" -ForegroundColor Cyan
Write-Host "   git checkout -b release/v1.0.0" -ForegroundColor Gray
Write-Host "   git push origin release/v1.0.0" -ForegroundColor Gray
Write-Host "   # Deploys to staging tenant with approval" -ForegroundColor Green

Write-Host "`n   Production Deployment:" -ForegroundColor Cyan
Write-Host "   git checkout main" -ForegroundColor Gray
Write-Host "   git merge release/v1.0.0" -ForegroundColor Gray
Write-Host "   git push origin main" -ForegroundColor Gray
Write-Host "   # Deploys to production tenant with approval + creates tag" -ForegroundColor Green

Write-Host "`n4. 🔗 Useful Links:" -ForegroundColor White
Write-Host "   • Actions: https://github.com/vnyrjkmr/auth0-terraform-deployment/actions" -ForegroundColor Cyan
Write-Host "   • Secrets: https://github.com/vnyrjkmr/auth0-terraform-deployment/settings/secrets" -ForegroundColor Cyan
Write-Host "   • Environments: https://github.com/vnyrjkmr/auth0-terraform-deployment/settings/environments" -ForegroundColor Cyan

Write-Host "`n💡 Pro Tips:" -ForegroundColor Blue
Write-Host "• Use 'workflow_dispatch' for manual deployments" -ForegroundColor White
Write-Host "• Monitor deployments in the Actions tab" -ForegroundColor White
Write-Host "• Check environment protection rules are properly configured" -ForegroundColor White
Write-Host "• Test with small changes first" -ForegroundColor White

Write-Host "`n🎯 Ready to deploy! Use the flags to run specific steps:" -ForegroundColor Green
Write-Host ".\setup-end-to-end.ps1 -SetupEnvironments" -ForegroundColor Gray
Write-Host ".\setup-end-to-end.ps1 -TestLocalDeploy -Environment dev" -ForegroundColor Gray
Write-Host ".\setup-end-to-end.ps1 -CommitAndPush" -ForegroundColor Gray