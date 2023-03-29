data "azurerm_client_config" "example" {}

data "azurerm_resource_group" "example" {
  name     = "key-vault-managed-sa1001"
}
data "azurerm_storage_account" "example" {
  name                = "keyvaultmanagedsa1001"
  resource_group_name = "key-vault-managed-sa1001"
}

data "azurerm_storage_account_sas" "example" {
  connection_string = azurerm_storage_account.example.primary_connection_string
  https_only        = true

  resource_types {
    service   = true
    container = false
    object    = false
  }

  services {
    blob  = true
    queue = false
    table = false
    file  = false
  }

  start  = "2021-04-30T00:00:00Z"
  expiry = "2023-04-30T00:00:00Z"

  permissions {
    read    = true
    write   = true
    delete  = false
    list    = false
    add     = true
    create  = true
    update  = false
    process = false
    tag     = false
    filter  = false
  }
}

data "azurerm_key_vault" "example" {
  name                = "key-vaultmanaged-sa1001"
  resource_group_name = "key-vault-managed-sa1001"
}

resource "azurerm_key_vault_managed_storage_account" "example" {
  name                         = "examplemanagedstorage"
  key_vault_id                 = azurerm_key_vault.example.id
  storage_account_id           = azurerm_storage_account.example.id
  storage_account_key          = "key1"
  regenerate_key_automatically = true
  regeneration_period          = "P1D"
}

resource "azurerm_key_vault_managed_storage_account_sas_token_definition" "example" {
  name                       = "examplesasdefinition"
  validity_period            = "P1D"
  managed_storage_account_id = azurerm_key_vault_managed_storage_account.example.id
  sas_template_uri           = data.azurerm_storage_account_sas.example.sas
  sas_type                   = "account"
}