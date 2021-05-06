# - Create Resource Group

resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location  
}

resource "azurerm_resource_group" "rg" {
  for_each            = var.rg
  name                = each.value["name"]
  location            = each.value["location"] 
}

# - Virtual Network

resource "azurerm_virtual_network" "this" {
  name                = var.virtual_network_name
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  address_space       = var.address_space
  dns_servers         = var.dns_servers
}

# - Subnet

resource "azurerm_subnet" "this" {
  for_each             = var.subnets
  name                 = each.value["name"]
  resource_group_name  = azurerm_resource_group.this.name
  address_prefixes     = each.value["address_prefixes"]
  virtual_network_name = azurerm_virtual_network.this.name

  depends_on = [azurerm_virtual_network.this]
}

# - Network Security Group
resource "azurerm_network_security_group" "this" {
  for_each            = var.network_security_groups
  name                = each.value["name"]
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  dynamic "security_rule" {
    for_each = lookup(each.value, "security_rules", [])
    content {
      name                                       = security_rule.value["name"]
      description                                = lookup(security_rule.value, "description", null)
      protocol                                   = coalesce(security_rule.value["protocol"], "Tcp")
      direction                                  = security_rule.value["direction"]
      access                                     = coalesce(security_rule.value["access"], "Allow")
      priority                                   = security_rule.value["priority"]
      source_address_prefix                      = lookup(security_rule.value, "source_address_prefix", null)
      source_address_prefixes                    = lookup(security_rule.value, "source_address_prefixes", null)
      destination_address_prefix                 = lookup(security_rule.value, "destination_address_prefix", null)
      destination_address_prefixes               = lookup(security_rule.value, "destination_address_prefixes", null)
      source_port_range                          = lookup(security_rule.value, "source_port_range", null)
      source_port_ranges                         = lookup(security_rule.value, "source_port_ranges", null)
      destination_port_range                     = lookup(security_rule.value, "destination_port_range", null)
      destination_port_ranges                    = lookup(security_rule.value, "destination_port_ranges", null)
    }
  }
}


locals {
  subnet_names_network_security_group = [
      for x in var.subnets : x.name if lookup(x, "nsg_key", null) != null
  ]
  subnet_nsg_keys_network_security_group = [
      for x in var.subnets : {
          subnet_name = x.name
          nsg_key     = x.nsg_key
      } if lookup (x, "nsg_key", null) != null
  ]
  subnets_network_security_group = zipmap(local.subnet_names_network_security_group, local.subnet_nsg_keys_network_security_group)
}

# - Network Security Group association to Subnet

resource "azurerm_subnet_network_security_group_association" "this" {
  for_each                  = local.subnets_network_security_group
  network_security_group_id = lookup(azurerm_network_security_group.this, each.value["nsg_key"], null)["id"]
  subnet_id = [
    for x in azurerm_subnet.this : x.id if 
    x.name == each.value["subnet_name"] &&
    x.virtual_network_name == azurerm_virtual_network.this.name
  ][0]

  depends_on = [azurerm_subnet.this, azurerm_network_security_group.this ]
}

# - Public IP Address
module "PublicIpAddress" {
  source              = "./public_ip_addresses"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  public_ip_addresses = var.public_ip_addresses
}

# - Virtual Network Gateway
module "VpnGw" {
  source                    = "./virtual_network_gateways"
  resource_group_name       = azurerm_resource_group.this.name
  location                  = azurerm_resource_group.this.location
  virtual_network_gateways  = var.virtual_network_gateways
  vnet_id                   = azurerm_virtual_network.this.id
  public_ip_address_ids_map = module.PublicIpAddress.public_ip_address_ids_map
  depends_on = [ module.PublicIpAddress, azurerm_subnet.this ]
}

module "LocalNetworkGateway" {
  source                 = "./local_network_gateways"
  resource_group_name    = azurerm_resource_group.this.name
  location               = azurerm_resource_group.this.location
  local_network_gateways = var.local_network_gateways
}

module "VirtualNetworkGatewayConnection" {
  source                              = "./virtual_network_gateway_connections"
  resource_group_name                 = azurerm_resource_group.this.name
  location                            = azurerm_resource_group.this.location
  virtual_network_gateway_connections = var.virtual_network_gateway_connections
  vpngw_ids_map                       = module.VpnGw.vpngw_ids_map
  lgw_ids_map                         = module.LocalNetworkGateway.lgw_ids_map

  depends_on = [ module.VpnGw, module.LocalNetworkGateway ]
}

# - Bastion Host
module "BastionHost" {
  source                         = "./bastion_host"
  resource_group_name            = azurerm_resource_group.this.name
  location                       = azurerm_resource_group.this.location
  bastion_host_name              = var.bastion_host_name
  bastion_public_ip_address_name = var.bastion_public_ip_address_name
  vnet_id                        = azurerm_virtual_network.this.id
  public_ip_address_ids_map      = module.PublicIpAddress.public_ip_address_ids_map

  depends_on = [ module.PublicIpAddress, azurerm_subnet.this ]
}