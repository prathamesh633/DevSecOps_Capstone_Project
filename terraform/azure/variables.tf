# ── Region & Environment ───────────────────────────────────────────────────
variable "location" {
  description = "Azure region"
  type        = string
  default     = "East US"
}

variable "environment" {
  description = "Deployment environment (dev / staging / prod)"
  type        = string
  default     = "dev"
}

variable "project" {
  description = "Project name used as a prefix for resources"
  type        = string
  default     = "expense-tracker"
}

# ── Networking ─────────────────────────────────────────────────────────────
variable "vnet_address_space" {
  description = "Address space for the Virtual Network"
  type        = list(string)
  default     = ["10.1.0.0/16"]
}

variable "public_subnet_prefix" {
  type    = string
  default = "10.1.1.0/24"
}

variable "private_subnet_prefix" {
  type    = string
  default = "10.1.10.0/24"
}

variable "db_subnet_prefix" {
  type    = string
  default = "10.1.20.0/24"
}

# ── AKS ───────────────────────────────────────────────────────────────────
variable "cluster_name" {
  type    = string
  default = "expense-tracker-aks"
}

variable "kubernetes_version" {
  type    = string
  default = "1.29"
}

variable "node_vm_size" {
  type    = string
  default = "Standard_D2s_v3"
}

variable "node_count" {
  type    = number
  default = 2
}

variable "node_min_count" {
  type    = number
  default = 1
}

variable "node_max_count" {
  type    = number
  default = 4
}

# ── PostgreSQL ─────────────────────────────────────────────────────────────
variable "db_admin_username" {
  description = "Admin username for PostgreSQL Flexible Server"
  type        = string
  default     = "dbadmin"
  sensitive   = true
}

variable "db_admin_password" {
  description = "Admin password — override via TF_VAR_db_admin_password"
  type        = string
  sensitive   = true
}

variable "db_sku_name" {
  description = "SKU for PostgreSQL Flexible Server"
  type        = string
  default     = "B_Standard_B1ms"
}
