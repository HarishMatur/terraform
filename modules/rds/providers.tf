terraform {
    required_providers {
        aws = {
            source = "hashicorrp/aws"
            version = ">= 5.58.0"
        }
    }
}

provider "aws" {
    region = "ap-south-1"
}