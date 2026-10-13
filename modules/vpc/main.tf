
# VPC Module
# Creates a secure VPC with public and private subnets
# EKS nodes run in private subnets for security

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Environment = var.environment
    Purpose     = "Secure VPC for EKS cluster"
  }
}

# Public subnets - for load balancers only
resource "aws_subnet" "public" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  map_public_ip_on_launch = false

  tags = {
    Environment                         = var.environment
    "kubernetes.io/role/elb"            = "1"
  }
}

# Private subnets - EKS nodes live here
resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + 10)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Environment                              = var.environment
    "kubernetes.io/role/internal-elb"        = "1"
  }
}

# Internet gateway for public subnets
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Environment = var.environment
  }
}

# Get available AZs automatically
data "aws_availability_zones" "available" {
  state = "available"
}

# Elastic IP for NAT gateway
resource "aws_eip" "nat" {
  domain = "vpc"
  tags = {
    Environment = var.environment
  }
}

# NAT gateway in public subnet so private nodes can reach EKS API
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id
  depends_on    = [aws_internet_gateway.main]
  tags = {
    Environment = var.environment
  }
}

# Route table for private subnets via NAT gateway
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }
  tags = {
    Environment = var.environment
  }
}

# Associate private subnets with private route table
resource "aws_route_table_association" "private" {
  count          = 2
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

# Route table for public subnets via internet gateway
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = {
    Environment = var.environment
  }
}

# Associate public subnets with public route table
resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}
