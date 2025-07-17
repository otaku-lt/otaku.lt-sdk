# DNS records for otaku.lt domain
# This file contains all DNS records for the domain

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

# DNS record for events API subdomain
resource "cloudflare_record" "otaku_lt_api_events" {
  zone_id = var.cloudflare_zone_id
  name    = "api"
  content = "192.0.2.1"  # Placeholder IP, will be handled by Worker
  type    = "A"
  ttl     = 1 # Auto TTL
  proxied = true

  comment = "Managed by Terraform - Events API subdomain (api.otaku.lt)"
}

# CNAME record for yurucamp subdomain
resource "cloudflare_record" "otaku_lt_yurucamp" {
  zone_id = var.cloudflare_zone_id
  name    = "yurucamp"
  content = var.domain_name  # Using content instead of value to fix deprecation warning
  type    = "CNAME"
  ttl     = 1 # Auto TTL
  proxied = true

  comment = "Managed by Terraform - YuruCamp subdomain (yurucamp.otaku.lt)"
}

# CNAME record for korniha subdomain
resource "cloudflare_record" "otaku_lt_korniha" {
  zone_id = var.cloudflare_zone_id
  name    = "korniha"
  content = var.domain_name  # Using content instead of value to fix deprecation warning
  type    = "CNAME"
  ttl     = 1 # Auto TTL
  proxied = true

  comment = "Managed by Terraform - Korniha subdomain (korniha.otaku.lt)"
}
