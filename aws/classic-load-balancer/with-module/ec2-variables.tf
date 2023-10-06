variable "instance_type" {
  description = "value"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "value"
  type        = string
  default     = "terraform"
}

variable "private_instance_count" {
  description = "value"
  type        = number
  default     = 1
}