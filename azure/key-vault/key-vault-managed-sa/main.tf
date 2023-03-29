data "azurerm_client_config" "current" {}


# data "azuread_service_principal" "test" {
#   # https://docs.microsoft.com/en-us/azure/key-vault/secrets/overview-storage-keys-powershell#service-principal-application-id
#   application_id = ""
#   # display_name = "subhterraform001"
# }

data "azuread_service_principal" "test" {
  # display_name = "Azure Key Vault"
  application_id = "cfa8b339-82a2-471a-a3c9-0fc0be7a4093"
}

resource "azurerm_resource_group" "example" {
  name     = "key-vault-managed-sa1001"
  location = "East US"
}

resource "azurerm_storage_account" "example" {
  name                     = "keyvaultmanagedsa1001"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  is_hns_enabled           = true
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
  expiry = "2024-04-30T00:00:00Z"

  permissions {
    read    = true
    write   = false
    delete  = false
    list    = true
    add     = true
    create  = false
    update  = false
    process = false
    tag     = false
    filter  = false
  }
}

resource "azurerm_key_vault" "example" {
  name                = "key-vaultmanaged-sa1001"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    secret_permissions = [
      "Get",
      "Delete"
    ]

    storage_permissions = [
      "Get",
      "List",
      "Set",
      "SetSAS",
      "GetSAS",
      "DeleteSAS",
      "Update",
      "RegenerateKey"
    ]
  }
}

resource "azurerm_role_assignment" "example" {
  scope                = azurerm_storage_account.example.id
  role_definition_name = "Storage Account Key Operator Service Role"
  principal_id         = data.azuread_service_principal.test.id
}

resource "azurerm_key_vault_managed_storage_account" "example" {
  name                         = "examplemanagedstorage"
  key_vault_id                 = azurerm_key_vault.example.id
  storage_account_id           = azurerm_storage_account.example.id
  storage_account_key          = "key1"
  regenerate_key_automatically = false
  regeneration_period          = "P1D"

  depends_on = [
    azurerm_role_assignment.example,
  ]
}

# resource "azurerm_key_vault_managed_storage_account_sas_token_definition" "example" {
#   name                       = "examplesasdefinition"
#   validity_period            = "P1D"
#   managed_storage_account_id = azurerm_key_vault_managed_storage_account.example.id
#   sas_template_uri           = data.azurerm_storage_account_sas.example.sas
#   sas_type                   = "account"
# }