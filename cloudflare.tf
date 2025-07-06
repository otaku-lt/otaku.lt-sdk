# Cloudflare Pages project for otaku.lt
resource "cloudflare_pages_project" "otaku_lt" {
  account_id        = var.cloudflare_account_id
  name              = var.pages_project_name
  production_branch = var.default_branch

  source {
    type = "github"
    config {
      owner                         = "otaku-lt"
      repo_name                     = var.otaku_lt_repo_name
      production_branch             = var.default_branch
      pr_comments_enabled           = true
      deployments_enabled           = true
      production_deployment_enabled = true
      preview_deployment_setting    = "all"
      preview_branch_includes       = ["*"]
      preview_branch_excludes       = ["main"]
    }
  }

  build_config {
    build_command       = "npm run build"
    destination_dir     = "out"
    root_dir            = ""
    web_analytics_tag   = null
    web_analytics_token = null
  }

  deployment_configs {
    preview {
      environment_variables = {
        NODE_ENV = "development"
        NEXT_TELEMETRY_DISABLED = "1"
      }
      
      compatibility_date  = "2024-01-01"
      compatibility_flags = ["nodejs_compat"]
      fail_open          = false
      always_use_latest_compatibility_date = false
    }

    production {
      environment_variables = {
        NODE_ENV = "production"
        NEXT_TELEMETRY_DISABLED = "1"
      }
      
      compatibility_date  = "2024-01-01"
      compatibility_flags = ["nodejs_compat"]
      fail_open          = false
      always_use_latest_compatibility_date = false
    }
  }
}

# Custom domain for the Pages project
resource "cloudflare_pages_domain" "otaku_lt_domain" {
  account_id   = var.cloudflare_account_id
  project_name = cloudflare_pages_project.otaku_lt.name
  domain       = var.domain_name
}

# DNS record to point the domain to Cloudflare Pages
resource "cloudflare_record" "otaku_lt_cname" {
  zone_id = var.cloudflare_zone_id
  name    = "@"
  value   = "${var.pages_project_name}.pages.dev"
  type    = "CNAME"
  ttl     = 1 # Auto TTL
  proxied = true

  comment = "Managed by Terraform - Points to Cloudflare Pages"
}

# WWW subdomain redirect
resource "cloudflare_record" "otaku_lt_www" {
  zone_id = var.cloudflare_zone_id
  name    = "www"
  value   = var.domain_name
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

# Security and performance settings
resource "cloudflare_zone_settings_override" "otaku_lt_settings" {
  zone_id = var.cloudflare_zone_id

  settings {
    always_use_https         = "on"
    automatic_https_rewrites = "on"
    ssl                     = "strict"
    min_tls_version         = "1.2"
    tls_1_3                 = "on"
    brotli                  = "on"
    browser_cache_ttl       = 14400
    cache_level             = "aggressive"
    development_mode        = "off"
    hotlink_protection      = "on"
    ip_geolocation         = "on"
    ipv6                   = "on"
    rocket_loader          = "on"
    security_level         = "medium"
    server_side_exclude    = "on"
  }
}
