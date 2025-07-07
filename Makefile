# Makefile for otaku.lt-sdk Terraform project
# Default target: setup environment and show status

.DEFAULT_GOAL := setup

# Colors for output
GREEN := \033[0;32m
YELLOW := \033[1;33m
RED := \033[0;31m
BLUE := \033[0;34m
NC := \033[0m # No Color

# Include modular makefiles
include cloudflare.mk
include workers.mk

.PHONY: setup check-deps check-auth check-cf-auth env plan apply fmt validate clean set-zone-id shell-env github-secrets help github-secrets

# Default target: setup environment
setup: check-deps check-auth check-cf-auth env
	@echo "$(GREEN)🚀 Environment setup complete!$(NC)"
	@echo ""
	@echo "$(YELLOW)Available commands:$(NC)"
	@echo "  make plan    - Run terraform plan"
	@echo "  make apply   - Run terraform apply"
	@echo "  make fmt     - Format terraform files"
	@echo "  make clean   - Clean terraform cache"
	@echo "  make help    - Show all available commands"

# Check if required dependencies are installed
check-deps:
	@echo "$(YELLOW)🔧 Checking dependencies...$(NC)"
	@command -v terraform >/dev/null 2>&1 || { echo "$(RED)❌ Terraform is not installed$(NC)"; echo "   Install with: brew install terraform"; exit 1; }
	@command -v gh >/dev/null 2>&1 || { echo "$(RED)❌ GitHub CLI (gh) is not installed$(NC)"; echo "   Install with: brew install gh"; exit 1; }
	@command -v wrangler >/dev/null 2>&1 || { echo "$(RED)❌ Wrangler CLI is not installed$(NC)"; echo "   Install with: brew install cloudflare-wrangler"; exit 1; }
	@echo "$(GREEN)✅ Dependencies installed$(NC)"

# Check GitHub authentication
check-auth:
	@echo "$(YELLOW)🔐 Checking GitHub authentication...$(NC)"
	@gh auth status >/dev/null 2>&1 || { echo "$(RED)❌ Not authenticated with GitHub CLI$(NC)"; echo "   Run: gh auth login"; exit 1; }
	@echo "$(GREEN)✅ GitHub authentication verified$(NC)"

# Check Cloudflare authentication
check-cf-auth:
	@echo "$(YELLOW)🌤️  Checking Cloudflare authentication...$(NC)"
	@if command -v wrangler >/dev/null 2>&1; then \
		wrangler whoami >/dev/null 2>&1 || { echo "$(RED)❌ Not authenticated with Wrangler CLI$(NC)"; echo "   Run: wrangler login"; exit 1; }; \
		echo "$(GREEN)✅ Cloudflare authentication verified (wrangler)$(NC)"; \
	elif [ -n "$$CLOUDFLARE_API_TOKEN" ]; then \
		echo "$(GREEN)✅ Cloudflare API token found (env var)$(NC)"; \
	else \
		echo "$(RED)❌ Cloudflare authentication required$(NC)"; \
		echo "   Option 1: wrangler login"; \
		echo "   Option 2: export CLOUDFLARE_API_TOKEN=\"your_token\""; \
		exit 1; \
	fi

# Set up environment variables
env: check-auth check-cf-auth
	@echo "$(YELLOW)🌍 Setting up environment variables...$(NC)"
	$(eval export GITHUB_TOKEN=$(shell gh auth token))
	$(eval export GITHUB_OWNER=otaku-lt)
	@echo "$(GREEN)✅ Environment variables configured$(NC)"
	@echo "   GITHUB_TOKEN: $${GITHUB_TOKEN:0:7}... (hidden)"
	@echo "   GITHUB_OWNER: otaku-lt"
	@if [ -n "$$CLOUDFLARE_API_TOKEN" ]; then \
		echo "   CLOUDFLARE_API_TOKEN: $${CLOUDFLARE_API_TOKEN:0:7}... (env var)"; \
	else \
		echo "   CLOUDFLARE_API_TOKEN: (managed by wrangler)"; \
	fi

# Initialize terraform
init: setup
	@echo "$(YELLOW)📦 Initializing Terraform...$(NC)"
	@export GITHUB_TOKEN="$$(gh auth token)" && export GITHUB_OWNER="otaku-lt" && terraform init
	@echo "$(GREEN)✅ Terraform initialized$(NC)"

# Run terraform plan
plan: setup
	@echo "$(YELLOW)📋 Running Terraform plan...$(NC)"
	@if [ -f .env ]; then \
		. ./.env && export GITHUB_TOKEN="$$(gh auth token)" && export GITHUB_OWNER="otaku-lt" && \
			export CLOUDFLARE_API_TOKEN="$$CLOUDFLARE_OAUTH_TOKEN" && \
			export TF_VAR_cloudflare_account_id="$$CLOUDFLARE_ACCOUNT_ID" && \
			export TF_VAR_cloudflare_zone_id="$$CLOUDFLARE_ZONE_ID" && \
			export TF_VAR_domain_name="$$DOMAIN_NAME" && \
			export TF_VAR_pages_project_name="$$PAGES_PROJECT_NAME" && \
			terraform plan; \
	else \
		echo "$(RED)❌ .env file not found$(NC)"; \
		echo "$(YELLOW)Run 'make cf-extract' first to extract credentials$(NC)"; \
		exit 1; \
	fi

# Run terraform apply
apply: setup
	@echo "$(YELLOW)🚀 Applying Terraform configuration...$(NC)"
	@if [ -f .env ]; then \
		. ./.env && export GITHUB_TOKEN="$$(gh auth token)" && export GITHUB_OWNER="otaku-lt" && \
			export CLOUDFLARE_API_TOKEN="$$CLOUDFLARE_OAUTH_TOKEN" && \
			export TF_VAR_cloudflare_account_id="$$CLOUDFLARE_ACCOUNT_ID" && \
			export TF_VAR_cloudflare_zone_id="$$CLOUDFLARE_ZONE_ID" && \
			export TF_VAR_domain_name="$$DOMAIN_NAME" && \
			export TF_VAR_pages_project_name="$$PAGES_PROJECT_NAME" && \
			terraform apply; \
	else \
		echo "$(RED)❌ .env file not found$(NC)"; \
		echo "$(YELLOW)Run 'make cf-extract' first to extract credentials$(NC)"; \
		exit 1; \
	fi

# Apply with auto-approve
apply-auto: setup
	@echo "$(YELLOW)🚀 Auto-applying Terraform configuration...$(NC)"
	@export GITHUB_TOKEN="$$(gh auth token)" && export GITHUB_OWNER="otaku-lt" && terraform apply -auto-approve

# Format terraform files
fmt:
	@echo "$(YELLOW)🎨 Formatting Terraform files...$(NC)"
	@terraform fmt -recursive
	@echo "$(GREEN)✅ Files formatted$(NC)"

# Validate terraform configuration
validate: setup
	@echo "$(YELLOW)✅ Validating Terraform configuration...$(NC)"
	@export GITHUB_TOKEN="$$(gh auth token)" && export GITHUB_OWNER="otaku-lt" && terraform validate
	@echo "$(GREEN)✅ Configuration valid$(NC)"

# Show terraform state
show: setup
	@export GITHUB_TOKEN="$$(gh auth token)" && export GITHUB_OWNER="otaku-lt" && terraform show

# Clean terraform cache and temporary files
clean:
	@echo "$(YELLOW)🧹 Cleaning Terraform cache...$(NC)"
	@rm -rf .terraform/
	@rm -f .terraform.lock.hcl
	@rm -f terraform.tfstate.backup
	@echo "$(GREEN)✅ Cache cleaned$(NC)"

# Generate shell environment setup
shell-env:
	@echo "$(YELLOW)🐚 Shell environment setup:$(NC)"
	@echo ""
	@echo "GitHub authentication is handled automatically by 'gh' CLI."
	@echo "Cloudflare authentication is handled automatically by 'wrangler' CLI."
	@echo ""
	@echo "Make sure you're authenticated with:"
	@echo "  gh auth login"
	@echo "  wrangler login"

# Helper to set Zone ID in terraform.tfvars
set-zone-id:
	@echo "$(YELLOW)📝 Setting up Zone ID in terraform.tfvars...$(NC)"
	@if [ -z "$(ZONE_ID)" ]; then \
		echo "$(RED)❌ Zone ID not provided$(NC)"; \
		echo "Usage: make set-zone-id ZONE_ID=your_zone_id_here"; \
		echo ""; \
		echo "$(YELLOW)💡 Get your Zone ID from:$(NC)"; \
		echo "1. https://dash.cloudflare.com"; \
		echo "2. Click on otaku.lt domain"; \
		echo "3. Copy Zone ID from right sidebar"; \
		exit 1; \
	fi
	@if [ ! -f terraform.tfvars ]; then \
		echo "$(YELLOW)📄 Creating terraform.tfvars from template...$(NC)"; \
		cp terraform.tfvars.example terraform.tfvars; \
	fi
	@if grep -q "cloudflare_zone_id" terraform.tfvars; then \
		sed -i '' 's/cloudflare_zone_id = ".*"/cloudflare_zone_id = "$(ZONE_ID)"/' terraform.tfvars; \
		echo "$(GREEN)✅ Updated Zone ID in terraform.tfvars$(NC)"; \
	else \
		echo 'cloudflare_zone_id = "$(ZONE_ID)"' >> terraform.tfvars; \
		echo "$(GREEN)✅ Added Zone ID to terraform.tfvars$(NC)"; \
	fi
	@echo "$(BLUE)💡 Zone ID set to: $(ZONE_ID)$(NC)"
	@echo "$(BLUE)🚀 Ready to run: make plan$(NC)"

# Setup GitHub Actions secrets for CI/CD (Organization-Level)
github-org-secrets: setup
	@echo "$(YELLOW)🔐 Setting up Organization-Level GitHub Actions secrets...$(NC)"
	@echo ""
	@if [ ! -f .env ]; then \
		echo "$(RED)❌ .env file not found$(NC)"; \
		echo "$(YELLOW)Run 'make cf-extract' first to extract credentials$(NC)"; \
		exit 1; \
	fi
	@echo "$(BLUE)💡 This will configure GitHub ORGANIZATION secrets for CI/CD$(NC)"
	@echo "$(GREEN)✨ Organization secrets are available to ALL repositories in otaku-lt$(NC)"
	@echo "$(YELLOW)Secrets to be created:$(NC)"
	@echo "  - CLOUDFLARE_API_TOKEN"
	@echo "  - CLOUDFLARE_ACCOUNT_ID"
	@echo "  - CLOUDFLARE_ZONE_ID"
	@echo "  - CLOUDFLARE_ZONE_NAME"
	@echo ""
	@echo "$(BLUE)🔑 Checking GitHub permissions...$(NC)"
	@gh api orgs/otaku-lt/actions/secrets >/dev/null 2>&1 || { \
		echo "$(RED)❌ Insufficient GitHub permissions for organization secrets$(NC)"; \
		echo "$(YELLOW)🔧 Fix: Run 'gh auth refresh --scopes admin:org'$(NC)"; \
		echo "$(BLUE)💡 Alternative: Use 'make github-secrets' for repository-level secrets$(NC)"; \
		exit 1; \
	}
	@echo "$(GREEN)✅ GitHub permissions verified$(NC)"
	@. ./.env && export GITHUB_TOKEN="$$(gh auth token)" && export GITHUB_OWNER="otaku-lt" && \
		export CLOUDFLARE_API_TOKEN="$$CLOUDFLARE_OAUTH_TOKEN" && \
		export TF_VAR_cloudflare_api_token="$$CLOUDFLARE_OAUTH_TOKEN" && \
		export TF_VAR_cloudflare_account_id="$$CLOUDFLARE_ACCOUNT_ID" && \
		export TF_VAR_cloudflare_zone_id="$$CLOUDFLARE_ZONE_ID" && \
		export TF_VAR_cloudflare_zone_name="$$DOMAIN_NAME" && \
		export TF_VAR_domain_name="$$DOMAIN_NAME" && \
		export TF_VAR_pages_project_name="$$PAGES_PROJECT_NAME" && \
		terraform apply -target=github_actions_organization_secret.cloudflare_api_token \
			-target=github_actions_organization_secret.cloudflare_account_id \
			-target=github_actions_organization_secret.cloudflare_zone_id \
			-target=github_actions_organization_secret.cloudflare_zone_name
	@echo ""
	@echo "$(GREEN)🎉 Organization-Level GitHub Actions secrets configured!$(NC)"
	@echo "$(BLUE)🌟 All repositories in the otaku-lt organization can now use these secrets$(NC)"
	@echo "$(BLUE)🚀 Ready to create new Workers/API repositories with automatic CI/CD$(NC)"

# Show organization secrets status
github-org-status:
	@echo "$(YELLOW)📊 Organization-Level Secrets Status$(NC)"
	@echo ""
	@echo "$(BLUE)💡 Checking GitHub organization secrets...$(NC)"
	@gh api orgs/otaku-lt/actions/secrets --jq '.secrets[] | select(.name | startswith("CLOUDFLARE_")) | "✅ " + .name + " (updated: " + .updated_at + ")"' 2>/dev/null || echo "$(YELLOW)⚠️  No organization secrets found or permission denied$(NC)"
	@echo ""
	@echo "$(YELLOW)🔧 To set up organization secrets:$(NC)"
	@echo "  make github-org-secrets"

# Setup GitHub Actions secrets for CI/CD (Repository-Level - Legacy)
github-secrets: setup
	@echo "$(YELLOW)🔐 Setting up Repository-Level GitHub Actions secrets...$(NC)"
	@echo "$(BLUE)💡 For organization-wide secrets, use 'make github-org-secrets' instead$(NC)"
	@echo ""
	@if [ ! -f .env ]; then \
		echo "$(RED)❌ .env file not found$(NC)"; \
		echo "$(YELLOW)Run 'make cf-extract' first to extract credentials$(NC)"; \
		exit 1; \
	fi
	@echo "$(YELLOW)Secrets to be created (repository-level):$(NC)"
	@echo "  - CLOUDFLARE_API_TOKEN"
	@echo "  - CLOUDFLARE_ACCOUNT_ID"
	@echo ""
	@. ./.env && export GITHUB_TOKEN="$$(gh auth token)" && export GITHUB_OWNER="otaku-lt" && \
		export CLOUDFLARE_API_TOKEN="$$CLOUDFLARE_OAUTH_TOKEN" && \
		export TF_VAR_cloudflare_api_token="$$CLOUDFLARE_OAUTH_TOKEN" && \
		export TF_VAR_cloudflare_account_id="$$CLOUDFLARE_ACCOUNT_ID" && \
		export TF_VAR_cloudflare_zone_id="$$CLOUDFLARE_ZONE_ID" && \
		export TF_VAR_domain_name="$$DOMAIN_NAME" && \
		export TF_VAR_pages_project_name="$$PAGES_PROJECT_NAME" && \
		terraform apply -target=github_actions_secret.cloudflare_api_token_otaku_lt -target=github_actions_secret.cloudflare_account_id_otaku_lt
	@echo ""
	@echo "$(GREEN)🎉 Repository-Level GitHub Actions secrets configured!$(NC)"
	@echo "$(BLUE)🚀 This repository's CI/CD pipeline is now ready$(NC)"

# Show help
help:
	@echo "$(GREEN)otaku.lt-sdk Terraform + Cloudflare Workers Project$(NC)"
	@echo ""
	@echo "$(YELLOW)🏗️  Infrastructure Management:$(NC)"
	@echo "  setup        - Set up environment and check dependencies (default)"
	@echo "  cf-setup     - Show Cloudflare API token setup instructions"
	@echo "  cf-extract   - Extract Cloudflare credentials from wrangler to .env"
	@echo "  cf-set-token - Set custom API token in .env (usage: make cf-set-token TOKEN=xyz)"
	@echo "  cf-import-dns - Import existing DNS records into Terraform state"
	@echo "  cf-connect-github - Show instructions to connect Pages to GitHub repo (legacy)"
	@echo "  cf-check-github - Check GitHub App installation status (legacy)"
	@echo "  cf-info      - Show Cloudflare account information from .env"
	@echo "  cf-auto-setup - Extract credentials and run terraform plan"
	@echo "  github-org-secrets - Setup Organization-Level GitHub Actions secrets (RECOMMENDED)"
	@echo "  github-secrets - Setup Repository-Level GitHub Actions secrets (legacy)"
	@echo "  github-org-status - Show organization secrets status"
	@echo "  init         - Initialize Terraform"
	@echo "  plan         - Run terraform plan (uses .env for credentials)"
	@echo "  apply        - Run terraform apply (uses .env for credentials)"
	@echo "  apply-auto   - Run terraform apply with auto-approve"
	@echo "  fmt          - Format terraform files"
	@echo "  validate     - Validate terraform configuration"
	@echo "  show         - Show current terraform state"
	@echo "  clean        - Clean terraform cache"
	@echo ""
	@echo "$(YELLOW)🚀 Cloudflare Workers Deployment:$(NC)"
	@echo "  workers-build          - Build Next.js frontend for deployment"
	@echo "  workers-deploy         - Deploy to Cloudflare Workers (production)"
	@echo "  workers-deploy-preview - Deploy to Cloudflare Workers (preview)"
	@echo "  workers-test           - Test Workers locally with wrangler dev"
	@echo "  workers-setup          - Complete Workers setup (infra + build)"
	@echo "  workers-apply          - Apply infrastructure and deploy Workers"
	@echo "  workers-status         - Show Workers deployment status and logs"
	@echo ""
	@echo "$(YELLOW)🛠️  Utilities:$(NC)"
	@echo "  set-zone-id  - Set Zone ID in terraform.tfvars (legacy, use cf-extract instead)"
	@echo "  shell-env    - Show shell environment setup instructions"
	@echo "  help         - Show this help message"
	@echo ""
	@echo "$(YELLOW)🚀 Quick Start (Cloudflare Workers):$(NC)"
	@echo "  gh auth login                    # Authenticate with GitHub"
	@echo "  wrangler login                   # Authenticate with Cloudflare"
	@echo "  make cf-extract                  # Extract credentials to .env"
	@echo "  make workers-setup               # Setup infrastructure"
	@echo "  make github-org-secrets          # Setup Organization-Level GitHub Actions secrets"
	@echo "  make workers-apply               # Deploy everything"
	@echo ""
	@echo "$(YELLOW)🏗️  Infrastructure Only:$(NC)"
	@echo "  make cf-set-token TOKEN=xyz      # Set your custom API token"
	@echo "  make plan                        # Preview infrastructure changes"
	@echo "  make apply                       # Apply changes"
	@echo ""
	@echo "$(YELLOW)🚀 Deploy Only:$(NC)"
	@echo "  make workers-deploy              # Deploy to production"
	@echo "  make workers-deploy-preview      # Deploy to preview/staging"
	@echo ""
	@echo "$(YELLOW)🧪 Development & Testing:$(NC)"
	@echo "  make workers-test                # Test locally with wrangler dev"
	@echo "  make workers-status              # Check deployment status"
