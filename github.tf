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
