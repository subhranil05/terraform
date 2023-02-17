# Required varibles for EC2

# Variables for AMI ID
variable "ami" {
  description = "Variables for AMI ID"
  default = "ami-06178cf087598769c"
}

variable "region" {
  description = "Variables for AWS region to provision EC2"
  default = "eu-west-2"
}

variable "instance_type" {
  description = "Variables for EC2 instance_type "
  default = "m5.large"
}