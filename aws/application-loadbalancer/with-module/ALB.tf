# Create Application loadbalancer by alb module

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "5.16.0"

  name = "${local.name}-my-ALB"

  load_balancer_type = "application"

  vpc_id             = module.vpc.vpc_id
  subnets            = [module.vpc.public_subnets[0], module.vpc.public_subnets[1]]
  security_groups    = [module.alb_sg.this_security_group_id]

  target_groups = [
    {
      name_prefix      = "${local.name}"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"
      health_check = {
        enabled             = true
        interval            = 30
        path                = "/app/index.html"
        port                = "traffic-port"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 6
        protocol            = "HTTP"
        matcher             = "200-399"
      }
      protocol_version = "HTTP1"
      targets = {
        my_private1_ec2 = {
          target_id = module.private_ec2_instance.id[0]
          port = 80
        },
        my_private2_ec2 = {
          target_id = module.private_ec2_instance.id[1]
          port = 80
        }
      }
    }
  ]
  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]

  tags = local.common_tags
}