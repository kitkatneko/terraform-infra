resource "azurerm_local_network_gateway" "this" {
  for_each            = var.local_network_gateways
  name                = each.value["name"]
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = each.value["address_space"]
  gateway_address     = each.value["gateway_address"]
}

