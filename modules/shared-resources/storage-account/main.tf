# - Get the current user config
data "azurerm_client_config" "current" {}

locals {
  key_permissions         = ["get", "wrapkey", "unwrapkey"]
  secret_permissions      = ["get"]
  certificate_permissions = ["get"]
  storage_permissions     = ["get"]
}

# - Storage Account
resource "azurerm_storage_account" "this" {
  for_each                  = var.storage_accounts
  name                      = each.value["name"]
  resource_group_name       = var.resource_group_name
  location                  = var.location
  account_tier              = coalesce(lookup(each.value, "account_kind"), "StorageV2") == "FileStorage" ? "Premium" : split("_", each.value["sku"])[0]
  account_replication_type  = coalesce(lookup(each.value, "account_kind"), "StorageV2") == "FileStorage" ? "LRS" : split("_", each.value["sku"])[1]
  account_kind              = coalesce(lookup(each.value, "account_kind"), "StorageV2")
  access_tier               = lookup(each.value, "access_tier", null)
  enable_https_traffic_only = true

  dynamic "identity" {
    for_each = coalesce(lookup(each.value, "assign_identity"), false) == false ? [] : list(lookup(each.value, "assign_identity", false))
    content {
      type = "SystemAssigned"
    }
  }
}

# - Store Storage Account Access Key to Key Vault Secrets
resource "azurerm_key_vault_secret" "this" {
  for_each     = var.storage_accounts
  name         = "${each.value["name"]}-access-key"
  value        = lookup(lookup(azurerm_storage_account.this, each.key), "primary_access_key")
  key_vault_id = var.key_vault_id
  depends_on = [
    azurerm_storage_account.this,
    null_resource.dependency_modules
  ]
}

resource "null_resource" "dependency_sa" {
  depends_on = [azurerm_storage_account.this]
}

/*

# - Container
resource "azurerm_storage_container" "this" {
  for_each              = var.containers
  name                  = each.value["name"]
  storage_account_name  = each.value["storage_account_name"]
  container_access_type = coalesce(lookup(each.value, "container_access_type"), "private")
  depends_on            = [azurerm_storage_account.this, null_resource.dependency_modules]
}

# - Blob
resource "azurerm_storage_blob" "this" {
  for_each               = local.blobs
  name                   = each.value["name"]
  storage_account_name   = each.value["storage_account_name"]
  storage_container_name = each.value["storage_container_name"]
  type                   = each.value["type"]
  size                   = lookup(each.value, "size", null)
  content_type           = lookup(each.value, "content_type", null)
  source_uri             = lookup(each.value, "source_uri", null)
  metadata               = lookup(each.value, "metadata", null)
  depends_on = [
    azurerm_storage_account.this,
    azurerm_storage_container.this,
    null_resource.dependency_modules
  ]
}
*/
# - Create Key Vault Accesss Policy for SA MSI
locals {
  msi_enabled_storage_accounts = [
    for sa_k, sa_v in var.storage_accounts :
    sa_v if coalesce(lookup(sa_v, "assign_identity"), false) == true
  ]

  sa_principal_ids = flatten([
    for x in azurerm_storage_account.this :
    [
      for y in x.identity :
      y.principal_id if y.principal_id != ""
    ] if length(keys(azurerm_storage_account.this)) > 0
  ])
}

resource "azurerm_key_vault_access_policy" "this" {
  count        = length(local.msi_enabled_storage_accounts) > 0 ? length(local.sa_principal_ids) : 0
  key_vault_id = var.key_vault_id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = element(local.sa_principal_ids, count.index)

  key_permissions         = local.key_permissions
  secret_permissions      = local.secret_permissions
  certificate_permissions = local.certificate_permissions
  storage_permissions     = local.storage_permissions

  depends_on = [azurerm_storage_account.this]
}

resource "null_resource" "dependency_modules" {
  provisioner "local-exec" {
    command = "echo ${length(var.dependencies)}"
  }
}