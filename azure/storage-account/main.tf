# If the resource group is already created then use data source of rg
data "azurerm_resource_group" "my_rg" {
  name = "example"
}

# create new resource group
    # resource "azurerm_resource_group" "example" {
    #   name     = "example"
    #   location = "East US"
    # }


# Create Storage Account
    resource "azurerm_storage_account" "example" {
    name                     = "storageaccountname"
    resource_group_name      = data.azurerm_resource_group.my_rg.name
    location                 = data.azurerm_resource_group.my_rg.location
    account_tier             = "Standard"
    account_replication_type = "LRS"

    tags = {
        environment = "test"
    }
}

