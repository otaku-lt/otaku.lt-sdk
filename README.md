# otaku.lt-sdk

Infrastructure as Code for otaku.lt using Terraform and Cloudflare Workers.

## Overview

This project manages the complete infrastructure for [otaku.lt](https://otaku.lt), a Next.js website deployed on Cloudflare Workers. The infrastructure uses Terraform for infrastructure management and Wrangler for deployment automation.

### Key Features

- 🌟 **Cloudflare Workers** deployment
- 🏗️ **Terraform** infrastructure management
- 🚀 **Automated CI/CD** with GitHub Actions
- 📦 **Wrangler** deployment automation
- 🔒 **Secure authentication** via environment variables
- 🌐 **Custom domain** with SSL/TLS

## Structure

- `providers.tf` - Terraform, GitHub, and Cloudflare provider configuration
- `variables.tf` - Input variables for configuration
- `workers.tf` - Cloudflare Workers configuration
- `cloudflare.tf` - Legacy configuration (deprecated)
- `github.tf` - GitHub repository resources
- `outputs.tf` - Output values
- `Makefile` - Project automation and deployment commands
- `.env.example` - Environment variables template

## Prerequisites

1. **Install required tools:**
   ```bash
   # On macOS using Homebrew
   brew install terraform
   brew install gh
   brew install cloudflare-wrangler
   ```

2. **Authenticate:**
   ```bash
   gh auth login      # GitHub authentication
   # Get API token from: https://dash.cloudflare.com/profile/api-tokens
   ```

## Quick Start

1. **Setup environment:**
   ```bash
   make workers-setup
   ```

2. **Deploy everything:**
   ```bash
   make workers-apply
   ```

That's it! Your site should be live at https://otaku.lt

## Step-by-Step Setup

### 1. Authentication & Credentials

```bash
# Authenticate with both services
gh auth login

# Set up Cloudflare API token (get from dashboard)
make cf-set-token TOKEN=your_api_token_here
```

### 2. Infrastructure Management

```bash
# Review infrastructure changes
make plan

# Apply infrastructure (Workers, DNS, etc.)
make apply
```

### 3. Deploy Website

```bash
# Build and deploy to Workers
make workers-deploy

# OR deploy to preview/staging
make workers-deploy-preview
```
## Available Commands

### 🏗️ Infrastructure Management
- `make setup` - Setup environment and check dependencies  
- `make plan` - Run terraform plan
- `make apply` - Run terraform apply  
- `make fmt` - Format terraform files
- `make validate` - Validate configuration
- `make clean` - Clean terraform cache

### 🚀 Workers Deployment
- `make workers-build` - Build Next.js application
- `make workers-deploy` - Deploy to production Workers
- `make workers-deploy-preview` - Deploy to preview/staging
- `make workers-test` - Test Workers locally
- `make workers-setup` - Complete Workers setup
- `make workers-apply` - Apply infrastructure + deploy
- `make workers-status` - Check deployment status

### 🔧 Utilities
- `make cf-set-token TOKEN=xyz` - Set Cloudflare API token from dashboard
- `make cf-set-token TOKEN=xyz` - Set custom API token
- `make help` - Show all available commands

## Authentication

**🔒 Secure Authentication via Environment Variables**

The Makefile automatically handles authentication:

### Automatic Setup (Recommended):
```bash
# Authenticate with GitHub
gh auth login

# Set up API token (get from Cloudflare dashboard)
make cf-set-token TOKEN=your_api_token_here
```

### Manual API Token Setup:
```bash
# Create custom API token at: https://dash.cloudflare.com/profile/api-tokens
# Required permissions: Zone:Zone:Read, Zone:DNS:Edit, Account:Cloudflare Workers:Edit
make cf-set-token TOKEN=your_custom_api_token
```

## Configuration

The project uses `.env` file for configuration (set up with `make cf-set-token`):

```bash
# Example .env file (auto-generated)
CLOUDFLARE_API_TOKEN=your_api_token
CLOUDFLARE_ZONE_ID=your_zone_id  
CLOUDFLARE_ACCOUNT_ID=your_account_id
DOMAIN_NAME=otaku.lt
PAGES_PROJECT_NAME=otaku-lt
```

## Resources Managed

This Terraform configuration manages:

### GitHub Resources:
- **otaku.lt**: Main website repository (Next.js application)
- **otaku.lt-sdk**: Infrastructure as Code repository (this repository)

### Cloudflare Workers Resources:
- **Worker Script**: Main application handler with static asset serving
- **Custom Domains**: DNS configuration for otaku.lt and www.otaku.lt
- **Worker Routes**: Traffic routing and WWW redirect
- **SSL/TLS**: Security and performance settings
- **DNS Records**: A records pointing to Workers

## Deployment Flow

### Workers Flow:
1. **Code Push** → GitHub repository (otaku.lt)
2. **GitHub Actions** → Builds Next.js app and deploys to Workers
3. **Workers** → Serves static assets and handles routing
4. **Live Site** → https://otaku.lt

### Manual Deployment:
1. **Build** → `make workers-build` 
2. **Deploy** → `make workers-deploy`
3. **Live Site** → https://otaku.lt

## Environment Variables

The project uses these environment variables (managed in `.env`):

```bash
# Cloudflare (set using cf-set-token)
CLOUDFLARE_API_TOKEN=your_api_token
CLOUDFLARE_ZONE_ID=your_zone_id
CLOUDFLARE_ACCOUNT_ID=your_account_id

# Project configuration
DOMAIN_NAME=otaku.lt
PAGES_PROJECT_NAME=otaku-lt

# GitHub (handled automatically by Makefile)
GITHUB_TOKEN=$(gh auth token)
GITHUB_OWNER=otaku-lt
```

## Frontend Configuration

The Next.js application includes:

### wrangler.toml
```toml
name = "otaku-lt"
main = "src/index.js"
compatibility_date = "2024-01-15"

[assets]
directory = "out"
serve_single_page_app = true
```

### package.json Scripts
```json
{
  "scripts": {
    "deploy": "npm run build && wrangler deploy",
    "deploy:preview": "npm run build && wrangler deploy --env preview",
    "wrangler:dev": "wrangler dev"
  }
}
```

## CI/CD with GitHub Actions

Automatic deployment is configured via `.github/workflows/deploy.yml`:

- **Pull Requests**: Deploy to preview environment
- **Main Branch**: Deploy to production  

### **🔐 Automated Secrets Management**

The required GitHub Actions secrets are automatically managed by Terraform:

```bash
# Setup GitHub Actions secrets for CI/CD
make github-secrets
```

This creates the following repository secrets:
- `CLOUDFLARE_API_TOKEN` - Your Cloudflare API token
- `CLOUDFLARE_ACCOUNT_ID` - Your Cloudflare account ID

### **🚀 Complete CI/CD Setup**

```bash
# Full automated setup
gh auth login              # Authenticate with GitHub
gh auth login              # Authenticate with GitHub
# Get API token from: https://dash.cloudflare.com/profile/api-tokens  
make cf-set-token TOKEN=xyz  # Set up credentials
make workers-setup         # Setup infrastructure
make github-secrets        # Configure CI/CD secrets
make workers-apply         # Deploy everything
```

After this setup, your CI/CD pipeline will automatically:
- Deploy previews for pull requests
- Deploy to production when merging to main
- Comment on PRs with preview URLs

## Getting Cloudflare Values

1. **Account ID**: Cloudflare Dashboard → Right sidebar
2. **Zone ID**: Cloudflare Dashboard → Your domain → Right sidebar
3. **API Token**: Use `make cf-set-token TOKEN=xyz` or create at [API Tokens](https://dash.cloudflare.com/profile/api-tokens)

For custom tokens, required permissions:
- `Zone:Zone:Read`
- `Zone:DNS:Edit` 
- `Account:Cloudflare Workers:Edit`

## Project Structure

```
otaku.lt-sdk/              # Infrastructure
├── workers.tf             # Workers configuration
├── cloudflare.tf          # Legacy configuration (deprecated)
├── providers.tf           # Provider configuration
├── variables.tf           # Variable definitions
├── outputs.tf            # Output definitions
├── Makefile              # Automation commands
├── .env                  # Credentials (auto-generated)
└── README.md             # This file

otaku.lt/                  # Frontend Application
├── wrangler.toml         # Workers configuration
├── src/index.js          # Worker script
├── .github/workflows/    # CI/CD
├── package.json          # Updated with Wrangler
├── next.config.js        # Next.js configuration
└── ... (Next.js app)
```

## Development Workflow

### Local Development:
```bash
cd otaku.lt
npm run dev              # Next.js dev server
# OR
make workers-test        # Test Workers locally
```

### Deployment:
```bash
make workers-deploy      # Deploy to production
make workers-deploy-preview  # Deploy to staging
```

### Infrastructure Changes:
```bash
make plan               # Review changes
make apply              # Apply changes
```

## Troubleshooting

### Common Issues:

1. **Authentication errors:**
   ```bash
   make cf-set-token TOKEN=your_api_token_here
   ```

2. **Build failures:**
   ```bash
   cd otaku.lt
   npm install
   npm run build
   ```

3. **Deployment issues:**
   ```bash
   make workers-status     # Check deployment status
   wrangler tail           # View logs
   ```

4. **DNS issues:**
   ```bash
   make plan               # Check Terraform DNS config
   ```

## Security Notes

- Never commit `.env` or files containing sensitive data
- The `.gitignore` file excludes sensitive files
- Use remote state backend for production use
- Rotate API tokens regularly

## Contributing

When making changes:

1. **Test locally**: `make workers-test`
2. **Review infrastructure**: `make plan`
3. **Deploy preview**: `make workers-deploy-preview`
4. **Apply to production**: `make workers-apply`
5. **Commit changes** to both `otaku.lt` and `otaku.lt-sdk`

## Resources

- [Cloudflare Workers Documentation](https://developers.cloudflare.com/workers/)
- [Wrangler CLI Documentation](https://developers.cloudflare.com/workers/wrangler/)
- [Next.js on Workers](https://developers.cloudflare.com/workers/frameworks/framework-guides/nextjs/)
