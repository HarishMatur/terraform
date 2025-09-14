output "aws_rds_instance_id" {
    value = module.rds.aws_rds_instance_id
}

output "aws_rds_instance_endpoint" {
    value = module.rds.aws_rds_instance_endpoint
}

output "rds_secret_arn" {
    value = module.rds.rds_secret_arn
}