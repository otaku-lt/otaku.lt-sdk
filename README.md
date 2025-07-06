# otaku.lt-sdk

Infrastructure as Code for the otaku.lt project using Terraform with GitHub and Cloudflare providers.

## Structure

- `providers.tf` - Terraform, GitHub, and Cloudflare provider configuration
- `variables.tf` - Input variables for configuration
- `main.tf` - Main configuration entry point
- `github.tf` - GitHub repository resources
- `cloudflare.tf` - Cloudflare Pages and DNS resources
- `outputs.tf` - Output values
- `Makefile` - Project automation and environment setup
- `terraform.tfvars.example` - Example variables file

## Prerequisites

1. **Install Terraform** (>= 1.0)
   ```bash
   # On macOS using Homebrew
   brew install terraform
   ```

2. **Install GitHub CLI** and authenticate:
   ```bash
   gh auth login
   ```

3. **Get Cloudflare API Token** from [Cloudflare Dashboard](https://dash.cloudflare.com/profile/api-tokens)
   - Create a token with permissions: Zone:Read, Page:Edit

4. **Set Cloudflare environment variable**:
   ```bash
   export CLOUDFLARE_API_TOKEN="your_cloudflare_api_token"
   ```

## Quick Start

1. **Setup environment:**
   ```bash
   make
   ```

2. **Plan the deployment:**
   ```bash
   make plan
   ```

3. **Apply the configuration:**
   ```bash
   make apply
   ```

## Available Commands

- `make` or `make setup` - Setup environment and check dependencies
- `make plan` - Run terraform plan
- `make apply` - Run terraform apply  
- `make fmt` - Format terraform files
- `make validate` - Validate configuration
- `make clean` - Clean terraform cache
- `make help` - Show all available commands

## Authentication

**🔒 Secure Authentication via Environment Variables**

The Makefile automatically handles GitHub authentication using the `gh` CLI:

### Quick Setup:
```bash
# The Makefile will handle everything
make
```

### Manual Setup:
```bash
export GITHUB_TOKEN="$(gh auth token)"
export GITHUB_OWNER="otaku-lt"
export CLOUDFLARE_API_TOKEN="your_cloudflare_api_token"
```

### Persistent Setup:
```bash
# Show instructions for shell profile setup
make shell-env
```

## Configuration

1. **Copy and configure variables**:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```
   
2. **Edit `terraform.tfvars`** and fill in required values:
   ```hcl
   # Required Cloudflare values
   cloudflare_account_id = "your_cloudflare_account_id"
   cloudflare_zone_id = "your_cloudflare_zone_id"
   
   # Optional overrides
   domain_name = "otaku.lt"
   pages_project_name = "otaku-lt"
   ```

## Resources Managed

This Terraform configuration manages:

### GitHub Resources:
- **otaku.lt**: Main website repository (Next.js application)
- **otaku.lt-sdk**: Infrastructure as Code repository (this repository)

### Cloudflare Resources:
- **Pages Project**: Automated deployment from GitHub
- **Custom Domain**: DNS configuration for otaku.lt
- **SSL/TLS**: Security and performance settings
- **Page Rules**: WWW redirect and optimization

## Deployment Flow

1. **Code Push** → GitHub repository (otaku.lt)
2. **Auto Build** → Cloudflare Pages builds Next.js app
3. **Auto Deploy** → Live at https://otaku.lt
4. **DNS Management** → Terraform manages domain configuration

5. **Apply the configuration**:
   ```bash
   terraform apply
   ```

## Repository Management

This Terraform configuration manages the following repositories:

- **otaku.lt**: Main website repository (Next.js application)
- **otaku.lt-sdk**: Infrastructure as Code repository (this repository)

## Environment Variables

Instead of using `terraform.tfvars`, you can also use environment variables:

```bash
# GitHub (handled automatically by Makefile)
export GITHUB_TOKEN="$(gh auth token)"
export GITHUB_OWNER="otaku-lt"

# Cloudflare (required)
export CLOUDFLARE_API_TOKEN="your_cloudflare_api_token"

# Or use Terraform variable format
export TF_VAR_cloudflare_account_id="your_account_id"
export TF_VAR_cloudflare_zone_id="your_zone_id"
```

## Getting Cloudflare Values

1. **Account ID**: Cloudflare Dashboard → Right sidebar
2. **Zone ID**: Cloudflare Dashboard → Your domain → Right sidebar  
3. **API Token**: Cloudflare Dashboard → My Profile → API Tokens → Create Token
   - Use "Custom token" template
   - Permissions: `Zone:Read`, `Page:Edit`
   - Zone Resources: Include your domain

## Importing Existing Repositories

If the repositories already exist on GitHub, you'll need to import them into Terraform state:

```bash
# Import the otaku.lt repository
terraform import github_repository.otaku_lt otaku.lt

# Import the otaku.lt-sdk repository
terraform import github_repository.otaku_lt_sdk otaku.lt-sdk
```

## Project Structure

```
.
├── main.tf                 # Main Terraform configuration
├── variables.tf           # Variable definitions
├── outputs.tf            # Output definitions
├── terraform.tfvars.example  # Example variables file
├── .gitignore            # Git ignore patterns
└── README.md             # This file
```

## Useful Commands

- **Format code**: `terraform fmt`
- **Validate configuration**: `terraform validate`
- **Show current state**: `terraform show`
- **List resources**: `terraform state list`
- **Plan destruction**: `terraform plan -destroy`
- **Destroy infrastructure**: `terraform destroy`

## Security Notes

- Never commit `terraform.tfvars` or any files containing sensitive data
- The `.gitignore` file is configured to exclude sensitive files
- Consider using Terraform Cloud or other remote state backends for production use

## Contributing

When making changes to the infrastructure:

1. Run `terraform plan` to review changes
2. Test in a development environment if possible
3. Apply changes with `terraform apply`
4. Commit and push the Terraform configuration changes
