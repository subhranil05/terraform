variable "aws_region" {
  description = "AWS region to provison resources"
  default = "us-east-1"
}


variable "environment" {
  description = "Environment variable used as prefix"
  default = "dev"
}

variable "business_divison" {
  description = "Business Division in the large organization this Infrastructure belongs"
  default = "HR"
}