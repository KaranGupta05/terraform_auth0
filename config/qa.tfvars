# Staging environment
auth0_domain        = "dev-fimbrzye0161xm5f.us.auth0.com"
auth0_client_id     = "bl6gTEatijSPH9JeiwJ0pwqNJwrM0eaW"
auth0_client_secret = "F5RPxpq2CXv8zWW7jK3AOPbDS5zYryzng5qZsT1l6Vok49FpBuwvYrYZZnCYboUw"

# Tenant Configuration
tenant_friendly_name = "CDW"
tenant_support_email = "support@CDW.com"

environment = "qa"

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
