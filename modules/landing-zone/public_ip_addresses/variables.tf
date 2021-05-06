variable resource_group_name {
  description = "(Required) The name of the resource group where to create the resource."
  type        = string
}
variable location {
  description = "(Required) Specifies the supported Azure location where to create the resource. Changing this forces a new resource to be created."
  type        = string
}

# - Public IP Address Object
variable "public_ip_addresses" {
  description = "The public IP address with its properties."
  type = map(object({
    name                       = string
    sku                        = string
    allocation_method          = string
    ip_version                 = string
    idle_timeout_in_minutes    = string
  }))
}