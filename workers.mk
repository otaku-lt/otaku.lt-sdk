# Workers deployment targets for otaku.lt
# This file is included by the main Makefile

# Build the Next.js frontend
workers-build:
	@echo "$(YELLOW)🏗️  Building Next.js frontend...$(NC)"
	@cd ../otaku.lt && npm install
	@cd ../otaku.lt && npm run build
	@echo "$(GREEN)✅ Frontend built successfully$(NC)"

# Deploy to Cloudflare Workers (production)
workers-deploy: workers-build
	@echo "$(YELLOW)🚀 Deploying to Cloudflare Workers (production)...$(NC)"
	@cd ../otaku.lt && wrangler deploy
	@echo "$(GREEN)🎉 Deployed to production!$(NC)"
	@echo "$(BLUE)🌐 Site should be live at: https://otaku.lt$(NC)"

# Deploy to Cloudflare Workers (preview/staging)
workers-deploy-preview: workers-build
	@echo "$(YELLOW)🚀 Deploying to Cloudflare Workers (preview)...$(NC)"
	@cd ../otaku.lt && wrangler deploy --env preview
	@echo "$(GREEN)🎉 Deployed to preview!$(NC)"
	@echo "$(BLUE)🌐 Preview available at Workers dev URL$(NC)"

# Test Workers locally
workers-test: workers-build
	@echo "$(YELLOW)🧪 Testing Workers locally...$(NC)"
	@echo "$(BLUE)💡 This will start a local development server$(NC)"
	@cd ../otaku.lt && wrangler dev

# Complete Workers setup (infrastructure + deployment)
workers-setup: setup
	@echo "$(YELLOW)🌟 Setting up complete Workers deployment...$(NC)"
	@echo ""
	@echo "$(BLUE)Step 1: Terraform infrastructure...$(NC)"
	@$(MAKE) plan
	@echo ""
	@echo "$(YELLOW)💡 Review the Terraform plan above.$(NC)"
	@echo "$(YELLOW)If it looks good, run: make workers-apply$(NC)"

# Apply infrastructure and deploy Workers
workers-apply: apply workers-deploy
	@echo "$(GREEN)🎉 Infrastructure applied and Workers deployed!$(NC)"
	@echo "$(BLUE)🌐 Your site should be live at: https://otaku.lt$(NC)"

# Show Workers deployment status
workers-status:
	@echo "$(YELLOW)📊 Cloudflare Workers Status:$(NC)"
	@echo ""
	@cd ../otaku.lt && wrangler deployments list --limit 5 2>/dev/null || echo "$(YELLOW)⚠️  No deployments found or not authenticated$(NC)"
	@echo ""
	@echo "$(YELLOW)💡 Recent logs:$(NC)"
	@cd ../otaku.lt && wrangler tail --format pretty --limit 10 2>/dev/null || echo "$(YELLOW)⚠️  Unable to fetch logs$(NC)"
