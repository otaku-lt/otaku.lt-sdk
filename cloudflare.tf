# Legacy Cloudflare Pages configuration (DEPRECATED)
# Migrated to Cloudflare Workers - see workers.tf
# 
# This configuration is kept for reference and state migration
# TODO: Remove after successful migration to Workers

# The Pages project is now replaced by Workers configuration in workers.tf
# resource "cloudflare_pages_project" "otaku_lt" {
#   account_id        = var.cloudflare_account_id
#   name              = var.pages_project_name
#   production_branch = var.default_branch
# 
#   # GitHub integration
#   source {
#     type = "github"
#     config {
#       owner                         = var.github_owner
#       repo_name                     = var.otaku_lt_repo_name
#       production_branch             = var.default_branch
#       pr_comments_enabled           = true
#       deployments_enabled           = true
#       production_deployment_enabled = true
#       preview_deployment_setting    = "all"
#       preview_branch_includes       = ["*"]
#       preview_branch_excludes       = [var.default_branch]
#     }
#   }
# 
#   build_config {
#     build_command   = "npm run build"
#     destination_dir = "out"
#     root_dir        = ""
#   }
# 
#   deployment_configs {
#     preview {
#       environment_variables = {
#         NODE_ENV                = "development"
#         NEXT_TELEMETRY_DISABLED = "1"
#       }
#       compatibility_date  = "2024-01-01"
#       compatibility_flags = ["nodejs_compat"]
#     }
# 
#     production {
#       environment_variables = {
#         NODE_ENV                = "production"
#         NEXT_TELEMETRY_DISABLED = "1"
#       }
#       compatibility_date  = "2024-01-01"
#       compatibility_flags = ["nodejs_compat"]
#     }
#   }
# }

# Custom domain for the Pages project (DEPRECATED)
# resource "cloudflare_pages_domain" "otaku_lt_domain" {
#   account_id   = var.cloudflare_account_id
#   project_name = cloudflare_pages_project.otaku_lt.name
#   domain       = var.domain_name
# }

# DNS records and routing are now handled in workers.tf
# The Workers configuration provides better performance and control

# Zone settings are now configured in workers.tf to avoid conflicts
# resource "cloudflare_zone_settings_override" "otaku_lt_settings" {
#   zone_id = var.cloudflare_zone_id
# 
#   settings {
#     # SSL/TLS settings (modifiable)
#     always_use_https         = "on"
#     automatic_https_rewrites = "on"
#     ssl                      = "strict"
#     min_tls_version          = "1.0"
# 
#     # Performance settings (modifiable)
#     brotli = "on"
# 
#     # Security settings (modifiable)
#     security_level = "medium"
# 
#     # Development mode (modifiable)
#     development_mode = "off"
# 
#     # Cache settings (modifiable)
#     browser_cache_ttl = 14400
#     cache_level       = "aggressive"
# 
#     # Other modifiable settings
#     challenge_ttl            = 1800
#     browser_check            = "on"
#     email_obfuscation        = "on"
#     hotlink_protection       = "off"
#     ip_geolocation           = "on"
#     ipv6                     = "on"
#     opportunistic_encryption = "on"
#     rocket_loader            = "off"
#     server_side_exclude      = "on"
#     websockets               = "on"
#   }
# }
