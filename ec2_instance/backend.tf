terraform {
    backend s3 {
        bucket = "remote-statefile-backup"
        key = "ec2"
        region = "ap-south-1"
        encrypt = false
        enable_locking = true
    }
}