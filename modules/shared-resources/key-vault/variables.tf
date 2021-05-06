variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which to create the Key Vault"
}

variable "location" {
  type = string
  description = "The region in which all the resources should be created"
}

# keyvault
variable "name" {
  type        = string
  description = "Specifies the name of the Key Vault"
}

variable "enabled_for_deployment" {
  type        = bool
  description = "Allow Virtual Machines to retrieve certificates stored as secrets from the key vault."
  default     = null
}

variable "enabled_for_disk_encryption" {
  type        = bool
  description = "Allow Disk Encryption to retrieve secrets from the vault and unwrap keys."
  default     = null
}

variable "enabled_for_template_deployment" {
  type        = bool
  description = "Allow Resource Manager to retrieve secrets from the key vault."
  default     = null
}

/*
variable "soft_delete_enabled" {
  type        = bool
  description = "Allow Soft Delete be enabled for this Key Vault"
  default     = true
}
*/

variable "purge_protection_enabled" {
  type        = bool
  description = "Allow purge_protection be enabled for this Key Vault"
  default     = true
}

variable "sku_name" {
  type        = string
  description = "The name of the SKU used for the Key Vault. The options are: `standard`, `premium`."
  default     = "standard"
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "Specifies the Id of a Log Analytics Workspace where Diagnostics Data should be sent"
}

variable "storage_account_ids_map" {
  type        = map(string)
  description = "Map of Storage Account Id's"
}

variable "diagnostics_storage_account_name" {
  type        = string
  description = "Specifies the name of the Storage Account where Diagnostics Data should be sent"
}

# Key Vault Serets
variable "secrets" {
  type        = map(string)
  description = "A map of secrets for the Key Vault"
  default     = {}
}