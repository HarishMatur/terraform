module "ec2" {
  source        = "../modules/ec2"
  instance_type = var.instance_type
  ami           = var.ami
  region        = var.region
  key_name      = var.key_name
}
