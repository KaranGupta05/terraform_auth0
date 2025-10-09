# Staging environment
auth0_domain        = "dev-3ey3z12ipauxwzup.us.auth0.com"
auth0_client_id     = "Q2rxVFYyhprC4VH6y9Rec0op17mYSxEU"
auth0_client_secret = "T8UAMXbpGU2nX9lEDUrKvXDpAk2Jxq8SQ5H9AhrOgcRbVqfOp1BFfX25IeepuzjJ"

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
