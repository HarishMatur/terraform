variable "cidr_block" {
    type = string
    description = " CIDR for VPC"
    default = "10.12.0.0/20"
}

variable "public_subnet_cidr_block" {
    type = string
    description = "value for public subnet cidr block"
}

variable "public_subnet_az" {
    type = string
    description = "value for public subnet availability zone"
}

variable "private_subnet_cidr_block" {
    type = string
    description = "value for private subnet cidr block"
}

variable "private_subnet_az" {
    type = string
    description = "value for private subnet availability zone"
}

variable "public_route_cidr_block" {
    type = string
    description = "value for public route cidr block"  
}

variable "private_route_cidr_block" {
    type = string
    description = "value for private route cidr block"
}

