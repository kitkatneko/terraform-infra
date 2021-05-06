output "id" {
  value = [for x in azurerm_public_ip.this : x.id]
}

output "ip_address" {
  value = [for x in azurerm_public_ip.this : x.ip_address]
}

output "public_ip_address_ids_map" {
  value = { for x in azurerm_public_ip.this : x.name => x.id }
}