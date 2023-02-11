# Create Vpc Module

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.19.0"
# Basic details of Vpc

  name = "my-test-vpc"
  cidr = "10.0.0.0/16"

# Availability zones and subnets

  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

# Database subnets
  create_database_subnet_group = true   # to create database subnet group
  database_subnets = ["10.0.151.0/24", "10.0.152.0/24"]

# NAT Gateway (Outbound Connection)
  enable_nat_gateway = true   # to enable it for all private subnets
  single_nat_gateway  = true  # for single zone only

# Route table
  create_database_subnet_route_table = true    # create separate route tbale for database subnets only

# DNS
  enable_dns_hostnames  = true    # enable dns hostnames
  enable_dns_support = true  # to support 

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

  tags = {
    Owner = "Subhranil"
    Environment = "Dev"
  }

  vpc_tags = {
    Name = "my-dev-vpc"
  }
}