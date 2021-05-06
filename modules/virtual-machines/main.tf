data "azurerm_resource_group" "this" {
  for_each             = var.windows_vms
  name                 = each.value.resource_group_name
}

# - Generate Password for Windows Virtual Machine
resource "random_password" "this" {
  for_each         = var.windows_vms
  length           = 32
  min_upper        = 2
  min_lower        = 2
  min_special      = 2
  number           = true
  special          = true
  override_special = "!@#$%&"
}

# - Store Generated Password to Key Vault Secrets
resource "azurerm_key_vault_secret" "this" {
  for_each     = var.windows_vms
  name         = each.value["name"]
  value        = lookup(random_password.this, each.key)["result"]
  key_vault_id = var.key_vault_id

  lifecycle {
    ignore_changes = [value]
  }
}

#- Availability Set
resource "azurerm_availability_set" "this" {
  for_each                     = var.availability_sets
  name                         = each.value["name"]
  resource_group_name          = each.value["resource_group_name"]
  location                     = each.value["location"]
  platform_update_domain_count = each.value["platform_update_domain_count"]
  platform_fault_domain_count  = each.value["platform_fault_domain_count"]
}

# - Windows Virtual Machine

resource "azurerm_windows_virtual_machine" "windows_vms" {
  for_each              = var.windows_vms
  name                  = each.value["name"]
  location              = each.value["location"]
  resource_group_name   = each.value["resource_group_name"]
  admin_username        = each.value["administrator_user_name"]
  admin_password        = lookup(random_password.this, each.key)["result"]
  network_interface_ids = [for nic_k, nic_v in azurerm_network_interface.windows_nics : nic_v.id if(contains(each.value["vm_nic_keys"], nic_k) == true)]
  size                  = each.value["vm_size"]
  zone                  = lookup(each.value, "availability_set_key", null) == null ? lookup(each.value, "zone", null) : null
  availability_set_id   = lookup(each.value, "availability_set_key", null) == null ? null : lookup(azurerm_availability_set.this, each.value["availability_set_key"])["id"]

  os_disk {
    name                 = each.value["os_disk_name"]
    caching              = coalesce(lookup(each.value, "storage_os_disk_caching"), "ReadWrite")
    storage_account_type = coalesce(lookup(each.value, "managed_disk_type"), "Standard_LRS")
    disk_size_gb         = lookup(each.value, "disk_size_gb", null)
  }

  source_image_reference {
    publisher = lookup(each.value, "source_image_reference_publisher", "MicrosoftWindowsServer")
    offer     = lookup(each.value, "source_image_reference_offer", "WindowsServer")
    sku       = lookup(each.value, "source_image_reference_sku", "2016-Datacenter")
    version   = lookup(each.value, "source_image_reference_version", "latest")
  }

  computer_name            = upper(each.value["computer_name"])

  lifecycle {
    ignore_changes = [
      admin_password,
      network_interface_ids
    ]
  }
}


# - Windows Network Interfaces
resource "azurerm_network_interface" "windows_nics" {
  for_each            = var.windows_vm_nics
  name                = each.value["name"]
  resource_group_name = each.value["resource_group_name"]
  location            = each.value["location"]

  ip_configuration {
    name                          = "internal"
    #subnet_id                     = each.value["subnet_name"]
    subnet_id                     = lookup(var.map_subnet_ids, each.value["subnet_name"])
    private_ip_address_allocation = "Dynamic"
  }
}

#########################################################
# Linux VM Managed Disk and VM & Managed Disk Attachment
#########################################################
locals {
  windows_vm_ids = {
    for vm in azurerm_windows_virtual_machine.windows_vms :
    vm.name => vm.id
  }
  windows_vm_zones = {
    for vm_k, vm_v in var.windows_vms :
    azurerm_windows_virtual_machine.windows_vms[vm_k].name => vm_v.zone
  }
  windows_vms = {
    for vm_k, vm_v in var.windows_vms :
    azurerm_windows_virtual_machine.windows_vms[vm_k].name => {
      key                        = vm_k
      #enable_cmk_disk_encryption = coalesce(vm_v.enable_cmk_disk_encryption, false)
    }
  }
}

resource "azurerm_managed_disk" "this" {
  for_each              = var.managed_data_disks
  name                  = lookup(each.value, "name", null) == null ? "-datadisk" : each.value["name"]
  location              = "canadacentral"
  resource_group_name   = "hcac-hub-sharedsvc-rg"
  storage_account_type  = coalesce(lookup(each.value, "storage_account_type"), "Premium_LRS")
  create_option         = "Empty"
  disk_size_gb          = coalesce(lookup(each.value, "disk_size_gb"), 100)
  #name                  = "${var.each.value["name"]}-datadisk"
  #name                 = "${var.vm-name}-datadisk"
  #storage_account_type  = "StandardSSD_LRS"
  #create_option         = "Empty"
  #disk_size_gb          = 10
  #tags                  = var.tags
}

# attach the disks

resource "azurerm_virtual_machine_data_disk_attachment" "this" {
  for_each                  = var.managed_data_disks
  managed_disk_id           = lookup(lookup(azurerm_managed_disk.this, each.key, null), "id", null)
  virtual_machine_id        = lookup(local.windows_vm_ids, each.value["name"])
  lun                       = "10"
  caching                   = "ReadWrite"
}