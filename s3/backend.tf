terraform {
    backend "s3" {
    bucket = "remote-statefile-backup"
    key = "s3/s3.tfstate"
    region = "ap-south-1"
    encrypt = false
    dynamodb_table = "terraform-locks"
    }
}