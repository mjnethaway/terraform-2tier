################################################################################
# VPC
################################################################################

resource "aws_vpc" "default" {
  cidr_block = "10.0.0.0/16"
  tags = "${var.default_tags}"
}

################################################################################
# AVAILABILITY ZONES
################################################################################

data "aws_availability_zone" "az1" {
  name = "${var.aws_region}a"
}

data "aws_availability_zone" "az2" {
  name = "${var.aws_region}b"
}

################################################################################
# SUBNETS
################################################################################

# These subnets are for machines that need to be publicly accessible.
resource "aws_subnet" "public1" {
  vpc_id                  = "${aws_vpc.default.id}"
  cidr_block              = "10.0.10.0/24"
  map_public_ip_on_launch = true
  tags = "${var.default_tags}"
}

resource "aws_subnet" "public2" {
  vpc_id                  = "${aws_vpc.default.id}"
  cidr_block              = "10.0.11.0/24"
  map_public_ip_on_launch = true
  tags = "${var.default_tags}"
}

# These subnets are for machines that should not be publicly accessible.
resource "aws_subnet" "private1" {
  vpc_id                  = "${aws_vpc.default.id}"
  cidr_block              = "10.0.20.0/24"
  map_public_ip_on_launch = false
  tags = "${var.default_tags}"
}
resource "aws_subnet" "private2" {
  vpc_id                  = "${aws_vpc.default.id}"
  cidr_block              = "10.0.21.0/24"
  map_public_ip_on_launch = false
  tags = "${var.default_tags}"
}

################################################################################
# GATEWAYS
################################################################################

resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"
  tags = "${var.default_tags}"
}

resource "aws_eip" "eip1" {
  vpc = true
}

resource "aws_eip" "eip2" {
  vpc = true
}

resource "aws_nat_gateway" "ngw1" {
  allocation_id = "${aws_eip.eip1.id}"
  subnet_id     = "${aws_subnet.private1.id}"

  depends_on = [aws_internet_gateway.default]
}

resource "aws_nat_gateway" "ngw2" {
  allocation_id = "${aws_eip.eip2.id}"
  subnet_id     = "${aws_subnet.private2.id}"

  depends_on = [aws_internet_gateway.default]
}

################################################################################
# ROUTE TABLES
################################################################################

# The route table for the public network goes through the internet gateway without NAT
resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.default.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.default.id}"
  }
  tags = "${var.default_tags}"
}

# The route table for the private network goes through the internet gateway with NAT
resource "aws_route_table" "private1" {
  vpc_id = "${aws_vpc.default.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.ngw1.id}"
  }
  tags = "${var.default_tags}"
}

resource "aws_route_table" "private2" {
  vpc_id = "${aws_vpc.default.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.ngw2.id}"
  }
  tags = "${var.default_tags}"
}

# Associate the route tables to their respective subnets

resource "aws_route_table_association" "public1" {
  subnet_id      = "${aws_subnet.public1.id}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route_table_association" "public2" {
  subnet_id      = "${aws_subnet.public2.id}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route_table_association" "private1" {
  subnet_id      = "${aws_subnet.private1.id}"
  route_table_id = "${aws_route_table.private1.id}"
}

resource "aws_route_table_association" "private2" {
  subnet_id      = "${aws_subnet.private2.id}"
  route_table_id = "${aws_route_table.private2.id}"
}

################################################################################
# SECURITY GROUPS
################################################################################

# This security group is for the public subnet
resource "aws_security_group" "public" {
  name        = "public"
  description = "This security group restricts access for public"
  vpc_id      = "${aws_vpc.default.id}"

  # enable all access from all subnets within the VPC
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/16"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${var.default_tags}"
}

# This security group is for the private subnet, which is not publically accessible
resource "aws_security_group" "private" {
  name        = "private"
  description = "This security group restricts access for private"
  vpc_id      = "${aws_vpc.default.id}"

  # enable all access from all subnets within the VPC
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/16"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${var.default_tags}"
}