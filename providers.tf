terraform {
  required_version = ">= 1.0"

  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

provider "github" {
  # Use environment variables instead of data sources to avoid storing tokens in state
  # Set: export GITHUB_TOKEN="your_token"
  owner = "otaku-lt"
}

provider "cloudflare" {
  # Use environment variables for authentication
  # Set: export CLOUDFLARE_API_TOKEN="your_api_token"
  # Or get from dashboard: https://dash.cloudflare.com/profile/api-tokens
}
