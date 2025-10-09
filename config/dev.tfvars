#I am making changes in dev site

# Tenant Configuration
tenant_friendly_name = "CDW"
tenant_support_email = "support@CDW.com"

environment = "dev"

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

# Optional Features - set to true only if properly configured
create_email_templates = false
create_log_stream = false
enable_enhanced_breach_detection = false
enable_breach_detection = false

# Application Creation Settings
skip_existing_applications = false
skip_existing_resource_servers = false

# Application definitions
applications = {
  main_app_new = {
    name        = "cdw Main App New app"
    type        = "spa"
    description = "Main customer portal application New app"
    callbacks   = [
      "http://localhost:3000/callback",
      "https://main.cdw.com/callback"
    ]
    logout_urls = [
      "http://localhost:3000",
      "https://main.cdw.com"
    ]
    allowed_origins = [
      "http://localhost:3000",
      "https://main.cdw.com"
    ]
    web_origins = [
      "http://localhost:3000",
      "https://main.cdw.com"
    ]
  },
  main_app = {
    name        = "cdw Main App"
    type        = "spa"
    description = "Main customer portal application"
    callbacks   = [
      "http://localhost:3000/callback",
      "https://main.cdw.com/callback"
    ]
    logout_urls = [
      "http://localhost:3000",
      "https://main.cdw.com"
    ]
    allowed_origins = [
      "http://localhost:3000",
      "https://main.cdw.com"
    ]
    web_origins = [
      "http://localhost:3000",
      "https://main.cdw.com"
    ]
  },
  admin_dashboard = {
    name        = "cdw Admin Dashboard"
    type        = "spa"
    description = "Administrative dashboard application"
    callbacks   = [
      "http://localhost:3001/callback",
      "https://admin.cdw.com/callback"
    ]
    logout_urls = [
      "http://localhost:3001",
      "https://admin.cdw.com"
    ]
    allowed_origins = [
      "http://localhost:3001",
      "https://admin.cdw.com"
    ]
    web_origins = [
      "http://localhost:3001",
      "https://admin.cdw.com"
    ]
  },
  admin_test_app = {
    name        = "cdw Admin test app"
    type        = "spa"
    description = "Administrative dashboard application"
    callbacks   = [
      "http://localhost:5001/callback",
      "https://admin.cdw1.com/callback"
    ]
    logout_urls = [
      "http://localhost:5001",
      "https://admin.cdw1.com"
    ]
    allowed_origins = [
      "http://localhost:5001",
      "https://admin.cdw1.com"
    ]
    web_origins = [
      "http://localhost:5001",
      "https://admin.cdw1.com"
    ]
  },
  main_api = {
    name         = "cdw Main API"
    type         = "api"
    description  = "Main backend API service"
    api_identifier = "https://api.cdw2.com"
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
    name         = "cdw Admin API"
    type         = "api"
    description  = "Administrative API service"
    api_identifier = "https://admin-api.cdw2.com"
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
# Test comment to trigger deployment
