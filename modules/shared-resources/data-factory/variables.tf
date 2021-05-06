# - Data Factory

variable "data_factory" {
  description = "Data Factory"
  type = map(object({
    name                   = string
    location               = string
    resource_group_name    = string
    tags                   = map(string)
  }))
  default = {}
}