provider "aws" {
    region = "us-east-1"
}

variable "cidr_blocks" {
    description = "subnet and vpc cidr block"
    type = list(object({
        cidr_block = string
        name = string
    }))
}


resource "aws_vpc" "test_vpc"{
    cidr_block = var.cidr_blocks[0].cidr_block
    tags = {
    Name = var.cidr_blocks[0].name
 }
}

resource "aws_subnet" "test-subnet-1" {
    vpc_id = aws_vpc.test_vpc.id
    cidr_block = var.cidr_blocks[1].cidr_block
    availability_zone = "us-east-1a"
    tags = {
    Name = var.cidr_blocks[1].name
}
}