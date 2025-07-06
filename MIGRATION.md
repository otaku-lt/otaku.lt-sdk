# Migration from Cloudflare Pages to Workers

This document outlines the migration from legacy Cloudflare Pages to the new Cloudflare Workers with static asset hosting.

## Why Migrate?

- Cloudflare Pages is being deprecated in favor of Workers
- Workers provides better performance and more control
- Better integration with Cloudflare's edge computing platform
- More flexible routing and custom logic capabilities

## Changes Made

### 1. Infrastructure (Terraform)

**Files Changed:**
- `cloudflare.tf` - Legacy Pages configuration commented out
- `workers.tf` - New Workers configuration added

**Key Changes:**
- Replaced `cloudflare_pages_project` with `cloudflare_worker_script`
- Added `cloudflare_worker_domain` for custom domain binding
- Added `cloudflare_worker_route` for traffic routing
- Updated DNS records to point to Workers instead of Pages

### 2. Frontend Configuration

**Files Added:**
- `wrangler.toml` - Wrangler configuration for Workers deployment
- `src/index.js` - Worker script for handling requests and static assets
- `.github/workflows/deploy.yml` - GitHub Actions for automated deployment

**Files Modified:**
- `package.json` - Added Wrangler and deployment scripts

### 3. Deployment Process

**Before (Pages):**
- Automatic deployment via GitHub integration
- Build and deploy handled by Cloudflare Pages

**After (Workers):**
- Deployment via Wrangler CLI
- Build process handled locally or in CI/CD
- Static assets served via Workers [assets] feature

## Migration Steps

### Step 1: Update Infrastructure

```bash
# Navigate to the SDK directory
cd otaku.lt-sdk

# Authenticate with GitHub and Cloudflare
gh auth login
wrangler login

# Extract credentials
make cf-extract

# Review infrastructure changes
make plan

# Apply the new Workers infrastructure
make apply
```

### Step 2: Install Dependencies

```bash
# Navigate to the frontend directory
cd ../otaku.lt

# Install Wrangler
npm install wrangler --save-dev

# Verify wrangler.toml configuration
cat wrangler.toml
```

### Step 3: Test Local Deployment

```bash
# Build the application
npm run build

# Test Workers locally
npm run wrangler:dev
# OR
make test-workers
```

### Step 4: Deploy to Production

```bash
# Deploy using Makefile (recommended)
make deploy-workers

# OR deploy directly with Wrangler
cd ../otaku.lt
npm run deploy
```

### Step 5: Setup CI/CD (Optional)

The GitHub Actions workflow in `.github/workflows/deploy.yml` provides:
- Automatic preview deployments for pull requests
- Automatic production deployments for main branch
- PR comments with preview URLs

**Required GitHub Secrets:**
- `CLOUDFLARE_API_TOKEN` - Your Cloudflare API token
- `CLOUDFLARE_ACCOUNT_ID` - Your Cloudflare account ID

## New Makefile Commands

The Makefile has been updated with new Workers-specific commands:

```bash
# Infrastructure Management
make setup              # Setup environment
make plan               # Preview Terraform changes
make apply              # Apply infrastructure changes

# Workers Deployment
make build-frontend     # Build Next.js application
make deploy-workers     # Deploy to production
make deploy-workers-preview # Deploy to preview
make test-workers       # Test locally
make setup-workers      # Complete setup
make apply-workers      # Apply infra + deploy
make workers-status     # Check deployment status

# Quick commands
make help               # Show all available commands
```

## Configuration Files

### wrangler.toml
```toml
name = "otaku-lt"
main = "src/index.js"
compatibility_date = "2024-01-15"
compatibility_flags = ["nodejs_compat"]

[assets]
directory = "out"
serve_single_page_app = true

[env.production.vars]
NODE_ENV = "production"
NEXT_TELEMETRY_DISABLED = "1"
```

### package.json Scripts
```json
{
  "scripts": {
    "deploy": "npm run build && wrangler deploy",
    "deploy:preview": "npm run build && wrangler deploy --env preview",
    "wrangler:dev": "wrangler dev",
    "wrangler:login": "wrangler auth login"
  }
}
```

## Rollback Plan

If issues arise, you can temporarily rollback:

1. **Uncomment Pages configuration** in `cloudflare.tf`
2. **Comment out Workers configuration** in `workers.tf`
3. **Run `make apply`** to restore Pages infrastructure
4. **Redeploy via Pages** using the old GitHub integration

## Verification

After migration, verify:

1. **Domain accessibility:** https://otaku.lt
2. **WWW redirect:** https://www.otaku.lt → https://otaku.lt
3. **SSL/TLS:** Ensure HTTPS is working
4. **Performance:** Check loading times and edge caching
5. **Routing:** Verify all Next.js routes work correctly

## Troubleshooting

### Common Issues

1. **Authentication errors:**
   ```bash
   wrangler login
   make cf-extract
   ```

2. **Build failures:**
   ```bash
   npm install
   npm run build
   ```

3. **Domain not working:**
   - Check DNS records in Cloudflare dashboard
   - Verify Worker routes are active
   - Check custom domain bindings

4. **Assets not loading:**
   - Verify `[assets]` configuration in wrangler.toml
   - Check build output directory (`out/`)
   - Ensure static files are in the correct location

### Support

For issues:
1. Check Cloudflare Workers dashboard for deployment status
2. Review Wrangler logs: `wrangler tail`
3. Check GitHub Actions workflow logs
4. Verify Terraform state: `make show`

## Resources

- [Cloudflare Workers Documentation](https://developers.cloudflare.com/workers/)
- [Wrangler CLI Documentation](https://developers.cloudflare.com/workers/wrangler/)
- [Workers Static Assets](https://developers.cloudflare.com/workers/static-assets/)
- [Next.js on Workers](https://developers.cloudflare.com/workers/frameworks/framework-guides/nextjs/)
