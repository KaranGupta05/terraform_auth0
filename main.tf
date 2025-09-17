# Configure the Auth0 Provider
terraform {
  required_providers {
    auth0 = {
      source  = "auth0/auth0"
      version = "~> 1.0"
    }
  }
  required_version = ">= 1.0"
}

# Configure Auth0 Provider
provider "auth0" {
  domain        = var.auth0_domain
  client_id     = var.auth0_client_id
  client_secret = var.auth0_client_secret
}

# Auth0 Application (SPA - Single Page Application)
resource "auth0_client" "spa_app" {
  name                = var.spa_app_name
  description         = "Single Page Application for ${var.project_name}"
  app_type            = "spa"
  callbacks           = var.spa_callbacks
  allowed_logout_urls = var.spa_logout_urls
  allowed_origins     = var.spa_allowed_origins
  web_origins         = var.spa_web_origins
  oidc_conformant     = true
  
  jwt_configuration {
    lifetime_in_seconds = 36000
    secret_encoded      = true
    alg                 = "RS256"
  }

  refresh_token {
    expiration_type = "expiring"
    leeway          = 0
    token_lifetime  = 2592000
    idle_token_lifetime = 1296000
    infinite_token_lifetime = false
    infinite_idle_token_lifetime = false
    rotation_type = "rotating"
  }

  grant_types = [
    "authorization_code",
    "refresh_token"
  ]
}

# Auth0 Application (API/Backend)
resource "auth0_client" "api_app" {
  name        = var.api_app_name
  description = "API Application for ${var.project_name}"
  app_type    = "non_interactive"
  
  jwt_configuration {
    lifetime_in_seconds = 36000
    secret_encoded      = true
    alg                 = "RS256"
  }

  grant_types = [
    "client_credentials"
  ]
}

# Auth0 Resource Server (API)
resource "auth0_resource_server" "api" {
  name       = var.api_name
  identifier = var.api_identifier

  allow_offline_access                            = true
  token_lifetime                                 = 86400
  token_lifetime_for_web                         = 7200
  skip_consent_for_verifiable_first_party_clients = true
}

# Auth0 Resource Server Scopes
resource "auth0_resource_server_scopes" "api_scopes" {
  resource_server_identifier = auth0_resource_server.api.identifier
  
  scopes {
    name        = "read:users"
    description = "Read user information"
  }
  
  scopes {
    name        = "write:users"
    description = "Write user information"
  }
  
  scopes {
    name        = "admin"
    description = "Administrator access"
  }
}

# Auth0 Client Grant (API permissions)
resource "auth0_client_grant" "api_grant" {
  client_id = auth0_client.api_app.id
  audience  = auth0_resource_server.api.identifier
  
  scopes = [
    "read:users",
    "write:users"
  ]
}

# Auth0 Connection (Database)
resource "auth0_connection" "database" {
  name     = "${var.project_name}-database"
  strategy = "auth0"
  
  options {
    password_policy                = "good"
    password_history {
      enable = true
      size   = 5
    }
    password_no_personal_info {
      enable = true
    }
    password_dictionary {
      enable     = true
      dictionary = ["password", "admin", "123456"]
    }
    password_complexity_options {
      min_length = 8
    }
    enabled_database_customization = true
    brute_force_protection         = true
    import_mode                    = false
    disable_signup                 = false
    requires_username              = false
  }
}

# Enable connection for SPA application
resource "auth0_connection_clients" "spa_connection" {
  connection_id = auth0_connection.database.id
  enabled_clients = [
    auth0_client.spa_app.id
  ]
}

# Auth0 Role - Admin
resource "auth0_role" "admin" {
  name        = "Admin"
  description = "Administrator role with full access"
}

# Auth0 Role - User
resource "auth0_role" "user" {
  name        = "User"
  description = "Standard user role"
}

# Auth0 Role Permissions - Admin
resource "auth0_role_permissions" "admin_permissions" {
  role_id = auth0_role.admin.id
  
  permissions {
    resource_server_identifier = auth0_resource_server.api.identifier
    name                      = "admin"
  }
  
  permissions {
    resource_server_identifier = auth0_resource_server.api.identifier
    name                      = "read:users"
  }
  
  permissions {
    resource_server_identifier = auth0_resource_server.api.identifier
    name                      = "write:users"
  }
  
  depends_on = [auth0_resource_server_scopes.api_scopes]
}

# Auth0 Role Permissions - User
resource "auth0_role_permissions" "user_permissions" {
  role_id = auth0_role.user.id
  
  permissions {
    resource_server_identifier = auth0_resource_server.api.identifier
    name                      = "read:users"
  }
  
  depends_on = [auth0_resource_server_scopes.api_scopes]
}

# Auth0 Action (Login Flow)
resource "auth0_action" "login_action" {
  name = "add-user-metadata"
  
  supported_triggers {
    id      = "post-login"
    version = "v3"
  }
  
  code = <<-EOT
    exports.onExecutePostLogin = async (event, api) => {
      const namespace = 'https://example.com';
      
      if (event.authorization) {
        api.idToken.setCustomClaim(namespace + '/roles', event.authorization.roles);
        api.accessToken.setCustomClaim(namespace + '/roles', event.authorization.roles);
      }
      
      api.user.setAppMetadata('last_login', new Date().toISOString());
    };
  EOT
  
  dependencies {
    name    = "lodash"
    version = "4.17.21"
  }
  
  runtime = "node18"
  deploy  = true
}
