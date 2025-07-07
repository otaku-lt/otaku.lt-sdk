# GitHub configuration variables
variable "github_token" {
  description = "GitHub personal access token"
  type        = string
  sensitive   = true
  default     = null
}

variable "github_owner" {
  description = "GitHub username or organization name"
  type        = string
  default     = "otaku-lt"
}

# Repository configuration variables
variable "otaku_lt_repo_name" {
  description = "Name of the otaku.lt repository"
  type        = string
  default     = "otaku.lt"
}

variable "otaku_lt_sdk_repo_name" {
  description = "Name of the otaku.lt-sdk repository"
  type        = string
  default     = "otaku.lt-sdk"
}

variable "otaku_events_api_repo_name" {
  description = "Name of the otaku-events-api repository"
  type        = string
  default     = "otaku-events-api"
}

variable "default_branch" {
  description = "Default branch for the repositories"
  type        = string
  default     = "main"
}

# Cloudflare configuration variables
variable "cloudflare_api_token" {
  description = "Cloudflare API token"
  type        = string
  sensitive   = true
  default     = null
}

variable "cloudflare_account_id" {
  description = "Cloudflare account ID"
  type        = string
  default     = null
}

variable "cloudflare_zone_id" {
  description = "Cloudflare zone ID for the domain"
  type        = string
  default     = null
}

variable "cloudflare_zone_name" {
  description = "Cloudflare zone name (domain)"
  type        = string
  default     = "otaku.lt"
}

variable "domain_name" {
  description = "Domain name for the website"
  type        = string
  default     = "otaku.lt"
}

variable "pages_project_name" {
  description = "Name of the Cloudflare Pages project"
  type        = string
  default     = "otaku-lt"
}
