# ── Azure Container Registry ─────────────────────────────────────────────────
resource "azurerm_container_registry" "main" {
  name                = replace("${var.project}acr${var.environment}", "-", "")
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = "Premium" # Premium enables geo-replication & private endpoints
  admin_enabled       = false     # Use service principal / managed identity instead

  identity {
    type = "SystemAssigned"
  }

  # Enable image scanning
  quarantine_policy_enabled = true
  retention_policy_enabled  = true
  retention_policy_days     = 30
  trust_policy_enabled      = true
  export_policy_enabled     = false # prevent exporting images outside ACR

  tags = {
    Environment = var.environment
    Project     = var.project
  }
}
