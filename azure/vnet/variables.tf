variable "vnet_name" {
  description = "name of the vnet"
  default     = "my-vnet"
}

variable "vnet_location" {
  description = "location of the vnet"
  default     = "EAST US"
}

variable "vnet_rg_name" {
  description = "resource group of the vnet"
  default     = "example"
}

variable "vnet_address_space" {
  description = "address space of the vnet"
  default     = "10.0.0.0/16"
}

variable "environment" {
  description = "env of the vnet"
  default     = "test"
}

variable "subnet_name" {
  description = "name of the subnet"
  default     = "my-subnet"
}

# variable "subnet_address_prefix" {
#   description = "address space of the subnet"
#   default = "10.0.1.0/24"
# }