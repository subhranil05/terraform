# Bastian host EC2 (Public) Outputs
# EC2 id
output "bastian_host_id" {
  description = "value"
  value       = module.bastian_ec2_instance.id
}
# Public IP

output "bastian_host_public_ip" {
  description = "value"
  value       = module.bastian_ec2_instance.public_ip
}
#Private IP

output "bastian_host_private_ip" {
  description = "value"
  value       = module.bastian_ec2_instance.private_ip
}


# Private EC2 instance Outputs
# EC2 id
output "private_ec2_id" {
  description = "value"
  value       = module.private_ec2_instance.id
}
# Public IP
output "private_ec2_public_ip" {
  description = "value"
  value       = module.private_ec2_instance.public_ip
}
#Private IP
output "bprivate_ec2_private_ip" {
  description = "value"
  value       = module.private_ec2_instance.private_ip
}