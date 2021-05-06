output "id" {
  value = [for x in azurerm_virtual_network_gateway_connection.this : x.id]
}