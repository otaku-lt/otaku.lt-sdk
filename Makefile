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

.PHONY: setup check-deps check-auth check-cf-auth env plan apply fmt validate clean set-zone-id shell-env help debug-env debug-env-simple

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
	@if [ -f .env ]; then \
		. ./.env && [ -n "$$CLOUDFLARE_API_TOKEN" ] && echo "$(GREEN)✅ Cloudflare API token found in .env$(NC)" || { \
			echo "$(RED)❌ CLOUDFLARE_API_TOKEN not found in .env$(NC)"; \
			echo "   Run: make cf-set-token TOKEN=your_api_token"; \
			echo "   Get token from: https://dash.cloudflare.com/profile/api-tokens"; \
			exit 1; \
		}; \
	elif [ -n "$$CLOUDFLARE_API_TOKEN" ]; then \
		echo "$(GREEN)✅ Cloudflare API token found (env var)$(NC)"; \
	else \
		echo "$(RED)❌ Cloudflare authentication required$(NC)"; \
		echo "   Run: make cf-set-token TOKEN=your_api_token"; \
		echo "   Get token from: https://dash.cloudflare.com/profile/api-tokens"; \
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
		echo "$(BLUE)🔧 Loading environment variables from .env...$(NC)"; \
		. ./.env && \
		export GITHUB_TOKEN="$$(gh auth token)" && \
		export GITHUB_OWNER="otaku-lt" && \
		export CLOUDFLARE_API_TOKEN="$$CLOUDFLARE_API_TOKEN" && \
		export TF_VAR_cloudflare_api_token="$$CLOUDFLARE_API_TOKEN" && \
		export TF_VAR_cloudflare_account_id="$$CLOUDFLARE_ACCOUNT_ID" && \
		export TF_VAR_cloudflare_zone_id="$$CLOUDFLARE_ZONE_ID" && \
		export TF_VAR_domain_name="$$DOMAIN_NAME" && \
		export TF_VAR_pages_project_name="$$PAGES_PROJECT_NAME" && \
		echo "$(GREEN)✅ Environment loaded$(NC)" && \
		echo "$(BLUE)🚀 Running: terraform plan$(NC)" && \
		terraform plan; \
	else \
		echo "$(RED)❌ .env file not found$(NC)"; \
		echo "$(YELLOW)Run 'make cf-set-token TOKEN=xyz' first to set up credentials$(NC)"; \
		exit 1; \
	fi

# Quick terraform plan without setup checks
plan-quick:
	@echo "$(YELLOW)📋 Running Terraform plan (quick)...$(NC)"
	@if [ -f .env ]; then \
		echo "$(BLUE)🔧 Loading environment variables from .env...$(NC)"; \
		. ./.env && \
		export GITHUB_TOKEN="$$(gh auth token)" && \
		export GITHUB_OWNER="otaku-lt" && \
		export CLOUDFLARE_API_TOKEN="$$CLOUDFLARE_API_TOKEN" && \
		export TF_VAR_cloudflare_api_token="$$CLOUDFLARE_API_TOKEN" && \
		export TF_VAR_cloudflare_account_id="$$CLOUDFLARE_ACCOUNT_ID" && \
		export TF_VAR_cloudflare_zone_id="$$CLOUDFLARE_ZONE_ID" && \
		export TF_VAR_domain_name="$$DOMAIN_NAME" && \
		export TF_VAR_pages_project_name="$$PAGES_PROJECT_NAME" && \
		echo "$(GREEN)✅ Environment loaded$(NC)" && \
		echo "$(BLUE)🚀 Running: terraform plan$(NC)" && \
		terraform plan; \
	else \
		echo "$(RED)❌ .env file not found$(NC)"; \
		echo "$(YELLOW)Run 'make cf-set-token TOKEN=xyz' first to set up credentials$(NC)"; \
		exit 1; \
	fi

# Run terraform apply
apply: setup
	@echo "$(YELLOW)🚀 Applying Terraform configuration...$(NC)"
	@if [ -f .env ]; then \
		echo "$(BLUE)🔧 Loading environment variables from .env...$(NC)"; \
		. ./.env && \
		export GITHUB_TOKEN="$$(gh auth token)" && \
		export GITHUB_OWNER="otaku-lt" && \
		export CLOUDFLARE_API_TOKEN="$$CLOUDFLARE_API_TOKEN" && \
		export TF_VAR_cloudflare_api_token="$$CLOUDFLARE_API_TOKEN" && \
		export TF_VAR_cloudflare_account_id="$$CLOUDFLARE_ACCOUNT_ID" && \
		export TF_VAR_cloudflare_zone_id="$$CLOUDFLARE_ZONE_ID" && \
		export TF_VAR_domain_name="$$DOMAIN_NAME" && \
		export TF_VAR_pages_project_name="$$PAGES_PROJECT_NAME" && \
		echo "$(GREEN)✅ Environment loaded$(NC)" && \
		echo "$(BLUE)🚀 Running: terraform apply$(NC)" && \
		terraform apply; \
	else \
		echo "$(RED)❌ .env file not found$(NC)"; \
		echo "$(YELLOW)Run 'make cf-set-token TOKEN=xyz' first to set up credentials$(NC)"; \
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
	rm -rf .terraform
	rm -f .terraform.lock.hcl
	rm -f terraform.tfstate.backup

# Generate shell environment setup
shell-env:
	@echo "$(YELLOW)🐚 Shell environment setup:$(NC)"
	@echo ""
	@echo "GitHub authentication is handled automatically by 'gh' CLI."
	@echo "Cloudflare authentication uses API tokens from dashboard."
	@echo ""
	@echo "Make sure you're authenticated with:"
	@echo "  gh auth login"
	@echo "  make cf-set-token TOKEN=your_api_token"

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

# Debug target to show environment variables
debug-env: setup
	@echo "$(YELLOW)🔍 Debugging environment variables...$(NC)"
	@if [ -f .env ]; then \
		echo "$(BLUE)📄 Contents of .env file:$(NC)"; \
		cat .env; \
		echo ""; \
		echo "$(BLUE)🔧 Loaded environment variables:$(NC)"; \
		. ./.env && \
		export GITHUB_TOKEN="$$(gh auth token)" && \
		export GITHUB_OWNER="otaku-lt" && \
		export CLOUDFLARE_API_TOKEN="$$CLOUDFLARE_API_TOKEN" && \
		export TF_VAR_cloudflare_api_token="$$CLOUDFLARE_API_TOKEN" && \
		export TF_VAR_cloudflare_account_id="$$CLOUDFLARE_ACCOUNT_ID" && \
		export TF_VAR_cloudflare_zone_id="$$CLOUDFLARE_ZONE_ID" && \
		export TF_VAR_domain_name="$$DOMAIN_NAME" && \
		export TF_VAR_pages_project_name="$$PAGES_PROJECT_NAME" && \
		echo "GITHUB_TOKEN: $${GITHUB_TOKEN:0:10}..." && \
		echo "GITHUB_OWNER: $$GITHUB_OWNER" && \
		echo "CLOUDFLARE_API_TOKEN: $${CLOUDFLARE_API_TOKEN:0:10}..." && \
		echo "TF_VAR_cloudflare_api_token: $${TF_VAR_cloudflare_api_token:0:10}..." && \
		echo "TF_VAR_cloudflare_account_id: $$TF_VAR_cloudflare_account_id" && \
		echo "TF_VAR_cloudflare_zone_id: $$TF_VAR_cloudflare_zone_id" && \
		echo "TF_VAR_domain_name: $$TF_VAR_domain_name" && \
		echo "TF_VAR_pages_project_name: $$TF_VAR_pages_project_name"; \
	else \
		echo "$(RED)❌ .env file not found$(NC)"; \
		echo "$(YELLOW)Run 'make cf-set-token TOKEN=xyz' first to set up credentials$(NC)"; \
		exit 1; \
	fi

# Simple debug target without setup dependencies  
debug-env-simple:
	@echo "$(YELLOW)🔍 Debugging environment variables...$(NC)"
	@if [ -f .env ]; then \
		echo "$(BLUE)📄 Contents of .env file:$(NC)"; \
		cat .env; \
		echo ""; \
		echo "$(BLUE)🔧 Loaded environment variables:$(NC)"; \
		. ./.env && \
		export GITHUB_TOKEN="$$(gh auth token)" && \
		export GITHUB_OWNER="otaku-lt" && \
		export CLOUDFLARE_API_TOKEN="$$CLOUDFLARE_API_TOKEN" && \
		export TF_VAR_cloudflare_api_token="$$CLOUDFLARE_API_TOKEN" && \
		export TF_VAR_cloudflare_account_id="$$CLOUDFLARE_ACCOUNT_ID" && \
		export TF_VAR_cloudflare_zone_id="$$CLOUDFLARE_ZONE_ID" && \
		export TF_VAR_domain_name="$$DOMAIN_NAME" && \
		export TF_VAR_pages_project_name="$$PAGES_PROJECT_NAME" && \
		echo "GITHUB_TOKEN: $${GITHUB_TOKEN:0:10}..." && \
		echo "GITHUB_OWNER: $$GITHUB_OWNER" && \
		echo "CLOUDFLARE_API_TOKEN: $${CLOUDFLARE_API_TOKEN:0:10}..." && \
		echo "TF_VAR_cloudflare_api_token: $${TF_VAR_cloudflare_api_token:0:10}..." && \
		echo "TF_VAR_cloudflare_account_id: $$TF_VAR_cloudflare_account_id" && \
		echo "TF_VAR_cloudflare_zone_id: $$TF_VAR_cloudflare_zone_id" && \
		echo "TF_VAR_domain_name: $$TF_VAR_domain_name" && \
		echo "TF_VAR_pages_project_name: $$TF_VAR_pages_project_name"; \
	else \
		echo "$(RED)❌ .env file not found$(NC)"; \
		echo "$(YELLOW)Run 'make cf-set-token TOKEN=xyz' first to set up credentials$(NC)"; \
		exit 1; \
	fi

# Events API specific commands
.PHONY: events-config events-migrate events-migrate-dev events-deploy events-deploy-dev events-dev events-logs

# Show events API infrastructure configuration
events-config:
	@echo "$(YELLOW)📊 Events API Infrastructure:$(NC)"
	@terraform output events_api_wrangler_config

# Apply database migrations to production
events-migrate:
	@echo "$(YELLOW)🔄 Applying migrations to production database...$(NC)"
	@if [ -d "../otaku.lt-api-events" ] && [ -f "../otaku.lt-api-events/migrations/0001_initial.sql" ]; then \
		cd ../otaku.lt-api-events && wrangler d1 execute otaku-events-db --file=migrations/0001_initial.sql; \
		echo "$(GREEN)✅ Production migrations applied$(NC)"; \
	else \
		echo "$(RED)❌ Migration files not found. Expected: ../otaku.lt-api-events/migrations/0001_initial.sql$(NC)"; \
	fi

# Apply database migrations to development
events-migrate-dev:
	@echo "$(YELLOW)🔄 Applying migrations to development database...$(NC)"
	@if [ -d "../otaku.lt-api-events" ] && [ -f "../otaku.lt-api-events/migrations/0001_initial.sql" ]; then \
		cd ../otaku.lt-api-events && wrangler d1 execute otaku-events-db-dev --file=migrations/0001_initial.sql; \
		echo "$(GREEN)✅ Development migrations applied$(NC)"; \
	else \
		echo "$(RED)❌ Migration files not found. Expected: ../otaku.lt-api-events/migrations/0001_initial.sql$(NC)"; \
	fi

# Deploy events API to production
events-deploy:
	@echo "$(YELLOW)🚀 Deploying events API to production...$(NC)"
	@if [ -d "../otaku.lt-api-events" ]; then \
		cd ../otaku.lt-api-events && npm run deploy:prod; \
		echo "$(GREEN)✅ Events API deployed to production$(NC)"; \
	else \
		echo "$(RED)❌ Events API directory not found: ../otaku.lt-api-events$(NC)"; \
	fi

# Deploy events API to development
events-deploy-dev:
	@echo "$(YELLOW)🚀 Deploying events API to development...$(NC)"
	@if [ -d "../otaku.lt-api-events" ]; then \
		cd ../otaku.lt-api-events && npm run deploy:dev; \
		echo "$(GREEN)✅ Events API deployed to development$(NC)"; \
	else \
		echo "$(RED)❌ Events API directory not found: ../otaku.lt-api-events$(NC)"; \
	fi

# Run events API in development mode
events-dev:
	@echo "$(YELLOW)🔧 Starting events API in development mode...$(NC)"
	@if [ -d "../otaku.lt-api-events" ]; then \
		cd ../otaku.lt-api-events && npm run dev; \
	else \
		echo "$(RED)❌ Events API directory not found: ../otaku.lt-api-events$(NC)"; \
	fi

# Show events API logs
events-logs:
	@echo "$(YELLOW)📋 Showing events API logs...$(NC)"
	@if [ -d "../otaku.lt-api-events" ]; then \
		cd ../otaku.lt-api-events && npm run logs; \
	else \
		echo "$(RED)❌ Events API directory not found: ../otaku.lt-api-events$(NC)"; \
	fi

# Show help
help:
	@echo "$(GREEN)otaku.lt-sdk Terraform + Cloudflare Workers Project$(NC)"
	@echo ""
	@echo "$(YELLOW)🏗️  Infrastructure Management:$(NC)"
	@echo "  setup        - Set up environment and check dependencies (default)"
	@echo "  cf-setup     - Show Cloudflare API token setup instructions"
	@echo "  cf-set-token - Set custom API token in .env (usage: make cf-set-token TOKEN=xyz)"
	@echo "  cf-info      - Show Cloudflare account information from .env"
	@echo "  cf-auto-setup - Extract credentials and run terraform plan"
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
	@echo "$(YELLOW)🎯 Events API Management:$(NC)"
	@echo "  events-config          - Show wrangler.toml configuration for events API"
	@echo "  events-migrate         - Apply database migrations to production"
	@echo "  events-migrate-dev     - Apply database migrations to development"
	@echo "  events-deploy          - Deploy events API to production"
	@echo "  events-deploy-dev      - Deploy events API to development"
	@echo "  events-dev             - Run events API in development mode"
	@echo "  events-logs            - Show events API logs"
	@echo ""
	@echo "$(YELLOW)🛠️  Utilities:$(NC)"
	@echo "  debug-env    - Show environment variables and .env contents"
	@echo "  debug-env-simple - Simple debug of environment variables (no setup)"
	@echo "  set-zone-id  - Set Zone ID in terraform.tfvars (legacy, use cf-set-token instead)"
	@echo "  shell-env    - Show shell environment setup instructions"
	@echo "  help         - Show this help message"
	@echo ""
	@echo "$(YELLOW)🚀 Quick Start (Complete Infrastructure):$(NC)"
	@echo "  gh auth login                    # Authenticate with GitHub"
	@echo "  make cf-set-token TOKEN=xyz      # Set Cloudflare API token"
	@echo "  make apply                       # Deploy everything"
	@echo ""
	@echo "$(BLUE)📦 This creates everything automatically:$(NC)"
	@echo "  • Organization-level GitHub secrets"
	@echo "  • otaku.lt-api-events repository with security features"
	@echo "  • D1 database for events storage"
	@echo "  • KV namespaces for caching and rate limiting"
	@echo "  • DNS record for api.otaku.lt"
	@echo "  • Branch protection rules"
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
