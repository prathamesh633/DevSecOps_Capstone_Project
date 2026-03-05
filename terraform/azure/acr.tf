# ── Azure Container Registry ─────────────────────────────────────────────────
# checkov:skip=CKV_AZURE_165:Geo-replication not required for demo
# checkov:skip=CKV_AZURE_164:Signed images not required for demo
# checkov:skip=CKV_AZURE_167:Retention policy not required for demo
# checkov:skip=CKV_AZURE_233:Zone redundancy not required for demo
# checkov:skip=CKV_AZURE_237:Dedicated endpoints not required for demo
resource "azurerm_container_registry" "main" {
  name                = replace("${var.project}acr${var.environment}", "-", "")
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = "Premium" # Premium enables geo-replication & private endpoints
  admin_enabled       = false     # Use service principal / managed identity instead

  identity {
    type = "SystemAssigned"
  }

  # Enable image scanning via quarantine policy
  quarantine_policy_enabled     = true
  export_policy_enabled         = false # prevent exporting images outside ACR
  public_network_access_enabled = false

  tags = {
    Environment = var.environment
    Project     = var.project
  }
}
