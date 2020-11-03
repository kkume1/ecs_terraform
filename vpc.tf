###### ネットワークリソースの定義
# VPCの定義
resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.ProjectName}-VPC"
  }
}

######
# subnetの定義
resource "aws_subnet" "public0" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.0.0.0/24"
  map_public_ip_on_launch = false
  availability_zone = "ap-northeast-1a"
  tags = {
    Name = "${var.ProjectName}-public-0"
  }
}

resource "aws_subnet" "public1" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = false
  availability_zone = "ap-northeast-1c"
  tags = {
    Name = "${var.ProjectName}-public-1"
  }
}

resource "aws_subnet" "private0" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.0.2.0/24"
  map_public_ip_on_launch = false
  availability_zone = "ap-northeast-1a"
  tags = {
    Name = "${var.ProjectName}-private-0"
  }
}

resource "aws_subnet" "private1" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.0.3.0/24"
  map_public_ip_on_launch = false
  availability_zone = "ap-northeast-1c"
  tags = {
    Name = "${var.ProjectName}-private-1"
  }
}

######
# IGWの定義
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
    tags = {
    Name = "${var.ProjectName}-IGW"
  }
}

######
# NatGWの定義
resource "aws_eip" "eip0" {
  vpc = true
  depends_on = [aws_internet_gateway.igw]
  tags = {
    Name = "${var.ProjectName}-EIP-0"
  }
}

resource "aws_nat_gateway" "natgw0" {
  allocation_id = aws_eip.eip0.id
  subnet_id = aws_subnet.public0.id
  depends_on = [aws_internet_gateway.igw]
  tags = {
    Name = "${var.ProjectName}-NatGW"
  }
}

resource "aws_eip" "eip1" {
  vpc = true
  depends_on = [aws_internet_gateway.igw]
  tags = {
    Name = "${var.ProjectName}-EIP-0"
  }
}

resource "aws_nat_gateway" "natgw1" {
  allocation_id = aws_eip.eip1.id
  subnet_id = aws_subnet.public1.id
  depends_on = [aws_internet_gateway.igw]
  tags = {
    Name = "${var.ProjectName}-NatGW"
  }
}

######
# Public RouteTableの定義
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id
      tags = {
    Name = "${var.ProjectName}-public-RT"
  }
}

resource "aws_route" "public" {
  route_table_id = aws_route_table.public.id
  gateway_id = aws_internet_gateway.igw.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "public0" {
  subnet_id = aws_subnet.public0.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public1" {
  subnet_id = aws_subnet.public1.id
  route_table_id = aws_route_table.public.id
}

######
# Private Routetableの定義
resource "aws_route_table" "private0" {
  vpc_id = aws_vpc.vpc.id
      tags = {
    Name = "${var.ProjectName}-private0-RT"
  }
}

resource "aws_route_table" "private1" {
  vpc_id = aws_vpc.vpc.id
      tags = {
    Name = "${var.ProjectName}-private1-RT"
  }
}

resource "aws_route" "private0" {
  route_table_id = aws_route_table.private0.id
  nat_gateway_id = aws_nat_gateway.natgw0.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route" "private1" {
  route_table_id = aws_route_table.private1.id
  nat_gateway_id = aws_nat_gateway.natgw1.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "private0" {
  subnet_id = aws_subnet.private0.id
  route_table_id = aws_route_table.private0.id
}

resource "aws_route_table_association" "private1" {
  subnet_id = aws_subnet.private1.id
  route_table_id = aws_route_table.private1.id
}
