resource "azurerm_bastion_host" "this" {
  name                = var.bastion_host_name
  resource_group_name = var.resource_group_name
  location            = var.location

  ip_configuration {
    name                 = "configuration"
    subnet_id            = "${var.vnet_id}/subnets/AzureBastionSubnet"
    public_ip_address_id = lookup(var.public_ip_address_ids_map, var.bastion_public_ip_address_name)
  }
  timeouts {
    create = "60m"
  }
}