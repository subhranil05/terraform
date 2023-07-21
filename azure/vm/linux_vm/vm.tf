## If the resource group is already created then use data source of rg
# data "azurerm_resource_group" "my_rg" {
#   name = "example"
# }

## create new resource group
resource "azurerm_resource_group" "example" {
  name     = "example"
  location = "East US"
}

## Create Linux virtual machine

resource "azurerm_linux_virtual_machine" "linuxvm" {
  count               = var.vm_count
  name                = "local.vm.name-${count.index}"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  size                = "Standard_B1ls"
  admin_username      = "adminuser"
  availability_set_id = azurerm_availability_set.aset.id   # if using availability sets
  zone = (count.index+1)
  network_interface_ids = [
    azurerm_network_interface.interface[count.index].id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }

  tags = local.tags
}

## Avilability set
resource "azurerm_availability_set" "aset" {
  name                = "${local.vm.name}-aset"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  platform_update_domain_count = 3
  platform_fault_domain_count = 3

  tags = {
    environment = "Production"
  }

  depends_on = [ azurerm_resource_group.example ]
}

## If you want to use local values in vnet, example

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
  # tags = local.tags
}

## Subnets

resource "azurerm_subnet" "my_subnet" {
  count                = var.subnet_count
  name                 = "${azurerm_virtual_network.myvnet.name}-subnet-${count.index}"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.myvnet.name
  address_prefixes     = ["10.0.${count.index}.0/24"]

}  

## Subnets Association

resource "azurerm_subnet_network_security_group_association" "example" {
  count                     = var.subnet_count
  subnet_id                 = azurerm_subnet.my_subnet[count.index].id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

## Network interface

resource "azurerm_network_interface" "interface" {
  count               = var.vm_count
  name                = "${local.common_name}-interface-${count.index}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name = "internal"
    subnet_id                     = azurerm_subnet.my_subnet[count.index].id
    # subnet_id                     = tolist(azurerm_virtual_network.myvnet.subnet)[0].id    # if not managing subnets as seperate resource
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.publicip[count.index].id
  }
  depends_on = [
      azurerm_subnet.my_subnet,
      azurerm_public_ip.publicip
    ]
}


## Public IP address

resource "azurerm_public_ip" "publicip" {
  count               = var.vm_count
  name                = "${local.common_name}-publicip-${count.index}"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  allocation_method   = "Static"
  zones = [ "${count.index+1}" ]

  tags = local.tags
  # depends_on = [
  #   azurerm_resource_group.my_rg
  # ]
}

## Network Security Group

resource "azurerm_network_security_group" "nsg" {
  name                = "${local.common_name}-nsg"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  security_rule {
    name                       = "allowssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = local.tags
  # depends_on = [
  #   azurerm_resource_group.my_rg
  # ]
}

## Adding Data disk to VM

resource "azurerm_managed_disk" "data_disk" {
  count                = var.vm_count
  name                 = "${local.vm.name}-disk-${count.index}"
  location             = azurerm_resource_group.example.location
  resource_group_name  = azurerm_resource_group.example.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = 10

  tags = local.tags
}

resource "azurerm_virtual_machine_data_disk_attachment" "example" {
  count              = var.vm_count
  managed_disk_id    = azurerm_managed_disk.data_disk[count.index].id
  virtual_machine_id = azurerm_linux_virtual_machine.linuxvm[count.index].id
  lun                = "${count.index}"
  caching            = "ReadWrite"
}