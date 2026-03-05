# ── Log Analytics for AKS monitoring ────────────────────────────────────────
resource "azurerm_log_analytics_workspace" "main" {
  name                = "${var.project}-log-analytics"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# ── AKS Cluster ──────────────────────────────────────────────────────────────
# tfsec:ignore:azure-container-limit-authorized-ips
# checkov:skip=CKV_AZURE_171:Upgrade channel not strictly required for demo
# checkov:skip=CKV_AZURE_168:50 pods per node minimum not required for demo
# checkov:skip=CKV_AZURE_226:Ephemeral disks not required for demo
# checkov:skip=CKV_AZURE_227:Data flow encryption not required for demo
# checkov:skip=CKV_AZURE_232:Critical pods distribution not required for demo
# checkov:skip=CKV_AZURE_115:Private cluster not required for demo
# checkov:skip=CKV_AZURE_172:Secrets Store CSI Driver not required for demo
# checkov:skip=CKV_AZURE_141:Local admin disabling not required for demo
# checkov:skip=CKV_AZURE_117:Disk encryption set not required for demo
# checkov:skip=CKV_AZURE_170:Paid SKU SLA not required for demo
# checkov:skip=CKV_AZURE_6:API Server Authorized IP Ranges disabled for demo
resource "azurerm_kubernetes_cluster" "main" {
  name                = var.cluster_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  dns_prefix          = var.cluster_name
  kubernetes_version  = var.kubernetes_version

  default_node_pool {
    name                = "default"
    node_count          = var.node_count
    vm_size             = var.node_vm_size
    vnet_subnet_id      = azurerm_subnet.private.id
    enable_auto_scaling = true
    min_count           = var.node_min_count
    max_count           = var.node_max_count

    upgrade_settings {
      max_surge = "10%"
    }
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = "azure"
    network_policy    = "calico"
    load_balancer_sku = "standard"
  }

  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
  }

  azure_policy_enabled              = true
  role_based_access_control_enabled = true

  tags = {
    Environment = var.environment
    Project     = var.project
  }
}

# ── Attach ACR to AKS (pull role) ────────────────────────────────────────────
resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                = azurerm_container_registry.main.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.main.kubelet_identity[0].object_id
}
