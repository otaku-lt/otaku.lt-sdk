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
