output "aws_rds_instance_id" {
    value = aws_db_instance.my_rds_instance.id
}

output "aws_rds_instance_endpoint" {
    value = aws_db_instance.my_rds_instance.endpoint
}

output "rds_secret_arn" {
    value = aws_secretmanager_secret.rds_secret.arn
}