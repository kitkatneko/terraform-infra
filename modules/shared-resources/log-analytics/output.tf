# OUTPUTS Log Analytics Workspace
output "law_workspace" {
  value       = azurerm_log_analytics_workspace.this
}

output "law_id" {
  value       = azurerm_log_analytics_workspace.this.id
}

output "law_name" {
  value       = azurerm_log_analytics_workspace.this.name
}

output "law_key" {
  value       = azurerm_log_analytics_workspace.this.primary_shared_key
}

output "law_workspace_id" {
  value       = azurerm_log_analytics_workspace.this.workspace_id
}

/*output "law_id_map" {
  value = {
    for x in list(azurerm_log_analytics_workspace.this) :
    x.name => x.id
  }
}*/
