variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which to create the storage account"
}

variable "location" {
  type = string
  description = "The region in which all the resources should be created"
}

variable "key_vault_id" {
  type        = string
  description = "The ID of the Key Vault from which all Secrets should be sourced"
}

variable "dependencies" {
  type        = list(any)
  description = "Specifies the modules that the Storage Account Resource depends on."
  default     = []
}

# Storage Account
variable "storage_accounts" {
  type = map(object({
    name            = string
    sku             = string
    account_kind    = string
    access_tier     = string
    assign_identity = bool
  }))
  description = "Map of storage accouts which needs to be created in a resource group"
  default     = {}
}
/*

# Container
variable "containers" {
  type = map(object({
    name                  = string
    storage_account_name  = string
    container_access_type = string
  }))
  description = "Map of Storage Containers"
  default     = {}
}

# Bolb
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
}*/