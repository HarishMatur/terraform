terraform {
    backend s3 {
        bucket = "remote-statefile-backup"
        key = "ec2/ec2.tfstate"
        region = "ap-south-1"
        encrypt = false
        dynamodb_table = "terraform-locks"
    }
}
