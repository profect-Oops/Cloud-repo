# Public Subnet (ap-northeast-2a)
resource "aws_subnet" "public_subnet_a" {
  vpc_id                  = aws_vpc.oops_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-northeast-2a"

  tags = {
    Name = "public_subnet_a"
  }
}

# Public Subnet (ap-northeast-2c)
resource "aws_subnet" "public_subnet_c" {
  vpc_id                  = aws_vpc.oops_vpc.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-northeast-2c"

  tags = {
    Name = "public_subnet_c"
  }
}

# Private Subnets (ap-northeast-2a)
resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.oops_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "private_subnet_1"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.oops_vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "private_subnet_2"
  }
}

resource "aws_subnet" "private_subnet_3" {
  vpc_id            = aws_vpc.oops_vpc.id
  cidr_block        = "10.0.5.0/24"
  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "private_subnet_3"
  }
}

# Private Subnets (ap-northeast-2c)
resource "aws_subnet" "private_subnet_4" {
  vpc_id            = aws_vpc.oops_vpc.id
  cidr_block        = "10.0.6.0/24"
  availability_zone = "ap-northeast-2c"

  tags = {
    Name = "private_subnet_4"
  }
}

resource "aws_subnet" "private_subnet_5" {
  vpc_id            = aws_vpc.oops_vpc.id
  cidr_block        = "10.0.7.0/24"
  availability_zone = "ap-northeast-2c"

  tags = {
    Name = "private_subnet_5"
  }
}

resource "aws_subnet" "private_subnet_6" {
  vpc_id            = aws_vpc.oops_vpc.id
  cidr_block        = "10.0.8.0/24"
  availability_zone = "ap-northeast-2c"

  tags = {
    Name = "private_subnet_6"
  }
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds_single_subnet_group"
  subnet_ids = [aws_subnet.private_subnet_3.id, aws_subnet.private_subnet_6.id]

  tags = {
    Name = "RDS Single Subnet Group"
  }
}
