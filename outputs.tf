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

# Cloudflare Pages outputs
output "pages_project_id" {
  description = "ID of the Cloudflare Pages project"
  value       = cloudflare_pages_project.otaku_lt.id
}

output "pages_project_name" {
  description = "Name of the Cloudflare Pages project"
  value       = cloudflare_pages_project.otaku_lt.name
}

output "pages_project_subdomain" {
  description = "Subdomain of the Cloudflare Pages project"
  value       = cloudflare_pages_project.otaku_lt.subdomain
}

output "pages_project_domains" {
  description = "Domains associated with the Cloudflare Pages project"
  value       = cloudflare_pages_project.otaku_lt.domains
}

output "website_url" {
  description = "URL of the deployed website"
  value       = "https://${var.domain_name}"
}

output "pages_dev_url" {
  description = "Cloudflare Pages development URL"
  value       = "https://${var.pages_project_name}.pages.dev"
}
