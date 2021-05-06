variable resource_group_name {
  description = "(Required) The name of the resource group where to create the resource."
  type        = string
}
variable location {
  description = "(Required) Specifies the supported Azure location where to create the resource. Changing this forces a new resource to be created."
  type        = string
}

# - Virtual Network Gateway Connection
variable "virtual_network_gateway_connections" {
  description = "The Virtual Network Gateway Connection with its properties"
  type = map(object({
      name                       = string
      type                       = string
      vpngw_name                 = string
      shared_key                 = string
      local_network_gateway_name = string
  }))
}

variable "vpngw_ids_map" {
  type        = map(string)
  description = "Map of Virtual Network Gateway Id's"
}

variable "lgw_ids_map" {
  type        = map(string)
  description = "Map of Local Network Gateway Id's"
}