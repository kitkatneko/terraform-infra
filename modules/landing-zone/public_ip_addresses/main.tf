resource "azurerm_public_ip" "this" {
  for_each                = var.public_ip_addresses
  name                    = each.value["name"]
  resource_group_name     = var.resource_group_name
  location                = var.location
  allocation_method       = each.value["allocation_method"]
  sku                     = each.value["sku"]
  ip_version              = each.value["ip_version"]
  idle_timeout_in_minutes = each.value["idle_timeout_in_minutes"]
}