# - Create Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.sku
  retention_in_days   = var.retention_in_days
}

# - Store LAW Workspace Id and Primary Key to Key Vault Secrets
locals {
  log_analytics_workspace = {
    law-primary-shared-key = azurerm_log_analytics_workspace.this.primary_shared_key
    law-workspace-id       = azurerm_log_analytics_workspace.this.workspace_id
    law-resource-id        = azurerm_log_analytics_workspace.this.id
  }
}
resource "null_resource" "dependency_modules" {
  provisioner "local-exec" {
    command = "echo ${length(var.dependencies)}"
  }
}
resource "azurerm_key_vault_secret" "this" {
  for_each     = local.log_analytics_workspace
  name         = each.key
  value        = each.value
  key_vault_id = var.key_vault_id
  depends_on = [
    azurerm_log_analytics_workspace.this,
    null_resource.dependency_modules
  ]
}
