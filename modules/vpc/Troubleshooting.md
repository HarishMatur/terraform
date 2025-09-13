# VPC Module – Troubleshooting Guide

This document lists common errors and their fixes when working with the VPC Terraform module.

---

## ❌ Error: `RouteAlreadyExists`

Error: creating Route in Route Table (...) with destination (10.0.0.0/16):
api error RouteAlreadyExists: The route identified by 10.0.0.0/16 already exists.

yaml
Copy code

**Cause**  
Every VPC automatically has a **local route** for its CIDR (e.g., `10.0.0.0/16`).  
Adding it manually in a route table causes duplication.

**Fix**  
- Remove explicit routes that match the VPC CIDR.  
- For internet/NAT routes, use `0.0.0.0/0` instead.

---

## ❌ Error: `Unexpected Identity Change`

Error: Unexpected Identity Change: During the read operation, the Terraform Provider
unexpectedly returned a different identity then the previously stored one.

pgsql
Copy code

**Cause**  
Terraform’s state does not have proper identity info for the resource  
(e.g., `id=null` in state but AWS API returns a valid resource).  
This often happens after interrupted applies, provider bugs, or manual AWS changes.

**Fix**
```bash
# 1. Refresh state
terraform refresh

# 2. If still broken, import the resource
terraform import module.vpc.aws_route_table.private_rt rtb-xxxxxxxx

# 3. Upgrade the AWS provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.58.0"
    }
  }
}
terraform init -upgrade

# 4. Last resort: remove resource from state and delete manually in AWS
terraform state rm module.vpc.aws_route_table.private_rt
❌ Error: InvalidAMIID.NotFound
vbnet
Copy code
Error: creating EC2 Instance: api error InvalidAMIID.NotFound: The image id does not exist
Cause
AMI IDs are region-specific. The AMI you used is not available in the configured region.

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

resource "aws_instance" "test" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
}
❌ Error: NAT Gateway creation failed
Possible Causes

NAT Gateway deployed in a private subnet instead of a public subnet.

Internet Gateway not attached to the VPC before NAT creation.

No free Elastic IPs available in the account.

Fix

Deploy NAT Gateway in the public subnet.

Add dependency:

hcl
Copy code
depends_on = [aws_internet_gateway.my-igw]
Verify available Elastic IPs in AWS console.

❌ Subnet instances cannot reach the internet
Symptoms

Public subnet instances cannot access the internet.

Private subnet instances cannot reach the internet via NAT.

Fix

Public subnet must be associated with a public route table (0.0.0.0/0 → IGW).

Private subnet must be associated with a private route table (0.0.0.0/0 → NAT GW).

Verify route table associations.

❌ Destroy fails with dangling resources
Cause
Dependencies (e.g., NAT → EIP → IGW) may not be destroyed in the right order.

Fix

bash
Copy code
# Target NAT GW first
terraform destroy -target=module.vpc.aws_nat_gateway.my-nat-gw

# Then destroy everything else
terraform destroy
Or manually delete stuck resources in AWS console, then refresh Terraform state:

bash
Copy code
terraform refresh
🔑 General Tips
Always run terraform plan before apply or destroy.

Keep region defined only in the root provider block, not inside modules.

Use terraform state list to inspect tracked resources.

If drift occurs (manual AWS changes), use terraform import to re-sync.