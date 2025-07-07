# Cloudflare authentication and setup targets
# This file is included by the main Makefile

# Setup Cloudflare authentication
cf-setucf-info:
	@echo "$(YELLOW)🌤️  Cloudflare Account Information:$(NC)"
	@echo ""
	@if [ -f .env ]; then \
		echo "$(GREEN)📄 Found .env file with credentials$(NC)"; \
		. ./.env && echo "$(BLUE)API Token: $${CLOUDFLARE_API_TOKEN:0:10}...$(NC)"; \
		. ./.env && echo "$(BLUE)Zone ID: $$CLOUDFLARE_ZONE_ID$(NC)"; \
		. ./.env && echo "$(BLUE)Account ID: $$CLOUDFLARE_ACCOUNT_ID$(NC)"; \
		echo "$(GREEN)✅ Ready to run terraform!$(NC)"; \
	else \
		echo "$(YELLOW)📄 No .env file found$(NC)"; \
		echo "$(BLUE)💡 Run 'make cf-set-token TOKEN=xyz' to set up credentials$(NC)"; \
	fiLLOW)🌤️  Setting up Cloudflare authentication...$(NC)"
	@echo ""
	@echo "$(RED)⚠️  NOTE: Please use a proper API token from Cloudflare dashboard!$(NC)"
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
	@echo "   - Account:Cloudflare Workers:Edit"
	@echo "5. 🎯 Set zone resources: Include > Specific zone > otaku.lt"
	@echo "6. 🎯 Set account resources: Include > Your account"
	@echo "7. ✅ Create token and copy it"
	@echo "8. 💾 Save token: make cf-set-token TOKEN=your_token_here"

# Extract Cloudflare credentials to .env file (deprecated - use cf-set-token instead)
cf-extract:
	@echo "$(RED)⚠️  WARNING: cf-extract is deprecated!$(NC)"
	@echo "$(YELLOW)Please use 'make cf-set-token TOKEN=your_api_token' instead$(NC)"
	@echo "$(BLUE)Get your API token from: https://dash.cloudflare.com/profile/api-tokens$(NC)"
	@echo ""
	@echo "$(YELLOW)💡 Create a custom API token with these permissions:$(NC)"
	@echo "  - Zone:Zone:Read"
	@echo "  - Zone:Zone Settings:Edit"  
	@echo "  - Zone:DNS:Edit"
	@echo "  - Account:Cloudflare Workers:Edit"
	@echo ""
	@exit 1

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
		echo "- Account:Cloudflare Workers:Edit"; \
		exit 1; \
	fi
	@if [ ! -f .env ]; then \
		echo "$(BLUE)📄 Creating .env from template...$(NC)"; \
		cp .env.example .env; \
	fi
	@if grep -q "^CLOUDFLARE_API_TOKEN=" .env; then \
		sed -i '' "s/^CLOUDFLARE_API_TOKEN=.*/CLOUDFLARE_API_TOKEN=$(TOKEN)/" .env; \
		echo "$(GREEN)✅ Updated API token in .env$(NC)"; \
	else \
		echo "CLOUDFLARE_API_TOKEN=$(TOKEN)" >> .env; \
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
		export CLOUDFLARE_API_TOKEN="$$CLOUDFLARE_API_TOKEN" && \
		export TF_VAR_cloudflare_account_id="$$CLOUDFLARE_ACCOUNT_ID" && \
		export TF_VAR_cloudflare_zone_id="$$CLOUDFLARE_ZONE_ID" && \
		export TF_VAR_domain_name="$$DOMAIN_NAME" && \
		export TF_VAR_pages_project_name="$$PAGES_PROJECT_NAME"
	@echo "$(YELLOW)🔍 Finding existing DNS records...$(NC)"
	@. ./.env && CNAME_ID=$$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$$CLOUDFLARE_ZONE_ID/dns_records?name=$$DOMAIN_NAME&type=CNAME" \
		-H "Authorization: Bearer $$CLOUDFLARE_API_TOKEN" \
		-H "Content-Type: application/json" | jq -r '.result[0].id // empty' 2>/dev/null); \
	if [ -n "$$CNAME_ID" ] && [ "$$CNAME_ID" != "null" ]; then \
		echo "$(GREEN)✅ Found existing CNAME record: $$CNAME_ID$(NC)"; \
		echo "$(YELLOW)🔄 Importing into Terraform...$(NC)"; \
		terraform import cloudflare_record.otaku_lt_root "$$CLOUDFLARE_ZONE_ID/$$CNAME_ID" || echo "$(YELLOW)⚠️  Import failed or already imported$(NC)"; \
	else \
		echo "$(BLUE)💡 No existing CNAME record found for root domain$(NC)"; \
	fi
	@. ./.env && WWW_ID=$$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$$CLOUDFLARE_ZONE_ID/dns_records?name=www.$$DOMAIN_NAME&type=CNAME" \
		-H "Authorization: Bearer $$CLOUDFLARE_API_TOKEN" \
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

# Show Cloudflare account information
cf-info:
	@echo "$(YELLOW)🌤️  Cloudflare Account Information:$(NC)"
	@echo ""
	@wrangler whoami 2>/dev/null || echo "$(RED)❌ Not authenticated - run 'wrangler login' first$(NC)"
	@echo ""
	@if [ -f .env ]; then \
		echo "$(GREEN)📄 Found .env file with credentials$(NC)"; \
		. ./.env && echo "$(BLUE)API Token: $${CLOUDFLARE_API_TOKEN:0:10}...$(NC)"; \
		. ./.env && echo "$(BLUE)Zone ID: $$CLOUDFLARE_ZONE_ID$(NC)"; \
		. ./.env && echo "$(BLUE)Account ID: $$CLOUDFLARE_ACCOUNT_ID$(NC)"; \
		echo "$(GREEN)✅ Ready to run terraform!$(NC)"; \
	else \
		echo "$(YELLOW)📄 No .env file found$(NC)"; \
		echo "$(BLUE)💡 Run 'make cf-extract' to extract credentials from wrangler config$(NC)"; \
	fi

# Automatically setup Cloudflare credentials and run terraform plan
cf-auto-setup: setup
	@echo "$(YELLOW)🚀 Auto-configuring Cloudflare credentials and running terraform plan...$(NC)"
	@echo ""
	@if [ ! -f .env ]; then \
		echo "$(RED)❌ No .env file found$(NC)"; \
		echo "$(YELLOW)💡 Please run 'make cf-set-token TOKEN=your_api_token' first$(NC)"; \
		echo "$(BLUE)Get your API token from: https://dash.cloudflare.com/profile/api-tokens$(NC)"; \
		exit 1; \
	else \
		echo "$(GREEN)📄 Found existing .env file$(NC)"; \
	fi
	@echo ""
	@echo "$(YELLOW)📦 Initializing Terraform...$(NC)"
	@. ./.env && export GITHUB_TOKEN="$$(gh auth token)" && export GITHUB_OWNER="otaku-lt" && \
		export CLOUDFLARE_API_TOKEN="$$CLOUDFLARE_API_TOKEN" && \
		terraform init -upgrade
	@echo ""
	@echo "$(YELLOW)📋 Running Terraform plan...$(NC)"
	@. ./.env && export GITHUB_TOKEN="$$(gh auth token)" && export GITHUB_OWNER="otaku-lt" && \
		export CLOUDFLARE_API_TOKEN="$$CLOUDFLARE_API_TOKEN" && \
		export TF_VAR_cloudflare_account_id="$$CLOUDFLARE_ACCOUNT_ID" && \
		export TF_VAR_cloudflare_zone_id="$$CLOUDFLARE_ZONE_ID" && \
		export TF_VAR_domain_name="$$DOMAIN_NAME" && \
		export TF_VAR_pages_project_name="$$PAGES_PROJECT_NAME" && \
		terraform plan

# Legacy GitHub connection targets (for reference only)
cf-connect-github:
	@echo "$(YELLOW)📱 Cloudflare Pages GitHub Connection (Legacy):$(NC)"
	@echo ""
	@echo "$(RED)⚠️  NOTE: This project now uses Cloudflare Workers, not Pages!$(NC)"
	@echo "$(YELLOW)The following instructions are for legacy reference only.$(NC)"
	@echo ""
	@echo "$(BLUE)To connect Cloudflare Pages to GitHub (if needed):$(NC)"
	@echo "1. 🌐 Go to: https://dash.cloudflare.com/pages"
	@echo "2. 🔗 Click 'Connect to Git'"
	@echo "3. 📁 Select 'otaku-lt/otaku.lt' repository"
	@echo "4. ⚙️  Configure build settings:"
	@echo "   - Build command: npm run build"
	@echo "   - Build output directory: out"
	@echo "   - Root directory: /"
	@echo "5. 🚀 Click 'Save and Deploy'"
	@echo ""
	@echo "$(GREEN)💡 For current Workers deployment, use: make workers-deploy$(NC)"

cf-check-github:
	@echo "$(YELLOW)🔍 Checking GitHub App Installation (Legacy):$(NC)"
	@echo ""
	@echo "$(RED)⚠️  NOTE: This project now uses Cloudflare Workers, not Pages!$(NC)"
	@echo "$(YELLOW)GitHub App installation is not required for Workers deployment.$(NC)"
	@echo ""
	@if command -v gh >/dev/null 2>&1; then \
		echo "$(GREEN)✅ GitHub CLI is installed and authenticated$(NC)"; \
		gh auth status; \
	else \
		echo "$(RED)❌ GitHub CLI not found$(NC)"; \
		echo "$(YELLOW)Install with: brew install gh$(NC)"; \
	fi
	@echo ""
	@echo "$(GREEN)💡 For current Workers deployment, use: make workers-deploy$(NC)"
