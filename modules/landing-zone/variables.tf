variable "resource_group_name" {
  type = string
  description = "The Name which should be used for this Resource Group"
}

variable "location" {
  type = string
  description = "The region in which all the resources should be created"
}

variable "rg" {
  type = map(object({
    name        = string
    location    = string
  }))
}

variable "virtual_network_name" {
  type = string
  description = "The Virtual Network name"
}

variable "address_space" {
  type = list(string)
  description = "The address space of the Virtual Network"
}

variable "dns_servers" {
  type = list(string)
  description = "The DNS servers of the Virtual Network"
}

# - Subnet Object
variable "subnets" {
  description = "The Virtual networks Subnets with its properties"
  type = map(object({
      name             = string
      nsg_key          = string
      address_prefixes = list(string)
  }))
}

# - Network Security Group Object
variable "network_security_groups" {
  description = "The network security groups with its properties."
  type = map(object({
      name =  string
      security_rules = list(object({
          name                         = string
          description                  = string
          protocol                     = string
          direction                    = string
          access                       = string
          priority                     = number
          source_address_prefix        = string
          source_address_prefixes      = list(string)
          destination_address_prefix   = string
          destination_address_prefixes = list(string)
          source_port_range            = string
          source_port_ranges           = list(string)
          destination_port_range       = string
          destination_port_ranges      = list(string)
      }))
  }))
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

# - Local Network Gateway
variable "local_network_gateways" {
  description = "The Local Network Gateway with its properties"
  type = map(object({
      name             = string
      gateway_address  = string
      address_space    = list(string)
  }))
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

# - Bastion Host
variable bastion_host_name {
  description = "(Required) The name of the Bastion Host"
  type        = string
}

variable "bastion_public_ip_address_name" {
  type        = string
  description = "Bastion Public Ip address name"
}