## reffering data block of present provider creds
data "azurerm_client_config" "current" {}

## KeyVault
resource "azurerm_key_vault" "myvault" {
  name                        = "myvmkeyvault"
  location                    = azurerm_resource_group.example.location
  resource_group_name         = azurerm_resource_group.example.name
#   enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    # key_permissions = [
    #   "Get",
    # ]

    secret_permissions = [
      "Get", "Set", "Delete"
    ]

    # storage_permissions = [
    #   "Get",
    # ]
  }
}

## Create secret inside the KeyVault

resource "azurerm_key_vault_secret" "vmsecret" {
  name         = "myvmpassword"
  value        = local.vm.password
  key_vault_id = azurerm_key_vault.myvault.id

  depends_on = [ azurerm_key_vault.myvault ]
}