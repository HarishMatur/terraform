terraform {
  backend "s3" {
    bucket         = "remote-statefile-backup"
    key            = "vpc/vpc.tfstate"
    region         = "ap-south-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}