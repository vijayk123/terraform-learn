
resource "aws_subnet" "test-subnet-1" {
    vpc_id = var.vpc_id
    cidr_block = var.subnet_cidr_block
    availability_zone = var.avail_zone
    tags = {
    Name = "${var.env_prefix}-sn-1"
}
}
resource "aws_internet_gateway" "igw" {
  vpc_id = var.vpc_id
  tags = {
    Name = "${var.env_prefix}-igw"
  }
}

resource "aws_route_table" "dev-route-table" {
  vpc_id = var.vpc_id
  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "${var.env_prefix}-rtb-1"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.test-subnet-1.id
  route_table_id = aws_route_table.dev-route-table.id
}