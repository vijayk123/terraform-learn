provider "aws" {
    region = "us-east-1"
}

variable vpc_cidr_block {}
variable subnet_cidr_block {}
variable avail_zone {}
variable env_prefix {}
variable my_ip {}
variable "public_key_location" {}



resource "aws_vpc" "test_vpc"{
    cidr_block = var.vpc_cidr_block
    tags = {
    Name = "${var.env_prefix}-vpc"
 }
}


resource "aws_subnet" "test-subnet-1" {
    vpc_id = aws_vpc.test_vpc.id
    cidr_block = var.subnet_cidr_block
    availability_zone = var.avail_zone
    tags = {
    Name = "${var.env_prefix}-sn-1"
}
} 

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.test_vpc.id
  tags = {
    Name = "${var.env_prefix}-igw"
  }
}

resource "aws_route_table" "dev-route-table" {
  vpc_id = aws_vpc.test_vpc.id
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

resource "aws_security_group" "myapp-sg" {
    #name = "myapp-sg"
    vpc_id = aws_vpc.test_vpc.id

    ingress{
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [var.my_ip]

    }
    ingress{
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]

    }

    egress{
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        prefix_list_ids = []
 }
    tags = {
    Name = "${var.env_prefix}-myapp-sg"
 }
}

resource "aws_key_pair" "ssh-key" {
  key_name = "test1-key"
  public_key = file(var.public_key_location)
}
resource "aws_instance" "test-instance" {
    ami = "ami-087c17d1fe0178315"
    instance_type = "t2.micro"
    subnet_id = aws_subnet.test-subnet-1.id
    vpc_security_group_ids = [aws_security_group.myapp-sg.id]
    availability_zone = var.avail_zone
    
    associate_public_ip_address = true
    key_name = aws_key_pair.ssh-key.key_name

    user_data = file("entry-script.sh")
    tags = {
       Name = "${var.env_prefix}-instance"
   }
}