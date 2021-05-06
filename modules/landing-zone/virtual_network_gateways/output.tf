//output id {
  //value = azurerm_virtual_network_gateway.vngw.id

//}

output "id" {
  value = [for x in azurerm_virtual_network_gateway.this : x.id]
}

output "vpngw_ids_map" {
  value = { for x in azurerm_virtual_network_gateway.this : x.name => x.id }
}