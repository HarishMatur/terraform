# VPC Module

This Terraform module creates a complete **VPC network** in AWS, including:

- VPC
- Public and Private Subnets
- Internet Gateway
- NAT Gateway with Elastic IP
- Public and Private Route Tables
- Route Table Associations

---

## 📦 Resources Created

- **VPC** with CIDR block you specify
- **Public Subnet** (with route to Internet Gateway)
- **Private Subnet** (with route to NAT Gateway)
- **Internet Gateway (IGW)**
- **Elastic IP (EIP)** for NAT Gateway
- **NAT Gateway** (deployed in public subnet)
- **Public Route Table** with default route (`0.0.0.0/0 → IGW`)
- **Private Route Table** with default route (`0.0.0.0/0 → NAT GW`)
- **Route Table Associations** for both subnets

---

## 🚀 Usage

In your **root module**:

```hcl
provider "aws" {
  region = var.region
}

module "vpc" {
  source = "../modules/vpc"

  cidr_block               = "10.0.0.0/16"
  public_subnet_cidr_block = "10.0.1.0/24"
  private_subnet_cidr_block = "10.0.2.0/24"

  public_subnet_az  = "ap-south-1a"
  private_subnet_az = "ap-south-1b"
}
📥 Input Variables
Name	Type	Description	Example
cidr_block	string	CIDR block for the VPC	"10.0.0.0/16"
public_subnet_cidr_block	string	CIDR block for the public subnet	"10.0.1.0/24"
private_subnet_cidr_block	string	CIDR block for the private subnet	"10.0.2.0/24"
public_subnet_az	string	Availability Zone for public subnet	"ap-south-1a"
private_subnet_az	string	Availability Zone for private subnet	"ap-south-1b"

📤 Outputs
Name	Description
vpc_id	ID of the created VPC
public_subnet_id	ID of the public subnet
private_subnet_id	ID of the private subnet
igw_id	ID of the Internet Gateway
nat_gateway_id	ID of the NAT Gateway
public_route_table_id	ID of the Public Route Table
private_route_table_id	ID of the Private Route Table

⚠️ Notes
The NAT Gateway is deployed in the public subnet (required by AWS).

Both route tables automatically get a local route for the VPC CIDR block.

Make sure your AWS account has sufficient Elastic IPs available before deploying.

Destroying the VPC will remove all subnets, gateways, and route tables created by this module.

🧪 Example Outputs
After applying:

hcl
Copy code
Outputs:

vpc_id                 = "vpc-0f30770b0410a5e99"
public_subnet_id       = "subnet-02d0bc2b9fb799f1f"
private_subnet_id      = "subnet-072a59afcca21e371"
igw_id                 = "igw-026980089f23772b2"
nat_gateway_id         = "nat-01cabd3ae672993bc"
public_route_table_id  = "rtb-03ebeee71d0fd8a67"
private_route_table_id = "rtb-0ac6b8e1be24e0b6d"
🧹 Cleanup
To destroy all resources created by this module:

bash
Copy code
terraform destroy
⚠️ Ensure no other resources are using the VPC/subnets before destroying.