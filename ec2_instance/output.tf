output "ec2_instance_id" {
  value = module.ec2.ec2_instance_id
}

output "ec2_instance_public_ip" {
    value = module.ec2.ec2_instance_public_ip
}

output "ec2_instance_private_ip" {
    value = module.ec2.ec2_instance_private_ip
}

output "ec2_instance_public_dns" {
    value = module.ec2.ec2_instance_public_dns
}
