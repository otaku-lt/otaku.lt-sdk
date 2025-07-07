# Output values for the repositories
output "otaku_lt_repository_url" {
  description = "The URL of the otaku.lt repository"
  value       = github_repository.otaku_lt.html_url
}

output "otaku_lt_repository_clone_url" {
  description = "The clone URL of the otaku.lt repository"
  value       = github_repository.otaku_lt.http_clone_url
}

output "otaku_lt_repository_ssh_clone_url" {
  description = "The SSH clone URL of the otaku.lt repository"
  value       = github_repository.otaku_lt.ssh_clone_url
}

output "otaku_lt_sdk_repository_url" {
  description = "The URL of the otaku.lt-sdk repository"
  value       = github_repository.otaku_lt_sdk.html_url
}

output "otaku_lt_sdk_repository_clone_url" {
  description = "The clone URL of the otaku.lt-sdk repository"
  value       = github_repository.otaku_lt_sdk.http_clone_url
}

output "otaku_lt_sdk_repository_ssh_clone_url" {
  description = "The SSH clone URL of the otaku.lt-sdk repository"
  value       = github_repository.otaku_lt_sdk.ssh_clone_url
}

# Events API repository outputs
output "otaku_events_api_repository_url" {
  description = "The URL of the otaku-events-api repository"
  value       = github_repository.otaku_events_api.html_url
}

output "otaku_events_api_repository_clone_url" {
  description = "The clone URL of the otaku-events-api repository"
  value       = github_repository.otaku_events_api.http_clone_url
}

output "otaku_events_api_repository_ssh_clone_url" {
  description = "The SSH clone URL of the otaku-events-api repository"
  value       = github_repository.otaku_events_api.ssh_clone_url
}

# Cloudflare Pages outputs (DEPRECATED - migrated to Workers)
# output "pages_project_id" {
#   description = "ID of the Cloudflare Pages project"
#   value       = cloudflare_pages_project.otaku_lt.id
# }

# output "pages_project_name" {
#   description = "Name of the Cloudflare Pages project"
#   value       = cloudflare_pages_project.otaku_lt.name
# }

# output "pages_project_subdomain" {
#   description = "Subdomain of the Cloudflare Pages project"
#   value       = cloudflare_pages_project.otaku_lt.subdomain
# }

# output "pages_project_domains" {
#   description = "Domains associated with the Cloudflare Pages project"
#   value       = cloudflare_pages_project.otaku_lt.domains
# }

output "website_url" {
  description = "URL of the deployed website"
  value       = "https://${var.domain_name}"
}

# Events API infrastructure outputs
output "events_api_url" {
  description = "URL of the events API"
  value       = "https://api.${var.domain_name}"
}

output "d1_database_id" {
  description = "ID of the D1 database for events"
  value       = cloudflare_d1_database.otaku_events_db.id
}

output "kv_cache_namespace_id" {
  description = "ID of the KV namespace for caching"
  value       = cloudflare_workers_kv_namespace.otaku_events_cache.id
}

output "kv_rate_limit_namespace_id" {
  description = "ID of the KV namespace for rate limiting"
  value       = cloudflare_workers_kv_namespace.otaku_events_rate_limit.id
}

# output "pages_dev_url" {
#   description = "Cloudflare Pages development URL"
#   value       = "https://${var.pages_project_name}.pages.dev"
# }

# GitHub Actions secrets outputs (removed - unnecessary noise in output)
# output "github_secrets_configured" {
#   description = "List of GitHub Actions secrets that have been configured"
#   value = [
#     github_actions_secret.cloudflare_api_token.secret_name,
#     github_actions_secret.cloudflare_account_id.secret_name
#   ]
# }

# output "github_actions_workflow_ready" {
#   description = "Whether GitHub Actions workflow is ready to run"
#   value = "✅ GitHub Actions secrets configured. Workflow ready for deployment!"
# }
