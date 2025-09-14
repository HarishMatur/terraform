# Terraform code to create RDS instance with single AZ deployment with security group attached to it.

resource "random_password" "rds_password" {
    length = 16
    special = true
    override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_secretmanager_secret" "rds_secret" {
    name = "${var.db_name}-master-credentials"
    description = "Master credentials for RDS instance ${var.db_name}"
    tags = {
        Name = "${var.db_name}-master-credentials"
    }
}


resource "aws_secretmanager_secret_version" "rds_secret_version" {
    secret_id = aws_secretmanager_secret.rds_secret.id
    secret_string = jsonencode({
        username = var.master_username
        password = random_password.rds_password.result
    })
}

resource "aws_db_instance" "my_rds_instance" {
    engine = var.engine
    engine_version = var.engine_version
    master_username = var.master_username
    master_password = random_password.rds_password.result
    instance_class = var.instance_class
    allocated_storage = var.allocated_storage
    multi_az = var.multi_az
    publicly_accessible = var.publicly_accessible
    db_name = var.db_name
    skip_final_snapshot = var.skip_final_snapshot
    storage_encrypted = var.storage_encrypted

    tags = {
        Name = var.db_name
    }
}