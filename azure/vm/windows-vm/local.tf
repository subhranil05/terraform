locals {
  common_name = local.vnet.name
  vnet = {
    name          = var.vnet_name
    location      = var.vnet_location
    address_space = var.vnet_address_space
  }
  vm ={
    name          = var.vm_name
    username      = var.vm_username
    password      = var.vm_pwd
  }
  tags = {
    environment = var.environment
    service = "virtual machine"

  }
  subnet = [
    {
      name           = "${local.vnet.name}-${var.subnet_name}-0"
      address_prefix = "10.0.0.0/24"
    },
    {
      name           = "${local.vnet.name}-${var.subnet_name}-1"
      address_prefix = "10.0.1.0/24"
    }
  ]
}