## If the resource group is already created then use data source of rg
# data "azurerm_resource_group" "my_rg" {
#   name = "example"
# }

## create new resource group
resource "azurerm_resource_group" "example" {
  name     = "example"
  location = "East US"
}

## Create Windows virtual machine

resource "azurerm_windows_virtual_machine" "windowsvm" {
  name                = local.vm.name
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  size                = "Standard_B1ls"
  admin_username      = local.vm.username
  # admin_password      = local.vm.password
  admin_password      = azurerm_key_vault_secret.vmsecret.value   # when managing your password/secrets with Azure Key Vault
  network_interface_ids = [
    azurerm_network_interface.interface.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
  # storage_data_disk{
  #   name = mydata
  #   caching = ReadWrite
  #   lun = 0
  #   disk_size_gb = 5
  # }

  depends_on = [
    azurerm_network_interface.interface
  ]
}
## VM extension for custom script

resource "azurerm_virtual_machine_extension" "example" {
  name                 = "hostname"
  virtual_machine_id   = azurerm_windows_virtual_machine.windowsvm.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "2.0"

  settings = <<SETTINGS
 {
  "commandToExecute": "hostname && uptime"
 }
SETTINGS


  tags = {
    environment = "Production"
  }
}

## If you want to use loacl values in vnet, example

resource "azurerm_virtual_network" "myvnet" {
  name                = local.vnet.name
  location            = local.vnet.location
  resource_group_name = azurerm_resource_group.example.name
  address_space       = [local.vnet.address_space]

  # subnet {
  #   name           = local.subnet[0].name
  #   address_prefix = local.subnet[0].address_prefix
  #   security_group = azurerm_network_security_group.nsg.id
  # }
  # subnet {
  #   name           = local.subnet[1].name
  #   address_prefix = local.subnet[1].address_prefix
  # }
  tags = local.tags
}

## Subnets

resource "azurerm_subnet" "my_subnet" {
  name                 = "${azurerm_virtual_network.myvnet.name}-subnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.myvnet.name
  address_prefixes     = ["10.0.1.0/24"]
  

} 

resource "azurerm_subnet_network_security_group_association" "sub_as1" {
  subnet_id                 = azurerm_subnet.my_subnet.id
  network_security_group_id = azurerm_network_security_group.nsg1.id
}

resource "azurerm_subnet_network_security_group_association" "sub_as2" {
  subnet_id                 = azurerm_subnet.my_subnet.id
  network_security_group_id = azurerm_network_security_group.nsg2.id
}

## Network interface

resource "azurerm_network_interface" "interface" {
  name                = "${local.common_name}-interface"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name = "internal"
    # subnet_id                     = azurerm_subnet.subnet1.id
    subnet_id                     = tolist(azurerm_virtual_network.myvnet.subnet)[0].id # if not managing subnets as seperate resource
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.publicip.id
    # public_ip_address_id          = azurerm_public_ip.bastion_publicip.id   # If using Azure Bastion Host
  }
  depends_on = [
      azurerm_virtual_network.myvnet
    ]
}


## Public IP address
## Remove this publicip if bastion host is in use
resource "azurerm_public_ip" "publicip" {
  name                = "${local.common_name}-publicip"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  allocation_method   = "Static"

  tags = local.tags
  # depends_on = [
  #   azurerm_resource_group.my_rg
  # ]
}


## Network Security Group

resource "azurerm_network_security_group" "nsg1" {
  name                = "${local.common_name}-nsg-1"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  security_rule {
    name                       = "allowrdp"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = local.tags
  # depends_on = [
  #   azurerm_resource_group.my_rg
  # ]
}

resource "azurerm_network_security_group" "nsg2" {
  name                = "${local.common_name}-nsg-2"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  security_rule {
    name                       = "allowrdp"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = local.tags
  # depends_on = [
  #   azurerm_resource_group.my_rg
  # ]
}

# Adding Data disk to VM
resource "azurerm_managed_disk" "data_disk" {
  name                 = "${local.vm.name}-disk1"
  location             = azurerm_resource_group.example.location
  resource_group_name  = azurerm_resource_group.example.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = 10

  tags = local.tags
}

resource "azurerm_virtual_machine_data_disk_attachment" "example" {
  managed_disk_id    = azurerm_managed_disk.data_disk.id
  virtual_machine_id = azurerm_windows_virtual_machine.windowsvm.id
  lun                = "0"
  caching            = "ReadWrite"
}