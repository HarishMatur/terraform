variable "instance_type" {
  type        = string
  description = "Type of instance to be created"
  default     = "t2.nano"
}

variable "ami" {
  type        = string
  description = "Instance AMI ID"
  default     = "ami-0b982602dbb32c5bd"
}

variable "region" {
  type        = string
  description = " AWS region to create resources"
  default     = "us-east-1"
}

variable "key_name" {
  type        = string
  description = "key pair name to access the instance"
  default     = "my-key-pair"
}