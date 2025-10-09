
# Tenant Configuration
tenant_friendly_name = "CDW"
tenant_support_email = "support@CDW.com"
#custom_domain_name = "auth.CDW.com"

environment = "prod"

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

# Optional Features - set to true only if properly configured and subscription supports it
create_email_templates = false
create_log_stream = false
enable_enhanced_breach_detection = false
enable_breach_detection = false

# Application definitions
applications = {
  main_app_new = {
    name        = "ITCyberSecSol Main App New app"
    type        = "spa"
    description = "Main customer portal application New app"
    callbacks   = [
      "http://localhost:3000/callback",
      "https://main.itcybersecsol.com/callback"
    ]
    logout_urls = [
      "http://localhost:3000",
      "https://main.itcybersecsol.com"
    ]
    allowed_origins = [
      "http://localhost:3000",
      "https://main.itcybersecsol.com"
    ]
    web_origins = [
      "http://localhost:3000",
      "https://main.itcybersecsol.com"
    ]
  },
  main_app = {
    name        = "ITCyberSecSol Main App"
    type        = "spa"
    description = "Main customer portal application"
    callbacks   = [
      "http://localhost:3000/callback",
      "https://main.itcybersecsol.com/callback"
    ]
    logout_urls = [
      "http://localhost:3000",
      "https://main.itcybersecsol.com"
    ]
    allowed_origins = [
      "http://localhost:3000",
      "https://main.itcybersecsol.com"
    ]
    web_origins = [
      "http://localhost:3000",
      "https://main.itcybersecsol.com"
    ]
  },
  admin_dashboard = {
    name        = "ITCyberSecSol Admin Dashboard"
    type        = "spa"
    description = "Administrative dashboard application"
    callbacks   = [
      "http://localhost:3001/callback",
      "https://admin.itcybersecsol.com/callback"
    ]
    logout_urls = [
      "http://localhost:3001",
      "https://admin.itcybersecsol.com"
    ]
    allowed_origins = [
      "http://localhost:3001",
      "https://admin.itcybersecsol.com"
    ]
    web_origins = [
      "http://localhost:3001",
      "https://admin.itcybersecsol.com"
    ]
  },
  admin_test_app = {
    name        = "ITCyberSecSol Admin test app"
    type        = "spa"
    description = "Administrative dashboard application"
    callbacks   = [
      "http://localhost:5001/callback",
      "https://admin.itcybersecsol1.com/callback"
    ]
    logout_urls = [
      "http://localhost:5001",
      "https://admin.itcybersecsol1.com"
    ]
    allowed_origins = [
      "http://localhost:5001",
      "https://admin.itcybersecsol1.com"
    ]
    web_origins = [
      "http://localhost:5001",
      "https://admin.itcybersecsol1.com"
    ]
  },
  main_api = {
    name         = "ITCyberSecSol Main API"
    type         = "api"
    description  = "Main backend API service"
    api_identifier = "https://api.itcybersecsol2.com"
    api_scopes   = [
      {
        name        = "read:users"
        description = "Read user information"
      },
      {
        name        = "write:users"
        description = "Write user information"
      }
    ]
  },
  admin_api = {
    name         = "ITCyberSecSol Admin API"
    type         = "api"
    description  = "Administrative API service"
    api_identifier = "https://admin-api.itcybersecsol2.com"
    api_scopes   = [
      {
        name        = "read:admin"
        description = "Read administrative data"
      },
      {
        name        = "write:admin"
        description = "Write administrative data"
      }
    ]
  }
}