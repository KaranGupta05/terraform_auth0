# Auth0 Terraform Infrastructure

This Terraform project manages Auth0 infrastructure including applications, resource servers, roles, and connections.

## Prerequisites

1. **Terraform**: Install Terraform >= 1.0
   ```bash
   # On macOS using Homebrew
   brew install terraform
   
   # Verify installation
   terraform version
   ```

2. **Auth0 Account**: You need an Auth0 tenant and Management API credentials

## Setup

### 1. Get Auth0 Management API Credentials

1. Go to your [Auth0 Dashboard](https://manage.auth0.com/)
2. Navigate to **Applications** → **Machine to Machine Applications**
3. Create a new Machine to Machine application or use an existing one
4. Authorize it for the **Auth0 Management API**
5. Grant the following scopes:
   - `read:clients`
   - `create:clients`
   - `update:clients`
   - `delete:clients`
   - `read:resource_servers`
   - `create:resource_servers`
   - `update:resource_servers`
   - `delete:resource_servers`
   - `read:roles`
   - `create:roles`
   - `update:roles`
   - `delete:roles`
   - `read:connections`
   - `create:connections`
   - `update:connections`
   - `delete:connections`
   - `read:actions`
   - `create:actions`
   - `update:actions`
   - `delete:actions`

### 2. Configure Variables

**Option A: Use the setup script (Recommended)**
```bash
./setup-auth0.sh
```

**Option B: Manual configuration**
1. Copy the example variables file:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. Edit `terraform.tfvars` with your actual values:
   ```hcl
   auth0_domain        = "your-tenant.auth0.com"
   auth0_client_id     = "your_management_api_client_id"
   auth0_client_secret = "your_management_api_client_secret"
   
   # Customize other variables as needed
   project_name = "my-awesome-app-2"
   spa_app_name = "My Awesome SPA"
   # ... etc
   ```

### 3. Initialize and Deploy

1. Initialize Terraform:
   ```bash
   terraform init
   ```

2. Validate the configuration:
   ```bash
   terraform validate
   ```

3. Plan the deployment:
   ```bash
   terraform plan
   ```

4. Apply the configuration:
   ```bash
   terraform apply
   ```

## What This Creates

### Applications
- **SPA Application**: Single Page Application with PKCE flow
- **API Application**: Machine-to-Machine application for backend services

### Resource Server (API)
- Defines API with scopes: `read:users`, `write:users`, `admin`
- Configured with appropriate token lifetimes

### Database Connection
- Username/Password authentication database
- Security policies for passwords
- Brute force protection enabled

### Roles and Permissions
- **Admin Role**: Full access to all API scopes
- **User Role**: Limited access to read operations

### Actions
- **Login Action**: Adds user metadata and custom claims to tokens

## Usage Examples

### Frontend Configuration (React/Angular/Vue)

After deployment, use the output values to configure your frontend:

```javascript
// auth0.config.js
export const auth0Config = {
  domain: 'your-tenant.auth0.com',
  clientId: 'spa_client_id_from_output',
  audience: 'https://api.yourdomain.com',
  redirectUri: window.location.origin + '/callback'
};
```

### Backend API Configuration

Use the API application credentials for securing your backend:

```javascript
// Express.js example
const jwt = require('express-jwt');
const jwks = require('jwks-rsa');

const jwtCheck = jwt({
  secret: jwks.expressJwtSecret({
    cache: true,
    rateLimit: true,
    jwksRequestsPerMinute: 5,
    jwksUri: 'https://your-tenant.auth0.com/.well-known/jwks.json'
  }),
  audience: 'https://api.yourdomain.com',
  issuer: 'https://your-tenant.auth0.com/',
  algorithms: ['RS256']
});
```

## Customization

### Adding New Scopes

Edit `main.tf` to add new scopes to the resource server:

```hcl
resource "auth0_resource_server" "api" {
  # ... existing configuration
  
  scopes {
    value       = "read:posts"
    description = "Read blog posts"
  }
}
```

### Adding New Roles

Create additional roles as needed:

```hcl
resource "auth0_role" "moderator" {
  name        = "Moderator"
  description = "Content moderator role"
}
```

### Environment-Specific Configurations

Use Terraform workspaces for different environments:

```bash
# Create workspaces
terraform workspace new dev
terraform workspace new staging
terraform workspace new prod

# Switch between workspaces
terraform workspace select dev
terraform apply -var="environment=dev"
```

## Security Considerations

1. **Never commit `terraform.tfvars`** - It contains sensitive credentials
2. **Use strong passwords** for Auth0 Management API applications
3. **Regularly rotate** Management API credentials
4. **Review scopes** granted to applications regularly
5. **Enable MFA** on your Auth0 dashboard account

## Cleanup

To destroy all resources:

```bash
terraform destroy
```

## Troubleshooting

### Common Issues

1. **Invalid credentials**: Verify your Management API credentials and scopes
2. **Resource conflicts**: Check if resources already exist in your Auth0 tenant
3. **Terraform state issues**: Use `terraform refresh` to sync state

### Getting Help

- [Auth0 Terraform Provider Documentation](https://registry.terraform.io/providers/auth0/auth0/latest/docs)
- [Auth0 Community Forum](https://community.auth0.com/)
- [Terraform Documentation](https://www.terraform.io/docs/)

## Outputs

After successful deployment, you'll see outputs including:
- SPA Client ID
- API Client ID  
- Resource Server Identifier
- Role IDs
- Complete Auth0 configuration object

Use these values to configure your applications and services.
# auth0-terraform-deployment
# Test deployment trigger 10/09/2025 22:11:58
