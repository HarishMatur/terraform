# ✅ Terraform VPC – Troubleshooting Guide

> A comprehensive guide for identifying and resolving issues when creating a VPC with Terraform (VPC, subnets, IGW, NAT, route tables, and associations).

---

## 🎯 Objective

This guide is designed to help DevOps engineers and cloud practitioners:

- Understand common pitfalls when deploying a VPC in AWS
- Resolve subnet, route table, and NAT gateway errors
- Avoid state drift and provider issues
- Build a reusable and reliable VPC module

---

## ⚠️ Problem 1: `RouteAlreadyExists`

**Explanation**:  
AWS automatically adds a **local route** for the VPC CIDR (e.g., `10.0.0.0/16`).  
Manually adding the same route in a route table causes duplication.

**Fix**:

```hcl
# ❌ Wrong
route {
  cidr_block     = "10.0.0.0/16"
  nat_gateway_id = aws_nat_gateway.my-nat-gw.id
}

# ✅ Correct
route {
  cidr_block     = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.my-nat-gw.id
}
⚠️ Problem 2: Unexpected Identity Change
Explanation:
Terraform state has id=null for a resource while AWS API returns a valid ID.
This happens after interrupted runs, state corruption, or provider bugs.

Fix:

bash
Copy code
# Refresh state
terraform refresh

# Import resource
terraform import module.vpc.aws_route_table.private_rt rtb-xxxxxxxx

# Upgrade provider
terraform init -upgrade

# Last resort: remove from state
terraform state rm module.vpc.aws_route_table.private_rt
⚠️ Problem 3: InvalidAMIID.NotFound
Explanation:
AMI IDs are region-specific. An AMI in us-east-1 won’t exist in ap-south-1.

Fix:

bash
Copy code
# Verify AMI in region
aws ec2 describe-images --image-ids ami-xxxxxx --region ap-south-1
Or fetch dynamically:

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
⚠️ Problem 4: NAT Gateway Creation Failed
Explanation:
NAT Gateways must be created in a public subnet with an Internet Gateway.
Placing it in a private subnet or missing IGW causes failure.

Fix:

hcl
Copy code
resource "aws_nat_gateway" "my-nat-gw" {
  allocation_id = aws_eip.my-nat-gw-eip.id
  subnet_id     = aws_subnet.public_subnet.id

  depends_on = [aws_internet_gateway.my-igw]
}
⚠️ Problem 5: Instances Have No Internet Access
Explanation:

Public subnets require a route to the Internet Gateway.

Private subnets require a route to the NAT Gateway.

Missing associations cause connectivity issues.

Fix:

hcl
Copy code
# Public route table
route {
  cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.my-igw.id
}

# Private route table
route {
  cidr_block     = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.my-nat-gw.id
}
And associate subnets properly:

hcl
Copy code
resource "aws_route_table_association" "public_rt_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "private_rt_assoc" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_rt.id
}
⚠️ Problem 6: Destroy Fails With Dangling Resources
Explanation:
NAT, EIP, and IGW may not destroy in the right order.

Fix:

bash
Copy code
# Destroy NAT first
terraform destroy -target=module.vpc.aws_nat_gateway.my-nat-gw

# Then destroy the rest
terraform destroy
If still stuck, delete resources manually in AWS console and refresh:

bash
Copy code
terraform refresh
✅ Best Practices Summary
Resource	Best Practice
VPC	Use a clear CIDR (e.g., 10.0.0.0/16)
Subnets	Split into /24 ranges per AZ
Public Routing	Route → IGW
Private Routing	Route → NAT GW
NAT Gateway	Must be in public subnet
Provider Config	Keep region only in root provider
State Drift	Use terraform import to re-sync

👨‍💻 Maintainer
Author: Your DevOps Team