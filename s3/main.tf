module "s3" {
    source = "../modules/s3"
    Purpose = var.Purpose
    Environment = var.Environment
    Account_id = var.Account_id
    Enable_versioning = var.Enable_versioning
}