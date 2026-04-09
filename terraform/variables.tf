variable "project_id" {
  type = string
}

variable "project_name" {
  type = string
}

variable "billing_account" {
  type = string
}

variable "region" {
  type    = string
  default = "europe-west4"
}

variable "zones" {
  type    = list(string)
  default = ["europe-west4-a", "europe-west4-b", "europe-west4-c"]
}

variable "environment" {
  type    = string
  default = "prod"
}

variable "network_name" {
  type    = string
  default = "olaba-vpc"
}

variable "subnet_name" {
  type    = string
  default = "olaba-main"
}

variable "subnet_cidr" {
  type    = string
  default = "10.10.0.0/20"
}

variable "pods_cidr" {
  type    = string
  default = "10.20.0.0/16"
}

variable "services_cidr" {
  type    = string
  default = "10.30.0.0/20"
}

variable "master_ipv4_cidr_block" {
  type    = string
  default = "172.16.0.0/28"
}

variable "gke_cluster_name" {
  type    = string
  default = "olaba-senaite"
}

variable "artifact_registry_repo" {
  type    = string
  default = "senaite"
}

variable "gke_release_channel" {
  type    = string
  default = "REGULAR"
}

variable "enable_binary_authorization" {
  type    = bool
  default = false
}

variable "deletion_protection" {
  type    = bool
  default = true
}

variable "db_tier" {
  type    = string
  default = "db-custom-4-16384"
}

variable "db_disk_size_gb" {
  type    = number
  default = 100
}

variable "db_availability_type" {
  type    = string
  default = "REGIONAL"
}

variable "domain" {
  type    = string
  default = "olaba-lis.com"
}

variable "root_subdomain" {
  type    = string
  default = "app"
}

variable "cloudflare_zone_id" {
  type = string
}

variable "cloudflare_api_token" {
  type      = string
  sensitive = true
}

variable "tenant_hosts" {
  description = "Subdomains to provision in Cloudflare pointing at the shared ingress IP"
  type        = list(string)
  default     = ["app.olaba-lis.com", "lab01.olaba-lis.com"]
}

variable "labels" {
  type = map(string)
  default = {
    app         = "senaite"
    owner       = "olaba"
    managed_by  = "terraform"
    environment = "prod"
  }
}
