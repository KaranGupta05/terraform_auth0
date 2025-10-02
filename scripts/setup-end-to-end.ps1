# End-to-End Deployment Setup Script
# This script helps you set up and test the GitHub Actions deployment pipeline

param(
    [switch]$SetupEnvironments = $false,
    [switch]$TestLocalDeploy = $false,
    [switch]$CommitAndPush = $false,
    [string]$Environment = "dev"
)

# Helper Functions
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

Write-Host "🚀 Auth0 Terraform - End-to-End Deployment Setup" -ForegroundColor Blue

# Interactive Configuration Section
Write-Step "Interactive Configuration Setup" "Cyan"

# Get GitHub Repository URL
$defaultRepoUrl = "KaranGupta05/terrform_auth0"
$repoUrl = Read-Host "Enter GitHub repository URL (owner/repo format) [$defaultRepoUrl]"
if ([string]::IsNullOrWhiteSpace($repoUrl)) {
    $repoUrl = $defaultRepoUrl
}
Write-Host "Using repository: $repoUrl" -ForegroundColor Cyan

# Extract owner and repo name from URL
if ($repoUrl -match "^(?:https://github\.com/)?([^/]+)/([^/]+?)(?:\.git)?/?$") {
    $repoOwner = $matches[1]
    $repoName = $matches[2]
} elseif ($repoUrl -match "^([^/]+)/([^/]+)$") {
    $repoOwner = $matches[1]
    $repoName = $matches[2]
} else {
    Write-Error "Invalid repository URL format. Use: owner/repo or https://github.com/owner/repo"
    exit 1
}

Write-Host "Repository Owner: $repoOwner" -ForegroundColor Gray
Write-Host "Repository Name: $repoName" -ForegroundColor Gray

# Get Auth0 Configuration for Each Environment
Write-Host "`n🔐 Auth0 Configuration for Each Environment" -ForegroundColor Yellow
Write-Host "You'll need to provide Auth0 credentials for each environment (development, staging, production)" -ForegroundColor Cyan

$auth0Config = @{}
$environments = @("development", "staging", "production")

foreach ($env in $environments) {
    Write-Host "`n--- $($env.ToUpper()) Environment ---" -ForegroundColor Magenta
    
    $envDomain = Read-Host "Enter Auth0 Domain for $env (e.g., $env-xyz.us.auth0.com)"
    $envClientId = Read-Host "Enter Auth0 Client ID for $env"
    $envClientSecret = Read-Host "Enter Auth0 Client Secret for $env" -AsSecureString
    $envClientSecretPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($envClientSecret))
    
    # Validate inputs for this environment
    if ([string]::IsNullOrWhiteSpace($envDomain) -or [string]::IsNullOrWhiteSpace($envClientId) -or [string]::IsNullOrWhiteSpace($envClientSecretPlain)) {
        Write-Error "All Auth0 configuration values are required for $env environment"
        exit 1
    }
    
    # Store configuration for this environment
    $auth0Config[$env] = @{
        Domain = $envDomain
        ClientId = $envClientId
        ClientSecret = $envClientSecretPlain
    }
    
    Write-Success "✅ $env environment configuration collected"
}

# Optional Configuration
Write-Host "`n⚙️ Optional Configuration" -ForegroundColor Yellow
$tenantFriendlyName = Read-Host "Enter Tenant Friendly Name [CDW]"
if ([string]::IsNullOrWhiteSpace($tenantFriendlyName)) {
    $tenantFriendlyName = "CDW"
}

$tenantSupportEmail = Read-Host "Enter Tenant Support Email [support@$tenantFriendlyName.com]"
if ([string]::IsNullOrWhiteSpace($tenantSupportEmail)) {
    $tenantSupportEmail = "support@$tenantFriendlyName.com"
}

# Display collected configuration
Write-Host "`n📋 Configuration Summary:" -ForegroundColor Green
Write-Host "Repository: $repoUrl" -ForegroundColor White
Write-Host "Tenant Name: $tenantFriendlyName" -ForegroundColor White
Write-Host "Support Email: $tenantSupportEmail" -ForegroundColor White

Write-Host "`nAuth0 Configuration by Environment:" -ForegroundColor Yellow
foreach ($env in $environments) {
    $config = $auth0Config[$env]
    Write-Host "  $($env.ToUpper()):" -ForegroundColor Cyan
    Write-Host "    Domain: $($config.Domain)" -ForegroundColor White
    Write-Host "    Client ID: $($config.ClientId)" -ForegroundColor White
    Write-Host "    Client Secret: $('*' * $config.ClientSecret.Length)" -ForegroundColor White
}

$confirm = Read-Host "`nDo you want to continue with this configuration? (y/N)"
if ($confirm -ne 'y' -and $confirm -ne 'Y') {
    Write-Host "Setup cancelled by user" -ForegroundColor Yellow
    exit 0
}

# Add GitHub CLI to PATH
if (Test-Path "C:\Program Files\GitHub CLI\gh.exe") {
    $env:PATH += ";C:\Program Files\GitHub CLI"
    $ghPath = "C:\Program Files\GitHub CLI\gh.exe"
} else {
    $ghPath = "gh"
}



# Step 1: Setup GitHub Environments
if ($SetupEnvironments) {
    Write-Step "Setting up GitHub Environments"
    
    try {
        # Check GitHub CLI authentication
        Write-Host "Verifying GitHub CLI authentication..." -ForegroundColor Cyan
        $authStatus = & $ghPath auth status 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            Write-Success "GitHub CLI is authenticated"
            
            # Display authentication info for verification
            $authInfo = $authStatus | Select-String "Logged in to github.com as"
            if ($authInfo) {
                Write-Host "  $authInfo" -ForegroundColor Gray
            }
            
            # Check if authenticated user has access to the repository
            Write-Host "Verifying repository access..." -ForegroundColor Cyan
            $repoAccess = & $ghPath repo view $repoUrl --json permissions 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-Success "Repository access confirmed"
                $repoInfo = $repoAccess | ConvertFrom-Json
                if ($repoInfo.permissions.admin -eq $true) {
                    Write-Success "Admin access confirmed - can create environments and secrets"
                } elseif ($repoInfo.permissions.push -eq $true) {
                    Write-Host "⚠️  Push access detected - may have limited environment creation abilities" -ForegroundColor Yellow
                } else {
                    Write-Host "⚠️  Limited repository access - may not be able to create environments" -ForegroundColor Yellow
                }
            } else {
                Write-Error "Cannot access repository $repoUrl. Please check repository name and permissions."
                return
            }
            
            # Check if GitHub Actions is enabled
            Write-Host "Checking GitHub Actions status..." -ForegroundColor Cyan
            $actionsStatus = & $ghPath api repos/$repoUrl/actions/permissions --jq '.enabled' 2>&1
            if ($actionsStatus -eq "true") {
                Write-Success "GitHub Actions is enabled"
            } else {
                Write-Host "⚠️ GitHub Actions might not be enabled. This is required for environments." -ForegroundColor Yellow
                Write-Host "   Enable it at: https://github.com/$repoUrl/settings/actions" -ForegroundColor Cyan
            }
            
            # Create environments using GitHub CLI commands
            $environments = @("development", "staging", "production")
            foreach ($env in $environments) {
                Write-Host "Creating environment: $env" -ForegroundColor Cyan
                
                # Create environment using GitHub CLI variable command (which creates environment if needed)
                # We'll use a dummy variable to create the environment, then delete it
                $result = & $ghPath variable set TEMP_SETUP_VAR --value "setup" --env $env --repo $repoUrl 2>&1
                
                if ($LASTEXITCODE -eq 0) {
                    Write-Success "Environment '$env' created successfully"
                    
                    # Clean up the temporary variable
                    & $ghPath variable delete TEMP_SETUP_VAR --env $env --repo $repoUrl 2>&1 | Out-Null
                } else {
                    Write-Error "Failed to create environment '$env'. Error: $result"
                    Write-Host "Debug info - Exit code: $LASTEXITCODE" -ForegroundColor Yellow
                    
                    Write-Host "💡 You may need to enable GitHub Actions and environments in repository settings" -ForegroundColor Yellow
                    Write-Host "   Go to: https://github.com/$repoUrl/settings/actions" -ForegroundColor Cyan
                }
            }
            
            # Verify environments were created before setting secrets
            Write-Host "`nVerifying created environments..." -ForegroundColor Cyan
            $createdEnvironments = @()
            
            foreach ($env in $environments) {
                Write-Host "Checking if $env environment exists..." -ForegroundColor Gray
                
                # Try to list variables for the environment to verify it exists
                $checkResult = & $ghPath variable list --env $env --repo $repoUrl 2>&1
                
                if ($LASTEXITCODE -eq 0) {
                    Write-Success "$env environment exists and is accessible"
                    $createdEnvironments += $env
                } else {
                    Write-Error "$env environment was not created successfully or is not accessible"
                    Write-Host "Error: $checkResult" -ForegroundColor Red
                }
            }
            
            if ($createdEnvironments.Count -eq 0) {
                Write-Error "No environments were created successfully. Cannot set secrets."
                Write-Host "💡 Try creating environments manually at: https://github.com/$repoUrl/settings/environments" -ForegroundColor Yellow
                return
            }
            
            # Set up environment secrets for Auth0 (only for successfully created environments)
            Write-Host "`nSetting up Auth0 environment secrets..." -ForegroundColor Cyan
            
            foreach ($env in $createdEnvironments) {
                Write-Host "Setting Auth0 secrets for $env environment..." -ForegroundColor Cyan
                
                # Get environment-specific credentials
                $envConfig = $auth0Config[$env]
                
                # Set environment secrets using GitHub CLI with proper repo specification and authentication
                Write-Host "  Setting AUTH0_DOMAIN for $env..." -ForegroundColor Gray
                $domainResult = Write-Output $envConfig.Domain | & $ghPath secret set AUTH0_DOMAIN --env $env --repo $repoUrl 2>&1
                
                if ($LASTEXITCODE -eq 0) {
                    Write-Success "AUTH0_DOMAIN set successfully for $env"
                } else {
                    Write-Error "Failed to set AUTH0_DOMAIN for $env. Error: $domainResult"
                }
                
                Write-Host "  Setting AUTH0_CLIENT_ID for $env..." -ForegroundColor Gray
                $clientIdResult = Write-Output $envConfig.ClientId | & $ghPath secret set AUTH0_CLIENT_ID --env $env --repo $repoUrl 2>&1
                
                if ($LASTEXITCODE -eq 0) {
                    Write-Success "AUTH0_CLIENT_ID set successfully for $env"
                } else {
                    Write-Error "Failed to set AUTH0_CLIENT_ID for $env. Error: $clientIdResult"
                }
                
                Write-Host "  Setting AUTH0_CLIENT_SECRET for $env..." -ForegroundColor Gray
                $clientSecretResult = Write-Output $envConfig.ClientSecret | & $ghPath secret set AUTH0_CLIENT_SECRET --env $env --repo $repoUrl 2>&1
                
                if ($LASTEXITCODE -eq 0) {
                    Write-Success "AUTH0_CLIENT_SECRET set successfully for $env"
                    Write-Success "✅ All Auth0 secrets configured for $env environment"
                } else {
                    Write-Error "Failed to set AUTH0_CLIENT_SECRET for $env. Error: $clientSecretResult"
                }
                
                Write-Host "" # Add spacing between environments
            }
            
            # Update tfvars files with collected configuration
            Write-Host "`nUpdating configuration files..." -ForegroundColor Cyan
            $envMapping = @{
                "development" = "dev"
                "staging" = "qa" 
                "production" = "prod"
            }
            
            foreach ($envType in $envMapping.GetEnumerator()) {
                $tfvarsFile = "config/$($envType.Value).tfvars"
                Write-Host "Updating $tfvarsFile..." -ForegroundColor Gray
                
                # Get environment-specific Auth0 configuration
                $envConfig = $auth0Config[$envType.Key]
                
                # Create or update tfvars file with environment-specific credentials
                $tfvarsContent = @"
# $($envType.Key.Substring(0,1).ToUpper() + $envType.Key.Substring(1)) environment
auth0_domain        = "$($envConfig.Domain)"
auth0_client_id     = "$($envConfig.ClientId)"
auth0_client_secret = "$($envConfig.ClientSecret)"

# Tenant Configuration
tenant_friendly_name = "$tenantFriendlyName"
tenant_support_email = "$tenantSupportEmail"

environment = "$($envType.Value)"

# SMTP configuration for email provider
smtp_host  = "smtp.yourprovider.com"
smtp_port  = 587
smtp_user  = "your-smtp-username"
smtp_pass  = "your-smtp-password"
smtp_secure = true

# Action Configuration - set to false if action already exists
create_login_action = false

# Resource Configuration - set to false if resources already exist
create_resource_server = false
create_admin_role = false
create_user_role = false

# Optional Features - set to true only if properly configured
create_email_templates = false
create_log_stream = false
enable_enhanced_breach_detection = false
enable_breach_detection = false
"@
                
                # Ensure config directory exists
                if (!(Test-Path "config")) {
                    New-Item -ItemType Directory -Path "config" -Force | Out-Null
                }
                
                # Write the configuration file
                Set-Content -Path $tfvarsFile -Value $tfvarsContent -Encoding UTF8
                Write-Success "Updated $tfvarsFile with $($envType.Key) environment credentials"
            }
            
            # Provide manual setup instructions if any environments failed
            if ($createdEnvironments.Count -lt $environments.Count) {
                Write-Host "`n🔧 Manual Environment Setup Required" -ForegroundColor Yellow
                Write-Host "Some environments weren't created automatically. Here's how to set them up manually:" -ForegroundColor Cyan
                
                Write-Host "`n1. Go to: https://github.com/$repoUrl/settings/environments" -ForegroundColor White
                Write-Host "2. Click 'New environment' for each missing environment" -ForegroundColor White
                Write-Host "3. Create these environments: development, staging, production" -ForegroundColor White
                
                Write-Host "`n4. For each environment, add these secrets:" -ForegroundColor White
                foreach ($env in $environments) {
                    if ($env -notin $createdEnvironments) {
                        $envConfig = $auth0Config[$env]
                        Write-Host "`n   $($env.ToUpper()) Environment Secrets:" -ForegroundColor Magenta
                        Write-Host "   AUTH0_DOMAIN = $($envConfig.Domain)" -ForegroundColor Gray
                        Write-Host "   AUTH0_CLIENT_ID = $($envConfig.ClientId)" -ForegroundColor Gray
                        Write-Host "   AUTH0_CLIENT_SECRET = $($envConfig.ClientSecret)" -ForegroundColor Gray
                    }
                }
                
                Write-Host "`n💡 After manual setup, your GitHub Actions workflows will have access to these secrets" -ForegroundColor Yellow
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
Write-Host "   Go to: https://github.com/$repoUrl/settings/secrets/actions" -ForegroundColor Cyan
Write-Host "   Add these secrets:" -ForegroundColor White
Write-Host "   • AUTH0_DOMAIN" -ForegroundColor Gray
Write-Host "   • AUTH0_CLIENT_ID" -ForegroundColor Gray
Write-Host "   • AUTH0_CLIENT_SECRET" -ForegroundColor Gray

Write-Host "`n2. 🌍 Configure GitHub Environments:" -ForegroundColor White
Write-Host "   Go to: https://github.com/$repoUrl/settings/environments" -ForegroundColor Cyan
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
Write-Host "   • Actions: https://github.com/$repoUrl/actions" -ForegroundColor Cyan
Write-Host "   • Secrets: https://github.com/$repoUrl/settings/secrets" -ForegroundColor Cyan
Write-Host "   • Environments: https://github.com/$repoUrl/settings/environments" -ForegroundColor Cyan

Write-Host "`n💡 Pro Tips:" -ForegroundColor Blue
Write-Host "• Use 'workflow_dispatch' for manual deployments" -ForegroundColor White
Write-Host "• Monitor deployments in the Actions tab" -ForegroundColor White
Write-Host "• Check environment protection rules are properly configured" -ForegroundColor White
Write-Host "• Test with small changes first" -ForegroundColor White

Write-Host "`n🎯 Ready to deploy! Use the flags to run specific steps:" -ForegroundColor Green
Write-Host ".\setup-end-to-end.ps1 -SetupEnvironments" -ForegroundColor Gray
Write-Host ".\setup-end-to-end.ps1 -TestLocalDeploy -Environment dev" -ForegroundColor Gray
Write-Host ".\setup-end-to-end.ps1 -CommitAndPush" -ForegroundColor Gray