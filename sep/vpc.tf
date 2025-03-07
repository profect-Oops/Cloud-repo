# Provider 설정
provider "aws" {
  region = "ap-northeast-2"
}

# VPC 생성
resource "aws_vpc" "oops_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "oops_vpc"
  }
}

# Internet Gateway 설정
resource "aws_internet_gateway" "oops_igw" {
  vpc_id = aws_vpc.oops_vpc.id

  tags = {
    Name = "oops_igw"
  }
}

# NAT Gateway 설정
resource "aws_eip" "nat_eip" {
  # vpc = true
  domain = "vpc"
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet_a.id

  tags = {
    Name = "oops_nat_gw"
  }
}