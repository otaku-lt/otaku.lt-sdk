# otaku.lt-sdk

Infrastructure as Code for the otaku.lt project using Terraform and GitHub provider.

## Structure

- `providers.tf` - Terraform and GitHub provider configuration
- `variables.tf` - Input variables for configuration
- `main.tf` - Main configuration entry point
- `github.tf` - GitHub repository resources
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
```

### Persistent Setup:
```bash
# Show instructions for shell profile setup
make shell-env
```

1. **Clone this repository** (if not already done):
   ```bash
   git clone <your-repo-url>
   cd otaku.lt-sdk
   ```

2. **Copy and configure variables**:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```
   
   Edit `terraform.tfvars` and fill in your GitHub token and username/organization.

3. **Initialize Terraform**:
   ```bash
   terraform init
   ```

4. **Plan the deployment**:
   ```bash
   terraform plan
   ```

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
export TF_VAR_github_token="your_github_token"
export TF_VAR_github_owner="your_github_username"
```

Or set the GitHub provider environment variables directly:

```bash
export GITHUB_TOKEN="your_github_token"
export GITHUB_OWNER="your_github_username"
```

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
