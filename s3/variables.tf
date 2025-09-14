variable "Purpose" {
  type        = string
  description = "The purpose of the S3 bucket"
}

variable "Environment" {
  type        = string
  description = "The environment where the S3 bucket is deployed"
}

variable "Account_id" {
  type        = string
  description = "The AWS account ID"
}

variable "Enable_versioning" {
  type        = bool
  description = "Enable versioning for the s3 bucket"
  default     = false
}