# Development environment
auth0_domain        = "dev-ttiw0oehq6nnv2jk.us.auth0.com"
auth0_client_id     = "oKs0PcU5MhzDnKQqalf1xQKYLE4YsCOK"
auth0_client_secret = "M5aaGAZTJG4-tD7rMQMBECk9TWUHDrAMG0wCRFyFvYqOoIskj7juIdtj5BBUDpdB"

project_name = "my-app-dev-1"

# Tenant Configuration
tenant_friendly_name = "My App (Development)"
tenant_support_email = "support@cdw-test.com"
#custom_domain_name = "auth.cdw-test.com"

spa_app_name = "My App (Development)"
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

api_app_name = "My API (Development)"
api_name     = "My API (Development)"
api_identifier = "https://api-dev.example.com"

environment = "dev"
