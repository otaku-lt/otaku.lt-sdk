# Makefile for otaku.lt-sdk Terraform project
# Default target: setup environment and show status

.DEFAULT_GOAL := setup

# Colors for output
GREEN := \033[0;32m
YELLOW := \033[1;33m
RED := \033[0;31m
NC := \033[0m # No Color

.PHONY: setup check-deps check-auth check-cf-auth cf-setup env plan apply fmt validate clean help

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
	@echo "$(GREEN)✅ Dependencies installed$(NC)"

# Check GitHub authentication
check-auth:
	@echo "$(YELLOW)🔐 Checking GitHub authentication...$(NC)"
	@gh auth status >/dev/null 2>&1 || { echo "$(RED)❌ Not authenticated with GitHub CLI$(NC)"; echo "   Run: gh auth login"; exit 1; }
	@echo "$(GREEN)✅ GitHub authentication verified$(NC)"

# Check Cloudflare authentication
check-cf-auth:
	@echo "$(YELLOW)🌤️  Checking Cloudflare authentication...$(NC)"
	@if [ -z "$$CLOUDFLARE_API_TOKEN" ]; then \
		echo "$(RED)❌ CLOUDFLARE_API_TOKEN not set$(NC)"; \
		echo "   Run: make cf-setup"; \
		exit 1; \
	fi
	@echo "$(GREEN)✅ Cloudflare API token found$(NC)"

# Setup Cloudflare API token
cf-setup:
	@echo "$(YELLOW)🌤️  Setting up Cloudflare API Token...$(NC)"
	@echo ""
	@echo "To get your Cloudflare API Token:"
	@echo "1. Go to: https://dash.cloudflare.com/profile/api-tokens"
	@echo "2. Click 'Create Token'"
	@echo "3. Use 'Custom token' template"
	@echo "4. Set permissions: Zone:Read, Page:Edit"
	@echo "5. Add your domain to Zone Resources"
	@echo "6. Copy the token and run:"
	@echo ""
	@echo "   export CLOUDFLARE_API_TOKEN=\"your_token_here\""
	@echo ""
	@echo "Or add it to your shell profile for persistence."

# Set up environment variables
env: check-auth check-cf-auth
	@echo "$(YELLOW)🌍 Setting up environment variables...$(NC)"
	$(eval export GITHUB_TOKEN=$(shell gh auth token))
	$(eval export GITHUB_OWNER=otaku-lt)
	@echo "$(GREEN)✅ Environment variables configured$(NC)"
	@echo "   GITHUB_TOKEN: $${GITHUB_TOKEN:0:7}... (hidden)"
	@echo "   GITHUB_OWNER: otaku-lt"
	@echo "   CLOUDFLARE_API_TOKEN: $${CLOUDFLARE_API_TOKEN:0:7}... (hidden)"

# Initialize terraform
init: setup
	@echo "$(YELLOW)📦 Initializing Terraform...$(NC)"
	@export GITHUB_TOKEN="$$(gh auth token)" && export GITHUB_OWNER="otaku-lt" && \
	 export CLOUDFLARE_API_TOKEN="$$CLOUDFLARE_API_TOKEN" && terraform init
	@echo "$(GREEN)✅ Terraform initialized$(NC)"

# Run terraform plan
plan: setup
	@echo "$(YELLOW)📋 Running Terraform plan...$(NC)"
	@export GITHUB_TOKEN="$$(gh auth token)" && export GITHUB_OWNER="otaku-lt" && \
	 export CLOUDFLARE_API_TOKEN="$$CLOUDFLARE_API_TOKEN" && terraform plan

# Run terraform apply
apply: setup
	@echo "$(YELLOW)🚀 Applying Terraform configuration...$(NC)"
	@export GITHUB_TOKEN="$$(gh auth token)" && export GITHUB_OWNER="otaku-lt" && \
	 export CLOUDFLARE_API_TOKEN="$$CLOUDFLARE_API_TOKEN" && terraform apply

# Apply with auto-approve
apply-auto: setup
	@echo "$(YELLOW)🚀 Auto-applying Terraform configuration...$(NC)"
	@export GITHUB_TOKEN="$$(gh auth token)" && export GITHUB_OWNER="otaku-lt" && \
	 export CLOUDFLARE_API_TOKEN="$$CLOUDFLARE_API_TOKEN" && terraform apply -auto-approve

# Format terraform files
fmt:
	@echo "$(YELLOW)🎨 Formatting Terraform files...$(NC)"
	@terraform fmt -recursive
	@echo "$(GREEN)✅ Files formatted$(NC)"

# Validate terraform configuration
validate: setup
	@echo "$(YELLOW)✅ Validating Terraform configuration...$(NC)"
	@export GITHUB_TOKEN="$$(gh auth token)" && export GITHUB_OWNER="otaku-lt" && \
	 export CLOUDFLARE_API_TOKEN="$$CLOUDFLARE_API_TOKEN" && terraform validate
	@echo "$(GREEN)✅ Configuration valid$(NC)"

# Import existing repositories
import: setup
	@echo "$(YELLOW)📥 Importing existing repositories...$(NC)"
	@export GITHUB_TOKEN="$$(gh auth token)" && export GITHUB_OWNER="otaku-lt" && \
	 export CLOUDFLARE_API_TOKEN="$$CLOUDFLARE_API_TOKEN" && \
		terraform import github_repository.otaku_lt otaku.lt || true
	@export GITHUB_TOKEN="$$(gh auth token)" && export GITHUB_OWNER="otaku-lt" && \
	 export CLOUDFLARE_API_TOKEN="$$CLOUDFLARE_API_TOKEN" && \
		terraform import github_repository.otaku_lt_sdk otaku.lt-sdk || true
	@echo "$(GREEN)✅ Import complete$(NC)"

# Show terraform state
show: setup
	@export GITHUB_TOKEN="$$(gh auth token)" && export GITHUB_OWNER="otaku-lt" && \
	 export CLOUDFLARE_API_TOKEN="$$CLOUDFLARE_API_TOKEN" && terraform show

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
	@echo "Add these lines to your shell profile (~/.zshrc, ~/.bashrc, etc.):"
	@echo ""
	@echo "export GITHUB_TOKEN=\"\$$(gh auth token)\""
	@echo "export GITHUB_OWNER=\"otaku-lt\""
	@echo "export CLOUDFLARE_API_TOKEN=\"your_cloudflare_api_token\""
	@echo ""
	@echo "$(YELLOW)Or run these commands for the current session:$(NC)"
	@echo "export CLOUDFLARE_API_TOKEN=\"your_cloudflare_api_token\""

# Show help
help:
	@echo "$(GREEN)otaku.lt-sdk Terraform Project$(NC)"
	@echo ""
	@echo "$(YELLOW)Available targets:$(NC)"
	@echo "  setup        - Set up environment and check dependencies (default)"
	@echo "  cf-setup     - Show Cloudflare API token setup instructions"
	@echo "  init         - Initialize Terraform"
	@echo "  plan         - Run terraform plan"
	@echo "  apply        - Run terraform apply"
	@echo "  apply-auto   - Run terraform apply with auto-approve"
	@echo "  fmt          - Format terraform files"
	@echo "  validate     - Validate terraform configuration"
	@echo "  import       - Import existing repositories"
	@echo "  show         - Show current terraform state"
	@echo "  clean        - Clean terraform cache"
	@echo "  shell-env    - Show shell environment setup instructions"
	@echo "  help         - Show this help message"
	@echo ""
	@echo "$(YELLOW)Quick start:$(NC)"
	@echo "  make cf-setup # Get Cloudflare API token setup instructions"
	@echo "  make         # Setup environment"
	@echo "  make plan    # Check what will be changed"
	@echo "  make apply   # Apply changes"
