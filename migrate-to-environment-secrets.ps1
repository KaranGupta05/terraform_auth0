# 🔄 Migration Script: Repository Secrets → Environment Secrets
# This script migrates from repository-level secrets to environment-specific secrets

param(
    [switch]$DryRun = $false,
    [switch]$Cleanup = $false
)

Write-Host "🔄 Migrating to Environment-Specific Secrets" -ForegroundColor Blue
Write-Host "Repository: KaranGupta05/terraform_auth0" -ForegroundColor Cyan

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

# First, let's get the current repository secrets
Write-Step "Reading Current Repository Secrets"

$secrets = @{
    "development" = @{
        "AUTH0_DOMAIN" = "dev-fimbrzye0161xm5f.us.auth0.com"
        "AUTH0_CLIENT_ID" = "bl6gTEatijSPH9JeiwJ0pwqNJwrM0eaW"
        "AUTH0_CLIENT_SECRET" = "F5RPxpq2CXv8zWW7jK3AOPbDS5zYryzng5qZsT1l6Vok49FpBuwvYrYZZnCYboUw"
    }
    "staging" = @{
        "AUTH0_DOMAIN" = "dev-fimbrzye0161xm5f.us.auth0.com"
        "AUTH0_CLIENT_ID" = "bl6gTEatijSPH9JeiwJ0pwqNJwrM0eaW"
        "AUTH0_CLIENT_SECRET" = "F5RPxpq2CXv8zWW7jK3AOPbDS5zYryzng5qZsT1l6Vok49FpBuwvYrYZZnCYboUw"
    }
    "production" = @{
        "AUTH0_DOMAIN" = "dev-fimbrzye0161xm5f.us.auth0.com"
        "AUTH0_CLIENT_ID" = "bl6gTEatijSPH9JeiwJ0pwqNJwrM0eaW"
        "AUTH0_CLIENT_SECRET" = "F5RPxpq2CXv8zWW7jK3AOPbDS5zYryzng5qZsT1l6Vok49FpBuwvYrYZZnCYboUw"
    }
}

Write-Step "Creating Environment-Specific Secrets"

foreach ($envName in $secrets.Keys) {
    Write-Host "`n🌍 Setting up $envName environment secrets..." -ForegroundColor Cyan
    
    # First ensure the environment exists
    Write-Host "  Ensuring environment exists..." -ForegroundColor Gray
    if (-not $DryRun) {
        gh api "repos/KaranGupta05/terraform_auth0/environments/$envName" -X PUT | Out-Null
        if ($LASTEXITCODE -eq 0) {
            Write-Success "  Environment '$envName' ready"
        } else {
            Write-Error "  Failed to create environment '$envName'"
            continue
        }
    } else {
        Write-Host "  [DRY RUN] Would create environment: $envName" -ForegroundColor Gray
    }
    
    # Set environment secrets
    foreach ($secretName in $secrets[$envName].Keys) {
        $secretValue = $secrets[$envName][$secretName]
        Write-Host "  Setting $secretName..." -ForegroundColor Gray
        
        if (-not $DryRun) {
            try {
                # Use GitHub API to set environment secret
                $body = @{
                    "encrypted_value" = $secretValue
                    "key_id" = ""
                } | ConvertTo-Json
                
                # Use gh CLI with proper syntax - pipe the secret value directly
                $result = Write-Output $secretValue | gh secret set $secretName --env $envName 2>&1
                
                if ($LASTEXITCODE -eq 0) {
                    Write-Success "    ✓ $secretName set for $envName"
                } else {
                    Write-Error "    ✗ Failed to set $secretName for $envName`: $result"
                }
            } catch {
                Write-Error "    ✗ Error setting $secretName for $envName`: $_"
            }
        } else {
            Write-Host "  [DRY RUN] Would set $secretName = ${secretValue.Substring(0,8)}..." -ForegroundColor Gray
        }
    }
}

Write-Step "Updating Workflow to Use Environment Secrets"

$workflowPath = ".github/workflows/deploy-auth0.yml"

if (Test-Path $workflowPath) {
    if (-not $DryRun) {
        Write-Host "Updating workflow file..." -ForegroundColor Cyan
        
        # Read current content
        $content = Get-Content $workflowPath -Raw
        
        # Replace the complex environment-specific logic with simple environment secrets
        $oldPattern = @'
      - name: Configure Auth0 Credentials
        env:
          ENVIRONMENT: \$\{\{ needs\.determine-strategy\.outputs\.environment \}\}
        run: \|
          # Select environment-specific secrets
          case "\$ENVIRONMENT" in
            "development"\)
              AUTH0_DOMAIN="\$\{\{ secrets\.AUTH0_DOMAIN_DEV \}\}"
              AUTH0_CLIENT_ID="\$\{\{ secrets\.AUTH0_CLIENT_ID_DEV \}\}"
              AUTH0_CLIENT_SECRET="\$\{\{ secrets\.AUTH0_CLIENT_SECRET_DEV \}\}"
              ;;
            "staging"\)
              AUTH0_DOMAIN="\$\{\{ secrets\.AUTH0_DOMAIN_STAGING \}\}"
              AUTH0_CLIENT_ID="\$\{\{ secrets\.AUTH0_CLIENT_ID_STAGING \}\}"
              AUTH0_CLIENT_SECRET="\$\{\{ secrets\.AUTH0_CLIENT_SECRET_STAGING \}\}"
              ;;
            "production"\)
              AUTH0_DOMAIN="\$\{\{ secrets\.AUTH0_DOMAIN_PROD \}\}"
              AUTH0_CLIENT_ID="\$\{\{ secrets\.AUTH0_CLIENT_ID_PROD \}\}"
              AUTH0_CLIENT_SECRET="\$\{\{ secrets\.AUTH0_CLIENT_SECRET_PROD \}\}"
              ;;
            \*\)
              echo "❌ Unknown environment: \$ENVIRONMENT"
              exit 1
              ;;
          esac
          
          # Create secure terraform\.tfvars with environment-specific credentials
          cat > terraform\.tfvars << EOF
          auth0_domain = "\$AUTH0_DOMAIN"
          auth0_client_id = "\$AUTH0_CLIENT_ID"
          auth0_client_secret = "\$AUTH0_CLIENT_SECRET"
          EOF
          
          echo "✅ Configured Auth0 credentials for \$ENVIRONMENT environment"
'@

        $newPattern = @'
      - name: Configure Auth0 Credentials
        env:
          AUTH0_DOMAIN: ${{ secrets.AUTH0_DOMAIN }}
          AUTH0_CLIENT_ID: ${{ secrets.AUTH0_CLIENT_ID }}
          AUTH0_CLIENT_SECRET: ${{ secrets.AUTH0_CLIENT_SECRET }}
        run: |
          cat > terraform.tfvars << EOF
          auth0_domain = "$AUTH0_DOMAIN"
          auth0_client_id = "$AUTH0_CLIENT_ID"
          auth0_client_secret = "$AUTH0_CLIENT_SECRET"
          EOF
          echo "✅ Configured Auth0 credentials for ${{ needs.determine-strategy.outputs.environment }} environment"
'@

        Write-Host "⚠️  Manual workflow update required" -ForegroundColor Yellow
        Write-Host "The workflow file needs to be updated to use simple environment secrets." -ForegroundColor Yellow
        Write-Host "This requires manual editing due to complex patterns." -ForegroundColor Yellow
        
    } else {
        Write-Host "[DRY RUN] Would update workflow file to use environment secrets" -ForegroundColor Gray
    }
} else {
    Write-Error "Workflow file not found: $workflowPath"
}

if ($Cleanup -and -not $DryRun) {
    Write-Step "Cleaning Up Old Repository Secrets"
    
    $oldSecrets = @(
        "AUTH0_DOMAIN_DEV", "AUTH0_CLIENT_ID_DEV", "AUTH0_CLIENT_SECRET_DEV",
        "AUTH0_DOMAIN_STAGING", "AUTH0_CLIENT_ID_STAGING", "AUTH0_CLIENT_SECRET_STAGING",
        "AUTH0_DOMAIN_PROD", "AUTH0_CLIENT_ID_PROD", "AUTH0_CLIENT_SECRET_PROD"
    )
    
    foreach ($secret in $oldSecrets) {
        Write-Host "Removing repository secret: $secret" -ForegroundColor Cyan
        gh secret delete $secret --confirm 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) {
            Write-Success "✓ Removed $secret"
        } else {
            Write-Error "✗ Failed to remove $secret"
        }
    }
}

Write-Step "Migration Summary"

if ($DryRun) {
    Write-Host "🔍 DRY RUN COMPLETE - No changes made" -ForegroundColor Blue
    Write-Host "Run without -DryRun to apply changes" -ForegroundColor Yellow
} else {
    Write-Success "✅ Environment secrets migration completed!"
    Write-Host "`n📋 Next steps:" -ForegroundColor Yellow
    Write-Host "1. Manually update the workflow file (complex regex patterns)" -ForegroundColor White
    Write-Host "2. Test deployment to verify environment secrets work" -ForegroundColor White
    Write-Host "3. Run with -Cleanup to remove old repository secrets" -ForegroundColor White
}

Write-Host "`n🎯 Benefits of Environment Secrets:" -ForegroundColor Blue
Write-Host "• Better security isolation between environments" -ForegroundColor White
Write-Host "• Environment-specific access controls" -ForegroundColor White
Write-Host "• Cleaner secret organization" -ForegroundColor White
Write-Host "• Easier management per environment" -ForegroundColor White