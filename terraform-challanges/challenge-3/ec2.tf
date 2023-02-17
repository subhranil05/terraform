# Create EC2 resource
# Associate the key pair contents to it and run scripts file inside EC2 as user data

resource "aws_instance" "citadel" {
  ami                     = var.ami
  instance_type           = var.instance_type
  key_name                = aws_key_pair.citadel-key.key_name
  user_data               = file("${path.module}/install-nginx.sh")
}


# Create aws key pair resource and associate it with EC2

resource "aws_key_pair" "citadel-key" {
  key_name   = "citadel"
  public_key = file("${path.module}/.ssh/ec2-connect-key.pub")
}

# Create Elastic IP resource and associate it with EC2
# Create a local provisoners to print Elastic IP's public dns to a local file

resource "aws_eip" "eip" {
  instance = aws_instance.citadel.id
  vpc      = true

  provisioner "local-exec" {
    command = "echo ${self.public_dns} >> /root/citadel_public_dns.txt"
  }
}