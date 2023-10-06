module "private_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.17.1"

  name        = "private-sg"
  description = "Security group with HTTP and SSH port open within VPC (IPv4 VPC CIDR), egress ports are all world open"
  vpc_id      = module.vpc.vpc_id

  # Ingress for EC2
  ingress_cidr_blocks = [module.vpc.vpc_cidr_block]
  ingress_rules       = ["ssh-tcp", "http-80-tcp"]


  # Egress rules for EC2  

  #   egress_cidr_blocks = ["10.10.0.0/16"]
  egress_rules = ["all-all"]
  tags         = local.common_tags
}