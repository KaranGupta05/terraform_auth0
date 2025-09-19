
# Example terraform.tfvars file
# Copy this file to terraform.tfvars and fill in your actual values

# Auth0 Management API Configuration
# You can find these values in your Auth0 Dashboard > Applications > Machine to Machine Applications
auth0_domain        = "dev-ttiw0oehq6nnv2jk.us.auth0.com"
auth0_client_id     = "oKs0PcU5MhzDnKQqalf1xQKYLE4YsCOK"
auth0_client_secret = "M5aaGAZTJG4-tD7rMQMBECk9TWUHDrAMG0wCRFyFvYqOoIskj7juIdtj5BBUDpdB"

# Project Configuration
project_name = "cdw-first-terraform-project"

tenant_friendly_name = "VINAY FST CCOMPANY"
tenant_support_email = "support@cdw-test.com"
custom_domain_name = "auth.cdw-test.com"

# SPA Application Configuration
spa_app_name = "My CDW Account"
spa_callbacks = [
  "http://localhost:3000/callback",
  "http://localhost:3001/callback",
  "https://yourdomain.com/callback"
]
spa_logout_urls = [
  "http://localhost:3000",
  "http://localhost:3001",
  "https://yourdomain.com"
]
spa_allowed_origins = [
  "http://localhost:3000",
  "http://localhost:3001",
  "https://yourdomain.com"
]
spa_web_origins = [
  "http://localhost:3000",
  "http://localhost:3001",
  "https://yourdomain.com"
]

# API Application Configuration
api_app_name = "My CDW Account API"

# Resource Server Configuration
api_name       = "My CDW Account API"
api_identifier = "https://api.yourdomain.com"

# Database Connection Configuration
database_connection_name = "Username-Password-Authentication"

# Environment
environment = "dev"
