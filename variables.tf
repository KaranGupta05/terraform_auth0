variable "tenant_friendly_name" {
  description = "Friendly name for the Auth0 tenant"
  type        = string
}

variable "tenant_support_email" {
  description = "Support email for the Auth0 tenant"
  type        = string
}

variable "smtp_host" {
  description = "SMTP host for custom email provider"
  type        = string
}

variable "smtp_port" {
  description = "SMTP port for custom email provider"
  type        = number
}

variable "smtp_user" {
  description = "SMTP username for custom email provider"
  type        = string
}
variable "smtp_pass" {
  description = "SMTP password for custom email provider"
  type        = string
  sensitive   = true
}
variable "auth0_domain" {
  description = "Auth0 tenant domain"
  type        = string
}

variable "tenant_support_url" {
  description = "Support URL for the tenant"
  type        = string
  default     = ""
}

variable "tenant_default_audience" {
  description = "Default audience for the tenant"
  type        = string
  default     = ""
}

variable "auth0_client_id" {
  description = "Auth0 Management API client ID"
  type        = string
}

variable "auth0_client_secret" {
  description = "Auth0 Management API client secret"
  type        = string
  sensitive   = true
}

# Project Configuration
variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "my-app"
}

# SPA Application Variables
variable "spa_app_name" {
  description = "Name of the SPA application"
  type        = string
  default     = "My SPA App"
}

variable "spa_callbacks" {
  description = "Allowed callback URLs for SPA"
  type        = list(string)
  default     = [
    "http://localhost:3000/callback",
    "https://yourapp.com/callback"
  ]
}

variable "spa_logout_urls" {
  description = "Allowed logout URLs for SPA"
  type        = list(string)
  default     = [
    "http://localhost:3000",
    "https://yourapp.com"
  ]
}

# Custom Domain Configuration
#variable "custom_domain_name" {
#  description = "Custom domain name for Auth0 tenant (e.g., auth.yourdomain.com)"
#  type        = string
#}
#
#variable "custom_domain_type" {
#  description = "Type of custom domain verification (auth0_managed_certs or self_managed_certs)"
#  type        = string
#  default     = "auth0_managed_certs"
#}


variable "spa_allowed_origins" {
  description = "Allowed origins for SPA"
  type        = list(string)
  default     = [
    "http://localhost:3000",
    "https://yourapp.com"
  ]
}

variable "spa_web_origins" {
  description = "Allowed web origins for SPA"
  type        = list(string)
  default     = [
    "http://localhost:3000",
    "https://yourapp.com"
  ]
}

# API Application Variables
variable "api_app_name" {
  description = "Name of the API application"
  type        = string
  default     = "My API App"
}

# Resource Server Variables
variable "api_name" {
  description = "Name of the API resource server"
  type        = string
  default     = "My API"
}

variable "api_identifier" {
  description = "Identifier for the API resource server"
  type        = string
  default     = "https://api.example.com"
}

# Database Connection Variables
variable "database_connection_name" {
  description = "Name of the database connection"
  type        = string
  default     = "Username-Password-Authentication"
}

# Environment Variables
variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}
