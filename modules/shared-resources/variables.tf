variable "resource_group_name" {
  type = string
  description = "The Name which should be used for this Resource Group"
}

variable "location" {
  type = string
  description = "The region in which all the resources should be created"
}

# - Log Analytics Workspace
variable "log_analytics_name" {
  type        = string
  description = "Specifies the name of the Log Analytics Workspace that will be created as part of Base Infrastructure"
}

variable "sku" {
  type        = string
  description = "Specifies the Sku of the Log Analytics Workspace. Possible values are Free, PerNode, Premium, Standard, Standalone, Unlimited, and PerGB2018 "
  default     = "PerGB2018"
}

variable "retention_in_days" {
  type        = string
  description = "The workspace data retention in days. Possible values range between 30 and 730"
  default     = 7
}

# - Storage Account
variable "storage_accounts" {
  type = map(object({
    name            = string
    sku             = string
    account_kind    = string
    access_tier     = string
    assign_identity = bool
  }))
  description = "Map of Sorage Accounts that will be created as part of Base Infrastructure"
  default     = {}
}
/*
variable "containers" {
  type = map(object({
    name                  = string
    storage_account_name  = string
    container_access_type = string
  }))
  description = "Map of Storage Containers"
  default     = {}
}

variable "blobs" {
  type = map(object({
    name                   = string
    storage_account_name   = string
    storage_container_name = string
    type                   = string
    size                   = number
    content_type           = string
    source_uri             = string
    metadata               = map(any)
  }))
  description = "Map of Storage Blobs"
  default     = {}
}
*/

# - Key Vault
variable "keyvault_name" {
  type        = string
  description = "Specifies the name of the Key vault that will be created as part of Base Infrastructure"
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

variable "sku_name" {
  type        = string
  description = "The name of the SKU used for the Key Vault. The options are: `standard`, `premium`."
  default     = "standard"
}

variable "diagnostics_storage_account_name" {
  type        = string
  description = "Specifies the name of the Storage Account where Diagnostics Data should be sent"
}

variable "dependencies" {
  type        = list(any)
  description = "Specifies the modules that the Base Infrastructure Resources depends on."
  default     = []
}
