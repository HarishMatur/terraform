terraform {
  backend "s3" {
    bucket         = "remote-statefile-backup"
    key            = "rds/rds.tfstate"
    region         = "ap-south-1"
    encrypt        = false
    dynamodb_table = "terraform-locks"
  }
}