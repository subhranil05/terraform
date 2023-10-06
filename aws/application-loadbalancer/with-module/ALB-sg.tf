# Create a special security group for loadbalencer

module "alb_sg" {
  source = "terraform-aws-modules/security-group/aws"
  version = "3.18.0"

  name        = "alb-sg"
  description = "Security group for loadbalancer-sg with custom ports 81 open for entire Internet"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks      = ["0.0.0.0/0"]
  ingress_rules            = ["http-80-tcp"]

  # Create custom rules
  
  ingress_with_cidr_blocks = [
    {
      from_port   = 81
      to_port     = 80
      protocol    = 6
      description = "Allow port 81 port from internet"
      cidr_blocks = "0.0.0.0/0"
    },
  ]
}