# Cloudflare Workers configuration for otaku.lt
# This replaces the legacy Cloudflare Pages deployment

# Worker script for otaku.lt
resource "cloudflare_worker_script" "otaku_lt" {
  account_id = var.cloudflare_account_id
  name       = "otaku-lt"
  content    = file("${path.module}/../otaku.lt/src/index.js")
  
  # Module format for ES modules
  module = true
  
  # Compatibility settings
  compatibility_date  = "2024-01-15"
  compatibility_flags = ["nodejs_compat"]

  # Environment variables
  plain_text_binding {
    name = "NODE_ENV"
    text = "production"
  }
  
  plain_text_binding {
    name = "NEXT_TELEMETRY_DISABLED"
    text = "1"
  }

  # Tags for organization
  tags = ["frontend", "nextjs", "otaku-lt"]
}

# Custom domain for the Worker
resource "cloudflare_worker_domain" "otaku_lt_domain" {
  account_id = var.cloudflare_account_id
  hostname   = var.domain_name
  service    = cloudflare_worker_script.otaku_lt.name
  zone_id    = var.cloudflare_zone_id
}

# Custom domain for www subdomain (will redirect)
resource "cloudflare_worker_domain" "otaku_lt_www_domain" {
  account_id = var.cloudflare_account_id
  hostname   = "www.${var.domain_name}"
  service    = cloudflare_worker_script.otaku_lt.name
  zone_id    = var.cloudflare_zone_id
}

# Worker route to handle all requests
resource "cloudflare_worker_route" "otaku_lt_route" {
  zone_id     = var.cloudflare_zone_id
  pattern     = "${var.domain_name}/*"
  script_name = cloudflare_worker_script.otaku_lt.name
}

# Worker route for www subdomain
resource "cloudflare_worker_route" "otaku_lt_www_route" {
  zone_id     = var.cloudflare_zone_id
  pattern     = "www.${var.domain_name}/*"
  script_name = cloudflare_worker_script.otaku_lt.name
}

# DNS record for the main domain (A record pointing to Cloudflare proxy)
resource "cloudflare_record" "otaku_lt_root" {
  zone_id = var.cloudflare_zone_id
  name    = "@"
  content = "192.0.2.1"  # Placeholder IP, will be handled by Worker
  type    = "A"
  ttl     = 1 # Auto TTL
  proxied = true

  comment = "Managed by Terraform - Points to Cloudflare Worker"
}

# DNS record for www subdomain
resource "cloudflare_record" "otaku_lt_www" {
  zone_id = var.cloudflare_zone_id
  name    = "www"
  content = "192.0.2.1"  # Placeholder IP, will be handled by Worker
  type    = "A"
  ttl     = 1 # Auto TTL
  proxied = true

  comment = "Managed by Terraform - WWW subdomain for Worker"
}

# Security and performance settings (only modifiable settings)
resource "cloudflare_zone_settings_override" "otaku_lt_settings" {
  zone_id = var.cloudflare_zone_id

  settings {
    # Security settings
    security_level         = "medium"
    ssl                   = "strict"
    min_tls_version       = "1.2"
    tls_1_3               = "on"
    automatic_https_rewrites = "on"
    always_use_https      = "on"
    
    # Performance settings
    brotli               = "on"
    minify {
      css  = "on"
      js   = "on"
      html = "on"
    }
    
    # Caching settings
    browser_cache_ttl = 14400  # 4 hours
    
    # Development mode (turn off for production)
    development_mode = "off"
  }
}
