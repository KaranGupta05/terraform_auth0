# =============================================================================
# TENANT INFORMATION
# =============================================================================

output "tenant_domain" {
  description = "Auth0 tenant domain"
  value       = var.auth0_domain
}

output "tenant_friendly_name" {
  description = "Friendly name of the Auth0 tenant"
  value       = auth0_tenant.tenant.friendly_name
}

output "tenant_support_email" {
  description = "Support email for the tenant"
  value       = auth0_tenant.tenant.support_email
}

# =============================================================================
# ENVIRONMENT INFORMATION
# =============================================================================

output "environment" {
  description = "Current environment (dev/staging/prod)"
  value       = var.environment
}

output "deployment_timestamp" {
  description = "Timestamp of when this configuration was applied"
  value       = timestamp()
}

# =============================================================================
# APPLICATIONS (CLIENTS)
# =============================================================================

output "applications" {
  description = "Created Auth0 applications with their client IDs"
  value = {
    for app_key, app in auth0_client.applications : app_key => {
      name      = app.name
      client_id = app.client_id
      app_type  = app.app_type
      callbacks = app.callbacks
    }
  }
  sensitive = true  # Client IDs should be treated as sensitive
}

# =============================================================================
# API RESOURCES
# =============================================================================

output "api_resources" {
  description = "Created Auth0 API resource servers"
  value = {
    for api_key, api in auth0_resource_server.apis : api_key => {
      name       = api.name
      identifier = api.identifier
      scopes     = try([for scope in auth0_resource_server_scopes.api_scopes_new[api_key].scopes : scope.name], [])
    }
  }
}

# =============================================================================
# ROLES AND PERMISSIONS
# =============================================================================

output "roles" {
  description = "Created Auth0 roles"
  value = {
    admin = var.create_admin_role && length(auth0_role.admin) > 0 ? {
      name        = auth0_role.admin[0].name
      description = auth0_role.admin[0].description
    } : null
    user = var.create_user_role && length(auth0_role.user) > 0 ? {
      name        = auth0_role.user[0].name
      description = auth0_role.user[0].description
    } : null
  }
}

# Dynamic roles from configuration
output "custom_roles" {
  description = "Custom roles created from configuration"
  value = {
    for role_key, role in auth0_role.roles : role_key => {
      name        = role.name
      description = role.description
    }
  }
}

# =============================================================================
# DATABASE CONNECTIONS
# =============================================================================

output "database_connection" {
  description = "Database connection information"
  value = !var.skip_existing_database && length(auth0_connection.database) > 0 ? {
    name     = auth0_connection.database[0].name
    strategy = auth0_connection.database[0].strategy
  } : null
}

# =============================================================================
# SECURITY FEATURES
# =============================================================================

output "attack_protection" {
  description = "Attack protection settings"
  value = {
    breached_password_detection = {
      enabled = auth0_attack_protection.breached_password_detection.breached_password_detection[0].enabled
      shields = auth0_attack_protection.breached_password_detection.breached_password_detection[0].shields
    }
  }
}

# =============================================================================
# EMAIL CONFIGURATION
# =============================================================================

output "email_provider_configured" {
  description = "Whether custom email provider is configured"
  value       = var.smtp_host != "smtp.yourprovider.com" ? true : false
}

# =============================================================================
# DEPLOYMENT SUMMARY
# =============================================================================

output "deployment_summary" {
  description = "Summary of deployed resources"
  value = {
    environment           = var.environment
    tenant_domain        = var.auth0_domain
    applications_count   = length(var.applications)
    api_resources_count  = length([for app in var.applications : app if app.type == "api"])
    spa_applications_count = length([for app in var.applications : app if app.type == "spa"])
    deployment_time      = timestamp()
    terraform_workspace  = terraform.workspace
  }
}

# =============================================================================
# URLS AND ENDPOINTS
# =============================================================================

output "auth0_dashboard_url" {
  description = "URL to Auth0 Dashboard for this tenant"
  value       = "https://manage.auth0.com/dashboard/${split(".", var.auth0_domain)[0]}"
}

output "tenant_login_url" {
  description = "Base login URL for this tenant"
  value       = "https://${var.auth0_domain}/authorize"
}

# =============================================================================
# CONFIGURATION VALIDATION
# =============================================================================

output "configuration_status" {
  description = "Status of various configuration features"
  value = {
    login_action_created       = var.create_login_action
    resource_server_created    = var.create_resource_server
    admin_role_created         = var.create_admin_role
    user_role_created          = var.create_user_role
    email_templates_created    = var.create_email_templates
    log_stream_created         = var.create_log_stream
    breach_detection_enhanced  = var.enable_enhanced_breach_detection
    breach_detection_enabled   = var.enable_breach_detection
  }
}
