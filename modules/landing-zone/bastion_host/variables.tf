variable resource_group_name {
  description = "(Required) The name of the resource group where to create the resource."
  type        = string
}
variable location {
  description = "(Required) Specifies the supported Azure location where to create the resource. Changing this forces a new resource to be created."
  type        = string
}

variable bastion_host_name {
  description = "(Required) The name of the Bastion Host"
  type        = string
}

variable "bastion_public_ip_address_name" {
  type        = string
  description = "Bastion Public Ip address name"
}

variable "public_ip_address_ids_map" {
  type        = map(string)
  description = "Map of Public IP Addresses Id's"
}

variable "vnet_id" {
  type        = string
  description = "Virtual Network ID Bastion Host to create"
}
