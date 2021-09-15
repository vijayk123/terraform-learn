provider "aws" {
    region = "us-east-1"
}
resource "aws_vpc" "test_vpc"{
    cidr_block = var.vpc_cidr_block
    tags = {
    Name = "${var.env_prefix}-vpc"
 }
}

module "test-subnet" {
  source = "./Modules/subnets"
  subnet_cidr_block = var.subnet_cidr_block
  avail_zone = var.avail_zone
  env_prefix = var.env_prefix
  vpc_id = aws_vpc.test_vpc.id
}

module "test-webserver" {
  source = "./Modules/webserver"
  vpc_id = aws_vpc.test_vpc.id
  my_ip = var.my_ip
  env_prefix = var.env_prefix
  public_key_location = var.public_key_location
  subnet_id = module.test-subnet.subnet.id
  avail_zone =var.avail_zone
}