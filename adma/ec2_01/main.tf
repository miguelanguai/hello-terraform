terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 5.0"
    }
  }
}

provider "aws" {
    region = "us-east-1"
}

resource "aws_vpc" "mi_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "tf-mi_vpc"
  }
}

resource "aws_subnet" "name" {
  vpc_id = aws_vpc.mi_vpc.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "us-east-1a"
}

resource "aws_security_group" "gs_migrupo" {
  name = "mi_gs"

  ingress = {
    cidr_block = ["0.0.0.0/0"]
    description = "Acceso al puerto 80 desde el exterior"
    from_port = 80
    to_port = 80
    protocol = "TCP"
  }
}

resource "aws_instance" "example" {
  ami = "ami-0e2c8caa4b6378d8c"
  instance_type = "t3.micro"
  key_name = "vockey"

  tags = {
    Name = "EC2Instance"
  }
}