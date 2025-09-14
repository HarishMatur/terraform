terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = ">= 5.58.0"
        }
        random = {
            source = "hashicorp/random"
            version = ">= 3.4.3"
        }
    }
}

provider "aws" {
    region = "ap-south-1"
}
