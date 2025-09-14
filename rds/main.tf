module "rds" {
    source = "../modules/rds"
    engine = var.engine
    engine_version = var.engine_version
    username = var.username
    instance_class = var.instance_class
    allocated_storage = var.allocated_storage
    multi_az = var.multi_az
    publicly_accessible = var.publicly_accessible
    db_name = var.db_name
    skip_final_snapshot = var.skip_final_snapshot
    storage_encrypted = var.storage_encrypted
}