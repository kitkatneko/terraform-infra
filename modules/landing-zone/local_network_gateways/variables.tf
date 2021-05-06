variable resource_group_name {
  description = "(Required) The name of the resource group where to create the resource."
  type        = string
}
variable location {
  description = "(Required) Specifies the supported Azure location where to create the resource. Changing this forces a new resource to be created."
  type        = string
}

variable "local_network_gateways" {
  description = "The Local Network Gateway with its properties"
  type = map(object({
      name             = string
      gateway_address  = string
      address_space    = list(string)
  }))
}
