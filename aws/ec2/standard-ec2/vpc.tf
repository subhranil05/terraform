# Create Vpc Module

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.19.0"
  # Basic details of Vpc

  name = "${local.name}-${var.vpc_name}"
  cidr = var.vpc_cidr_block

  # Availability zones and subnets

  azs             = var.vpc_availability_zones
  private_subnets = var.vpc_private_subnets
  public_subnets  = var.vpc_public_subnets

  # Database subnets
  create_database_subnet_group = var.vpc_create_database_subnet_group # to create database subnet group
  database_subnets             = var.vpc_database_subnets

  # NAT Gateway (Outbound Connection)
  enable_nat_gateway = var.vpc_enable_nat_gateway # to enable it for all private subnets
  single_nat_gateway = var.vpc_single_nat_gateway # for single zone only

  # Route table
  create_database_subnet_route_table = var.vpc_create_database_subnet_route_table # create separate route tbale for database subnets only

  # DNS
  enable_dns_hostnames = true # enable dns hostnames
  enable_dns_support   = true # to support 

  # Tags
  private_subnet_tags = {
    Name = "private-subnet"
  }

  public_subnet_tags = {
    Name = "public-subnet"
  }

  database_subnet_tags = {
    Name = "database-subnet"
  }

  tags     = local.common_tags
  vpc_tags = local.common_tags
}