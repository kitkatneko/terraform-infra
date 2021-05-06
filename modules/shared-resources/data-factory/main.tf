# - Get current Subscription details
data "azurerm_subscription" "current" {
}

# - Data Factory
resource "azurerm_data_factory" "this" {
    //depends_on          = []
    for_each            = var.data_factory
    name                = each.value["name"]
    location            = each.value["location"]
    resource_group_name = each.value["resource_group_name"]
    tags                = each.value["tags"]
}
