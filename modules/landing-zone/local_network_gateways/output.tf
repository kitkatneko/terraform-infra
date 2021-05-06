//output id {
  //value = azurerm_local_network_gateway.lngw.id
//}

output "id" {
  value = [for x in azurerm_local_network_gateway.this : x.id]
}

output "lgw_ids_map" {
  value = { for x in azurerm_local_network_gateway.this : x.name => x.id }
}