terraform {
    backend s3 {
        bucket = "remote-statefile-backup"
        key = "vpc/vpc.tfstate"
        region = var.region
        encrypt = true
        dynamodb_table = "terraform-locks"
    }
}