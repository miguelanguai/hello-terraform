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

resource "aws_subnet" "misubnet" {
  vpc_id = aws_vpc.mi_vpc.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "us-east-1a"
}

resource "aws_security_group" "gs_migrupo" {
  name = "mi_gs"
  vpc_id = aws_vpc.mi_vpc.id

  ingress {
      cidr_blocks = ["0.0.0.0/0"]
      description = "Acceso al puerto 80 desde el exterior"
      from_port = 80
      to_port = 80
      protocol = "TCP"
  }

  egress {
      cidr_blocks = ["0.0.0.0/0"]
      description = "Acceso al puerto 80 desde el exterior"
      from_port = 0
      to_port = 0
      protocol = "-1"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.mi_vpc.id

  tags = {
    Name = "main"
  }
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.mi_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "route-table"
  }
}

resource "aws_route_table_association" "rt-association" {
  subnet_id      = aws_subnet.misubnet.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_instance" "miec2" {
  ami = "ami-08b5b3a93ed654d19"
  instance_type = "t3.micro"
  subnet_id = aws_subnet.misubnet.id
  vpc_security_group_ids = [aws_security_group.gs_migrupo.id]
  key_name = "vockey"
  associate_public_ip_address = true
  user_data = <<-EOF
      #!/bin/bash
      yum update -y
      yum install -y httpd
      systemctl enable httpd
      systemctl start httpd
      echo "<html><body><h1>¡Hola, mundo! Esto es una página de prueba.</h1><p>Instancia EC2 con Amazon Linux y Apache.</p></body></html> > /var/www/html/index.html
      chmod 644 /var/www/html/index.html
      systemctl restart httpd
      EOF


  tags = {
    Name = "EC2Instance"
  }
}