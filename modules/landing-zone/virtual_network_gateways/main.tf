resource "azurerm_virtual_network_gateway" "this" {
  for_each            = var.virtual_network_gateways
  name                = each.value["name"]
  location            = var.location
  resource_group_name = var.resource_group_name
  type                = each.value["type"] #ExpressRoute or VPN
  # ExpressRoute SKUs : Basic, Standard, HighPerformance, UltraPerformance
  # VPN SKUs : Basic, VpnGw1, VpnGw2, VpnGw3, VpnGw4,VpnGw5, VpnGw1AZ, VpnGw2AZ, VpnGw3AZ,VpnGw4AZ and VpnGw5AZ
  # SKUs are subject to change. Check Documentation page for updated information
  # The following options may change depending upon SKU type. Check product documentation
  sku = each.value["sku"]

  active_active = try(each.value["active_active"], null)
  #vpn_type defaults to 'RouteBased'. Type 'PolicyBased' supported only by Basic SKU
  vpn_type = try(each.value["vpn_type"], null)

  #Create multiple IPs only if active-active mode is enabled.
  dynamic "ip_configuration" {
    for_each = try(each.value["ip_configuration"], {})
    content {
      name                          = ip_configuration.value.ipconfig_name
      public_ip_address_id          = lookup(var.public_ip_address_ids_map, ip_configuration.value.public_ip_address_name)
      private_ip_address_allocation = ip_configuration.value.private_ip_address_allocation
      subnet_id                     = "${var.vnet_id}/subnets/GatewaySubnet"
     }
  }

 
  #Point 2 site (P2S) configuration
  dynamic "vpn_client_configuration" {
    for_each = try(each.value["vpn_client_configuration"], {})
    content {
      address_space = vpn_client_configuration.value.address_space
      dynamic "root_certificate" {
        for_each = vpn_client_configuration.value["root_certificates"]
        content {
          name             = root_certificate.value["name"]
          public_cert_data = root_certificate.value["public_cert_data"]
        }
      }
      #dynamic "revoked_certificate" {
      #  for_each = vpn_client_configuration.value["revoked_certificates"]
      #  content {
      #    name       = revoked_certificate.value["name"]
      #    thumbprint = revoked_certificate.value["thumbprint"]
      #  }
      #}
      #radius_server_address = vpn_client_configuration.value.radius_server_address
      #radius_server_secret  = vpn_client_configuration.value.radius_server_secret
      vpn_client_protocols  = vpn_client_configuration.value.vpn_client_protocols
    }
  }



  timeouts {
    create = "60m"
    delete = "60m"
  }
}