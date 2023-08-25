# VPC configuration
resource "aws_vpc" "honeypot_vpc" {
  cidr_block = var.vpc_cidr_block
}

# Subnet configuration
resource "aws_subnet" "pub_honeypot_subnet" {
  count = 2
  vpc_id     = aws_vpc.honeypot_vpc.id
  cidr_block = var.pub_subnet_cidr_block[count.index]
  availability_zone = var.AZs[count.index]
  map_public_ip_on_launch = true  # Enabling auto-assign public IP

  
  tags = {
    Name = "Public Subnet"
  }
}

resource "aws_subnet" "priv_honeypot_subnet" {
  count = 2
  vpc_id     = aws_vpc.honeypot_vpc.id
  cidr_block = var.priv_subnet_cidr_block[count.index]
  availability_zone = var.AZs[count.index]
  
  tags = {
    Name = "Private Subnet"
  }
}

resource "aws_internet_gateway" "honeypot_igw" {
  vpc_id = aws_vpc.honeypot_vpc.id
}

resource "aws_route_table" "honeypot_route_table" {
  vpc_id = aws_vpc.honeypot_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.honeypot_igw.id
  }
}

resource "aws_route_table_association" "pub_subnet_association" {
  count = length(aws_subnet.pub_honeypot_subnet)
  subnet_id      = aws_subnet.pub_honeypot_subnet[count.index].id
  route_table_id = aws_route_table.honeypot_route_table.id
}

resource "aws_route_table_association" "priv_subnet_association" {
  count = length(aws_subnet.priv_honeypot_subnet)
  subnet_id      = aws_subnet.priv_honeypot_subnet[count.index].id  # Use private subnets
  route_table_id = aws_route_table.honeypot_route_table.id
}

resource "aws_network_interface" "honeypot_nic"{
  count = length(aws_subnet.pub_honeypot_subnet)
  subnet_id      = aws_subnet.pub_honeypot_subnet[count.index].id
  private_ips = [var.private_ips_nic[count.index]] 
  security_groups = [aws_security_group.honeypot_security_group.id]
}

resource "aws_eip" "ip-one" {
    count = length(aws_network_interface.honeypot_nic)
    network_interface = aws_network_interface.honeypot_nic[count.index].id
  
}
# Security Group configuration
resource "aws_security_group" "honeypot_security_group" {
  name        = "honeypot-security-group"
  description = "Honeypot security group"
  vpc_id      = aws_vpc.honeypot_vpc.id

  ingress {
    from_port   = var.ingress_port
    to_port     = var.ingress_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

