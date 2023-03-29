# Data source of resource group
    data "azurerm_resource_group" "my_rg" {
      name = "example"
    }

# Create Storage Account
    resource "azurerm_storage_account" "for_blob" {
    name                     = "myterraformaccount24424"
    resource_group_name      = data.azurerm_resource_group.my_rg.name
    location                 = data.azurerm_resource_group.my_rg.location
    account_tier             = "Standard"
    account_replication_type = "LRS"

    tags = {
        environment = "test"
    }
}

## Create a container

resource "azurerm_storage_container" "for_container" {
  name                  = "my-content"
  storage_account_name  = azurerm_storage_account.for_blob.name
  container_access_type = "blob"
}

## Uploading a file to the container

resource "azurerm_storage_blob" "example" {
  name                   = "rg.tf"
  storage_account_name   = azurerm_storage_account.for_blob.name
  storage_container_name = azurerm_storage_container.for_container.name
  type                   = "Block"
  source                 = "/home/subhranil/softwares_tmdc/my-git/terraform/azure/resource-group/rg.tf"
}