# Staging environment
# Resource Creation Control - SKIP EVERYTHING TO AVOID CONFLICTS
skip_existing_applications      = true   # Skip applications to avoid tenant limits
skip_existing_resource_servers = true   # Skip resource servers to avoid conflicts
skip_existing_database        = true   # Skip database to avoid conflicts
skip_existing_action          = true   # Skip actions
# Tenant Configuration
tenant_friendly_name = "CDW"
tenant_support_email = "dsfdsf"

# Empty applications to skip all app creation
applications = {}
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

primary_color = "#af0ed7"