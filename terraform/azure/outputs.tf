output "aks_cluster_name" {
  description = "Name of the AKS cluster"
  value       = azurerm_kubernetes_cluster.main.name
}

output "aks_kubeconfig_command" {
  description = "Command to configure kubectl for this cluster"
  value       = "az aks get-credentials --resource-group ${azurerm_resource_group.main.name} --name ${azurerm_kubernetes_cluster.main.name}"
}

output "acr_login_server" {
  description = "ACR login server URL"
  value       = azurerm_container_registry.main.login_server
}

output "acr_push_command" {
  description = "Command to push images to ACR"
  value       = "az acr login --name ${azurerm_container_registry.main.name}"
}

output "postgres_fqdn" {
  description = "FQDN of the PostgreSQL Flexible Server"
  value       = azurerm_postgresql_flexible_server.main.fqdn
  sensitive   = true
}

output "postgres_connection_string" {
  description = "PostgreSQL connection string for the backend app"
  value       = "postgresql://${var.db_admin_username}@${azurerm_postgresql_flexible_server.main.name}:${var.db_admin_password}@${azurerm_postgresql_flexible_server.main.fqdn}/expenses"
  sensitive   = true
}

output "resource_group_name" {
  description = "Name of the Azure Resource Group"
  value       = azurerm_resource_group.main.name
}
