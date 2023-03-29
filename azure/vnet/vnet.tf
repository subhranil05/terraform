## If the resource group is already created then use data source of rg
data "azurerm_resource_group" "my_rg" {
  name = "example"
}

# create new resource group
# resource "azurerm_resource_group" "example" {
#   name     = "example"
#   location = "East US"
# }

## If you want to use loacl values in vnet, example

resource "azurerm_virtual_network" "example" {
  name                = local.vnet.name
  location            = local.vnet.location
  resource_group_name = data.azurerm_resource_group.my_rg.name
  address_space       = [local.vnet.address_space]

  subnet {
    name           = local.subnet[0].name
    address_prefix = local.subnet[0].address_prefix
    security_group = azurerm_network_security_group.nsg.id
  }
  subnet {
    name           = local.subnet[1].name
    address_prefix = local.subnet[1].address_prefix
  }
  tags = local.tags
}

## Vnet creaetion

# resource "azurerm_virtual_network" "example" {
#   name                = "example-network"
#   location            = data.azurerm_resource_group.my_rg.location
#   resource_group_name = data.azurerm_resource_group.my_rg.name
#   address_space       = ["10.0.0.0/16"]
# #   dns_servers         = ["10.0.0.4", "10.0.0.5"]

#   subnet {
#     name           = "subnet1"
#     address_prefix = "10.0.1.0/24"
#   }

#   subnet {
#     name           = "subnet2"
#     address_prefix = "10.0.2.0/24"
#     security_group = azurerm_network_security_group.example.id
#   }

#   tags = {
#     environment = "test"
#   }
# }

## If you want manage Seperate subnet resource

# resource "azurerm_subnet" "subnet1" {
#   name                 = local.subnet[0].name
#   resource_group_name  = data.azurerm_resource_group.my_rg.name
#   virtual_network_name = azurerm_virtual_network.example.name
#   address_prefixes     = [local.subnet[0].address_prefix]
#   depends_on = [
#     azurerm_virtual_network.example
#   ]
# }

# resource "azurerm_subnet" "subnet2" {
#   name                 = local.subnet[1].name
#   resource_group_name  = data.azurerm_resource_group.my_rg.name
#   virtual_network_name = azurerm_virtual_network.example.name
#   address_prefixes     = [local.subnet[1].address_prefix]
#   depends_on = [
#     azurerm_virtual_network.example
#   ]
# }

## Network security group association resource, If only managing seperate subnet resources

# resource "azurerm_subnet_network_security_group_association" "example" {
#   subnet_id                 = azurerm_subnet.subnet1.id
#   network_security_group_id = azurerm_network_security_group.nsg.id
#   depends_on = [
#     azurerm_virtual_network.example
#   ]
# }

## Network interface

resource "azurerm_network_interface" "interface" {
  name                = "${local.common_name}-interface"
  location            = data.azurerm_resource_group.my_rg.location
  resource_group_name = data.azurerm_resource_group.my_rg.name

  ip_configuration {
    name = "internal"
    # subnet_id                     = azurerm_subnet.subnet1.id
    subnet_id                     = tolist(azurerm_virtual_network.example.subnet)[0].id # if not managing subnets as seperate resource
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.publicip.id
  }
  depends_on = [
      azurerm_virtual_network.example
    ]
}


## Public IP address

resource "azurerm_public_ip" "publicip" {
  name                = "${local.common_name}-publicip"
  resource_group_name = data.azurerm_resource_group.my_rg.name
  location            = data.azurerm_resource_group.my_rg.location
  allocation_method   = "Static"

  tags = local.tags
  # depends_on = [
  #   azurerm_resource_group.my_rg
  # ]
}

## Network Security Group

resource "azurerm_network_security_group" "nsg" {
  name                = "${local.common_name}-nsg"
  location            = data.azurerm_resource_group.my_rg.location
  resource_group_name = data.azurerm_resource_group.my_rg.name

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