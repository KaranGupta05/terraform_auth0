# Auth0 Configuration Variables
variable "auth0_domain" {
  description = "Auth0 tenant domain"
  type        = string
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
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}
