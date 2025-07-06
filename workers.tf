# Cloudflare Workers configuration for otaku.lt
# Migrated from Pages to Workers following official migration guide
# Uses Workers static assets without custom script
# Custom domains are managed via wrangler.toml routes

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
    
    # Caching settings
    browser_cache_ttl = 14400  # 4 hours
    
    # Development mode (turn off for production)
    development_mode = "off"
  }
}
