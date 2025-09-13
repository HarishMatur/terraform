# ✅ VPC Module – Troubleshooting Guide

> A comprehensive guide for identifying and resolving issues when working with the Terraform VPC module (VPC, subnets, IGW, NAT, route tables, and associations).

---

## 🎯 Objective

This guide is designed to help DevOps engineers:

- Understand common pitfalls when deploying a VPC with Terraform
- Resolve routing and networking errors in AWS
- Avoid misconfigurations in subnets, NAT gateways, and route tables
- Build reliable and reusable Terraform VPC modules

---

## ⚠️ Problem 1: `RouteAlreadyExists`

**Explanation**  
Every VPC automatically includes a **local route** for its own CIDR block (e.g., `10.0.0.0/16`). Adding this route manually in your route tables causes duplication.

**Fix**  

```hcl
# ❌ Wrong
route {
  cidr_block = "10.0.0.0/16"
  nat_gateway_id = aws_nat_gateway.my-nat-gw.id
}

# ✅ Correct
route {
  cidr_block     = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.my-nat-gw.id
}
⚠️ Problem 2: Unexpected Identity Change
Explanation
Terraform’s state may lose identity values (id=null) while AWS returns valid resource IDs. This usually happens due to interrupted runs or provider bugs.

Fix

bash
Copy code
# 1. Refresh state
terraform refresh

# 2. Import the resource if missing
terraform import module.vpc.aws_route_table.private_rt rtb-xxxxxxxx

# 3. Upgrade AWS provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.58.0"
    }
  }
}
terraform init -upgrade

# 4. Last resort: remove from state and delete manually in AWS
terraform state rm module.vpc.aws_route_table.private_rt
⚠️ Problem 3: InvalidAMIID.NotFound
Explanation
AMI IDs are region-specific. An AMI from us-east-1 will not exist in ap-south-1.

Fix

bash
Copy code
# Check AMI availability
aws ec2 describe-images --image-ids ami-xxxxxx --region ap-south-1
Or fetch AMI dynamically:

hcl
Copy code
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

resource "aws_instance" "example" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
}
⚠️ Problem 4: NAT Gateway Creation Fails
Explanation
NAT Gateways must be in a public subnet (with an IGW). Creating one in a private subnet fails.

Fix

hcl
Copy code
resource "aws_nat_gateway" "my-nat-gw" {
  allocation_id = aws_eip.my-nat-gw-eip.id
  subnet_id     = aws_subnet.public_subnet.id

  depends_on = [aws_internet_gateway.my-igw] # ensure IGW exists first
}
⚠️ Problem 5: Subnet Instances Have No Internet
Explanation

Public subnet must route to IGW.

Private subnet must route to NAT GW.

Missing associations break connectivity.

Fix

hcl
Copy code
# Public Route Table
route {
  cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.my-igw.id
}

# Private Route Table
route {
  cidr_block     = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.my-nat-gw.id
}

# Associations
resource "aws_route_table_association" "public_rt_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "private_rt_assoc" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_rt.id
}
⚠️ Problem 6: Destroy Fails With Dangling Resources
Explanation
Sometimes dependencies (NAT → EIP → IGW) don’t destroy in the right order.

Fix

bash
Copy code
# Destroy NAT first
terraform destroy -target=module.vpc.aws_nat_gateway.my-nat-gw

# Then clean up everything else
terraform destroy
If resources remain in AWS, delete them manually and refresh Terraform state:

bash
Copy code
terraform refresh
✅ Best Practices Summary
Resource	Best Practice
VPC	Use a clear CIDR (e.g., 10.0.0.0/16)
Subnets	Split into /24 ranges per AZ
Internet Access	Public RT → IGW, Private RT → NAT GW
NAT Gateway	Place only in public subnet
Provider	Keep region only in root provider
State Drift	Use terraform import to re-sync

👨‍💻 Maintainer
Author: Harish M