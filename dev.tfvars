# Development environment
auth0_domain        = "dev-tenant.auth0.com"
auth0_client_id     = "dev_management_api_client_id"
auth0_client_secret = "dev_management_api_client_secret"

project_name = "my-app-dev-1"

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
