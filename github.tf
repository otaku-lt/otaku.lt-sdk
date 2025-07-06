# Import the otaku.lt repository
resource "github_repository" "otaku_lt" {
  name        = "otaku.lt"
  description = "Otaku.lt - Lithuanian otaku community website"

  visibility = "public"

  # Repository settings
  has_issues    = true
  has_projects  = true
  has_wiki      = false
  has_downloads = true

  # Security and analysis
  vulnerability_alerts = true

  # Pages configuration (if using GitHub Pages)
  pages {
    source {
      branch = "main"
      path   = "/"
    }
  }

  # Topics/tags for the repository
  topics = ["nextjs", "typescript", "tailwindcss", "otaku", "lithuania", "community"]
}

# Import the otaku.lt-sdk repository (this current repository)
resource "github_repository" "otaku_lt_sdk" {
  name        = "otaku.lt-sdk"
  description = "Infrastructure as Code for otaku.lt using Terraform"

  visibility = "public"

  # Repository settings
  has_issues    = true
  has_projects  = false
  has_wiki      = false
  has_downloads = false

  # Security and analysis
  vulnerability_alerts = true

  # Topics/tags for the repository
  topics = ["terraform", "infrastructure", "github", "iac"]
}

# GitHub repository secrets for Cloudflare deployment
resource "github_actions_secret" "cloudflare_api_token" {
  repository      = github_repository.otaku_lt.name
  secret_name     = "CLOUDFLARE_API_TOKEN"
  plaintext_value = var.cloudflare_api_token
}

resource "github_actions_secret" "cloudflare_account_id" {
  repository      = github_repository.otaku_lt.name
  secret_name     = "CLOUDFLARE_ACCOUNT_ID"
  plaintext_value = var.cloudflare_account_id
}
