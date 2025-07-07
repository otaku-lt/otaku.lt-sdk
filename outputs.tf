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

# Development environment outputs
output "events_api_database_id_dev" {
  description = "ID of the D1 database for events (development)"
  value       = cloudflare_d1_database.otaku_lt_api_events_db_dev.id
}

output "events_api_cache_namespace_id_dev" {
  description = "ID of the KV namespace for events cache (development)"
  value       = cloudflare_workers_kv_namespace.otaku_lt_api_events_cache_dev.id
}

output "events_api_rate_limit_namespace_id_dev" {
  description = "ID of the KV namespace for rate limiting (development)"
  value       = cloudflare_workers_kv_namespace.otaku_lt_api_events_rate_limit_dev.id
}

# Formatted wrangler.toml configuration
output "events_api_wrangler_config" {
  description = "Ready-to-use configuration for wrangler.toml"
  value = <<-EOT
# Copy this configuration to your wrangler.toml file

# Production environment
[[env.production.d1_databases]]
binding = "DB"
database_name = "otaku-events-db"
database_id = "${cloudflare_d1_database.otaku_lt_api_events_db.id}"

[[env.production.kv_namespaces]]
binding = "CACHE"
id = "${cloudflare_workers_kv_namespace.otaku_lt_api_events_cache.id}"

[[env.production.kv_namespaces]]
binding = "RATE_LIMIT"
id = "${cloudflare_workers_kv_namespace.otaku_lt_api_events_rate_limit.id}"

# Development environment
[[env.development.d1_databases]]
binding = "DB"
database_name = "otaku-events-db-dev"
database_id = "${cloudflare_d1_database.otaku_lt_api_events_db_dev.id}"

[[env.development.kv_namespaces]]
binding = "CACHE"
id = "${cloudflare_workers_kv_namespace.otaku_lt_api_events_cache_dev.id}"

[[env.development.kv_namespaces]]
binding = "RATE_LIMIT"
id = "${cloudflare_workers_kv_namespace.otaku_lt_api_events_rate_limit_dev.id}"
EOT
}
