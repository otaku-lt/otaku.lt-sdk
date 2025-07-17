# Cloudflare Workers configuration for otaku.lt
# Migrated from Pages to Workers following official migration guide
# Uses Workers static assets without custom script
# Custom domains are managed via wrangler.toml routes

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

# D1 Database for events storage
resource "cloudflare_d1_database" "otaku_lt_api_events_db" {
  account_id = var.cloudflare_account_id
  name       = "otaku-events-db"
}

# KV Namespace for caching and rate limiting
resource "cloudflare_workers_kv_namespace" "otaku_lt_api_events_cache" {
  account_id = var.cloudflare_account_id
  title      = "otaku-events-cache"
}

# KV Namespace for API rate limiting
resource "cloudflare_workers_kv_namespace" "otaku_lt_api_events_rate_limit" {
  account_id = var.cloudflare_account_id
  title      = "otaku-events-rate-limit"
}

# Development environment resources
# D1 Database for events storage (development)
resource "cloudflare_d1_database" "otaku_lt_api_events_db_dev" {
  account_id = var.cloudflare_account_id
  name       = "otaku-events-db-dev"
}

# KV Namespace for caching (development)
resource "cloudflare_workers_kv_namespace" "otaku_lt_api_events_cache_dev" {
  account_id = var.cloudflare_account_id
  title      = "otaku-events-cache-dev"
}

# KV Namespace for API rate limiting (development)
resource "cloudflare_workers_kv_namespace" "otaku_lt_api_events_rate_limit_dev" {
  account_id = var.cloudflare_account_id
  title      = "otaku-events-rate-limit-dev"
}
