# VPC Module – Troubleshooting Guide

This guide documents common errors and fixes when working with the VPC Terraform module.

---

## ❌ Error: RouteAlreadyExists

### Error Output
```bash
Error: creating Route in Route Table (rtb-xxxxxx) with destination (10.0.0.0/16): 
api error RouteAlreadyExists: The route identified by 10.0.0.0/16 already exists.
Cause
Every VPC automatically has a local route for its own CIDR (e.g., 10.0.0.0/16).
Manually adding it in a route table causes duplication.

Fix
Remove any explicit route for the VPC CIDR.

Use 0.0.0.0/0 for internet or NAT routes instead.

❌ Error: Unexpected Identity Change
Error Output
bash
Copy code
Error: Unexpected Identity Change: During the read operation, the Terraform Provider 
unexpectedly returned a different identity then the previously stored one.
Cause
Terraform’s state is missing or has invalid identity info (id=null),
but AWS API returns a valid resource. This usually happens after:

Interrupted applies

Manual resource changes in AWS

Older AWS provider bugs

Fix
bash
Copy code
# 1. Refresh state
terraform refresh

# 2. Import the missing resource
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

# 4. Last resort: remove from state (resource must be deleted manually in AWS)
terraform state rm module.vpc.aws_route_table.private_rt
❌ Error: InvalidAMIID.NotFound
Error Output
bash
Copy code
Error: creating EC2 Instance: api error InvalidAMIID.NotFound: The image id does not exist
Cause
AMI IDs are region-specific.

The AMI you used does not exist in the configured region.

Fix
Verify that the AMI exists in the same region as your VPC.

Prefer using a data source to fetch the latest AMI dynamically:

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
❌ Error: NAT Gateway Creation Failed
Possible Causes
NAT Gateway deployed in a private subnet instead of a public subnet.

Internet Gateway not attached to the VPC before NAT creation.

No free Elastic IPs available.

Fix
Deploy NAT Gateway in the public subnet.

Add dependency on the IGW:

hcl
Copy code
depends_on = [aws_internet_gateway.my-igw]
Verify available Elastic IPs in the AWS console.

❌ Subnet Instances Have No Internet Access
Symptoms
Public subnet instances cannot reach the internet.

Private subnet instances cannot reach the internet via NAT.

Fix
Public Subnet → must be associated with a route table pointing to IGW:

hcl
Copy code
route {
  cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.my-igw.id
}
Private Subnet → must be associated with a route table pointing to NAT GW:

hcl
Copy code
route {
  cidr_block     = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.my-nat-gw.id
}
Double-check route table associations.

❌ Destroy Fails With Dangling Resources
Error
Terraform sometimes cannot delete NAT Gateway, EIP, or IGW in the right order.

Fix
bash
Copy code
# Destroy NAT first
terraform destroy -target=module.vpc.aws_nat_gateway.my-nat-gw

# Then destroy the rest
terraform destroy
Or manually delete stuck resources in the AWS console, then refresh:

bash
Copy code
terraform refresh
🔑 General Tips
Always run terraform plan before apply or destroy.

Keep region defined only in the root provider block, not inside modules.

Use terraform state list to inspect tracked resources.

Use terraform import to re-sync if resources drift due to manual changes in AWS.