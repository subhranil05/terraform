# public security group's outputs

output "security_group_arn_public" {
  description = "The ARN of the security group"
  value       = module.public_bastion_sg.security_group_arn
}

output "security_group_id_public" {
  description = "The ID of the security group"
  value       = module.public_bastion_sg.security_group_id
}

output "security_group_vpc_id_public" {
  description = "The VPC ID"
  value       = module.public_bastion_sg.security_group_vpc_id
}


# private security group's outputs

output "security_group_arn_private" {
  description = "The ARN of the security group"
  value       = module.private_sg.security_group_arn
}

output "security_group_id_private" {
  description = "The ID of the security group"
  value       = module.private_sg.security_group_id
}

output "security_group_vpc_id_private" {
  description = "The VPC ID"
  value       = module.private_sg.security_group_vpc_id
}
