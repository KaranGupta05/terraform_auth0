# Production environment
auth0_domain        = "dev-ttiw0oehq6nnv2jk.us.auth0.com"
auth0_client_id     = "oKs0PcU5MhzDnKQqalf1xQKYLE4YsCOK"
auth0_client_secret = "M5aaGAZTJG4-tD7rMQMBECk9TWUHDrAMG0wCRFyFvYqOoIskj7juIdtj5BBUDpdB"

project_name = "cdw-prd-first-terraform-project"

spa_app_name = "My CDW PRD Account (Production)"
spa_callbacks = [
  "https://app.cdw-test.com/callback"
]
spa_logout_urls = [
  "https://app.cdw-test.com"
]
spa_allowed_origins = [
  "https://app.cdw-test.com"
]
spa_web_origins = [
  "https://app.cdw-test.com"
]

api_app_name = "My CDW Account API (Production)"
api_name     = "My CDW Account API (Production)"
api_identifier = "https://api.cdw-test.com"

# Tenant Configuration
tenant_friendly_name = "VINAY FST COMPANY (Production)"
tenant_support_email = "support@cdw-test.com"
#custom_domain_name = "auth.cdw-test.com"

environment = "prod"
