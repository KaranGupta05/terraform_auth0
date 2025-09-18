#!/bin/bash

# Auth0 Configuration Setup Script
# This script helps you configure your Auth0 credentials for Terraform

echo "🚀 Auth0 Terraform Configuration Setup"
echo "======================================="
echo ""

# Check if terraform.tfvars exists
if [ -f "terraform.tfvars" ]; then
    echo "📄 Found existing terraform.tfvars file."
    read -p "Do you want to reconfigure it? (y/N): " reconfigure
    if [[ ! $reconfigure =~ ^[Yy]$ ]]; then
        echo "✅ Using existing configuration."
        exit 0
    fi
fi

echo ""
echo "📋 Please provide your Auth0 Management API credentials:"
echo "   You can find these in your Auth0 Dashboard > Applications > Machine to Machine Applications"
echo ""

# Get Auth0 domain
read -p "🌐 Enter your Auth0 domain (e.g., your-tenant.auth0.com): " auth0_domain
if [ -z "$auth0_domain" ]; then
    echo "❌ Auth0 domain is required."
    exit 1
fi

# Get client ID
read -p "🔑 Enter your Management API Client ID: " client_id
if [ -z "$client_id" ]; then
    echo "❌ Client ID is required."
    exit 1
fi

# Get client secret
read -s -p "🔐 Enter your Management API Client Secret: " client_secret
echo ""
if [ -z "$client_secret" ]; then
    echo "❌ Client secret is required."
    exit 1
fi

# Get project name
read -p "📱 Enter your project name (default: my-awesome-app): " project_name
project_name=${project_name:-my-awesome-app}

# Get environment
read -p "🏷️  Enter environment (dev/staging/prod, default: dev): " environment
environment=${environment:-dev}

echo ""
echo "🔧 Configuring terraform.tfvars..."

# Create terraform.tfvars
cat > terraform.tfvars << EOL
# Auth0 Management API Configuration
auth0_domain        = "$auth0_domain"
auth0_client_id     = "$client_id"
auth0_client_secret = "$client_secret"

# Project Configuration
project_name = "$project_name"

# SPA Application Configuration
spa_app_name = "$project_name SPA"
spa_callbacks = [
  "http://localhost:3000/callback",
  "http://localhost:3001/callback"
]
spa_logout_urls = [
  "http://localhost:3000",
  "http://localhost:3001"
]
spa_allowed_origins = [
  "http://localhost:3000",
  "http://localhost:3001"
]
spa_web_origins = [
  "http://localhost:3000",
  "http://localhost:3001"
]

# API Application Configuration
api_app_name = "$project_name API"

# Resource Server Configuration
api_name       = "$project_name API"
api_identifier = "https://api.${project_name}.com"

# Database Connection Configuration
database_connection_name = "Username-Password-Authentication"

# Environment
environment = "$environment"
EOL

echo "✅ Configuration saved to terraform.tfvars"
echo ""
echo "🔒 Security Note: terraform.tfvars contains sensitive information and is excluded from git."
echo ""
echo "📋 Next steps:"
echo "   1. Run: terraform validate"
echo "   2. Run: terraform plan"
echo "   3. Run: terraform apply"
echo "   4. Or use: ./deploy.sh"
echo ""
echo "🎉 Setup complete!"
