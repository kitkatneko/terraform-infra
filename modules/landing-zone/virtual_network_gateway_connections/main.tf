# The following arguments are applicable only if the type is IPsec (VPN)
resource "azurerm_virtual_network_gateway_connection" "this" {
  for_each                   = var.virtual_network_gateway_connections
  name                       = each.value["name"]
  location                   = var.location
  resource_group_name        = var.resource_group_name
  type                       = each.value["type"]
  virtual_network_gateway_id = lookup(var.vpngw_ids_map, each.value["vpngw_name"])
  shared_key                 = try(each.value["shared_key"], null)
  local_network_gateway_id   = lookup(var.lgw_ids_map, each.value["local_network_gateway_name"])

  timeouts {
    create = "60m"
    delete = "60m"
  }
}