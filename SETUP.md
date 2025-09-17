# Auth0 Terraform Project Setup Instructions

## 1. Install Prerequisites

### Install Homebrew (if not already installed)
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### Install Terraform
```bash
brew install terraform
```

### Verify Installation
```bash
terraform version
```

## 2. Quick Start

1. **Copy configuration file:**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. **Edit terraform.tfvars with your Auth0 credentials:**
   - Get your Auth0 Management API credentials from Auth0 Dashboard
   - Update the domain, client_id, and client_secret
   - Customize application names and URLs

3. **Initialize Terraform:**
   ```bash
   terraform init
   ```

4. **Deploy using the script:**
   ```bash
   ./deploy.sh dev
   ```

   Or manually:
   ```bash
   terraform validate
   terraform plan -var-file="dev.tfvars"
   terraform apply -var-file="dev.tfvars"
   ```

## 3. Auth0 Management API Setup

To get the required credentials:

1. Go to Auth0 Dashboard → Applications
2. Create or select a Machine to Machine application
3. Authorize it for Auth0 Management API
4. Grant these scopes:
   - `read:clients`, `create:clients`, `update:clients`, `delete:clients`
   - `read:resource_servers`, `create:resource_servers`, `update:resource_servers`, `delete:resource_servers`
   - `read:roles`, `create:roles`, `update:roles`, `delete:roles`
   - `read:connections`, `create:connections`, `update:connections`, `delete:connections`
   - `read:actions`, `create:actions`, `update:actions`, `delete:actions`

## 4. Environment Files

- `dev.tfvars` - Development environment
- `prod.tfvars` - Production environment
- `terraform.tfvars` - Default/local environment

Choose the appropriate file for your deployment.

## 5. Deployment Commands

```bash
# Development
./deploy.sh dev

# Production  
./deploy.sh prod

# Custom tfvars file
terraform apply -var-file="custom.tfvars"
```
