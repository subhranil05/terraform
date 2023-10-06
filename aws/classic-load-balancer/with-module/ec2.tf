# Data source for EC2 AMI

data "aws_ami" "my_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-*-gp2"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

# Bastian host EC2 instance (Public)

module "bastian_ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "2.17.0"

  name = "${local.name}-bastian-host"

  ami           = data.aws_ami.my_ami.id
  instance_type = var.instance_type
  #   instance_count         = 1
  key_name               = var.key_name
  monitoring             = false
  vpc_security_group_ids = [module.public_bastion_sg.security_group_id]
  subnet_id              = module.vpc.public_subnets[0]

  tags = local.common_tags
}

# Private EC2 instance

module "private_ec2_instance" {
  depends_on = [module.vpc]
  source     = "terraform-aws-modules/ec2-instance/aws"
  version    = "2.17.0"

  name = "${local.name}-private-instance"

  ami                    = data.aws_ami.my_ami.id
  instance_type          = var.instance_type
  instance_count         = var.private_instance_count
  key_name               = var.key_name
  monitoring             = false
  vpc_security_group_ids = [module.private_sg.security_group_id]
  subnet_ids = [
    module.vpc.private_subnets[0],
    module.vpc.private_subnets[1],
  ]
  user_data = file("${path.module}/apps-install.sh")
  tags = {
    type = "private-ec2"
  }
}


# Bastian host Elastic IP

resource "aws_eip" "bastian_eip" {
  depends_on = [module.bastian_ec2_instance, module.vpc]
  instance   = module.bastian_ec2_instance.id[0]
  vpc        = true
  tags       = local.common_tags
}

# Null resource and Remote/Local Provisioners


resource "null_resource" "for_ec2" {
  depends_on = [
    module.bastian_ec2_instance
  ]
  # connection block to connect and executing remote provisioners in EC2
  connection {
    type        = "ssh"
    user        = "ec2-user"
    host        = aws_eip.bastian_eip.public_ip
    private_key = file("private key/terraform.pem")
  }
  # File provisioner to copy key file from local to EC2 host
  provisioner "file" {
    source      = "private key/terraform.pem"
    destination = "/tmp/terraform.pem"
  }
  # Remote provisioner to execute some commands on EC2 host created by terraform
  provisioner "remote-exec" {
    inline = [
      "sudo chmod 400 /tmp/terraform.pem"
    ]
  }
  # Local provisioner to execute some commands on local host created by terraform
  provisioner "local-exec" {
    command     = "echo VPC created on `date` and VPC ID: ${module.vpc.vpc_id} >> creation-time-vpcid.txt"
    working_dir = "/home/subhranil/softwares_tmdc/my-git/terraform/aws/ec2/standard-ec2"
    on_failure  = continue # terraform can skip any failure for provisoner if this flag is enabled
  }

  # Destroy time provisioner
  # provisioner "local-exec" {
  #   command = "echo destroyed on `date` >> destroy-time-vpcid.txt"
  #   working_dir = "/home/subhranil/softwares_tmdc/my-git/terraform/aws/ec2/standard-ec2"
  #   # on_failure = continue    # terraform can skip any failure for provisoner if this flag is enabled
  #   when = destroy   # identify if its a createion time provisioners or destroy time provisioners. By defualt provisioners are exceuted on creation time.
  # }
}