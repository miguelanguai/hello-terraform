resource "aws_vpc" "mi_vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    "Name" = "vpc-${var.vpc_name}"
  }
}

resource "aws_subnet" "subnet_publica" {
  vpc_id = aws_vpc.mi_vpc.id
  cidr_block = var.subnet_publica_cidr
  map_public_ip_on_launch = true

  tags = {
    "Name" = "Subred Pública"
  }
}

resource "aws_subnet" "subnet_privada" {
  vpc_id = aws_vpc.mi_vpc.id
  cidr_block = var.subnet_privada_cidr

  tags = {
    "Name" = "Subred Privada"
  }
}

resource "aws_internet_gateway" "migw" {
  vpc_id = aws_vpc.mi_vpc.id

  tags = {
    "Name" = "Internet Gateway"
  }
}

resource "aws_route_table" "rt_publica" {
  vpc_id = aws_vpc.mi_vpc.id
}

resource "aws_route" "name" {
  route_table_id = aws_route_table.rt_publica.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.migw.id
}

resource "aws_route_table_association" "publica" {
  subnet_id = aws_subnet.subnet_publica.id
  route_table_id = aws_route_table.rt_publica.id
}