# - Create Resource Group

resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location  
}

# - Log Analytics Workspace
module "LogAnalytics" {
  source              = "./log-analytics"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  name                = var.log_analytics_name
  sku                 = var.sku
  retention_in_days   = var.retention_in_days
  key_vault_id        = module.KeyVault.key_vault_id
  dependencies        = [module.KeyVault.depended_on_kv, null_resource.dependency_modules.id]
}

resource "null_resource" "dependency_modules" {
  provisioner "local-exec" {
    command = "echo ${length(var.dependencies)}"
  }
}

# - Storage Account
module "StorageAccount" {
  source              = "./storage-account"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  key_vault_id        = module.KeyVault.key_vault_id
  storage_accounts    = var.storage_accounts
  //containers        = var.containers
  //blobs             = var.blobs
  dependencies        = [module.KeyVault.depended_on_kv, null_resource.dependency_modules.id]
}

# - Key Vault
module "KeyVault" {
  source                           = "./key-vault"
  resource_group_name              = azurerm_resource_group.this.name
  location                         = azurerm_resource_group.this.location
  name                             = var.keyvault_name
  #soft_delete_enabled              = var.soft_delete_enabled
  purge_protection_enabled         = var.purge_protection_enabled
  enabled_for_deployment           = var.enabled_for_deployment
  enabled_for_disk_encryption      = var.enabled_for_disk_encryption
  enabled_for_template_deployment  = var.enabled_for_template_deployment
  sku_name                         = var.sku_name
  log_analytics_workspace_id       = module.LogAnalytics.law_id
  storage_account_ids_map          = module.StorageAccount.sa_ids_map
  diagnostics_storage_account_name = var.diagnostics_storage_account_name
}