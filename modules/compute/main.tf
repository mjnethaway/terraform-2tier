################################################################################
# AMI
################################################################################

# Get AMI ID
data "aws_ami" "amazon" {
  most_recent = true

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
  owners = ["amazon"]
}

################################################################################
# EC2 Instances
################################################################################

resource "aws_instance" "app" {
  count = var.app_count

  subnet_id = var.public_subnets[count.index % length(var.public_subnets)]
  ami = data.aws_ami.amazon.id
  vpc_security_group_ids = [aws_security_group.app.id]

  instance_type = var.app_instance_type
  key_name = var.ssh-key

  tags = {
    Name = "${var.prefix}app${count.index + 1}"
  }
  volume_tags = "${var.default_tags}"

  ebs_block_device {
    device_name = "/dev/sdm"
    volume_type = "standard"
    volume_size = 100
  }
}


resource "aws_instance" "db" {
  count = var.db_count

  subnet_id = var.private_subnets[count.index % length(var.private_subnets)]
  ami = data.aws_ami.amazon.id
  vpc_security_group_ids = [aws_security_group.db.id]

  instance_type = var.db_instance_type
  key_name = var.ssh-key

  tags = {
    Name = "${var.prefix}db${count.index + 1}"
  }
  volume_tags = "${var.default_tags}"

  ebs_block_device {
    device_name = "/dev/sdm"
    volume_type = "standard"
    volume_size = 250
  }
}

resource "aws_instance" "proxy" {
  count = var.proxy_count

  subnet_id = var.public_subnets[count.index % length(var.public_subnets)]
  ami = data.aws_ami.amazon.id
  vpc_security_group_ids = [aws_security_group.proxy.id]

  instance_type = var.proxy_instance_type
  key_name = var.ssh-key

  tags = {
    Name = "${var.prefix}proxy${count.index + 1}"
  }
}

################################################################################
# Security Groups
################################################################################

# This security group is for app servers
resource "aws_security_group" "app" {
  name        = "app"
  description = "This security group restricts access for public"
  vpc_id      = "${var.vpc_id}"

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.ssh_location}"]
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

# This security group is for database servers
resource "aws_security_group" "db" {
  name        = "db"
  description = "This security group restricts access for private"
  vpc_id      = "${var.vpc_id}"

  # SSH access from vpc
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  # MySQL from vpc
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
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

# This security group is for app servers
resource "aws_security_group" "proxy" {
  name        = "proxy"
  description = "This security group restricts access for public"
  vpc_id      = "${var.vpc_id}"

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.ssh_location}"]
  }

  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access from anywhere
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
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