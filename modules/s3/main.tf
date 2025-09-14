# Terraform Code to create an S3 bucket with versioning and server-side encryption enabled and blocking public access.

resource "aws_s3_bucket" "my_bucket" {
    bucket = "${var.Purpose}-${var.Environment}-${var.Account_id}-bucket"
    
    tags = {
        Name = var.Purpose
        Environment = var.Environment
        Account_id = var.Account_id
    }
}

resource "aws_s3_bucket_public_access_block" "block_public_access" {
    bucket = aws_s3_bucket.my_bucket.id
    block_public_acls = true
    block_public_policy = true
    restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "versioning" {
    bucket = aws_s3_bucket.my_bucket.id
    versioning_configuration {
        status = var.Enable_versioning ? "Enabled" : "Suspended"
    }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "sse" {
    bucket = aws_s3_bucket.my_bucket.id

    rule {
        apply_server_side_encryption_by_default {
            sse_algorithm = "AES256"
        }
    }
}

resource "aws_s3_bucket_lifecycle_configuration" "lifecycle" {
    bucket = aws_s3_bucket.my_bucket.id
    rule {
        id = "rule1"
        status = "Enabled"
        expiration {
            days = 30
        }
    }
}


