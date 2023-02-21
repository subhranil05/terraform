module "public_bastion_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.17.1"

  name        = "public-bastion-sg"
  description = "Security group with SSH port open for everybody (IPv4 CIDR), egress ports are all world open"
  vpc_id      = module.vpc.vpc_id

  # Ingress for EC2
  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["ssh-tcp"]


  # Egress rules for EC2  

  # egress_cidr_blocks = ["10.10.0.0/16"]
  egress_rules = ["all-all"]
  tags         = local.common_tags
}