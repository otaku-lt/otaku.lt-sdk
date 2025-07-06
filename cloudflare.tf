# Cloudflare Pages project for otaku.lt
resource "cloudflare_pages_project" "otaku_lt" {
  account_id        = var.cloudflare_account_id
  name              = var.pages_project_name
  production_branch = var.default_branch

  # Note: GitHub integration will be set up manually in Cloudflare dashboard
  # due to API limitations with Git installation

  build_config {
    build_command   = "npm run build"
    destination_dir = "out"
    root_dir        = ""
  }

  deployment_configs {
    preview {
      environment_variables = {
        NODE_ENV                = "development"
        NEXT_TELEMETRY_DISABLED = "1"
      }
      compatibility_date  = "2024-01-01"
      compatibility_flags = ["nodejs_compat"]
    }

    production {
      environment_variables = {
        NODE_ENV                = "production"
        NEXT_TELEMETRY_DISABLED = "1"
      }
      compatibility_date  = "2024-01-01"
      compatibility_flags = ["nodejs_compat"]
    }
  }
}

# Custom domain for the Pages project
resource "cloudflare_pages_domain" "otaku_lt_domain" {
  account_id   = var.cloudflare_account_id
  project_name = cloudflare_pages_project.otaku_lt.name
  domain       = var.domain_name
}

# DNS record to point the domain to Cloudflare Pages (temporarily disabled due to existing records)
# TODO: Import existing DNS records first, then manage them
# resource "cloudflare_record" "otaku_lt_cname" {
#   zone_id = var.cloudflare_zone_id
#   name    = "@"
#   content = "${var.pages_project_name}.pages.dev"
#   type    = "CNAME"
#   ttl     = 1 # Auto TTL
#   proxied = true
# 
#   comment = "Managed by Terraform - Points to Cloudflare Pages"
# }
# 
# WWW subdomain redirect
resource "cloudflare_record" "otaku_lt_www" {
  zone_id = var.cloudflare_zone_id
  name    = "www"
  content = var.domain_name
  type    = "CNAME"
  ttl     = 1 # Auto TTL
  proxied = true

  comment = "Managed by Terraform - WWW redirect"
}

# Page Rules for WWW redirect
resource "cloudflare_page_rule" "www_redirect" {
  zone_id  = var.cloudflare_zone_id
  target   = "www.${var.domain_name}/*"
  priority = 1
  status   = "active"

  actions {
    forwarding_url {
      url         = "https://${var.domain_name}/$1"
      status_code = 301
    }
  }
}

# Security and performance settings (only modifiable settings)
resource "cloudflare_zone_settings_override" "otaku_lt_settings" {
  zone_id = var.cloudflare_zone_id

  settings {
    # SSL/TLS settings (modifiable)
    always_use_https         = "on"
    automatic_https_rewrites = "on"
    ssl                      = "strict"
    min_tls_version          = "1.0"

    # Performance settings (modifiable)
    brotli = "on"

    # Security settings (modifiable)
    security_level = "medium"

    # Development mode (modifiable)
    development_mode = "off"
    
    # Cache settings (modifiable)
    browser_cache_ttl = 14400
    cache_level       = "aggressive"
    
    # Other modifiable settings
    challenge_ttl            = 1800
    browser_check            = "on"
    email_obfuscation        = "on"
    hotlink_protection       = "off"
    ip_geolocation           = "on"
    ipv6                     = "on"
    opportunistic_encryption = "on"
    rocket_loader            = "off"
    server_side_exclude      = "on"
    websockets               = "on"
  }
}
