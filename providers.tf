terraform {
  required_version = ">= 1.0"
  
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}

provider "github" {
  # Use environment variables instead of data sources to avoid storing tokens in state
  # Set: export GITHUB_TOKEN="your_token"
  owner = "otaku-lt"
}
