# Organization-Level API Token Setup

This document explains how Cloudflare API tokens are configured at the organization level for the `otaku-lt` organization.

## Organization Secrets

The following secrets are configured at the organization level and available to all repositories:

### Cloudflare Secrets
- `CLOUDFLARE_API_TOKEN` - Organization-wide API token with permissions for:
  - Zone:Zone:Edit (for DNS management)
  - Zone:Page Rule:Edit (for routing rules)
  - Account:Cloudflare Workers:Edit (for Workers deployment)
  - Account:D1:Edit (for database management)
  - Account:KV:Edit (for key-value storage)

- `CLOUDFLARE_ACCOUNT_ID` - Account identifier for Cloudflare resources
- `CLOUDFLARE_ZONE_ID` - Zone identifier for the otaku.lt domain
- `CLOUDFLARE_ZONE_NAME` - Domain name (otaku.lt)

## API Token Permissions Required

To create a comprehensive API token for the organization, you need:

### Zone Permissions (for otaku.lt domain)
- Zone:Zone:Edit
- Zone:DNS:Edit
- Zone:Page Rule:Edit
- Zone:SSL and Certificates:Edit

### Account Permissions
- Account:Cloudflare Workers:Edit
- Account:Account Settings:Read
- Account:D1:Edit
- Account:Workers KV Storage:Edit
- Account:Workers for Platforms:Edit

### Resources
- Include: All zones
- Include: All accounts

## Setting Up the Token

1. Go to [Cloudflare API Tokens](https://dash.cloudflare.com/profile/api-tokens)
2. Click "Create Token"
3. Use "Custom token" template
4. Add the permissions listed above
5. Set the token to never expire (or set appropriate expiration)
6. Copy the token and add it to your `.env` file or Terraform variables

## Repository Usage

Any repository in the `otaku-lt` organization can now use these secrets in GitHub Actions workflows:

```yaml
- name: Deploy to Cloudflare
  uses: cloudflare/wrangler-action@v3
  with:
    apiToken: ${{ secrets.CLOUDFLARE_API_TOKEN }}
    accountId: ${{ secrets.CLOUDFLARE_ACCOUNT_ID }}
```

## Security Benefits

- **Centralized management**: Update tokens in one place
- **Consistent access**: All repos use the same credentials
- **Easier rotation**: Change tokens organization-wide
- **Audit trail**: Organization-level logging and monitoring
