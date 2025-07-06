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
  default     = null
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

variable "default_branch" {
  description = "Default branch for the repositories"
  type        = string
  default     = "main"
}
