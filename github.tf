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

# Events API repository - Python Workers
resource "github_repository" "otaku_lt_api_events" {
  name        = "otaku.lt-api-events"
  description = "Python-based events API using Cloudflare Workers and FastAPI"

  visibility = "public"

  # Repository settings
  has_issues    = true
  has_projects  = false
  has_wiki      = false
  has_downloads = false

  # Security and analysis
  vulnerability_alerts = true
  
  # Enable advanced security features
  security_and_analysis {
    advanced_security {
      status = "enabled"
    }
    secret_scanning {
      status = "enabled"
    }
    secret_scanning_push_protection {
      status = "enabled"
    }
  }

  # Auto-init with README
  auto_init = true

  # Topics/tags for the repository
  topics = ["python", "fastapi", "cloudflare-workers", "api", "events", "serverless", "pyodide"]
}

# Set default branch for events API repository
resource "github_branch_default" "otaku_lt_api_events_default" {
  repository = github_repository.otaku_lt_api_events.name
  branch     = "main"
}

# Branch protection for events API repository
resource "github_branch_protection" "otaku_lt_api_events_main" {
  repository_id = github_repository.otaku_lt_api_events.name
  pattern       = "main"

  # Require pull request reviews
  required_pull_request_reviews {
    dismiss_stale_reviews           = true
    require_code_owner_reviews      = false
    required_approving_review_count = 1
  }

  # Require status checks
  required_status_checks {
    strict = true
    contexts = [
      "build-and-test",
      "security-scan"
    ]
  }

  # Additional protections
  enforce_admins         = false
  allows_deletions       = false
  allows_force_pushes    = false
  require_signed_commits = false
}

# Organization-level secrets for Cloudflare deployment
# These secrets will be available to all repositories in the organization
# Note: Requires GitHub token with admin:org scope
resource "github_actions_organization_secret" "cloudflare_api_token" {
  secret_name     = "CLOUDFLARE_API_TOKEN"
  plaintext_value = var.cloudflare_api_token
  visibility      = "all"
  
  # Only create if we have the necessary permissions
  count = var.cloudflare_api_token != null ? 1 : 0
}

resource "github_actions_organization_secret" "cloudflare_account_id" {
  secret_name     = "CLOUDFLARE_ACCOUNT_ID"
  plaintext_value = var.cloudflare_account_id
  visibility      = "all"
  
  count = var.cloudflare_account_id != null ? 1 : 0
}

resource "github_actions_organization_secret" "cloudflare_zone_id" {
  secret_name     = "CLOUDFLARE_ZONE_ID"
  plaintext_value = var.cloudflare_zone_id
  visibility      = "all"
  
  count = var.cloudflare_zone_id != null ? 1 : 0
}

resource "github_actions_organization_secret" "cloudflare_zone_name" {
  secret_name     = "CLOUDFLARE_ZONE_NAME"
  plaintext_value = var.cloudflare_zone_name
  visibility      = "all"
  
  count = var.cloudflare_zone_name != null ? 1 : 0
}

# Optional: Repository-level secrets for specific overrides (if needed)
# Uncomment if you need different tokens for different repos
# resource "github_actions_secret" "cloudflare_api_token_otaku_lt" {
#   repository      = github_repository.otaku_lt.name
#   secret_name     = "CLOUDFLARE_API_TOKEN"
#   plaintext_value = var.cloudflare_api_token
# }

# resource "github_actions_secret" "cloudflare_account_id_otaku_lt" {
#   repository      = github_repository.otaku_lt.name
#   secret_name     = "CLOUDFLARE_ACCOUNT_ID"
#   plaintext_value = var.cloudflare_account_id
# }
