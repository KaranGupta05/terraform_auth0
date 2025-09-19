# AI Coding Agent Instructions - Auth0 Terraform Project

## Project Overview
This project manages Auth0 infrastructure-as-code using Terraform, including applications, resource servers, roles, and connections. It follows a multi-environment deployment pattern (dev/prod).

## Key Components
- **Infrastructure Definition** (`main.tf`): Core Auth0 resources including:
  - SPA Application with PKCE flow
  - API Application (Machine-to-Machine)
  - Resource Server with scopes
  - Role definitions and assignments
  - Custom database connections
  
- **Environment Management**:
  - Environment-specific variables in `dev.tfvars` and `prod.tfvars`
  - Base configuration in `terraform.tfvars`
  - Deployment script `deploy.sh` handles environment selection

## Critical Workflows

### 1. Deployment Process
```bash
# Development deployment
./deploy.sh dev    # Uses dev.tfvars

# Production deployment
./deploy.sh prod   # Uses prod.tfvars
```

### 2. Permission Validation
```bash
./check-permissions.sh    # Validates Auth0 Management API permissions
```

## Project Conventions

### 1. Resource Naming
- Resources use `var.project_name` as prefix/suffix for consistency
- Example: `"${var.project_name}-api"` for API names

### 2. Variable Organization
- Common variables: `terraform.tfvars`
- Environment overrides: `dev.tfvars`, `prod.tfvars`
- Sensitive values (credentials): Never committed, set via `terraform.tfvars`

### 3. Auth0 Configuration Patterns
- SPA apps use PKCE with refresh tokens
- APIs use RS256 signing algorithm
- Resource servers define granular scopes
- Custom DB connections follow Auth0 script templates

## Integration Points
1. **Auth0 Management API**: Requires specific scopes listed in `SETUP.md`
2. **SPA Application**: Configure callbacks/origins in environment tfvars
3. **API Authorization**: Uses OAuth 2.0 client credentials flow

## Common Tasks
1. **Adding New Scopes**: Extend `auth0_resource_server_scopes` in `main.tf`
2. **Environment Configuration**: Add new variables to both `dev.tfvars` and `prod.tfvars`
3. **Role Management**: Define roles and assignments in `main.tf`