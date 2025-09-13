## Terraform code to create the VPC with public and private subnets, internet gateway, NAT gateway, route tables and necessary route table associations.

resource "aws_vpc" "main_vpc" {
    cidr_block = var.cidr_block

    tags = {
        Name = "testing-vpc"
    }
}

resource "aws_subnet" "public_subnet" {
    vpc_id = aws_vpc.main_vpc.id
    cidr_block = var.public_subnet_cidr_block
    availability_zone = var.public_subnet_az

    tags = {
        Name = "public-subnet"
    }
}

resource "aws_subnet" "private_subnet" {
    vpc_id = aws_vpc.main_vpc.id
    cidr_block = var.private_subnet_cidr_block
    availability_zone = var.private_subnet_az

    tags = {
        Name = "private-subent"
    }
}

resource "aws_internet_gateway" "my-igw" {
    vpc_id = aws_vpc.main_vpc.id

    tags = {
        Name = "my-igw"
    }
}

resource "aws_route_table" "public_rt" {
    vpc_id = aws_vpc.main_vpc.id
    
    route {
        cidr_block = var.public_route_cidr_block
        gateway_id = aws_internet_gateway.my-igw.id
    }

    tags = {
        Name = "public-rt"
    }
}

resource "aws_route_table" "private_rt" {
    vpc_id = aws_vpc.main_vpc.id

    route {
        cidr_block = var.private_route_cidr_block
        nat_gateway_id = aws_nat_gateway.my-nat-gw.id
    }
    tags = {
        Name = "private-rt"
    }
}

resource "aws_route_table_association" "public_rt_assoc" {
    subnet_id = aws_subnet.public_subnet.id
    route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "private_rt_assoc" {
    subnet_id = aws_subnet.private_subnet.id
    route_table_id = aws_route_table.private_rt.id
}

resource "aws_eip" "my-nat-gw-eip" {
    domain = "vpc"
}

resource "aws_nat_gateway" "my-nat-gw" {
    allocation_id = aws_eip.my-nat-gw-eip.id
    subnet_id = aws_subnet.public_subnet.id

    tags = {
        Name = "my-nat-gw"
    }
}