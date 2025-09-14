module "vpc" {
  source                    = "../modules/vpc"
  cidr_block                = var.cidr_block
  public_subnet_cidr_block  = var.public_subnet_cidr_block
  public_subnet_az          = var.public_subnet_az
  private_subnet_cidr_block = var.private_subnet_cidr_block
  private_subnet_az         = var.private_subnet_az
  public_route_cidr_block   = var.public_route_cidr_block
  private_route_cidr_block  = var.private_route_cidr_block
}