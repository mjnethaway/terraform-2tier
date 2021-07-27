################################################################################
# VPC
################################################################################

resource "aws_vpc" "default" {
  cidr_block = "10.0.0.0/16"
}

################################################################################
# SUBNETS
################################################################################

# These subnets are for machines that need to be publicly accessible.
resource "aws_subnet" "public" {
  for_each                = var.aws_availability_zones
  vpc_id                  = aws_vpc.default.id
  cidr_block              = each.value.public_subnet
  availability_zone       = each.value.az
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet-public-${split("-", each.value.az)[2]}"
  }
}

# These subnets are for machines that should not be publicly accessible.
resource "aws_subnet" "private" {
  for_each                = var.aws_availability_zones
  vpc_id                  = aws_vpc.default.id
  cidr_block              = each.value.private_subnet
  availability_zone       = each.value.az
  map_public_ip_on_launch = false

  tags = {
    Name = "subnet-private-${split("-", each.value.az)[2]}"
  }
}

################################################################################
# GATEWAYS
################################################################################

resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"
}

resource "aws_eip" "eip" {
  for_each = aws_subnet.private
  vpc = true

  tags = {
    Name = "eip-${split("-", each.value.availability_zone)[2]}"
  }
}

resource "aws_nat_gateway" "ngw" {
  for_each = aws_subnet.private
  allocation_id = "${aws_eip.eip[each.key].id}"
  subnet_id     = "${aws_subnet.private[each.key].id}"

  depends_on = [aws_internet_gateway.default]

  tags = {
    Name = "ngw-${split("-", each.value.availability_zone)[2]}"
  }
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
}

# The route table for the private network goes through the internet gateway with NAT
resource "aws_route_table" "private" {
  for_each = aws_subnet.private
  vpc_id = "${aws_vpc.default.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.ngw[each.key].id}"
  }

  tags = {
    Name = "rt-private-${split("-", each.value.availability_zone)[2]}"
  }
}

# Associate the route tables to their respective subnets
resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private
  subnet_id      = "${aws_subnet.private[each.key].id}"
  route_table_id = "${aws_route_table.private[each.key].id}"
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

}