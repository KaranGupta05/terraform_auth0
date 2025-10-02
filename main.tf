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

# Auth0 Tenant Configuration
resource "auth0_tenant" "tenant" {
  friendly_name      = var.tenant_friendly_name
  support_email      = var.tenant_support_email
  support_url        = var.tenant_support_url
  #default_audience   = var.tenant_default_audience
  #default_directory  = "Username-Password-Authentication"
  #Logo URL
  picture_url        = "https://www.shutterstock.com/shutterstock/photos/2174926871/display_1500/stock-vector-circle-line-simple-design-logo-blue-format-jpg-png-eps-2174926871.jpg"
  
   # Set Idle Session Lifetime (in minutes)
  idle_session_lifetime  = 24  # 1 day

  # Set Maximum Session Lifetime (in minutes)
  session_lifetime       = 480 # 20 days
  
  # Session cookie persistence policy: "persistent" or "non_persistent"
  # session_cookie is not a supported argument, removed
}

#Authentication Profile Configuration
resource "auth0_prompt" "tenant_prompt" {
  universal_login_experience = "new"
  identifier_first           = true
}

# Custom Domain Configuration
#resource "auth0_custom_domain" "domain" {
#  count  = var.custom_domain_name != "" ? 1 : 0
#  domain = var.custom_domain_name
#  type   = var.custom_domain_type
#}

# Attack Protection
resource "auth0_attack_protection" "breached_password_detection" {
  dynamic "breached_password_detection" {
    for_each = var.enable_breach_detection ? [1] : []
    content {
      enabled = true
      method  = var.enable_enhanced_breach_detection ? "enhanced" : "standard" # Use "enhanced" for Credential Guard, otherwise "standard" for regular public breach lists

      shields = [
        "block",
        "admin_notification",
        # "user_notification" # Add only if you want users notified directly
      ]

      admin_notification_frequency = ["immediately"] # Can also be "daily", "weekly", or "monthly"

      # Optionally enable/disable user notifications:
      # user_notification_enabled = false   # Only if provider supports this option

      # Example: disable user notification for compromised credentials
      # You may need to use management API for fine-grained settings if this option is not exposed in the provider
    }
  }
  
  brute_force_protection {
    enabled = true                # Enable brute-force protection
    shields = ["block", "user_notification"]    # Block login attempts, send notification to the user

    # threshold is not specified so it uses Auth0's default (recommended for most cases)
    # If you need to customize: 
    # threshold = <number of allowed attempts before account is blocked>
  }
  
  suspicious_ip_throttling {
    enabled = true
    shields = ["block", "admin_notification"]  # Block and send notifications to admins
    # By not specifying thresholds, Auth0 default thresholds are used.
  }
}


# Branding configuration
resource "auth0_branding" "tenant_branding" {
  logo_url = "https://www.shutterstock.com/shutterstock/photos/2174926871/display_1500/stock-vector-circle-line-simple-design-logo-blue-format-jpg-png-eps-2174926871.jpg"

  colors {
    primary          = "#123456"     # Primary color
    page_background  = "#f4f4f4"     # Page background color
  }
}

# Enable custom email provider
resource "auth0_email_provider" "custom_provider" {
  count     = var.create_email_templates ? 1 : 0
  name      = "smtp"
  default_from_address = "no-reply@yourdomain.com"
  credentials {
  smtp_host   = var.smtp_host
  smtp_port   = var.smtp_port
  smtp_user   = var.smtp_user
  smtp_pass   = var.smtp_pass
  }
}

# Email template example - Reset Password
resource "auth0_email_template" "reset_password" {
  count      = var.create_email_templates ? 1 : 0
  depends_on = [auth0_email_provider.custom_provider]
  template        = "reset_email"  # Email template identifier
  subject         = "Reset your password"
  from            = "no-reply@yourdomain.com"
  body            = "Click the link to reset your password." # Replace with file() if the file exists
  syntax          = "liquid"
  enabled         = true
}

# Add missing resource server resource
resource "auth0_resource_server" "api" {
  count      = var.create_resource_server ? 1 : 0
  name       = var.api_name
  identifier = var.api_identifier

  allow_offline_access                            = true
  token_lifetime                                 = 86400
  token_lifetime_for_web                         = 7200
  skip_consent_for_verifiable_first_party_clients = true
}

#Log Stream Configuration
resource "auth0_log_stream" "splunk_cribl" {
  count  = var.create_log_stream ? 1 : 0
  name   = "Cribl"
  type   = "splunk"
  status = "active"

  sink {
    splunk_domain = "default.main.dreamy-moore-3stzf1x.cribl.cloud"
    splunk_port   = 20001
    splunk_token  = "<Your Cribl/Splunk Event Collector Token>"
    splunk_secure = true
  }

  # Prioritized logs disabled (default)
  # No filter needed for "All"
}


# Add missing role resources
resource "auth0_role" "admin" {
  count       = var.create_admin_role ? 1 : 0
  name        = "Admin"
  description = "Administrator role with full access"
}

resource "auth0_role" "user" {
  count       = var.create_user_role ? 1 : 0
  name        = "User"
  description = "Standard user role"
}

# Auth0 Action (Login Flow)
resource "auth0_action" "login_action" {
  count = var.create_login_action ? 1 : 0
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
