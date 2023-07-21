## Bastion Subnets

# resource "azurerm_subnet" "bastion_subnet" {
#   name                 = "${azurerm_virtual_network.myvnet.name}-bastion-subnet"
#   resource_group_name  = azurerm_resource_group.example.name
#   virtual_network_name = azurerm_virtual_network.myvnet.name
#   address_prefixes     = ["10.0.2.0/24"]

# } 

# ## Bastion Host

# resource "azurerm_bastion_host" "example" {
#   name                = "${local.vm.name}bastion"
#   location            = azurerm_resource_group.example.location
#   resource_group_name = azurerm_resource_group.example.name

#   ip_configuration {
#     name                 = "configuration"
#     subnet_id            = azurerm_subnet.bastion_subnet.id
#     public_ip_address_id = azurerm_public_ip.bastion_publicip.id
#   }
# }

# ## Bastion Public IP address

# resource "azurerm_public_ip" "bastion_publicip" {
#   name                = "${local.common_name}-bastion-publicip"
#   resource_group_name = azurerm_resource_group.example.name
#   location            = azurerm_resource_group.example.location
#   allocation_method   = "Static"
#   sku = "Standard"
#   tags = local.tags
#   # depends_on = [
#   #   azurerm_resource_group.my_rg
#   # ]
# }