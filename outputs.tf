# Output values for the repositories

# Main repository outputs
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

# SDK repository outputs
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
output "otaku_lt_api_events_repository_url" {
  description = "The URL of the otaku.lt-api-events repository"
  value       = github_repository.otaku_lt_api_events.html_url
}

output "otaku_lt_api_events_repository_clone_url" {
  description = "The clone URL of the otaku.lt-api-events repository"
  value       = github_repository.otaku_lt_api_events.http_clone_url
}

output "otaku_lt_api_events_repository_ssh_clone_url" {
  description = "The SSH clone URL of the otaku.lt-api-events repository"
  value       = github_repository.otaku_lt_api_events.ssh_clone_url
}

# Cloudflare Pages outputs (DEPRECATED - migrated to Workers)
# output "pages_project_id" {
#   description = "ID of the Cloudflare Pages project"
#   value       = cloudflare_pages_project.otaku_lt.id
# }

output "website_url" {
  description = "URL of the deployed website"
  value       = "https://${var.domain_name}"
}

# Cloudflare Workers outputs
output "workers_domain" {
  description = "Main domain for Cloudflare Workers"
  value       = cloudflare_record.otaku_lt_root.hostname
}

# Events API Workers outputs
output "events_api_domain" {
  description = "Domain for the events API"
  value       = cloudflare_record.otaku_lt_api_events.hostname
}

output "events_api_database_id" {
  description = "ID of the D1 database for events"
  value       = cloudflare_d1_database.otaku_lt_api_events_db.id
}

output "events_api_cache_namespace_id" {
  description = "ID of the KV namespace for events cache"
  value       = cloudflare_workers_kv_namespace.otaku_lt_api_events_cache.id
}

output "events_api_rate_limit_namespace_id" {
  description = "ID of the KV namespace for rate limiting"
  value       = cloudflare_workers_kv_namespace.otaku_lt_api_events_rate_limit.id
}
