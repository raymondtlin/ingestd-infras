data "aws_availability_zones" "available" {}

# define vpc
resource "aws_vpc" "ingestd_vpc" {
  cidr_block = "${var.ingestd_cidr}"
  tags = {
    Name = "${var.ingestd_vpc}"
  }
  enable_dns_support = "true"
  enable_dns_hostnames = "true"
}

# public subnet gateway
resource "aws_internet_gateway" "ingestd_ig" {
  vpc_id = "${aws_vpc.ingestd_vpc.id}"
  tags = {
    Name = "ingestd_ig"
  }
}

# public subnet 1
resource = "aws_subnet" "ingestd_public_subnet_01" {
  vpc_id = "${aws_vpc.ingestd_vpc.id}"
  cidr_block = "${var.ingestd_public_01_cidr}"
  availability_zone = "${data.aws_availability_zones.available.names[0]}"
  tags = {
    Name = "ingestd_public_subnet_01"
  }
}

# public subnet 2
resource = "aws_subnet" "ingestd_public_subnet_02" {
  vpc_id = "${aws_vpc.ingestd_vpc.id}"
  cidr_block = "${var.ingestd_public_02_cidr}"
  availability_zone = "${data.aws_availability_zones.available.names[1]}"
  tags = {
    Name = "ingestd_public_subnet_02"
  }
}

# public subnet 1 - routing table
resource "aws_route_table" "ingestd_public_subnet_rt_01" {
  vpc_id = "${aws_vpc.igestd_vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.ingestd_ig.id}"
  }
  tags = {
    Name = "ingestd_public_subnet_rt_01"
  }
}
    
# public subnet 2 - routing table
resource "aws_route_table" "ingestd_public_subnet_rt_02" {
  vpc_id = "${aws_vpc.igestd_vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.ingestd_ig.id}"
  }
  tags = {
    Name = "ingestd_public_subnet_rt_02"
  }
}

# associate subnet 1 to routing table 1
resource "aws_route_table_association" "ingestd_public_subnet_rt_assn_01" {
  subnet_id = "${aws_subnet.ingestd_public_subnet_01.id}"
  route_table_id = "${aws_route_table.ingestd_public_subnet_rt_01.id}"
}

# associate subnet 2 to routing table 2
resource "aws_route_table_association" "ingestd_public_subnet_rt_assn_02" {
  subnet_id = "${aws_subnet.ingestd_public_subnet_02.id}"
  route_table_id = "${aws_route_table.ingestd_public_subnet_rt_02.id}"
}

# ECS Instance Security group
resource "aws_security_group" "ingestd_public_sg" {
  name = "ingestd_public_sg"
  description = "public access security group"
  vpc_id = "${aws_vpc.ingestd_vpc.id}"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "${var.ingestd_public_01_cidr}",
      "${var.ingestd_public_02_cidr}"]
  }

  egress {
    # allow all traffic to private SN
    from_port = "0"
    to_port = "0"
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  tags = {
    Name = "ingestd_public_sg"
  }
}
