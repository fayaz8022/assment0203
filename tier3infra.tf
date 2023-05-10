provider "aws" {
  region = "us-west-2"
}

# Create VPC
resource "aws_vpc" "example" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "example-vpc"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "example" {
  vpc_id = aws_vpc.example.id

  tags = {
    Name = "example-igw"
  }
}

# Create Public Subnets
resource "aws_subnet" "public1" {
  vpc_id     = aws_vpc.example.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-west-2a"

  tags = {
    Name = "example-public1"
  }
}

resource "aws_subnet" "public2" {
  vpc_id     = aws_vpc.example.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-west-2b"

  tags = {
    Name = "example-public2"
  }
}

# Create Private Subnets
resource "aws_subnet" "private1" {
  vpc_id     = aws_vpc.example.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-west-2a"

  tags = {
    Name = "example-private1"
  }
}

resource "aws_subnet" "private2" {
  vpc_id     = aws_vpc.example.id
  cidr_block = "10.0.4.0/24"
  availability_zone = "us-west-2b"

  tags = {
    Name = "example-private2"
  }
}

# Create Route Tables
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.example.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.example.id
  }

  tags = {
    Name = "example-public-rt"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.example.id

  tags = {
    Name = "example-private-rt"
  }
}

# Associate Subnets with Route Tables
resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public2" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private1" {
  subnet_id      = aws_subnet.private1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private2" {
  subnet_id      = aws_subnet.private2.id
  route_table_id = aws_route_table.private.id
}

# Create NAT Gateways
resource "aws_eip" "nat1" {
  vpc      = true

  tags = {
    Name = "example-nat1-eip"
  }
}

resource "aws_eip" "nat2" {
  vpc      = true

  tags = {
    Name = "example-nat2-eip"
  }
}

resource "aws_nat_gateway" "nat1" {
  allocation_id = aws_eip.nat1.id
subnet_id = aws_subnet.public1.id

tags = {
Name = "example-nat1"
}
}

resource "aws_nat_gateway" "nat2" {
allocation_id = aws_eip.nat2.id
subnet_id = aws_subnet.public2.id

tags = {
Name = "example-nat2"
}
}

Create Security Groups
resource "aws_security_group" "public" {
vpc_id = aws_vpc.example.id

ingress {
from_port = 0
to_port = 65535
protocol = "tcp"
cidr_blocks = ["0.0.0.0/0"]
}

tags = {
Name = "example-public-sg"
}
}

resource "aws_security_group" "private" {
vpc_id = aws_vpc.example.id

tags = {
Name = "example-private-sg"
}
}

Create EC2 Instances
resource "aws_instance" "public" {
ami = "ami-0c94855ba95c71c99"
instance_type = "t2.micro"
vpc_security_group_ids = [aws_security_group.public.id]
subnet_id = aws_subnet.public1.id

tags = {
Name = "example-public-instance"
}
}

resource "aws_instance" "private" {
ami = "ami-0c94855ba95c71c99"
instance_type = "t2.micro"
vpc_security_group_ids = [aws_security_group.private.id]
subnet_id = aws_subnet.private1.id

tags = {
Name = "example-private-instance"
}
}

Output Variables
output "vpc_id" {
value = aws_vpc.example.id
}

output "public_subnet_ids" {
value = [aws_subnet.public1.id, aws_subnet.public2.id]
}

output "private_subnet_ids" {
value = [aws_subnet.private1.id, aws_subnet.private2.id]
}

output "public_instance_id" {
value = aws_instance.public.id
}

output "private_instance_id" {
value = aws_instance.private.id
}
