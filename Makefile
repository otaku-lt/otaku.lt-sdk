# Makefile for otaku.lt-sdk Terraform project
# Default target: setup environment and show status

.DEFAULT_GOAL := setup

# Colors for output
GREEN := \033[0;32m
YELLOW := \033[1;33m
RED := \033[0;31m
NC := \033[0m # No Color

.PHONY: setup check-deps check-auth check-cf-auth cf-setup cf-info cf-extract cf-set-token cf-import-dns cf-auto-setup set-zone-id env plan apply fmt validate clean help

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

# Setup Cloudflare authentication
cf-setup:
	@echo "$(YELLOW)🌤️  Setting up Cloudflare authentication...$(NC)"
	@echo ""
	@echo "$(RED)⚠️  NOTE: Wrangler OAuth tokens have limited permissions!$(NC)"
	@echo "$(YELLOW)For full Terraform functionality, you need a custom API token.$(NC)"
	@echo ""
	@echo "$(YELLOW)🔑 Create Custom API Token (Required for Terraform):$(NC)"
	@echo "1. 🌐 Go to: https://dash.cloudflare.com/profile/api-tokens"
	@echo "2. 🔘 Click 'Create Token'"
	@echo "3. 🔧 Use 'Custom token' template"
	@echo "4. 📝 Set permissions:"
	@echo "   - Zone:Zone:Read"
	@echo "   - Zone:Zone Settings:Edit"
	@echo "   - Zone:DNS:Edit"
	@echo "   - Zone:Page Rules:Edit"
	@echo "   - Account:Cloudflare Pages:Edit"
	@echo "5. 🎯 Set zone resources: Include > Specific zone > otaku.lt"
	@echo "6. 🎯 Set account resources: Include > Your account"
	@echo "7. ✅ Create token and copy it"
	@echo "8. 💾 Save token: make cf-set-token TOKEN=your_token_here"
	@echo ""
	@echo "$(YELLOW)🚀 Alternative: Wrangler (Limited - Pages only):$(NC)"
	@echo "1. Install: brew install cloudflare-wrangler"
	@echo "2. Login: wrangler login"
	@echo "3. Extract config: make cf-extract"
	@echo "   $(RED)⚠️  Will only work for Pages, not DNS/Zone settings$(NC)"

# Extract Cloudflare credentials from wrangler config to .env file
cf-extract:
	@echo "$(YELLOW)🔧 Extracting Cloudflare credentials from wrangler config...$(NC)"
	@echo ""
	@if [ ! -f ~/Library/Preferences/.wrangler/config/default.toml ]; then \
		echo "$(RED)❌ Wrangler config not found at ~/Library/Preferences/.wrangler/config/default.toml$(NC)"; \
		echo "$(YELLOW)Run 'wrangler login' first$(NC)"; \
		exit 1; \
	fi
	@if [ ! -f .env ]; then \
		echo "$(BLUE)📄 Creating .env from template...$(NC)"; \
		cp .env.example .env; \
	fi
	@echo "$(YELLOW)🔑 Extracting OAuth token...$(NC)"
	@OAUTH_TOKEN=$$(grep -o 'oauth_token = "[^"]*"' ~/Library/Preferences/.wrangler/config/default.toml | cut -d'"' -f2 2>/dev/null); \
	if [ -n "$$OAUTH_TOKEN" ]; then \
		if grep -q "^CLOUDFLARE_OAUTH_TOKEN=" .env; then \
			sed -i '' "s/^CLOUDFLARE_OAUTH_TOKEN=.*/CLOUDFLARE_OAUTH_TOKEN=$$OAUTH_TOKEN/" .env; \
		else \
			echo "CLOUDFLARE_OAUTH_TOKEN=$$OAUTH_TOKEN" >> .env; \
		fi; \
		echo "$(GREEN)✅ OAuth token extracted and saved to .env$(NC)"; \
	else \
		echo "$(RED)❌ Could not extract OAuth token$(NC)"; \
		exit 1; \
	fi
	@echo "$(YELLOW)🌐 Fetching Zone ID for otaku.lt...$(NC)"
	@if command -v jq >/dev/null 2>&1; then \
		OAUTH_TOKEN=$$(grep -o 'oauth_token = "[^"]*"' ~/Library/Preferences/.wrangler/config/default.toml | cut -d'"' -f2 2>/dev/null); \
		ZONE_ID=$$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones?name=otaku.lt" \
			-H "Authorization: Bearer $$OAUTH_TOKEN" \
			-H "Content-Type: application/json" | jq -r '.result[0].id // empty' 2>/dev/null); \
		if [ -n "$$ZONE_ID" ] && [ "$$ZONE_ID" != "null" ]; then \
			if grep -q "^CLOUDFLARE_ZONE_ID=" .env; then \
				sed -i '' "s/^CLOUDFLARE_ZONE_ID=.*/CLOUDFLARE_ZONE_ID=$$ZONE_ID/" .env; \
			else \
				echo "CLOUDFLARE_ZONE_ID=$$ZONE_ID" >> .env; \
			fi; \
			echo "$(GREEN)✅ Zone ID fetched and saved to .env: $$ZONE_ID$(NC)"; \
		else \
			echo "$(RED)❌ Could not fetch Zone ID$(NC)"; \
			exit 1; \
		fi; \
	else \
		echo "$(RED)❌ jq not found - install with: brew install jq$(NC)"; \
		exit 1; \
	fi
	@echo ""
	@echo "$(GREEN)🎉 Credentials extracted successfully!$(NC)"
	@echo "$(BLUE)💡 .env file created with OAuth token and Zone ID$(NC)"
	@echo "$(BLUE)🚀 Ready to run: make plan$(NC)"

# Set Cloudflare API token in .env file
cf-set-token:
	@echo "$(YELLOW)🔑 Setting Cloudflare API token in .env file...$(NC)"
	@echo ""
	@if [ -z "$(TOKEN)" ]; then \
		echo "$(RED)❌ API token not provided$(NC)"; \
		echo "Usage: make cf-set-token TOKEN=your_api_token_here"; \
		echo ""; \
		echo "$(YELLOW)💡 Create your API token at:$(NC)"; \
		echo "https://dash.cloudflare.com/profile/api-tokens"; \
		echo ""; \
		echo "$(YELLOW)Required permissions:$(NC)"; \
		echo "- Zone:Zone:Read"; \
		echo "- Zone:Zone Settings:Edit"; \
		echo "- Zone:DNS:Edit"; \
		echo "- Zone:Page Rules:Edit"; \
		echo "- Account:Cloudflare Pages:Edit"; \
		exit 1; \
	fi
	@if [ ! -f .env ]; then \
		echo "$(BLUE)📄 Creating .env from template...$(NC)"; \
		cp .env.example .env; \
	fi
	@if grep -q "^CLOUDFLARE_OAUTH_TOKEN=" .env; then \
		sed -i '' "s/^CLOUDFLARE_OAUTH_TOKEN=.*/CLOUDFLARE_OAUTH_TOKEN=$(TOKEN)/" .env; \
		echo "$(GREEN)✅ Updated API token in .env$(NC)"; \
	else \
		echo "CLOUDFLARE_OAUTH_TOKEN=$(TOKEN)" >> .env; \
		echo "$(GREEN)✅ Added API token to .env$(NC)"; \
	fi
	@echo "$(YELLOW)🌐 Fetching Zone ID for otaku.lt with new token...$(NC)"
	@if command -v jq >/dev/null 2>&1; then \
		ZONE_ID=$$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones?name=otaku.lt" \
			-H "Authorization: Bearer $(TOKEN)" \
			-H "Content-Type: application/json" | jq -r '.result[0].id // empty' 2>/dev/null); \
		if [ -n "$$ZONE_ID" ] && [ "$$ZONE_ID" != "null" ]; then \
			if grep -q "^CLOUDFLARE_ZONE_ID=" .env; then \
				sed -i '' "s/^CLOUDFLARE_ZONE_ID=.*/CLOUDFLARE_ZONE_ID=$$ZONE_ID/" .env; \
			else \
				echo "CLOUDFLARE_ZONE_ID=$$ZONE_ID" >> .env; \
			fi; \
			echo "$(GREEN)✅ Zone ID fetched and saved: $$ZONE_ID$(NC)"; \
		else \
			echo "$(YELLOW)⚠️  Could not fetch Zone ID, but token saved$(NC)"; \
			echo "$(YELLOW)You may need to add CLOUDFLARE_ZONE_ID manually$(NC)"; \
		fi; \
	else \
		echo "$(YELLOW)⚠️  jq not found - Zone ID not fetched$(NC)"; \
		echo "$(YELLOW)Install jq: brew install jq$(NC)"; \
	fi
	@echo ""
	@echo "$(GREEN)🎉 API token configured successfully!$(NC)"
	@echo "$(BLUE)💡 .env file updated with API token$(NC)"
	@echo "$(BLUE)🚀 Ready to run: make plan$(NC)"

# Import existing DNS records into Terraform state
cf-import-dns:
	@echo "$(YELLOW)📥 Importing existing DNS records into Terraform state...$(NC)"
	@echo ""
	@if [ ! -f .env ]; then \
		echo "$(RED)❌ .env file not found$(NC)"; \
		echo "$(YELLOW)Run 'make cf-set-token TOKEN=xyz' first$(NC)"; \
		exit 1; \
	fi
	@. ./.env && export GITHUB_TOKEN="$$(gh auth token)" && export GITHUB_OWNER="otaku-lt" && \
		export CLOUDFLARE_API_TOKEN="$$CLOUDFLARE_OAUTH_TOKEN" && \
		export TF_VAR_cloudflare_account_id="$$CLOUDFLARE_ACCOUNT_ID" && \
		export TF_VAR_cloudflare_zone_id="$$CLOUDFLARE_ZONE_ID" && \
		export TF_VAR_domain_name="$$DOMAIN_NAME" && \
		export TF_VAR_pages_project_name="$$PAGES_PROJECT_NAME"
	@echo "$(YELLOW)🔍 Finding existing DNS records...$(NC)"
	@. ./.env && CNAME_ID=$$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$$CLOUDFLARE_ZONE_ID/dns_records?name=$$DOMAIN_NAME&type=CNAME" \
		-H "Authorization: Bearer $$CLOUDFLARE_OAUTH_TOKEN" \
		-H "Content-Type: application/json" | jq -r '.result[0].id // empty' 2>/dev/null); \
	if [ -n "$$CNAME_ID" ] && [ "$$CNAME_ID" != "null" ]; then \
		echo "$(GREEN)✅ Found existing CNAME record: $$CNAME_ID$(NC)"; \
		echo "$(YELLOW)🔄 Importing into Terraform...$(NC)"; \
		terraform import cloudflare_record.otaku_lt_cname "$$CLOUDFLARE_ZONE_ID/$$CNAME_ID" || echo "$(YELLOW)⚠️  Import failed or already imported$(NC)"; \
	else \
		echo "$(BLUE)💡 No existing CNAME record found for root domain$(NC)"; \
	fi
	@. ./.env && WWW_ID=$$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$$CLOUDFLARE_ZONE_ID/dns_records?name=www.$$DOMAIN_NAME&type=CNAME" \
		-H "Authorization: Bearer $$CLOUDFLARE_OAUTH_TOKEN" \
		-H "Content-Type: application/json" | jq -r '.result[0].id // empty' 2>/dev/null); \
	if [ -n "$$WWW_ID" ] && [ "$$WWW_ID" != "null" ]; then \
		echo "$(GREEN)✅ Found existing WWW CNAME record: $$WWW_ID$(NC)"; \
		echo "$(YELLOW)🔄 Importing into Terraform...$(NC)"; \
		terraform import cloudflare_record.otaku_lt_www "$$CLOUDFLARE_ZONE_ID/$$WWW_ID" || echo "$(YELLOW)⚠️  Import failed or already imported$(NC)"; \
	else \
		echo "$(BLUE)💡 No existing WWW CNAME record found$(NC)"; \
	fi
	@echo ""
	@echo "$(GREEN)🎉 DNS import process completed!$(NC)"
	@echo "$(BLUE)💡 Run 'make plan' to see what changes are needed$(NC)"

cf-info:
	@echo "$(YELLOW)🌤️  Cloudflare Account Information:$(NC)"
	@echo ""
	@wrangler whoami 2>/dev/null || echo "$(RED)❌ Not authenticated - run 'wrangler login' first$(NC)"
	@echo ""
	@if [ -f .env ]; then \
		echo "$(GREEN)� Found .env file with credentials$(NC)"; \
		. ./.env && echo "$(BLUE)OAuth Token: $${CLOUDFLARE_OAUTH_TOKEN:0:10}...$(NC)"; \
		. ./.env && echo "$(BLUE)Zone ID: $$CLOUDFLARE_ZONE_ID$(NC)"; \
		. ./.env && echo "$(BLUE)Account ID: $$CLOUDFLARE_ACCOUNT_ID$(NC)"; \
		echo "$(GREEN)✅ Ready to run terraform!$(NC)"; \
	else \
		echo "$(YELLOW)📄 No .env file found$(NC)"; \
		echo "$(BLUE)� Run 'make cf-extract' to extract credentials from wrangler config$(NC)"; \
	fi
	@echo ""
	@echo "$(YELLOW)🔧 Available commands:$(NC)"
	@echo "  make cf-extract  - Extract credentials from wrangler config to .env"
	@echo "  make plan        - Run terraform plan with .env credentials"
	@echo "  make apply       - Apply terraform changes"

# Automatically setup Cloudflare credentials and run terraform plan
cf-auto-setup: setup
	@echo "$(YELLOW)🚀 Auto-configuring Cloudflare credentials and running terraform plan...$(NC)"
	@echo ""
	@if [ ! -f .env ]; then \
		echo "$(YELLOW)� No .env file found, extracting credentials...$(NC)"; \
		$(MAKE) cf-extract; \
	else \
		echo "$(GREEN)📄 Found existing .env file$(NC)"; \
	fi
	@echo ""
	@echo "$(YELLOW)📦 Initializing Terraform...$(NC)"
	@. ./.env && export GITHUB_TOKEN="$$(gh auth token)" && export GITHUB_OWNER="otaku-lt" && \
		export CLOUDFLARE_API_TOKEN="$$CLOUDFLARE_OAUTH_TOKEN" && \
		terraform init -upgrade
	@echo ""
	@echo "$(YELLOW)📋 Running Terraform plan...$(NC)"
	@. ./.env && export GITHUB_TOKEN="$$(gh auth token)" && export GITHUB_OWNER="otaku-lt" && \
		export CLOUDFLARE_API_TOKEN="$$CLOUDFLARE_OAUTH_TOKEN" && \
		export TF_VAR_cloudflare_account_id="$$CLOUDFLARE_ACCOUNT_ID" && \
		export TF_VAR_cloudflare_zone_id="$$CLOUDFLARE_ZONE_ID" && \
		export TF_VAR_domain_name="$$DOMAIN_NAME" && \
		export TF_VAR_pages_project_name="$$PAGES_PROJECT_NAME" && \
		terraform plan

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

# Show help
help:
	@echo "$(GREEN)otaku.lt-sdk Terraform Project$(NC)"
	@echo ""
	@echo "$(YELLOW)Available targets:$(NC)"
	@echo "  setup        - Set up environment and check dependencies (default)"
	@echo "  cf-setup     - Show Cloudflare API token setup instructions"
	@echo "  cf-extract   - Extract Cloudflare credentials from wrangler to .env"
	@echo "  cf-set-token - Set custom API token in .env (usage: make cf-set-token TOKEN=xyz)"
	@echo "  cf-import-dns - Import existing DNS records into Terraform state"
	@echo "  cf-info      - Show Cloudflare account information from .env"
	@echo "  cf-auto-setup - Extract credentials and run terraform plan"
	@echo "  set-zone-id  - Set Zone ID in terraform.tfvars (legacy, use cf-extract instead)"
	@echo "  init         - Initialize Terraform"
	@echo "  plan         - Run terraform plan (uses .env for credentials)"
	@echo "  apply        - Run terraform apply (uses .env for credentials)"
	@echo "  apply-auto   - Run terraform apply with auto-approve"
	@echo "  fmt          - Format terraform files"
	@echo "  validate     - Validate terraform configuration"
	@echo "  show         - Show current terraform state"
	@echo "  clean        - Clean terraform cache"
	@echo "  shell-env    - Show shell environment setup instructions"
	@echo "  help         - Show this help message"
	@echo ""
	@echo "$(YELLOW)Quick start (recommended):$(NC)"
	@echo "  gh auth login                    # Authenticate with GitHub"
	@echo "  make cf-setup                    # Get API token creation instructions"
	@echo "  make cf-set-token TOKEN=xyz      # Set your custom API token"
	@echo "  make plan                        # Preview infrastructure changes"
	@echo "  make apply                       # Apply changes"
	@echo ""
	@echo "$(YELLOW)Alternative (wrangler - limited):$(NC)"
	@echo "  gh auth login       # Authenticate with GitHub"
	@echo "  wrangler login      # Authenticate with Cloudflare"
	@echo "  make cf-extract     # Extract credentials to .env file"
	@echo "  make plan           # Preview infrastructure changes (may fail for DNS)"
	@echo ""
	@echo "$(YELLOW)Super quick start:$(NC)"
	@echo "  gh auth login       # Authenticate with GitHub"
	@echo "  wrangler login      # Authenticate with Cloudflare"
	@echo "  make cf-auto-setup  # Extract credentials and preview changes"
	@echo "  make apply          # Apply changes"
	@echo ""
	@echo "$(YELLOW)Manual approach (legacy):$(NC)"
	@echo "  make               # Setup environment"
	@echo "  make cf-info       # Get Zone ID and configure terraform.tfvars"
	@echo "  make plan          # Check what will be changed"
	@echo "  make apply         # Apply changes"
