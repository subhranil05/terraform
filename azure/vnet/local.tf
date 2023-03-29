locals {
  common_name = local.vnet.name
  vnet = {
    name          = var.vnet_name
    location      = var.vnet_location
    address_space = var.vnet_address_space
  }
  tags = {
    environment = var.environment
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