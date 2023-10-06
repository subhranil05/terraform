# Create Classic loadbalancer by lb module

module "elb" {
  source  = "terraform-aws-modules/elb/aws"
  version = "2.5.0"

  name = "${local.name}-${var.lb_name}"

  subnets         = [module.vpc.public_subnets[0], module.vpc.public_subnets[1]]
  security_groups = [module.loadbalancer_sg.this_security_group_id]
  internal        = false

  listener = [
    {
      instance_port     = 80
      instance_protocol = "HTTP"
      lb_port           = 80
      lb_protocol       = "HTTP"
    },
    {
      instance_port     = 80
      instance_protocol = "HTTP"
      lb_port           = 81
      lb_protocol       = "HTTP"
    },
  ]

  health_check = {
    target              = "HTTP:80/"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
  }

  // ELB attachments
  number_of_instances = var.private_instance_count
  instances           = [module.private_ec2_instance.id[0], module.private_ec2_instance.id[1]]

  tags = local.common_tags
}