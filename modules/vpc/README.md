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