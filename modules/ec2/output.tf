output "ec2_instance_id" {
  value = aws_instance.test1.id
}

output "ec2_instance_public_ip" {
  value = aws_instance.test1.public_ip
}

output "ec2_instance_private_ip" {
  value = aws_instance.test1.private_ip
}

output "ec2_instance_public_dns" {
  value = aws_instance.test1.public_dns
}
