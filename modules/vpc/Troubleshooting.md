# VPC Module – Troubleshooting Guide

---

## ❌ Error: Unexpected Identity Change

### Error Output
```bash
Error: Unexpected Identity Change: During the read operation, the Terraform Provider 
unexpectedly returned a different identity then the previously stored one.
Cause
Terraform’s state did not store the correct identity (e.g., id=null), but AWS API returns a valid resource.
This often happens after interrupted applies or provider bugs.

Fix
bash
Copy code
# 1. Refresh state
terraform refresh

# 2. Import resource if needed
terraform import module.vpc.aws_route_table.private_rt rtb-xxxxxxxx

# 3. Upgrade provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.58.0"
    }
  }
}
terraform init -upgrade

# 4. Last resort: remove from state and delete manually
terraform state rm module.vpc.aws_route_table.private_rt
❌ Error: InvalidAMIID.NotFound
Error Output
bash
Copy code
Error: creating EC2 Instance: api error InvalidAMIID.NotFound: The image id does not exist
Cause
AMI IDs are region-specific.

The AMI ID you provided does not exist in the configured region.

Fix
Make sure the AMI exists in the same region as your VPC.

Use a data source to fetch the latest AMI dynamically:

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
❌ Error: NAT Gateway creation failed
Possible Causes
NAT Gateway deployed in a private subnet instead of a public subnet.

Internet Gateway not attached before NAT creation.

No free Elastic IPs available.

Fix
Deploy NAT GW in public subnet.

Add dependency:

hcl
Copy code
depends_on = [aws_internet_gateway.my-igw]
Verify Elastic IP availability in AWS console.