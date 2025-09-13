# VPC Module – Troubleshooting Guide

This document lists common errors and fixes when working with the VPC Terraform module.

---

## ❌ Error: `RouteAlreadyExists`

Error: creating Route in Route Table (...) with destination (10.0.0.0/16):
api error RouteAlreadyExists: The route identified by 10.0.0.0/16 already exists.

yaml
Copy code

**Cause**: Every VPC automatically has a **local route** for its CIDR (e.g. `10.0.0.0/16`). Adding it manually in a route table causes duplication.

**Fix**:
- Remove any explicit route that matches the VPC CIDR.
- Use `0.0.0.0/0` for internet or NAT routes.

---

## ❌ Error: `Unexpected Identity Change`

Error: Unexpected Identity Change: During the read operation, the Terraform Provider
unexpectedly returned a different identity then the previously stored one.

perl
Copy code

**Cause**: The Terraform state doesn’t have proper identity info for the resource  
(e.g. `id=null` in state but AWS API returns an actual resource). This often happens  
after interrupted applies, provider bugs, or manual changes in AWS.

**Fix**:
1. Refresh the state:
   ```bash
   terraform refresh
If still broken, import the resource:

bash
Copy code
terraform import module.vpc.aws_route_table.private_rt rtb-xxxxxxxx
Upgrade the AWS provider:

hcl
Copy code
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.58.0"
    }
  }
}
bash
Copy code
terraform init -upgrade
As a last resort, remove from state and clean manually:

bash
Copy code
terraform state rm module.vpc.aws_route_table.private_rt
❌ Error: InvalidAMIID.NotFound
vbnet
Copy code
Error: creating EC2 Instance: api error InvalidAMIID.NotFound: The image id does not exist
Cause: AMIs are region-specific. The ID you provided is not available in the configured region.

Fix:

Ensure the AMI exists in the same region as your VPC.

Use a data "aws_ami" block to fetch the latest AMI dynamically instead of hardcoding.

❌ Error: NAT Gateway creation failed
Possible causes:

NAT Gateway deployed in a private subnet instead of a public subnet.

Internet Gateway (igw) not attached to the VPC before NAT GW creation.

No Elastic IPs available in the account.

Fix:

Ensure NAT Gateway is created in the public subnet.

Add dependency:

hcl
Copy code
depends_on = [aws_internet_gateway.my-igw]
Verify you have free Elastic IPs (VPC → Elastic IPs in AWS console).

❌ Subnets not routing properly
Symptoms:

Public subnet instances have no internet access.

Private subnet instances cannot reach the internet.

Fix:

Public subnet → associated with public route table (0.0.0.0/0 → IGW).

Private subnet → associated with private route table (0.0.0.0/0 → NAT GW).

Double-check Route Table Associations.

❌ Destroy fails with dangling resources
Cause: Sometimes dependencies (e.g., NAT → EIP → IGW) don’t destroy in order.

Fix:

Run:

bash
Copy code
terraform destroy -target=module.vpc.aws_nat_gateway.my-nat-gw
terraform destroy
Or manually delete stuck resources in AWS console, then refresh state:

bash
Copy code
terraform refresh
🔑 General Tips
Always run terraform plan before apply or destroy.

Keep region defined in the root provider block, not inside modules.

Use terraform state list to inspect what Terraform is tracking.

If resources drift (manual changes in AWS), use terraform import to re-sync.