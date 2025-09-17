#!/bin/bash

# Deploy script for Auth0 Terraform infrastructure
# Usage: ./deploy.sh [environment]

set -e

ENVIRONMENT=${1:-dev}
TFVARS_FILE="${ENVIRONMENT}.tfvars"

echo "🚀 Deploying Auth0 infrastructure for environment: $ENVIRONMENT"

# Check if Terraform is installed
if ! command -v terraform &> /dev/null; then
    echo "❌ Terraform is not installed. Please install Terraform first."
    echo "   On macOS: brew install terraform"
    exit 1
fi

# Check if tfvars file exists
if [ ! -f "$TFVARS_FILE" ]; then
    echo "❌ Variables file $TFVARS_FILE not found."
    echo "   Please create $TFVARS_FILE with your Auth0 configuration."
    exit 1
fi

# Initialize Terraform if .terraform doesn't exist
if [ ! -d ".terraform" ]; then
    echo "📦 Initializing Terraform..."
    terraform init
fi

# Validate configuration
echo "✅ Validating Terraform configuration..."
terraform validate

# Plan deployment
echo "📋 Planning deployment..."
terraform plan -var-file="$TFVARS_FILE"

# Ask for confirmation
echo ""
read -p "Do you want to proceed with the deployment? (y/N): " confirm

if [[ $confirm =~ ^[Yy]$ ]]; then
    echo "🚀 Applying Terraform configuration..."
    terraform apply -var-file="$TFVARS_FILE" -auto-approve
    
    echo ""
    echo "✅ Deployment completed successfully!"
    echo ""
    echo "📋 Important outputs:"
    terraform output
    
    echo ""
    echo "🔗 Next steps:"
    echo "   1. Note down the client IDs and configure your applications"
    echo "   2. Visit your Auth0 Dashboard to verify the resources"
    echo "   3. Test your applications with the new configuration"
else
    echo "❌ Deployment cancelled."
    exit 1
fi
