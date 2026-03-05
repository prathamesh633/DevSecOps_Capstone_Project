# ── PostgreSQL Flexible Server ───────────────────────────────────────────────
resource "azurerm_postgresql_flexible_server" "main" {
  # checkov:skip=CKV_AZURE_136:Geo-redundant backups not required for demo
  # checkov:skip=CKV2_AZURE_57:Private endpoint not required for demo
  name                         = "${var.project}-postgres-${var.environment}"
  resource_group_name          = azurerm_resource_group.main.name
  location                     = azurerm_resource_group.main.location
  version                      = "15"
  delegated_subnet_id          = azurerm_subnet.db.id
  private_dns_zone_id          = azurerm_private_dns_zone.postgres.id
  administrator_login          = var.db_admin_username
  administrator_password       = var.db_admin_password
  zone                         = "1"
  sku_name                     = var.db_sku_name
  storage_mb                   = 32768
  backup_retention_days        = 7
  geo_redundant_backup_enabled = var.environment == "prod" ? true : false
  depends_on                   = [azurerm_private_dns_zone_virtual_network_link.postgres]
}

# ── Database ─────────────────────────────────────────────────────────────────
resource "azurerm_postgresql_flexible_server_database" "expenses" {
  name      = "expenses"
  server_id = azurerm_postgresql_flexible_server.main.id
  collation = "en_US.utf8"
  charset   = "utf8"
}

# ── Firewall — allow AKS internal access only ────────────────────────────────
resource "azurerm_postgresql_flexible_server_firewall_rule" "allow_aks" {
  name             = "allow-aks-subnet"
  server_id        = azurerm_postgresql_flexible_server.main.id
  start_ip_address = cidrhost(var.private_subnet_prefix, 0)
  end_ip_address   = cidrhost(var.private_subnet_prefix, 255)
}
