variable resource_group_name {
  description = "(Required) The name of the resource group where to create the resource."
  type        = string
}
variable location {
  description = "(Required) Specifies the supported Azure location where to create the resource. Changing this forces a new resource to be created."
  type        = string
}

variable "public_ip_address_ids_map" {
  type        = map(string)
  description = "Map of Public IP Addresses Id's"
}

variable "vnet_id" {
  type        = string
  description = "Virtual Network ID where VPN gateway to create"
}

# - Virtual Network Gateway Object
variable "virtual_network_gateways" {
  description = "The virtual network gateway with its properties."
  type = map(object({
    name                       = string
    type                       = string
    sku                        = string
    private_ip_address_enabled = bool
    active_active              = bool
    vpn_type                   = string
    
    ip_configuration = map(object({
      ipconfig_name                 = string
      public_ip_address_name        = string
      private_ip_address_allocation = string
    }))

    vpn_client_configuration = map(object({
      address_space = list(string)
      vpn_client_protocols  = list(string)
      root_certificates = list(object({
        name             = string
        public_cert_data = string
      }))
    }))

  }))
}

