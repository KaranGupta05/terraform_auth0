# SPA Application Outputs
output "spa_client_id" {
  description = "Client ID of the SPA application"
  value       = auth0_client.spa_app.client_id
}

# API Application Outputs
output "api_client_id" {
  description = "Client ID of the API application"
  value       = auth0_client.api_app.client_id
}

# Resource Server Outputs
output "api_identifier" {
  description = "Identifier of the API resource server"
  value       = auth0_resource_server.api.identifier
}

output "api_scopes" {
  description = "Available scopes for the API"
  value       = ["read:users", "write:users", "admin"]
}

# Connection Outputs
output "database_connection_id" {
  description = "ID of the database connection"
  value       = auth0_connection.database.id
}

output "database_connection_name" {
  description = "Name of the database connection"
  value       = auth0_connection.database.name
}

# Role Outputs
output "admin_role_id" {
  description = "ID of the admin role"
  value       = auth0_role.admin.id
}

output "user_role_id" {
  description = "ID of the user role"
  value       = auth0_role.user.id
}

# Auth0 Domain Output
output "auth0_domain" {
  description = "Auth0 tenant domain"
  value       = var.auth0_domain
}

# Complete Auth0 Configuration for Frontend
output "auth0_config" {
  description = "Complete Auth0 configuration for frontend applications"
  value = {
    domain        = var.auth0_domain
    clientId      = auth0_client.spa_app.client_id
    audience      = auth0_resource_server.api.identifier
    redirectUri   = var.spa_callbacks[0]
    logoutUrl     = var.spa_logout_urls[0]
  }
}
