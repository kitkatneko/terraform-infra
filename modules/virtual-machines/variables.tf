# - Windows VM's
variable "windows_vms" {
  type = map(object({
    name                                 = string
    computer_name                        = string
    administrator_user_name              = string
    resource_group_name                  = string
    location                             = string
    vm_size                              = string
    zone                                 = string
    availability_set_key                 = string
    vm_nic_keys                          = list(string)
    source_image_reference_publisher     = string
    source_image_reference_offer         = string
    source_image_reference_sku           = string
    source_image_reference_version       = string
    os_disk_name                         = string
    storage_os_disk_caching              = string
    managed_disk_type                    = string
    disk_size_gb                         = number
  }))
  description = "Map containing Windows VM objects"
  default     = {}
}

# Windows VM NIC's
variable "windows_vm_nics" {
  type = map(object({
    name                           = string
    subnet_name                    = string
    resource_group_name            = string
    location                       = string    
    nic_ip_configurations = list(object({
      name      = string
      static_ip = string
    }))
  }))
  description = "Map containing Windows VM NIC objects"
  default     = {}
}

# - Availability Sets
variable "availability_sets" {
  type = map(object({
    name                         = string
    resource_group_name          = string
    location                     = string  
    platform_update_domain_count = number
    platform_fault_domain_count  = number
  }))
  description = "Map containing availability set configurations"
  default     = {}
}

variable "key_vault_id" {
  type        = string
  description = "The ID of the Key Vault from which all Secrets should be sourced"
}


variable "managed_data_disks" {
  type = map(object({
    name                 = string
    location             = string
    resource_group_name  = string
    storage_account_type = string
    create_option        = string
    disk_size_gb         = number
}))
}

variable "map_subnet_ids" {
  type        = map(string)
  description = "Map of Subnet Id's"
}